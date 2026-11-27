# REQUIRES: sparc
# RUN: llvm-mc -filetype=obj -triple=sparcv9 -mattr=+osa2011 %s -o %t.o

## Every branch form reaches the same nearby target.
# RUN: ld.lld %t.o --defsym=w10=_start+0x18 --defsym=w16=_start+0x18 \
# RUN:   --defsym=w19=_start+0x18 --defsym=w22=_start+0x18 \
# RUN:   --defsym=w30=_start+0x18 --defsym=far=_start+0x100000 \
# RUN:   --defsym=pcfar=_start+0x123456789abc018 --defsym=imm5=-16 -o %t
# RUN: llvm-objdump -d -s -j .text --mattr=+osa2011 --no-print-imm-hex %t | \
# RUN:   FileCheck %s

## Displacements at the top of each field. R_SPARC_WDISP16 splits its
## displacement between bits 21:20 and 13:0, so d16hi is only exercised here.
# RUN: ld.lld %t.o --defsym=w10=_start+0x820 --defsym=w16=_start+0x1fffc \
# RUN:   --defsym=w19=_start+0x100000 --defsym=w22=_start+0x800004 \
# RUN:   --defsym=w30=_start+0x80000008 --defsym=far=_start+0x100000 \
# RUN:   --defsym=pcfar=_start+0x123456789abc018 --defsym=imm5=-16 -o %t.limits
# RUN: llvm-objdump -d --mattr=+osa2011 %t.limits | \
# RUN:   FileCheck --check-prefix=LIMITS %s

## R_SPARC_DISP8, R_SPARC_DISP16, R_SPARC_DISP32 and R_SPARC_DISP64 close out
## .text, each holding target - . = -4, -5, -7 and -11. The 16-, 32- and 64-bit
## stores are unaligned; SPARC has no unaligned variant of the DISP relocations.
# CHECK:      Contents of section .text:
# CHECK:      fcfffbff
# CHECK-NEXT: fffff9ff ffffffff fffff5

## far - . is 0xffff0 for the sethi and 0xfffec for the or.
# CHECK:      <_start>:
# CHECK-NEXT:   0a c8 40 06 brnz %g1, 0x[[#%x,TGT:]]
# CHECK-NEXT:   02 48 00 05 be %icc, 0x[[#TGT]]
# CHECK-NEXT:   10 80 00 04 ba 0x[[#TGT]]
# CHECK-NEXT:   40 00 00 03 call 0x[[#TGT]]
# CHECK-NEXT:   05 00 03 ff sethi 1023, %g2
# CHECK-NEXT:   84 10 a3 ec or %g2, 1004, %g2

## pcfar - . is 0x123456789abc000 for each of the three.
# CHECK:        07 00 48 d1 sethi 18641, %g3
# CHECK-NEXT:   86 10 e1 67 or %g3, 359, %g3
# CHECK-NEXT:   09 22 6a f0 sethi 2255600, %g4

## w10 - . is -0xc. R_SPARC_WDISP10 splits its displacement between bits
## 20:19 and 12:5, so d10hi is 0b11 and d10lo is 0xfd. The compare operand
## comes from R_SPARC_5.
# CHECK-NEXT:   12 da 3f b0 cwbe %o0, -16, 0x[[#TGT]]

## w16 - . is 0x1fffc, so d16hi is 0b01 and d16lo is 0x3fff.
## w19 - . is 0xffffc, w22 - . is 0x7ffffc and w30 - . is 0x7ffffffc.
## w10 - . is 0x7fc, so d10hi is 0b01 and d10lo is 0xff.
# LIMITS:      <_start>:
# LIMITS-NEXT:   0a d8 7f ff brnz
# LIMITS-NEXT:   02 4b ff ff be
# LIMITS-NEXT:   10 9f ff ff ba
# LIMITS-NEXT:   5f ff ff ff call
# LIMITS:        12 ca 3f f0 cwbe

.section .text.a,"ax",@progbits
.globl _start
_start:
## R_SPARC_WDISP16, R_SPARC_WDISP19, R_SPARC_WDISP22, R_SPARC_WDISP30
  brnz    %g1, w16
  be,pt   %icc, w19
  ba      w22
  call    w30
## R_SPARC_PC22, R_SPARC_PC10
  sethi   %pc22(far), %g2
  or      %g2, %pc10(far), %g2
## R_SPARC_PC_HH22, R_SPARC_PC_HM10, R_SPARC_PC_LM22. The addends make each
## displacement relative to the first instruction.
  sethi   0, %g3
  .reloc  .-4, R_SPARC_PC_HH22, pcfar
  or      %g3, 0, %g3
  .reloc  .-4, R_SPARC_PC_HM10, pcfar+4
  sethi   0, %g4
  .reloc  .-4, R_SPARC_PC_LM22, pcfar+8
## R_SPARC_WDISP10, R_SPARC_5
  cwbe    %o0, imm5, w10

.section .text.b,"ax",@progbits
target:
  nop

.section .text.c,"ax",@progbits
  .byte  target - .
  .half  target - .
  .word  target - .
  .xword target - .
