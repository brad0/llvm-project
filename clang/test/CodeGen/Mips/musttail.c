// RUN: %clang_cc1 %s -triple mipsel-unknown-linux-gnu -emit-llvm -o /dev/null
// RUN: %clang_cc1 %s -triple mips64el-unknown-linux-gnuabi64 \
// RUN:   -mrelocation-model static -emit-llvm -o /dev/null
// RUN: not %clang_cc1 %s -triple mips64el-unknown-linux-gnuabi64 \
// RUN:   -emit-llvm -o /dev/null 2>&1 | FileCheck %s
// RUN: not %clang_cc1 %s -triple mips64el-unknown-linux-gnuabin32 \
// RUN:   -emit-llvm -o /dev/null 2>&1 | FileCheck %s
// RUN: not %clang_cc1 %s -triple mipsel-unknown-linux-gnu -target-feature +mips16 \
// RUN:   -emit-llvm -o /dev/null 2>&1 | FileCheck %s --check-prefix=CHECK-MIPS16

// O32 and non-PIC code can tail call external functions. N32 and N64 PIC code
// can not, because $gp is callee-saved there.

// CHECK: error: 'musttail' attribute for this call is impossible because calls to preemptible functions cannot be tail called in MIPS N32/N64 PIC code
// CHECK-MIPS16: error: 'musttail' attribute for this call is impossible because the MIPS16 ABI does not support tail calls

static int local(int x) { return x; }

int call_local(int x) {
  [[clang::musttail]] return local(x);
}

extern int external(int x);

int call_external(int x) {
  [[clang::musttail]] return external(x);
}
