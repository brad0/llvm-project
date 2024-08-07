; RUN: opt -mtriple=s390x-unknown-linux -mcpu=z13 -passes=loop-vectorize \
; RUN:   -force-vector-width=2 -debug-only=loop-vectorize \
; RUN:   -disable-output < %s 2>&1 | FileCheck %s
; REQUIRES: asserts
;
; Check that a scalarized load does not get operands scalarization costs added.

define void @fun(ptr %data, i64 %n, i64 %s, ptr %Src) {
entry:
  br label %for.body

for.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %mul = mul nsw i64 %iv, %s
  %gep.src = getelementptr inbounds double, ptr %Src, i64 %mul
  %bct = bitcast ptr %gep.src to ptr
  %ld = load i64, ptr %bct
  %gep.data = getelementptr inbounds i64, ptr %data, i64 %iv
  store i64 %ld, ptr %gep.data
  %iv.next = add nuw nsw i64 %iv, 1
  %cmp110.us = icmp slt i64 %iv.next, %n
  br i1 %cmp110.us, label %for.body, label %for.end

for.end:
  ret void

; CHECK: LV: Found an estimated cost of 2 for VF 2 For instruction:   %mul = mul nsw i64 %iv, %s
; CHECK: LV: Found an estimated cost of 2 for VF 2 For instruction:   %ld = load i64, ptr %bct
}
