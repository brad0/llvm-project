// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -std=c++20 -O2 \
// RUN:    -Wno-coroutine-missing-unhandled-exception -emit-llvm %s -o - -disable-llvm-passes \
// RUN:   | FileCheck %s

namespace std {
template <typename... T>
struct coroutine_traits; // expected-note {{declared here}}

template <class Promise = void>
struct coroutine_handle {
  coroutine_handle() = default;
  static coroutine_handle from_address(void *) noexcept { return {}; }
};

template <>
struct coroutine_handle<void> {
  static coroutine_handle from_address(void *) { return {}; }
  coroutine_handle() = default;
  template <class PromiseType>
  coroutine_handle(coroutine_handle<PromiseType>) noexcept {}
};

struct nothrow_t {};
constexpr nothrow_t nothrow = {};

} // end namespace std

// Required when get_return_object_on_allocation_failure() is defined by
// the promise.
using SizeT = decltype(sizeof(int));
void* operator new(SizeT __sz, const std::nothrow_t&) noexcept;
void  operator delete(void* __p, const std::nothrow_t&) noexcept;


struct suspend_always {
  bool await_ready() noexcept { return false; }
  void await_suspend(std::coroutine_handle<>) noexcept {}
  void await_resume() noexcept {}
};

struct global_new_delete_tag {};

template <>
struct std::coroutine_traits<void, global_new_delete_tag> {
  struct promise_type {
    void get_return_object() {}
    suspend_always initial_suspend() { return {}; }
    suspend_always final_suspend() noexcept { return {}; }
    void return_void() {}
  };
};

// CHECK-LABEL: f0(
extern "C" void f0(global_new_delete_tag) {
  // CHECK: %[[ID:.+]] = call token @llvm.coro.id(i32 16
  // CHECK: %[[NeedAlloc:.+]] = call i1 @llvm.coro.alloc(token %[[ID]])
  // CHECK: br i1 %[[NeedAlloc]], label %[[AllocBB:.+]], label %[[InitBB:.+]]

  // CHECK: [[AllocBB]]:
  // CHECK: %[[SIZE:.+]] = call i64 @llvm.coro.size.i64()
  // CHECK: %[[MEM:.+]] = call noalias noundef nonnull ptr @_Znwm(i64 noundef %[[SIZE]])
  // CHECK: br label %[[InitBB]]

  // CHECK: [[InitBB]]:
  // CHECK: %[[PHI:.+]] = phi ptr [ null, %{{.+}} ], [ %call, %[[AllocBB]] ]
  // CHECK: %[[FRAME:.+]] = call ptr @llvm.coro.begin(token %[[ID]], ptr %[[PHI]])

  // CHECK: %[[MEM:.+]] = call ptr @llvm.coro.free(token %[[ID]], ptr %[[FRAME]])
  // CHECK: %[[NeedDealloc:.+]] = icmp ne ptr %[[MEM]], null
  // CHECK: br i1 %[[NeedDealloc]], label %[[FreeBB:.+]], label %[[Afterwards:.+]]

  // CHECK: [[FreeBB]]:
  // CHECK: %[[SIZE:.+]] = call i64 @llvm.coro.size.i64()
  // CHECK: call void @_ZdlPvm(ptr noundef %[[MEM]], i64 noundef %[[SIZE]])
  // CHECK: br label %[[Afterwards]]

  // CHECK: [[Afterwards]]:
  // CHECK: ret void
  co_return;
}

struct promise_new_tag {};

template <>
struct std::coroutine_traits<void, promise_new_tag> {
  struct promise_type {
    void *operator new(unsigned long);
    void get_return_object() {}
    suspend_always initial_suspend() { return {}; }
    suspend_always final_suspend() noexcept { return {}; }
    void return_void() {}
  };
};

// CHECK-LABEL: f1(
extern "C" void f1(promise_new_tag ) {
  // CHECK: %[[ID:.+]] = call token @llvm.coro.id(i32 16
  // CHECK: %[[SIZE:.+]] = call i64 @llvm.coro.size.i64()
  // CHECK: call noundef ptr @_ZNSt16coroutine_traitsIJv15promise_new_tagEE12promise_typenwEm(i64 noundef %[[SIZE]])

  // CHECK: %[[FRAME:.+]] = call ptr @llvm.coro.begin(
  // CHECK: %[[MEM:.+]] = call ptr @llvm.coro.free(token %[[ID]], ptr %[[FRAME]])
  // CHECK: %[[SIZE:.+]] = call i64 @llvm.coro.size.i64()
  // CHECK: call void @_ZdlPvm(ptr noundef %[[MEM]], i64 noundef %[[SIZE]])
  co_return;
}

struct promise_matching_placement_new_tag {};

template <>
struct std::coroutine_traits<void, promise_matching_placement_new_tag, int, float, double> {
  struct promise_type {
    void *operator new(unsigned long, promise_matching_placement_new_tag,
                       int, float, double);
    void get_return_object() {}
    suspend_always initial_suspend() { return {}; }
    suspend_always final_suspend() noexcept { return {}; }
    void return_void() {}
  };
};

// CHECK-LABEL: f1a(
extern "C" void f1a(promise_matching_placement_new_tag, int x, float y , double z) {
  // CHECK: store i32 %x, ptr %x.addr, align 4
  // CHECK: store float %y, ptr %y.addr, align 4
  // CHECK: store double %z, ptr %z.addr, align 8
  // CHECK: %[[ID:.+]] = call token @llvm.coro.id(i32 16
  // CHECK: %[[SIZE:.+]] = call i64 @llvm.coro.size.i64()
  // CHECK: %[[INT:.+]] = load i32, ptr %x.addr, align 4
  // CHECK: %[[FLOAT:.+]] = load float, ptr %y.addr, align 4
  // CHECK: %[[DOUBLE:.+]] = load double, ptr %z.addr, align 8
  // CHECK: call noundef ptr @_ZNSt16coroutine_traitsIJv34promise_matching_placement_new_tagifdEE12promise_typenwEmS0_ifd(i64 noundef %[[SIZE]], i32 noundef %[[INT]], float noundef %[[FLOAT]], double noundef %[[DOUBLE]])
  co_return;
}

// Declare a placement form operator new, such as the one described in
// C++ 18.6.1.3.1, which takes a ptr argument.
void* operator new(SizeT __sz, void *__p) noexcept;

struct promise_matching_global_placement_new_tag {};
struct dummy {};
template <>
struct std::coroutine_traits<void, promise_matching_global_placement_new_tag, dummy *> {
  struct promise_type {
    void get_return_object() {}
    suspend_always initial_suspend() { return {}; }
    suspend_always final_suspend() noexcept { return {}; }
    void return_void() {}
  };
};

// A coroutine that takes a single pointer argument should not invoke this
// placement form operator. [dcl.fct.def.coroutine]/7 dictates that lookup for
// allocation functions matching the coroutine function's signature be done
// within the scope of the promise type's class.
// CHECK-LABEL: f1b(
extern "C" void f1b(promise_matching_global_placement_new_tag, dummy *) {
  // CHECK: call noalias noundef nonnull ptr @_Znwm(i64
  co_return;
}

struct promise_delete_tag {};

template <>
struct std::coroutine_traits<void, promise_delete_tag> {
  struct promise_type {
    void operator delete(void*);
    void get_return_object() {}
    suspend_always initial_suspend() { return {}; }
    suspend_always final_suspend() noexcept { return {}; }
    void return_void() {}
  };
};

// CHECK-LABEL: f2(
extern "C" void f2(promise_delete_tag) {
  // CHECK: %[[ID:.+]] = call token @llvm.coro.id(i32 16
  // CHECK: %[[SIZE:.+]] = call i64 @llvm.coro.size.i64()
  // CHECK: call noalias noundef nonnull ptr @_Znwm(i64 noundef %[[SIZE]])

  // CHECK: %[[FRAME:.+]] = call ptr @llvm.coro.begin(
  // CHECK: %[[MEM:.+]] = call ptr @llvm.coro.free(token %[[ID]], ptr %[[FRAME]])
  // CHECK: call void @_ZNSt16coroutine_traitsIJv18promise_delete_tagEE12promise_typedlEPv(ptr noundef %[[MEM]])
  co_return;
}

struct promise_sized_delete_tag {};

template <>
struct std::coroutine_traits<void, promise_sized_delete_tag> {
  struct promise_type {
    void operator delete(void*, unsigned long);
    void get_return_object() {}
    suspend_always initial_suspend() { return {}; }
    suspend_always final_suspend() noexcept { return {}; }
    void return_void() {}
  };
};

// CHECK-LABEL: f3(
extern "C" void f3(promise_sized_delete_tag) {
  // CHECK: %[[ID:.+]] = call token @llvm.coro.id(i32 16
  // CHECK: %[[SIZE:.+]] = call i64 @llvm.coro.size.i64()
  // CHECK: call noalias noundef nonnull ptr @_Znwm(i64 noundef %[[SIZE]])

  // CHECK: %[[FRAME:.+]] = call ptr @llvm.coro.begin(
  // CHECK: %[[MEM:.+]] = call ptr @llvm.coro.free(token %[[ID]], ptr %[[FRAME]])
  // CHECK: %[[SIZE2:.+]] = call i64 @llvm.coro.size.i64()
  // CHECK: call void @_ZNSt16coroutine_traitsIJv24promise_sized_delete_tagEE12promise_typedlEPvm(ptr noundef %[[MEM]], i64 noundef %[[SIZE2]])
  co_return;
}

struct promise_on_alloc_failure_tag {};

template <>
struct std::coroutine_traits<int, promise_on_alloc_failure_tag> {
  struct promise_type {
    int get_return_object() { return 0; }
    suspend_always initial_suspend() { return {}; }
    suspend_always final_suspend() noexcept { return {}; }
    void return_void() {}
    static int get_return_object_on_allocation_failure() { return -1; }
  };
};

// CHECK-LABEL: f4(
extern "C" int f4(promise_on_alloc_failure_tag) {
  // CHECK: %[[RetVal:.+]] = alloca i32
  // CHECK: %[[ID:.+]] = call token @llvm.coro.id(i32 16
  // CHECK: %[[SIZE:.+]] = call i64 @llvm.coro.size.i64()
  // CHECK: %[[MEM:.+]] = call noalias noundef ptr @_ZnwmRKSt9nothrow_t(i64 noundef %[[SIZE]], ptr noundef nonnull align 1 dereferenceable(1) @_ZStL7nothrow)
  // CHECK: %[[OK:.+]] = icmp ne ptr %[[MEM]], null
  // CHECK: call i1 @llvm.expect.i1(i1 %[[OK]], i1 true)
  // CHECK: br i1 %[[OK]], label %[[OKBB:.+]], label %[[ERRBB:.+]]

  // CHECK: [[ERRBB]]:
  // CHECK:   %[[FailRet:.+]] = call noundef i32 @_ZNSt16coroutine_traitsIJi28promise_on_alloc_failure_tagEE12promise_type39get_return_object_on_allocation_failureEv(
  // CHECK:   store i32 %[[FailRet]], ptr %[[RetVal]]
  // CHECK:   br label %[[RetBB:.+]]

  // CHECK: [[OKBB]]:
  // CHECK:   %[[OkRet:.+]] = call noundef i32 @_ZNSt16coroutine_traitsIJi28promise_on_alloc_failure_tagEE12promise_type17get_return_objectEv(

  // CHECK: [[RetBB]]:
  // CHECK:   %[[LoadRet:.+]] = load i32, ptr %[[RetVal]], align 4
  // CHECK:   ret i32 %[[LoadRet]]
  co_return;
}

struct promise_sized_delete_tag2 {};

template <>
struct std::coroutine_traits<void, promise_sized_delete_tag2> {
  struct promise_type {
    // Tests that the compiler can choose the correct operator delete
    // when we have multiple operator delete
    void operator delete(void*, unsigned long);
    void operator delete(void*);
    void get_return_object() {}
    suspend_always initial_suspend() { return {}; }
    suspend_always final_suspend() noexcept { return {}; }
    void return_void() {}
  };
};

// CHECK-LABEL: f5(
extern "C" void f5(promise_sized_delete_tag2) {
  // CHECK: %[[ID:.+]] = call token @llvm.coro.id(i32 16
  // CHECK: %[[SIZE:.+]] = call i64 @llvm.coro.size.i64()
  // CHECK: call noalias noundef nonnull ptr @_Znwm(i64 noundef %[[SIZE]])

  // CHECK: %[[FRAME:.+]] = call ptr @llvm.coro.begin(
  // CHECK: %[[MEM:.+]] = call ptr @llvm.coro.free(token %[[ID]], ptr %[[FRAME]])
  // CHECK: %[[SIZE2:.+]] = call i64 @llvm.coro.size.i64()
  // CHECK: call void @_ZNSt16coroutine_traitsIJv25promise_sized_delete_tag2EE12promise_typedlEPvm(ptr noundef %[[MEM]], i64 noundef %[[SIZE2]])
  co_return;
}
