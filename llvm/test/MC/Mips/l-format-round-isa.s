# The .l rounding instructions came with MIPS III and MIPS32r2, like the other
# .l format instructions, even with a 64-bit FPU.
#
# RUN: not llvm-mc %s -triple=mips-unknown-linux -mcpu=mips2 -mattr=+fp64 \
# RUN:     2>&1 | FileCheck %s -check-prefix=INVALID
# RUN: not llvm-mc %s -triple=mips-unknown-linux -mcpu=mips32 -mattr=+fp64 \
# RUN:     2>&1 | FileCheck %s -check-prefix=INVALID
# RUN: llvm-mc %s -triple=mips64-unknown-linux -mcpu=mips3 -show-encoding \
# RUN:     | FileCheck %s -check-prefix=VALID
# RUN: llvm-mc %s -triple=mips-unknown-linux -mcpu=mips32r2 -mattr=+fp64 \
# RUN:     -show-encoding | FileCheck %s -check-prefix=VALID

        round.l.s $f2, $f4  # INVALID: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
                            # VALID: round.l.s $f2, $f4  # encoding: [0x46,0x00,0x20,0x88]
        round.l.d $f2, $f4  # INVALID: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
                            # VALID: round.l.d $f2, $f4  # encoding: [0x46,0x20,0x20,0x88]
        trunc.l.s $f2, $f4  # INVALID: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
                            # VALID: trunc.l.s $f2, $f4  # encoding: [0x46,0x00,0x20,0x89]
        trunc.l.d $f2, $f4  # INVALID: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
                            # VALID: trunc.l.d $f2, $f4  # encoding: [0x46,0x20,0x20,0x89]
        ceil.l.s  $f2, $f4  # INVALID: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
                            # VALID: ceil.l.s $f2, $f4   # encoding: [0x46,0x00,0x20,0x8a]
        ceil.l.d  $f2, $f4  # INVALID: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
                            # VALID: ceil.l.d $f2, $f4   # encoding: [0x46,0x20,0x20,0x8a]
        floor.l.s $f2, $f4  # INVALID: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
                            # VALID: floor.l.s $f2, $f4  # encoding: [0x46,0x00,0x20,0x8b]
        floor.l.d $f2, $f4  # INVALID: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
                            # VALID: floor.l.d $f2, $f4  # encoding: [0x46,0x20,0x20,0x8b]
