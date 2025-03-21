; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=memcpyopt < %s | FileCheck %s

declare void @func(ptr %dst)

; The noalias metadata from the call, the load and the store should be merged,
; so that no metadata is left on the call.
define i8 @test(ptr writable dereferenceable(1) noalias %dst) {
; CHECK-LABEL: @test(
; CHECK-NEXT:    [[TMP:%.*]] = alloca i8, align 1
; CHECK-NEXT:    call void @func(ptr captures(none) [[DST:%.*]]) #[[ATTR0:[0-9]+]]
; CHECK-NEXT:    [[V2:%.*]] = load i8, ptr [[DST]], align 1, !alias.scope [[META0:![0-9]+]]
; CHECK-NEXT:    ret i8 [[V2]]
;
  %tmp = alloca i8
  call void @func(ptr nocapture %tmp) nounwind, !noalias !0
  %v = load i8, ptr %tmp, !noalias !0
  store i8 %v, ptr %dst, !alias.scope !0
  %v2 = load i8, ptr %dst, !alias.scope !0
  ret i8 %v2
}

!0 = !{!1}
!1 = !{!1, !2}
!2 = !{!2}

