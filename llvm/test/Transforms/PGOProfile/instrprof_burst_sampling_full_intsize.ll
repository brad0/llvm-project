; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt < %s --passes=instrprof --sampled-instrumentation --sampled-instr-period=1000019 --sampled-instr-burst-duration=3000 -S | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

$__llvm_profile_raw_version = comdat any

@__llvm_profile_raw_version = constant i64 72057594037927940, comdat
@__profn_f = private constant [1 x i8] c"f"

define void @f() {
; CHECK-LABEL: define void @f() {
; CHECK-NEXT:  [[ENTRY:.*:]]
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, ptr @__llvm_profile_sampling, align 4
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ule i32 [[TMP0]], 2999
; CHECK-NEXT:    br i1 [[TMP1]], label %[[BB2:.*]], label %[[BB4:.*]], !prof [[PROF0:![0-9]+]]
; CHECK:       [[BB2]]:
; CHECK-NEXT:    [[PGOCOUNT:%.*]] = load i64, ptr @__profc_f, align 8
; CHECK-NEXT:    [[TMP3:%.*]] = add i64 [[PGOCOUNT]], 1
; CHECK-NEXT:    store i64 [[TMP3]], ptr @__profc_f, align 8
; CHECK-NEXT:    br label %[[BB4]]
; CHECK:       [[BB4]]:
; CHECK-NEXT:    [[TMP5:%.*]] = add i32 [[TMP0]], 1
; CHECK-NEXT:    [[TMP6:%.*]] = icmp uge i32 [[TMP5]], 1000019
; CHECK-NEXT:    br i1 [[TMP6]], label %[[BB7:.*]], label %[[BB8:.*]], !prof [[PROF1:![0-9]+]]
; CHECK:       [[BB7]]:
; CHECK-NEXT:    store i32 0, ptr @__llvm_profile_sampling, align 4
; CHECK-NEXT:    br label %[[BB9:.*]]
; CHECK:       [[BB8]]:
; CHECK-NEXT:    store i32 [[TMP5]], ptr @__llvm_profile_sampling, align 4
; CHECK-NEXT:    br label %[[BB9]]
; CHECK:       [[BB9]]:
; CHECK-NEXT:    ret void
;
entry:
  call void @llvm.instrprof.increment(i8* getelementptr inbounds ([1 x i8], [1 x i8]* @__profn_f, i32 0, i32 0), i64 12884901887, i32 1, i32 0)
  ret void
}

declare void @llvm.instrprof.increment(i8*, i64, i32, i32)
;.
; CHECK: [[PROF0]] = !{!"branch_weights", i32 3000, i32 997019}
; CHECK: [[PROF1]] = !{!"branch_weights", i32 1, i32 1000018}
;.
