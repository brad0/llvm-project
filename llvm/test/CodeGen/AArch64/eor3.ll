; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --extra_scrub
; RUN: llc -mtriple=aarch64 -mattr=+sha3 < %s | FileCheck --check-prefix=SHA3 %s
; RUN: llc -mtriple=aarch64 -mattr=-sha3 < %s | FileCheck --check-prefix=NOSHA3 %s
; RUN: llc -mtriple=aarch64 -mattr=+sve2 < %s | FileCheck --check-prefix=SVE2 %s
; RUN: llc -mtriple=aarch64 -mattr=+sha3,+sve2 < %s | FileCheck --check-prefix=SHA3-SVE2 %s

define <16 x i8> @eor3_16x8_left(<16 x i8> %0, <16 x i8> %1, <16 x i8> %2) {
; SHA3-LABEL: eor3_16x8_left:
; SHA3:       // %bb.0:
; SHA3-NEXT:    eor3 v0.16b, v0.16b, v1.16b, v2.16b
; SHA3-NEXT:    ret
;
; NOSHA3-LABEL: eor3_16x8_left:
; NOSHA3:       // %bb.0:
; NOSHA3-NEXT:    eor v0.16b, v0.16b, v1.16b
; NOSHA3-NEXT:    eor v0.16b, v2.16b, v0.16b
; NOSHA3-NEXT:    ret
;
; SVE2-LABEL: eor3_16x8_left:
; SVE2:       // %bb.0:
; SVE2-NEXT:    // kill: def $q2 killed $q2 def $z2
; SVE2-NEXT:    // kill: def $q1 killed $q1 def $z1
; SVE2-NEXT:    // kill: def $q0 killed $q0 def $z0
; SVE2-NEXT:    eor3 z2.d, z2.d, z0.d, z1.d
; SVE2-NEXT:    mov v0.16b, v2.16b
; SVE2-NEXT:    ret
;
; SHA3-SVE2-LABEL: eor3_16x8_left:
; SHA3-SVE2:       // %bb.0:
; SHA3-SVE2-NEXT:    eor3 v0.16b, v0.16b, v1.16b, v2.16b
; SHA3-SVE2-NEXT:    ret
  %4 = xor <16 x i8> %0, %1
  %5 = xor <16 x i8> %2, %4
  ret <16 x i8> %5
}

define <16 x i8> @eor3_16x8_right(<16 x i8> %0, <16 x i8> %1, <16 x i8> %2) {
; SHA3-LABEL: eor3_16x8_right:
; SHA3:       // %bb.0:
; SHA3-NEXT:    eor3 v0.16b, v1.16b, v2.16b, v0.16b
; SHA3-NEXT:    ret
;
; NOSHA3-LABEL: eor3_16x8_right:
; NOSHA3:       // %bb.0:
; NOSHA3-NEXT:    eor v1.16b, v1.16b, v2.16b
; NOSHA3-NEXT:    eor v0.16b, v1.16b, v0.16b
; NOSHA3-NEXT:    ret
;
; SVE2-LABEL: eor3_16x8_right:
; SVE2:       // %bb.0:
; SVE2-NEXT:    // kill: def $q1 killed $q1 def $z1
; SVE2-NEXT:    // kill: def $q2 killed $q2 def $z2
; SVE2-NEXT:    // kill: def $q0 killed $q0 def $z0
; SVE2-NEXT:    eor3 z1.d, z1.d, z2.d, z0.d
; SVE2-NEXT:    mov v0.16b, v1.16b
; SVE2-NEXT:    ret
;
; SHA3-SVE2-LABEL: eor3_16x8_right:
; SHA3-SVE2:       // %bb.0:
; SHA3-SVE2-NEXT:    eor3 v0.16b, v1.16b, v2.16b, v0.16b
; SHA3-SVE2-NEXT:    ret
  %4 = xor <16 x i8> %1, %2
  %5 = xor <16 x i8> %4, %0
  ret <16 x i8> %5
}

define <8 x i16> @eor3_8x16_left(<8 x i16> %0, <8 x i16> %1, <8 x i16> %2) {
; SHA3-LABEL: eor3_8x16_left:
; SHA3:       // %bb.0:
; SHA3-NEXT:    eor3 v0.16b, v0.16b, v1.16b, v2.16b
; SHA3-NEXT:    ret
;
; NOSHA3-LABEL: eor3_8x16_left:
; NOSHA3:       // %bb.0:
; NOSHA3-NEXT:    eor v0.16b, v0.16b, v1.16b
; NOSHA3-NEXT:    eor v0.16b, v2.16b, v0.16b
; NOSHA3-NEXT:    ret
;
; SVE2-LABEL: eor3_8x16_left:
; SVE2:       // %bb.0:
; SVE2-NEXT:    // kill: def $q2 killed $q2 def $z2
; SVE2-NEXT:    // kill: def $q1 killed $q1 def $z1
; SVE2-NEXT:    // kill: def $q0 killed $q0 def $z0
; SVE2-NEXT:    eor3 z2.d, z2.d, z0.d, z1.d
; SVE2-NEXT:    mov v0.16b, v2.16b
; SVE2-NEXT:    ret
;
; SHA3-SVE2-LABEL: eor3_8x16_left:
; SHA3-SVE2:       // %bb.0:
; SHA3-SVE2-NEXT:    eor3 v0.16b, v0.16b, v1.16b, v2.16b
; SHA3-SVE2-NEXT:    ret
  %4 = xor <8 x i16> %0, %1
  %5 = xor <8 x i16> %2, %4
  ret <8 x i16> %5
}

define <8 x i16> @eor3_8x16_right(<8 x i16> %0, <8 x i16> %1, <8 x i16> %2) {
; SHA3-LABEL: eor3_8x16_right:
; SHA3:       // %bb.0:
; SHA3-NEXT:    eor3 v0.16b, v1.16b, v2.16b, v0.16b
; SHA3-NEXT:    ret
;
; NOSHA3-LABEL: eor3_8x16_right:
; NOSHA3:       // %bb.0:
; NOSHA3-NEXT:    eor v1.16b, v1.16b, v2.16b
; NOSHA3-NEXT:    eor v0.16b, v1.16b, v0.16b
; NOSHA3-NEXT:    ret
;
; SVE2-LABEL: eor3_8x16_right:
; SVE2:       // %bb.0:
; SVE2-NEXT:    // kill: def $q1 killed $q1 def $z1
; SVE2-NEXT:    // kill: def $q2 killed $q2 def $z2
; SVE2-NEXT:    // kill: def $q0 killed $q0 def $z0
; SVE2-NEXT:    eor3 z1.d, z1.d, z2.d, z0.d
; SVE2-NEXT:    mov v0.16b, v1.16b
; SVE2-NEXT:    ret
;
; SHA3-SVE2-LABEL: eor3_8x16_right:
; SHA3-SVE2:       // %bb.0:
; SHA3-SVE2-NEXT:    eor3 v0.16b, v1.16b, v2.16b, v0.16b
; SHA3-SVE2-NEXT:    ret
  %4 = xor <8 x i16> %1, %2
  %5 = xor <8 x i16> %4, %0
  ret <8 x i16> %5
}

define <4 x i32> @eor3_4x32_left(<4 x i32> %0, <4 x i32> %1, <4 x i32> %2) {
; SHA3-LABEL: eor3_4x32_left:
; SHA3:       // %bb.0:
; SHA3-NEXT:    eor3 v0.16b, v0.16b, v1.16b, v2.16b
; SHA3-NEXT:    ret
;
; NOSHA3-LABEL: eor3_4x32_left:
; NOSHA3:       // %bb.0:
; NOSHA3-NEXT:    eor v0.16b, v0.16b, v1.16b
; NOSHA3-NEXT:    eor v0.16b, v2.16b, v0.16b
; NOSHA3-NEXT:    ret
;
; SVE2-LABEL: eor3_4x32_left:
; SVE2:       // %bb.0:
; SVE2-NEXT:    // kill: def $q2 killed $q2 def $z2
; SVE2-NEXT:    // kill: def $q1 killed $q1 def $z1
; SVE2-NEXT:    // kill: def $q0 killed $q0 def $z0
; SVE2-NEXT:    eor3 z2.d, z2.d, z0.d, z1.d
; SVE2-NEXT:    mov v0.16b, v2.16b
; SVE2-NEXT:    ret
;
; SHA3-SVE2-LABEL: eor3_4x32_left:
; SHA3-SVE2:       // %bb.0:
; SHA3-SVE2-NEXT:    eor3 v0.16b, v0.16b, v1.16b, v2.16b
; SHA3-SVE2-NEXT:    ret
  %4 = xor <4 x i32> %0, %1
  %5 = xor <4 x i32> %2, %4
  ret <4 x i32> %5
}

define <4 x i32> @eor3_4x32_right(<4 x i32> %0, <4 x i32> %1, <4 x i32> %2) {
; SHA3-LABEL: eor3_4x32_right:
; SHA3:       // %bb.0:
; SHA3-NEXT:    eor3 v0.16b, v1.16b, v2.16b, v0.16b
; SHA3-NEXT:    ret
;
; NOSHA3-LABEL: eor3_4x32_right:
; NOSHA3:       // %bb.0:
; NOSHA3-NEXT:    eor v1.16b, v1.16b, v2.16b
; NOSHA3-NEXT:    eor v0.16b, v1.16b, v0.16b
; NOSHA3-NEXT:    ret
;
; SVE2-LABEL: eor3_4x32_right:
; SVE2:       // %bb.0:
; SVE2-NEXT:    // kill: def $q1 killed $q1 def $z1
; SVE2-NEXT:    // kill: def $q2 killed $q2 def $z2
; SVE2-NEXT:    // kill: def $q0 killed $q0 def $z0
; SVE2-NEXT:    eor3 z1.d, z1.d, z2.d, z0.d
; SVE2-NEXT:    mov v0.16b, v1.16b
; SVE2-NEXT:    ret
;
; SHA3-SVE2-LABEL: eor3_4x32_right:
; SHA3-SVE2:       // %bb.0:
; SHA3-SVE2-NEXT:    eor3 v0.16b, v1.16b, v2.16b, v0.16b
; SHA3-SVE2-NEXT:    ret
  %4 = xor <4 x i32> %1, %2
  %5 = xor <4 x i32> %4, %0
  ret <4 x i32> %5
}

define <2 x i64> @eor3_2x64_left(<2 x i64> %0, <2 x i64> %1, <2 x i64> %2) {
; SHA3-LABEL: eor3_2x64_left:
; SHA3:       // %bb.0:
; SHA3-NEXT:    eor3 v0.16b, v0.16b, v1.16b, v2.16b
; SHA3-NEXT:    ret
;
; NOSHA3-LABEL: eor3_2x64_left:
; NOSHA3:       // %bb.0:
; NOSHA3-NEXT:    eor v0.16b, v0.16b, v1.16b
; NOSHA3-NEXT:    eor v0.16b, v2.16b, v0.16b
; NOSHA3-NEXT:    ret
;
; SVE2-LABEL: eor3_2x64_left:
; SVE2:       // %bb.0:
; SVE2-NEXT:    // kill: def $q2 killed $q2 def $z2
; SVE2-NEXT:    // kill: def $q1 killed $q1 def $z1
; SVE2-NEXT:    // kill: def $q0 killed $q0 def $z0
; SVE2-NEXT:    eor3 z2.d, z2.d, z0.d, z1.d
; SVE2-NEXT:    mov v0.16b, v2.16b
; SVE2-NEXT:    ret
;
; SHA3-SVE2-LABEL: eor3_2x64_left:
; SHA3-SVE2:       // %bb.0:
; SHA3-SVE2-NEXT:    eor3 v0.16b, v0.16b, v1.16b, v2.16b
; SHA3-SVE2-NEXT:    ret
  %4 = xor <2 x i64> %0, %1
  %5 = xor <2 x i64> %2, %4
  ret <2 x i64> %5
}

define <2 x i64> @eor3_2x64_right(<2 x i64> %0, <2 x i64> %1, <2 x i64> %2) {
; SHA3-LABEL: eor3_2x64_right:
; SHA3:       // %bb.0:
; SHA3-NEXT:    eor3 v0.16b, v1.16b, v2.16b, v0.16b
; SHA3-NEXT:    ret
;
; NOSHA3-LABEL: eor3_2x64_right:
; NOSHA3:       // %bb.0:
; NOSHA3-NEXT:    eor v1.16b, v1.16b, v2.16b
; NOSHA3-NEXT:    eor v0.16b, v1.16b, v0.16b
; NOSHA3-NEXT:    ret
;
; SVE2-LABEL: eor3_2x64_right:
; SVE2:       // %bb.0:
; SVE2-NEXT:    // kill: def $q1 killed $q1 def $z1
; SVE2-NEXT:    // kill: def $q2 killed $q2 def $z2
; SVE2-NEXT:    // kill: def $q0 killed $q0 def $z0
; SVE2-NEXT:    eor3 z1.d, z1.d, z2.d, z0.d
; SVE2-NEXT:    mov v0.16b, v1.16b
; SVE2-NEXT:    ret
;
; SHA3-SVE2-LABEL: eor3_2x64_right:
; SHA3-SVE2:       // %bb.0:
; SHA3-SVE2-NEXT:    eor3 v0.16b, v1.16b, v2.16b, v0.16b
; SHA3-SVE2-NEXT:    ret
  %4 = xor <2 x i64> %1, %2
  %5 = xor <2 x i64> %4, %0
  ret <2 x i64> %5
}

define <2 x i64> @eor3_vnot(<2 x i64> %0, <2 x i64> %1) {
; SHA3-LABEL: eor3_vnot:
; SHA3:       // %bb.0:
; SHA3-NEXT:    eor v0.16b, v0.16b, v1.16b
; SHA3-NEXT:    mvn v0.16b, v0.16b
; SHA3-NEXT:    ret
;
; NOSHA3-LABEL: eor3_vnot:
; NOSHA3:       // %bb.0:
; NOSHA3-NEXT:    eor v0.16b, v0.16b, v1.16b
; NOSHA3-NEXT:    mvn v0.16b, v0.16b
; NOSHA3-NEXT:    ret
;
; SVE2-LABEL: eor3_vnot:
; SVE2:       // %bb.0:
; SVE2-NEXT:    // kill: def $q0 killed $q0 def $z0
; SVE2-NEXT:    // kill: def $q1 killed $q1 def $z1
; SVE2-NEXT:    bsl2n z0.d, z0.d, z0.d, z1.d
; SVE2-NEXT:    // kill: def $q0 killed $q0 killed $z0
; SVE2-NEXT:    ret
;
; SHA3-SVE2-LABEL: eor3_vnot:
; SHA3-SVE2:       // %bb.0:
; SHA3-SVE2-NEXT:    // kill: def $q0 killed $q0 def $z0
; SHA3-SVE2-NEXT:    // kill: def $q1 killed $q1 def $z1
; SHA3-SVE2-NEXT:    bsl2n z0.d, z0.d, z0.d, z1.d
; SHA3-SVE2-NEXT:    // kill: def $q0 killed $q0 killed $z0
; SHA3-SVE2-NEXT:    ret
  %3 = xor <2 x i64> %0, <i64 -1, i64 -1>
  %4 = xor <2 x i64> %3, %1
  ret <2 x i64> %4
}

