; Check that the CPU names work.

; RUN: llc -mtriple=mips -mcpu=generic -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=GENERIC
; GENERIC: ISA: MIPS32

; RUN: llc -mtriple=mips -mcpu=mips1 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS1
; MIPS1: ISA: MIPS1
; RUN: llc -mtriple=mips -mcpu=r2000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS1
; RUN: llc -mtriple=mips -mcpu=r3000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS1
; RUN: llc -mtriple=mips -mcpu=mips2 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS2
; MIPS2: ISA: MIPS2
; RUN: llc -mtriple=mips -mcpu=r6000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS2
; RUN: llc -mtriple=mips64 -mcpu=mips3 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS3
; MIPS3: ISA: MIPS3
; RUN: llc -mtriple=mips64 -mcpu=mips4 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS4
; MIPS4: ISA: MIPS4
; RUN: llc -mtriple=mips64 -mcpu=r8000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS4
; RUN: llc -mtriple=mips64 -mcpu=r10000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS4
; RUN: llc -mtriple=mips64 -mcpu=r12000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS4
; RUN: llc -mtriple=mips64 -mcpu=r14000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS4
; RUN: llc -mtriple=mips64 -mcpu=r16000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS4
; RUN: llc -mtriple=mips64 -mcpu=vr5000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS4
; RUN: llc -mtriple=mips64 -mcpu=rm7000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS4

; RUN: llc -mtriple=mips -mcpu=mips32 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32
; MIPS32: ISA: MIPS32
; RUN: llc -mtriple=mips -mcpu=4kc -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32
; RUN: llc -mtriple=mips -mcpu=4km -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32
; RUN: llc -mtriple=mips -mcpu=4kp -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32
; RUN: llc -mtriple=mips -mcpu=4ksc -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32
; RUN: llc -mtriple=mips -mcpu=mips32r2 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; MIPS32R2: ISA: MIPS32r2
; RUN: llc -mtriple=mips -mcpu=4kec -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=4kem -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=4kep -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=4ksd -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=m4k -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=24kc -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=34kn -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=m14k -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=m14kc -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=24kf2_1 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=24kf -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=24kf1_1 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=24kfx -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=24kx -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc -mtriple=mips -mcpu=24kef2_1 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=24kef -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=24kef1_1 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=24kefx -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=24kex -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=34kf2_1 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=34kf -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=34kf1_1 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=34kfx -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=34kx -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=1004kf2_1 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=1004kf -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=1004kf1_1 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=interaptiv -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=24kec -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=34kc -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; RUN: llc -mtriple=mips -mcpu=1004kc -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSP
; MIPS32R2-DSP: ISA: MIPS32r2
; MIPS32R2-DSP: ASEs: DSP{{$}}
; RUN: llc -mtriple=mips -mcpu=74kf2_1 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSPR2
; RUN: llc -mtriple=mips -mcpu=74kf -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSPR2
; RUN: llc -mtriple=mips -mcpu=74kf1_1 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSPR2
; RUN: llc -mtriple=mips -mcpu=74kfx -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSPR2
; RUN: llc -mtriple=mips -mcpu=74kx -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSPR2
; RUN: llc -mtriple=mips -mcpu=74kf3_2 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSPR2
; RUN: llc -mtriple=mips -mcpu=74kc -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSPR2
; RUN: llc -mtriple=mips -mcpu=m14ke -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSPR2
; RUN: llc -mtriple=mips -mcpu=m14kec -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R2-DSPR2
; MIPS32R2-DSPR2: ISA: MIPS32r2
; MIPS32R2-DSPR2: ASEs: DSP, DSPR2{{$}}
; RUN: llc -mtriple=mips -mcpu=mips32r3 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R3
; MIPS32R3: ISA: MIPS32r3
; RUN: llc -mtriple=mips -mcpu=mips32r5 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R5
; MIPS32R5: ISA: MIPS32r5
; RUN: llc -mtriple=mips -mcpu=m5100 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R5
; RUN: llc -mtriple=mips -mcpu=m5101 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R5
; RUN: llc -mtriple=mips -mcpu=mips32r6 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS32R6
; MIPS32R6: ISA: MIPS32r6

; RUN: llc -mtriple=mips64 -mcpu=mips64 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS64
; MIPS64: ISA: MIPS64
; RUN: llc -mtriple=mips64 -mcpu=5kc -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS64
; RUN: llc -mtriple=mips64 -mcpu=5kf -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS64
; RUN: llc -mtriple=mips64 -mcpu=20kc -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS64
; RUN: llc -mtriple=mips64 -mcpu=sr71000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS64
; RUN: llc -mtriple=mips64 -mcpu=mips64r2 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS64R2
; MIPS64R2: ISA: MIPS64r2
; RUN: llc -mtriple=mips64 -mcpu=xlp -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS64R2
; RUN: llc -mtriple=mips64 -mcpu=mips64r3 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS64R3
; MIPS64R3: ISA: MIPS64r3
; RUN: llc -mtriple=mips64 -mcpu=mips64r5 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS64R5
; MIPS64R5: ISA: MIPS64r5
; RUN: llc -mtriple=mips64 -mcpu=mips64r6 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS64R6
; MIPS64R6: ISA: MIPS64r6
; RUN: llc -mtriple=mips64 -mcpu=p6600 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS64R6

; RUN: llc -mtriple=mips64 -mcpu=octeon -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=OCTEON
; OCTEON: ISA: MIPS64r2
; OCTEON: ISA Extension: Cavium Networks Octeon
; RUN: llc -mtriple=mips64 -mcpu=octeon+ -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=OCTEONP
; OCTEONP: ISA: MIPS64r2
; OCTEONP: ISA Extension: Cavium Networks OcteonP

; RUN: llc -mtriple=mips64el -mcpu=r5900 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=R5900
; R5900: ISA: MIPS3
; R5900: ISA Extension: Toshiba R5900

; RUN: llc -mtriple=mips64 -mcpu=r4000 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS3-IMPL
; RUN: llc -mtriple=mips64 -mcpu=r4400 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS3-IMPL
; RUN: llc -mtriple=mips64 -mcpu=r4600 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS3-IMPL
; RUN: llc -mtriple=mips64 -mcpu=orion -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS3-IMPL
; RUN: llc -mtriple=mips64 -mcpu=r4700 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS3-IMPL
; RUN: llc -mtriple=mips64 -mcpu=vr4300 -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=MIPS3-IMPL
; MIPS3-IMPL: ISA: MIPS3
; MIPS3-IMPL: ISA Extension: None

; RUN: llc -mtriple=mips64el -mcpu=loongson2e -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=LOONGSON2E
; LOONGSON2E: ISA: MIPS3
; LOONGSON2E: ISA Extension: Loongson 2E
; RUN: llc -mtriple=mips64el -mcpu=loongson2f -filetype=obj < %s \
; RUN:   | llvm-readelf -A - | FileCheck %s --check-prefix=LOONGSON2F
; LOONGSON2F: ISA: MIPS3
; LOONGSON2F: ISA Extension: Loongson 2F
; RUN: llc -mtriple=mips64el -mcpu=loongson2e -filetype=obj < %s \
; RUN:   | llvm-readelf -h - | FileCheck %s --check-prefix=LOONGSON2E-FLAGS
; LOONGSON2E-FLAGS: Flags: {{.*}}, loongson-2e, mips3
; RUN: llc -mtriple=mips64el -mcpu=loongson2f -filetype=obj < %s \
; RUN:   | llvm-readelf -h - | FileCheck %s --check-prefix=LOONGSON2F-FLAGS
; LOONGSON2F-FLAGS: Flags: {{.*}}, loongson-2f, mips3

; Check that we reject CPUs that are not implemented.

; RUN: not llc < %s -o /dev/null -mtriple=mips64 -mcpu=mips5 2>&1 \
; RUN:   | FileCheck %s --check-prefix=ERROR

; ERROR: LLVM ERROR: Code generation for MIPS-{{.}} is not implemented

define void @foo() {
  ret void
}
