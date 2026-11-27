# REQUIRES: sparc
# RUN: llvm-mc -filetype=obj -triple=sparcv9 %s -o %t.o
## d/e, f/g and h/i sit at the two ends of the 13-, 16- and 8-bit fields.
# RUN: ld.lld %t.o --defsym=a=0x0123456789ABCDEF --defsym=b=0x0123456789A --defsym=c=0x01234567 \
# RUN:   --defsym=d=0x1fff --defsym=e=-0x1000 --defsym=f=0xffff --defsym=g=-0x8000 \
# RUN:   --defsym=h=0xff --defsym=i=-0x80 --defsym=x=0xffffffff01234567 \
# RUN:   --defsym=imm5=0x1f --defsym=imm6=0x3f --defsym=imm7=0x7f -o %t
# RUN: llvm-objdump -d --no-show-raw-insn --no-print-imm-hex %t | FileCheck %s
# RUN: llvm-objdump -s %t | FileCheck --check-prefix=HEX %s

## R_SPARC_HH22, R_SPARC_HM10
# CHECK-LABEL: section .ABS_64:
# CHECK:        sethi 18641, %o0
# CHECK-NEXT:   or %o0, 359, %o0
.section .ABS_64,"ax",@progbits
  sethi %hh(a), %o0
  or    %o0, %hm(a), %o0

## R_SPARC_H44, R_SPARC_M44, R_SPARC_L44
# CHECK-LABEL: section .ABS_44:
# CHECK:        sethi 18641, %o0
# CHECK:        or %o0, 359, %o0
# CHECK:        or %o0, 2202, %o0
.section .ABS_44,"ax",@progbits
  sethi %h44(b), %o0
  or    %o0, %m44(b), %o0
  sllx  %o0, 12, %o0
  or    %o0, %l44(b), %o0

## R_SPARC_H34
# CHECK-LABEL: section .ABS_34:
# CHECK:        sethi 4660, %o0
.section .ABS_34,"ax",@progbits
  sethi 0, %o0
  .reloc .-4, R_SPARC_H34, c

## R_SPARC_HI22, R_SPARC_LO10
# CHECK-LABEL: section .ABS_32:
# CHECK:        sethi 18641, %o0
# CHECK-NEXT:   or %o0, 359, %o0
.section .ABS_32,"ax",@progbits
  sethi %hi(c), %o0
  or    %o0, %lo(c), %o0

## R_SPARC_13 takes a signed as well as an unsigned value. The field is a
## simm13, so the unsigned maximum 0x1fff is written and reads back as -1.
# CHECK-LABEL: section .ABS_13:
# CHECK:        mov -1, %o0
# CHECK-NEXT:   mov -4096, %o1
.section .ABS_13,"ax",@progbits
  or    %g0, d, %o0
  or    %g0, e, %o1

## R_SPARC_22, R_SPARC_11, R_SPARC_10, R_SPARC_7, R_SPARC_6 and R_SPARC_5 fill
## the immediate of sethi, movcc, movr, Tcc and the shifts. Like R_SPARC_13
## they take a signed as well as an unsigned value.
# CHECK-LABEL: section .ABS_IMM:
# CHECK:        sethi 65535, %o0
# CHECK-NEXT:   sethi 4161536, %o1
# CHECK-NEXT:   movne %icc, 255, %o0
# CHECK-NEXT:   movrnz %o2, 255, %o0
# CHECK-NEXT:   ta %icc, 127
# CHECK-NEXT:   sllx %o0, 63, %o0
# CHECK-NEXT:   sll %o0, 31, %o0
.section .ABS_IMM,"ax",@progbits
  sethi  0, %o0
  .reloc .-4, R_SPARC_22, f
  sethi  0, %o1
  .reloc .-4, R_SPARC_22, g
  movne  %icc, 0, %o0
  .reloc .-4, R_SPARC_11, h
  movrnz %o2, 0, %o0
  .reloc .-4, R_SPARC_10, h
  ta     0
  .reloc .-4, R_SPARC_7, imm7
  sllx   %o0, 0, %o0
  .reloc .-4, R_SPARC_6, imm6
  sll    %o0, 0, %o0
  .reloc .-4, R_SPARC_5, imm5

## -0x80 in the simm11 field of movcc and the simm10 field of movr.
# HEX-LABEL: section .ABS_IMM_NEG:
# HEX-NEXT:  93666780 937ab780
.section .ABS_IMM_NEG,"ax",@progbits
  movne  %icc, 0, %o1
  .reloc .-4, R_SPARC_11, i
  movrnz %o2, 0, %o1
  .reloc .-4, R_SPARC_10, i

## R_SPARC_HIX22, R_SPARC_LOX10. The pair encodes the complement of the value,
## so it is limited to values whose upper 32 bits are all ones.
## sethi(~x >> 10) ^ sext(0x1c00 | (x & 0x3ff)) = 0xfedcb800 ^ 0xfffffffffffffd67
# CHECK-LABEL: section .ABS_HIX:
# CHECK:        sethi 4175662, %o0
# CHECK-NEXT:   xor %o0, -665, %o0
.section .ABS_HIX,"ax",@progbits
  sethi %hix(x), %o0
  xor   %o0, %lox(x), %o0

## R_SPARC_LO10, R_SPARC_HM10 and R_SPARC_L44 write 10, 10 and 12 bits of the
## simm13 field and leave the remaining bits of the instruction alone, so an
## immediate of -1024 (0x1c00) survives in the high bits.
# CHECK-LABEL: section .ABS_MASK:
# CHECK:        or %o0, -665, %o0
# CHECK-NEXT:   or %o1, -665, %o1
# CHECK-NEXT:   or %o2, -1894, %o2
.section .ABS_MASK,"ax",@progbits
  or %o0, -1024, %o0
  .reloc .-4, R_SPARC_LO10, c
  or %o1, -1024, %o1
  .reloc .-4, R_SPARC_HM10, a
  or %o2, -1024, %o2
  .reloc .-4, R_SPARC_L44, b

## R_SPARC_64, R_SPARC_32, R_SPARC_16, R_SPARC_8, R_SPARC_UA16. R_SPARC_8 and
## R_SPARC_16 take a signed as well as an unsigned value.
# HEX-LABEL: section .ABS_DATA:
# HEX-NEXT:  01234567 89abcdef 01234567 ffffff80
# HEX-NEXT:  0080
.section .ABS_DATA,"ax",@progbits
  .quad a
  .long c
  .half f
  .byte h
## An odd offset makes the assembler pick the unaligned form.
  .half g
  .byte i

## Relocations in a non-SHF_ALLOC section are resolved through getRelExpr.
## The second group starts at an odd offset, so the assembler picks the
## unaligned forms.
# HEX-LABEL: section .debug_info:
# HEX-NEXT:  ffff8000 01234567 01234567 89abcdef
# HEX-NEXT:  ffffff01 23456701 23456789 abcdef
.section .debug_info,"",@progbits
  .half f
  .half g
  .long c
  .quad a
  .byte h
  .half f
  .long c
  .quad a
