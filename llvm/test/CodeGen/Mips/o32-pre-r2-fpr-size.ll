; MIPS III and later imply 64-bit FPRs for N32/N64. Before MIPS32r2, O32 has no
; mthc1/mfhc1, so it defaults to 32-bit FPRs like GCC does, unless 64-bit FPRs
; are requested explicitly.

; RUN: llc -mtriple=mipsel -mcpu=mips3 < %s \
; RUN:   | FileCheck %s -check-prefixes=FP32,EVEN
; RUN: llc -mtriple=mipsel -mcpu=mips4 < %s \
; RUN:   | FileCheck %s -check-prefixes=FP32,EVEN
; RUN: llc -mtriple=mips64el -mcpu=mips64 -target-abi=o32 < %s \
; RUN:   | FileCheck %s -check-prefix=FP32
; RUN: llc -mtriple=mipsel -mcpu=mips3 -mattr=+fpxx < %s \
; RUN:   | FileCheck %s -check-prefix=FPXX
; RUN: llc -mtriple=mipsel -mcpu=mips3 -mattr=+fp64 < %s \
; RUN:   | FileCheck %s -check-prefix=FP64
; RUN: llc -mtriple=mipsel -mcpu=mips3 -mattr=-fp64,+fp64 < %s \
; RUN:   | FileCheck %s -check-prefix=FP64
; RUN: llc -mtriple=mipsel -mcpu=mips3 -mattr=+fp64,-fp64 < %s \
; RUN:   | FileCheck %s -check-prefix=FP32
; RUN: llc -mtriple=mips64el -mcpu=mips64r2 -target-abi=o32 < %s \
; RUN:   | FileCheck %s -check-prefix=FP64
; RUN: llc -mtriple=mips64el -mcpu=mips3 -target-abi=n64 < %s \
; RUN:   | FileCheck %s -check-prefix=N64

; RUN: llc -mtriple=mipsel -mcpu=mips3 -filetype=obj < %s \
; RUN:   | llvm-readobj -A - | FileCheck %s -check-prefix=FLAGS-FP32
; RUN: llc -mtriple=mipsel -mcpu=mips3 -mattr=+fpxx -filetype=obj < %s \
; RUN:   | llvm-readobj -A - | FileCheck %s -check-prefix=FLAGS-FPXX

; FP32-NOT: .module fp=
; EVEN:     .module nooddspreg
; FPXX:     .module fp=xx
; FP64:     .module fp=64

; A double in the upper half of an even/odd pair is only addressable with
; 32-bit FPRs.
; FP32-LABEL: from_gprs:
; FP32-DAG:   mtc1 $6, $f0
; FP32-DAG:   mtc1 $7, $f1
; FP32-NOT:   ldc1
; FPXX-LABEL: from_gprs:
; FPXX:       ldc1 $f0, 0($sp)
; FP64-LABEL: from_gprs:
; FP64-NOT:   mtc1 ${{[0-9]+}}, $f1
; N64-LABEL:  from_gprs:
; N64:        mov.d $f0, $f13
define double @from_gprs(i32 %pad, double %value) {
  ret double %value
}

; FLAGS-FP32:      FP ABI: Hard float (double precision)
; FLAGS-FP32:      CPR1 size: 32
; FLAGS-FPXX:      FP ABI: Hard float (32-bit CPU, Any FPU)
; FLAGS-FPXX:      CPR1 size: 32
