! RUN: not llvm-mc %s -triple=sparc -mcpu=v7 -show-encoding 2>&1 | FileCheck %s --check-prefix=V7
! RUN: llvm-mc %s -triple=sparc -show-encoding | FileCheck %s --check-prefix=V8

!! The integer multiply and divide instructions, fsmuld and stbar are new
!! in V8.

! V7: error: instruction requires a CPU feature not currently enabled
! V8: umul %o0, %o1, %o2
umul %o0, %o1, %o2
! V7: error: instruction requires a CPU feature not currently enabled
! V8: smul %o0, 5, %o2
smul %o0, 5, %o2
! V7: error: instruction requires a CPU feature not currently enabled
! V8: umulcc %o0, %o1, %o2
umulcc %o0, %o1, %o2
! V7: error: instruction requires a CPU feature not currently enabled
! V8: smulcc %o0, %o1, %o2
smulcc %o0, %o1, %o2
! V7: error: instruction requires a CPU feature not currently enabled
! V8: udiv %o0, %o1, %o2
udiv %o0, %o1, %o2
! V7: error: instruction requires a CPU feature not currently enabled
! V8: sdiv %o0, 5, %o2
sdiv %o0, 5, %o2
! V7: error: instruction requires a CPU feature not currently enabled
! V8: udivcc %o0, %o1, %o2
udivcc %o0, %o1, %o2
! V7: error: instruction requires a CPU feature not currently enabled
! V8: sdivcc %o0, %o1, %o2
sdivcc %o0, %o1, %o2
! V7: error: instruction requires a CPU feature not currently enabled
! V8: fsmuld %f0, %f1, %f2
fsmuld %f0, %f1, %f2
! V7: error: instruction requires a CPU feature not currently enabled
! V8: stbar
stbar

!! These are in V7.

! V7: mulscc %o0, %o1, %o2
! V8: mulscc %o0, %o1, %o2
mulscc %o0, %o1, %o2
! V7: swap [%o0], %o1
! V8: swap [%o0], %o1
swap [%o0], %o1
! V7: ldstub [%o0], %o1
! V8: ldstub [%o0], %o1
ldstub [%o0], %o1
! V7: fsqrtd %f0, %f2
! V8: fsqrtd %f0, %f2
fsqrtd %f0, %f2
