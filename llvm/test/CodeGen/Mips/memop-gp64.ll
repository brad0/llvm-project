; Inline memcpy/memset should use 64-bit loads and stores whenever the GPRs are
; 64 bits wide, not only from MIPS64 on.

; RUN: llc -mtriple=mips64 -mcpu=mips3 -target-abi=n64 < %s \
; RUN:   | FileCheck %s -check-prefixes=ALL,GP64
; RUN: llc -mtriple=mips64 -mcpu=mips4 -target-abi=n64 < %s \
; RUN:   | FileCheck %s -check-prefixes=ALL,GP64
; RUN: llc -mtriple=mips64 -mcpu=mips3 -target-abi=n32 < %s \
; RUN:   | FileCheck %s -check-prefixes=ALL,GP64
; RUN: llc -mtriple=mips64 -mcpu=mips64 -target-abi=n64 < %s \
; RUN:   | FileCheck %s -check-prefixes=ALL,GP64
; RUN: llc -mtriple=mips -mcpu=mips64 -target-abi=o32 < %s \
; RUN:   | FileCheck %s -check-prefixes=ALL,GP32
; RUN: llc -mtriple=mips -mcpu=mips2 < %s \
; RUN:   | FileCheck %s -check-prefixes=ALL,GP32

define void @copy16(ptr align 8 %d, ptr align 8 %s) {
; ALL-LABEL: copy16:
; GP64-NOT:  {{lw|sw}}
; GP64-DAG:  ld ${{[0-9]+}}, 0(${{[0-9]+}})
; GP64-DAG:  ld ${{[0-9]+}}, 8(${{[0-9]+}})
; GP64-DAG:  sd ${{[0-9]+}}, 0(${{[0-9]+}})
; GP64-DAG:  sd ${{[0-9]+}}, 8(${{[0-9]+}})
; GP64-NOT:  {{lw|sw}}
; GP32-NOT:  {{ld|sd}}
; GP32-DAG:  lw ${{[0-9]+}}, 0(${{[0-9]+}})
; GP32-DAG:  lw ${{[0-9]+}}, 4(${{[0-9]+}})
; GP32-DAG:  lw ${{[0-9]+}}, 8(${{[0-9]+}})
; GP32-DAG:  lw ${{[0-9]+}}, 12(${{[0-9]+}})
; GP32-NOT:  {{ld|sd}}
; ALL:       .end copy16
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %d, ptr align 8 %s, i64 16, i1 false)
  ret void
}

define void @zero16(ptr align 8 %d) {
; ALL-LABEL: zero16:
; GP64-NOT:  sw
; GP64-DAG:  sd $zero, 0(${{[0-9]+}})
; GP64-DAG:  sd $zero, 8(${{[0-9]+}})
; GP64-NOT:  sw
; GP32-NOT:  sd
; GP32-DAG:  sw $zero, 0(${{[0-9]+}})
; GP32-DAG:  sw $zero, 4(${{[0-9]+}})
; GP32-DAG:  sw $zero, 8(${{[0-9]+}})
; GP32-DAG:  sw $zero, 12(${{[0-9]+}})
; GP32-NOT:  sd
; ALL:       .end zero16
  call void @llvm.memset.p0.i64(ptr align 8 %d, i8 0, i64 16, i1 false)
  ret void
}

declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)
