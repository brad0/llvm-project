; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -passes=slp-vectorizer < %s -o - -S | FileCheck %s

target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx15.4.0"

define fastcc i32 @rdar128092379(i8 %index) {
; CHECK-LABEL: define fastcc i32 @rdar128092379(
; CHECK-SAME: i8 [[INDEX:%.*]]) {
; CHECK-NEXT:  [[BLOCK:.*]]:
; CHECK-NEXT:    [[ZEXT:%.*]] = zext i8 [[INDEX]] to i64
; CHECK-NEXT:    [[ZEXT1:%.*]] = zext i8 [[INDEX]] to i64
; CHECK-NEXT:    br label %[[BLOCK3:.*]]
; CHECK:       [[BLOCK2:.*]]:
; CHECK-NEXT:    br label %[[BLOCK3]]
; CHECK:       [[BLOCK3]]:
; CHECK-NEXT:    [[PHI:%.*]] = phi i64 [ 0, %[[BLOCK2]] ], [ [[ZEXT1]], %[[BLOCK]] ]
; CHECK-NEXT:    [[PHI4:%.*]] = phi i64 [ 0, %[[BLOCK2]] ], [ [[ZEXT]], %[[BLOCK]] ]
; CHECK-NEXT:    [[EXTRACTELEMENT:%.*]] = extractelement <16 x i32> zeroinitializer, i64 [[PHI4]]
; CHECK-NEXT:    [[EXTRACTELEMENT5:%.*]] = extractelement <16 x i32> zeroinitializer, i64 [[PHI]]
; CHECK-NEXT:    [[SUM:%.*]] = add i32 [[EXTRACTELEMENT]], [[EXTRACTELEMENT5]]
; CHECK-NEXT:    ret i32 [[SUM]]
;
block:
  %zext = zext i8 %index to i64
  %zext1 = zext i8 %index to i64
  br label %block3

block2:
  br label %block3

block3:
  %phi = phi i64 [ 0, %block2 ], [ %zext1, %block ]
  %phi4 = phi i64 [ 0, %block2 ], [ %zext, %block ]
  %extractelement = extractelement <16 x i32> zeroinitializer, i64 %phi4
  %extractelement5 = extractelement <16 x i32> zeroinitializer, i64 %phi
  %sum = add i32 %extractelement, %extractelement5
  ret i32 %sum
}
