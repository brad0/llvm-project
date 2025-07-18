; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=slp-vectorizer -S | FileCheck %s

target triple = "aarch64--linux-gnu"

; This checks that we we prefer splats rather than load vectors + shuffles.
; A load + broadcast can be done efficiently with a single `ld1r` instruction.
define void @splat_loads_double(ptr %array1, ptr %array2, ptr %ptrA, ptr %ptrB) {
; CHECK-LABEL: @splat_loads_double(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[GEP_2_1:%.*]] = getelementptr inbounds double, ptr [[ARRAY2:%.*]], i64 1
; CHECK-NEXT:    [[LD_2_0:%.*]] = load double, ptr [[ARRAY2]], align 8
; CHECK-NEXT:    [[LD_2_1:%.*]] = load double, ptr [[GEP_2_1]], align 8
; CHECK-NEXT:    [[TMP0:%.*]] = load <2 x double>, ptr [[ARRAY1:%.*]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x double> poison, double [[LD_2_0]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <2 x double> [[TMP1]], <2 x double> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP3:%.*]] = fmul <2 x double> [[TMP0]], [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x double> poison, double [[LD_2_1]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <2 x double> [[TMP4]], <2 x double> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP6:%.*]] = fmul <2 x double> [[TMP0]], [[TMP5]]
; CHECK-NEXT:    [[TMP7:%.*]] = fadd <2 x double> [[TMP3]], [[TMP6]]
; CHECK-NEXT:    store <2 x double> [[TMP7]], ptr [[ARRAY1]], align 8
; CHECK-NEXT:    ret void
;
entry:
  %gep_1_1 = getelementptr inbounds double, ptr %array1, i64 1
  %ld_1_0 = load double, ptr %array1, align 8
  %ld_1_1 = load double, ptr %gep_1_1, align 8

  %gep_2_1 = getelementptr inbounds double, ptr %array2, i64 1
  %ld_2_0 = load double, ptr %array2, align 8
  %ld_2_1 = load double, ptr %gep_2_1, align 8

  %mul0 = fmul double %ld_1_0, %ld_2_0
  %mul1 = fmul double %ld_1_1, %ld_2_0

  %mul2 = fmul double %ld_1_0, %ld_2_1
  %mul3 = fmul double %ld_1_1, %ld_2_1

  %add0 = fadd double %mul0, %mul2
  %add1 = fadd double %mul1, %mul3

  store double %add0, ptr %array1
  store double %add1, ptr %gep_1_1
  ret void
}

; Same but with float instead of double
define void @splat_loads_float(ptr %array1, ptr %array2, ptr %ptrA, ptr %ptrB) {
; CHECK-LABEL: @splat_loads_float(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[GEP_2_1:%.*]] = getelementptr inbounds float, ptr [[ARRAY2:%.*]], i64 1
; CHECK-NEXT:    [[LD_2_0:%.*]] = load float, ptr [[ARRAY2]], align 8
; CHECK-NEXT:    [[LD_2_1:%.*]] = load float, ptr [[GEP_2_1]], align 8
; CHECK-NEXT:    [[TMP0:%.*]] = load <2 x float>, ptr [[ARRAY1:%.*]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x float> poison, float [[LD_2_0]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <2 x float> [[TMP1]], <2 x float> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP3:%.*]] = fmul <2 x float> [[TMP0]], [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x float> poison, float [[LD_2_1]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <2 x float> [[TMP4]], <2 x float> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP6:%.*]] = fmul <2 x float> [[TMP0]], [[TMP5]]
; CHECK-NEXT:    [[TMP7:%.*]] = fadd <2 x float> [[TMP3]], [[TMP6]]
; CHECK-NEXT:    store <2 x float> [[TMP7]], ptr [[ARRAY1]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %gep_1_1 = getelementptr inbounds float, ptr %array1, i64 1
  %ld_1_0 = load float, ptr %array1, align 8
  %ld_1_1 = load float, ptr %gep_1_1, align 8

  %gep_2_1 = getelementptr inbounds float, ptr %array2, i64 1
  %ld_2_0 = load float, ptr %array2, align 8
  %ld_2_1 = load float, ptr %gep_2_1, align 8

  %mul0 = fmul float %ld_1_0, %ld_2_0
  %mul1 = fmul float %ld_1_1, %ld_2_0

  %mul2 = fmul float %ld_1_0, %ld_2_1
  %mul3 = fmul float %ld_1_1, %ld_2_1

  %add0 = fadd float %mul0, %mul2
  %add1 = fadd float %mul1, %mul3

  store float %add0, ptr %array1
  store float %add1, ptr %gep_1_1
  ret void
}

; Same but with i64
define void @splat_loads_i64(ptr %array1, ptr %array2, ptr %ptrA, ptr %ptrB) {
; CHECK-LABEL: @splat_loads_i64(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[GEP_2_2:%.*]] = getelementptr inbounds i64, ptr [[ARRAY3:%.*]], i64 1
; CHECK-NEXT:    [[LD_2_2:%.*]] = load i64, ptr [[ARRAY3]], align 8
; CHECK-NEXT:    [[LD_2_3:%.*]] = load i64, ptr [[GEP_2_2]], align 8
; CHECK-NEXT:    [[TMP0:%.*]] = load <2 x i64>, ptr [[ARRAY1:%.*]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x i64> poison, i64 [[LD_2_2]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <2 x i64> [[TMP1]], <2 x i64> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP3:%.*]] = or <2 x i64> [[TMP0]], [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i64> poison, i64 [[LD_2_3]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <2 x i64> [[TMP4]], <2 x i64> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP6:%.*]] = or <2 x i64> [[TMP0]], [[TMP5]]
; CHECK-NEXT:    [[TMP7:%.*]] = add <2 x i64> [[TMP3]], [[TMP6]]
; CHECK-NEXT:    store <2 x i64> [[TMP7]], ptr [[ARRAY1]], align 8
; CHECK-NEXT:    ret void
;
entry:
  %gep_1_1 = getelementptr inbounds i64, ptr %array1, i64 1
  %ld_1_0 = load i64, ptr %array1, align 8
  %ld_1_1 = load i64, ptr %gep_1_1, align 8

  %gep_2_1 = getelementptr inbounds i64, ptr %array2, i64 1
  %ld_2_0 = load i64, ptr %array2, align 8
  %ld_2_1 = load i64, ptr %gep_2_1, align 8

  %or0 = or i64 %ld_1_0, %ld_2_0
  %or1 = or i64 %ld_1_1, %ld_2_0

  %or2 = or i64 %ld_1_0, %ld_2_1
  %or3 = or i64 %ld_1_1, %ld_2_1

  %add0 = add i64 %or0, %or2
  %add1 = add i64 %or1, %or3

  store i64 %add0, ptr %array1
  store i64 %add1, ptr %gep_1_1
  ret void
}

; Same but with i32
define void @splat_loads_i32(ptr %array1, ptr %array2, ptr %ptrA, ptr %ptrB) {
; CHECK-LABEL: @splat_loads_i32(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[GEP_2_2:%.*]] = getelementptr inbounds i32, ptr [[ARRAY3:%.*]], i64 1
; CHECK-NEXT:    [[LD_2_2:%.*]] = load i32, ptr [[ARRAY3]], align 8
; CHECK-NEXT:    [[LD_2_3:%.*]] = load i32, ptr [[GEP_2_2]], align 8
; CHECK-NEXT:    [[TMP0:%.*]] = load <2 x i32>, ptr [[ARRAY1:%.*]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x i32> poison, i32 [[LD_2_2]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <2 x i32> [[TMP1]], <2 x i32> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP3:%.*]] = or <2 x i32> [[TMP0]], [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i32> poison, i32 [[LD_2_3]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <2 x i32> [[TMP4]], <2 x i32> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP6:%.*]] = or <2 x i32> [[TMP0]], [[TMP5]]
; CHECK-NEXT:    [[TMP7:%.*]] = add <2 x i32> [[TMP3]], [[TMP6]]
; CHECK-NEXT:    store <2 x i32> [[TMP7]], ptr [[ARRAY1]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %gep_1_1 = getelementptr inbounds i32, ptr %array1, i64 1
  %ld_1_0 = load i32, ptr %array1, align 8
  %ld_1_1 = load i32, ptr %gep_1_1, align 8

  %gep_2_1 = getelementptr inbounds i32, ptr %array2, i64 1
  %ld_2_0 = load i32, ptr %array2, align 8
  %ld_2_1 = load i32, ptr %gep_2_1, align 8

  %or0 = or i32 %ld_1_0, %ld_2_0
  %or1 = or i32 %ld_1_1, %ld_2_0

  %or2 = or i32 %ld_1_0, %ld_2_1
  %or3 = or i32 %ld_1_1, %ld_2_1

  %add0 = add i32 %or0, %or2
  %add1 = add i32 %or1, %or3

  store i32 %add0, ptr %array1
  store i32 %add1, ptr %gep_1_1
  ret void
}
