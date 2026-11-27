! RUN: not llvm-mc %s -triple=sparc -show-encoding 2>&1 | FileCheck %s --check-prefix=V8
! RUN: llvm-mc %s -triple=sparcv9 -show-encoding | FileCheck %s --check-prefix=V9

!! The alternate names of %asr2-%asr6, the JPS1 names of the other ASRs and
!! the forms of the floating-point compares that name an %fcc register are
!! V9 only.

! V8: :[[@LINE+2]]:5: error: invalid register name
! V9: rd %ccr, %i0          ! encoding: [0xb1,0x40,0x80,0x00]
rd %ccr, %i0
! V8: :[[@LINE+2]]:13: error: invalid register name
! V9: wr %i0, 7, %ccr       ! encoding: [0x85,0x86,0x20,0x07]
wr %i0, 7, %ccr

! V8: :[[@LINE+2]]:5: error: invalid register name
! V9: rd %asi, %i0          ! encoding: [0xb1,0x40,0xc0,0x00]
rd %asi, %i0
! V8: :[[@LINE+2]]:13: error: invalid register name
! V9: wr %i0, 7, %asi       ! encoding: [0x87,0x86,0x20,0x07]
wr %i0, 7, %asi

! V8: :[[@LINE+2]]:5: error: invalid register name
! V9: rd %tick, %i0         ! encoding: [0xb1,0x41,0x00,0x00]
rd %tick, %i0
! V8: :[[@LINE+2]]:13: error: invalid register name
! V9: wr %i0, 7, %tick      ! encoding: [0x89,0x86,0x20,0x07]
wr %i0, 7, %tick

! V8: :[[@LINE+2]]:5: error: invalid register name
! V9: rd %pc, %i0           ! encoding: [0xb1,0x41,0x40,0x00]
rd %pc, %i0
! V8: :[[@LINE+2]]:13: error: invalid register name
! V9: wr %i0, 7, %pc        ! encoding: [0x8b,0x86,0x20,0x07]
wr %i0, 7, %pc

! V8: :[[@LINE+2]]:5: error: invalid register name
! V9: rd %fprs, %i0         ! encoding: [0xb1,0x41,0x80,0x00]
rd %fprs, %i0
! V8: :[[@LINE+2]]:13: error: invalid register name
! V9: wr %i0, 7, %fprs      ! encoding: [0x8d,0x86,0x20,0x07]
wr %i0, 7, %fprs

! V8: :[[@LINE+2]]:5: error: invalid register name
! V9: rd %asr19, %i0        ! encoding: [0xb1,0x44,0xc0,0x00]
rd %gsr, %i0

! V8: :[[@LINE+2]]:7: error: instruction requires a CPU feature not currently enabled
! V9: fcmps %f0, %f4      ! encoding: [0x81,0xa8,0x0a,0x24]
fcmps %fcc0, %f0, %f4
! V8: :[[@LINE+2]]:7: error: instruction requires a CPU feature not currently enabled
! V9: fcmps %fcc1, %f0, %f4 ! encoding: [0x83,0xa8,0x0a,0x24]
fcmps %fcc1, %f0, %f4
! V8: :[[@LINE+2]]:7: error: instruction requires a CPU feature not currently enabled
! V9: fcmpd %fcc2, %f0, %f4 ! encoding: [0x85,0xa8,0x0a,0x44]
fcmpd %fcc2, %f0, %f4
! V8: :[[@LINE+2]]:8: error: instruction requires a CPU feature not currently enabled
! V9: fcmpes %fcc3, %f0, %f4 ! encoding: [0x87,0xa8,0x0a,0xa4]
fcmpes %fcc3, %f0, %f4
! V8: :[[@LINE+2]]:8: error: instruction requires a CPU feature not currently enabled
! V9: fcmped %fcc1, %f0, %f4 ! encoding: [0x83,0xa8,0x0a,0xc4]
fcmped %fcc1, %f0, %f4
