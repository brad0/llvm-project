; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt -passes="print<cost-model>" 2>&1 -disable-output < %s | FileCheck %s

target triple = "nvptx64-nvidia-cuda"

define void @test1() {
; CHECK-LABEL: 'test1'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = call double asm "rsqrt.approx.ftz.f64 $0, $1;", "=d,d"(double 1.000000e+00)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %2 = call { i32, i32 } asm "{\0A\09mad.lo.cc.u32 $0, $2, $3, $4;\0A\09madc.hi.u32 $1, $2, $3, 0;\0A\09}", "=r,=r,r,r,r"(i32 2, i32 3, i32 3)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %3 = call i32 asm sideeffect "{ \0A\09.reg .pred \09%p1; \0A\09setp.ne.u32 \09%p1, $1, 0; \0A\09vote.ballot.b32 \09$0, %p1; \0A\09}", "=r,r"(i32 0)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %4 = call i32 asm sideeffect "{ \0A\09.reg .pred \09%p1; \0A\09setp.ne.u32 \09%p1, $1, 0; \0A\09@%p1 exit; \0A\09}", "=r,r"(i32 0)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: call void asm sideeffect ".pragma \22nounroll\22;\0A\09", "~{memory}"()
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret void
;
  %1 = call double asm "rsqrt.approx.ftz.f64 $0, $1;", "=d,d"(double 1.0)
  %2 = call { i32, i32 } asm "{\0A\09mad.lo.cc.u32   $0, $2, $3, $4;\0A\09madc.hi.u32     $1, $2, $3,  0;\0A\09}", "=r,=r,r,r,r"(i32 2, i32 3, i32 3)
  %3 = call i32 asm sideeffect "{ \0A\09.reg .pred \09%p1; \0A\09setp.ne.u32 \09%p1, $1, 0; \0A\09vote.ballot.b32 \09$0, %p1; \0A\09}", "=r,r"(i32 0)
  %4 = call i32 asm sideeffect "{ \0A\09.reg .pred \09%p1; \0A\09setp.ne.u32 \09%p1, $1, 0; \0A\09@%p1 exit; \0A\09}", "=r,r"(i32 0)
  call void asm sideeffect ".pragma \22nounroll\22;\0A\09", "~{memory}"()
  ret void
}
