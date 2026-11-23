! RUN: not llvm-mc %s -triple=sparc   -show-encoding 2>&1 | FileCheck %s --check-prefix=V8 \
! RUN:   --implicit-check-not=error:
! RUN: not llvm-mc %s -triple=sparcv9 -show-encoding 2>&1 | FileCheck %s --check-prefix=V9 \
! RUN:   --implicit-check-not=error:

! V8: :[[#@LINE+4]]:13: error: expected absolute expression
! V8-NEXT: lduba [%i0] asi, %o2
! V9: :[[#@LINE+2]]:13: error: expected absolute expression
! V9-NEXT: lduba [%i0] asi, %o2
lduba [%i0] asi, %o2

! V8: :[[#@LINE+4]]:13: error: malformed ASI tag, must be a constant integer expression
! V8-NEXT: lduba [%i0] %g0, %o2
! V9: :[[#@LINE+2]]:13: error: malformed ASI tag, must be %asi, a constant integer expression, or a named tag
! V9-NEXT: lduba [%i0] %g0, %o2
lduba [%i0] %g0, %o2

! V8: :[[#@LINE+4]]:13: error: malformed ASI tag, must be a constant integer expression
! V8-NEXT: lduba [%i0] %0, %o2
! V9: :[[#@LINE+2]]:13: error: malformed ASI tag, must be %asi, a constant integer expression, or a named tag
! V9-NEXT: lduba [%i0] %0, %o2
lduba [%i0] %0, %o2

! V8: :[[#@LINE+4]]:13: error: invalid ASI number, must be between 0 and 255
! V8-NEXT: lduba [%i0] -1, %o2
! V9: :[[#@LINE+2]]:13: error: invalid ASI number, must be between 0 and 255
! V9-NEXT: lduba [%i0] -1, %o2
lduba [%i0] -1, %o2

! V8: :[[#@LINE+4]]:13: error: invalid ASI number, must be between 0 and 255
! V8-NEXT: lduba [%i0] 256, %o2
! V9: :[[#@LINE+2]]:13: error: invalid ASI number, must be between 0 and 255
! V9-NEXT: lduba [%i0] 256, %o2
lduba [%i0] 256, %o2

!! %asi register is only introduced in V9
! V8: :[[#@LINE+2]]:13: error: malformed ASI tag, must be a constant integer expression
! V8-NEXT: lduba [%i0] %asi, %o2
lduba [%i0] %asi, %o2

!! [Reg+Imm] can't be used with immediate ASI forms.
! V8: :[[#@LINE+4]]:15: error: invalid operand for instruction
! V8-NEXT: lduba [%i0+1] 255, %o2
! V9: :[[#@LINE+2]]:15: error: invalid operand for instruction
! V9-NEXT: lduba [%i0+1] 255, %o2
lduba [%i0+1] 255, %o2

!! [Reg+Reg] can't be used with stored tag in %asi.
! V8: :[[#@LINE+4]]:17: error: malformed ASI tag, must be a constant integer expression
! V8-NEXT: lduba [%i0+%i1] %asi, %o2
! V9: :[[#@LINE+2]]:17: error: invalid operand for instruction
! V9-NEXT: lduba [%i0+%i1] %asi, %o2
lduba [%i0+%i1] %asi, %o2
