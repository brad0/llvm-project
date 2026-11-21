# REQUIRES: sparc
## R_SPARC_TLS_DTPOFF32/R_SPARC_TLS_DTPOFF64 in .debug_info resolve to the
## offset of the symbol within the TLS segment.

# RUN: llvm-mc -filetype=obj -triple=sparcv9 %s -o %t.o
# RUN: ld.lld %t.o -o %t
# RUN: llvm-objdump -s -j .debug_info %t | FileCheck %s

# CHECK:      Contents of section .debug_info:
# CHECK-NEXT:  0000 00000008 00000010 00000000 00000008
# CHECK-NEXT:  0010 00000000 00000010

.globl _start
_start:
  retl
  nop

.section .tdata,"awT",@progbits
  .zero 8
.globl var
var:
  .word 1
lvar:
  .zero 8

.section .debug_info,"",@progbits
  .word %r_tls_dtpoff32(var)
  .word %r_tls_dtpoff32(lvar + 4)
  .xword %r_tls_dtpoff64(var)
  .xword %r_tls_dtpoff64(lvar + 4)
