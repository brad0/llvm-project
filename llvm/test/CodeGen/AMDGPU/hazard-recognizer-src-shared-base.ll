; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc -mtriple=amdgcn-amdhsa -mcpu=gfx1201 %s -o - | FileCheck %s

define amdgpu_kernel void @foo() {
; CHECK-LABEL: foo:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    s_mov_b64 s[0:1], src_shared_base
; CHECK-NEXT:    s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(VALU_DEP_1)
; CHECK-NEXT:    v_dual_mov_b32 v0, 0 :: v_dual_mov_b32 v1, s1
; CHECK-NEXT:    v_dual_mov_b32 v2, v0 :: v_dual_mov_b32 v3, v0
; CHECK-NEXT:    flat_store_b64 v[0:1], v[2:3]
; CHECK-NEXT:    s_endpgm
entry:
  br label %bb1

bb0:
  br label %bb1

bb1:
  %dst = phi ptr [ null, %bb0 ], [ addrspacecast (ptr addrspace(3) null to ptr), %entry ]
  store i64 0, ptr %dst, align 16
  ret void
}
