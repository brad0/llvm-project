; RUN: not llc -mtriple=sparc <%s 2>&1 | FileCheck %s
; RUN: not llc -mtriple=sparc -mcpu=leon3 <%s 2>&1 | FileCheck %s

;; V8 has only %f0-%f31, so the double and quad registers above them
;; cannot be used.

; CHECK: error: could not allocate input reg for constraint '{f32}'
; CHECK: error: could not allocate input reg for constraint '{d16}'
; CHECK: error: could not allocate input reg for constraint '{f62}'
; CHECK: error: could not allocate input reg for constraint '{f32}'
; CHECK: error: could not allocate input reg for constraint '{f40}'
; CHECK: error: could not allocate input reg for constraint '{q15}'
define void @test_constraint_high_float_reg() {
entry:
  tail call void asm sideeffect "faddd $0,$1,$2", "{f32},{f0},{f0}"(double 9.0, double 10.0, double 11.0)
  tail call void asm sideeffect "faddd $0,$1,$2", "{d16},{f0},{f0}"(double 9.0, double 10.0, double 11.0)
  tail call void asm sideeffect "faddd $0,$1,$2", "{f62},{f0},{f0}"(double 9.0, double 10.0, double 11.0)
  tail call void asm sideeffect "faddq $0,$1,$2", "{f32},{f0},{f0}"(fp128 0xL0, fp128 0xL0, fp128 0xL0)
  tail call void asm sideeffect "faddq $0,$1,$2", "{f40},{f0},{f0}"(fp128 0xL0, fp128 0xL0, fp128 0xL0)
  tail call void asm sideeffect "faddq $0,$1,$2", "{q15},{f0},{f0}"(fp128 0xL0, fp128 0xL0, fp128 0xL0)
  ret void
}
