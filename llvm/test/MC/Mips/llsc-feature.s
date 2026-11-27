# MIPS I and the R5900 have no ll and sc, and MIPS I has no sync, but +llsc
# allows them, as when the kernel emulates them.

# RUN: llvm-mc %s -triple=mips -mcpu=mips1 -mattr=+llsc -show-encoding \
# RUN:   | FileCheck %s
# RUN: llvm-mc %s -triple=mipsel -mcpu=r5900 -mattr=+llsc -show-encoding \
# RUN:   | FileCheck %s --check-prefix=R5900
# RUN: not llvm-mc %s -triple=mips -mcpu=mips1 2>&1 \
# RUN:   | FileCheck %s --check-prefix=MIPS1-ERR
# RUN: not llvm-mc %s -triple=mipsel -mcpu=r5900 2>&1 \
# RUN:   | FileCheck %s --check-prefix=R5900-ERR

  ll $2, 0($4)
# CHECK: ll $2, 0($4)    # encoding: [0xc0,0x82,0x00,0x00]
# R5900: ll $2, 0($4)    # encoding: [0x00,0x00,0x82,0xc0]
# MIPS1-ERR: :[[@LINE-3]]:3: error: instruction requires a CPU feature not currently enabled
# R5900-ERR: :[[@LINE-4]]:3: error: instruction requires a CPU feature not currently enabled
  sc $2, 0($4)
# CHECK: sc $2, 0($4)    # encoding: [0xe0,0x82,0x00,0x00]
# R5900: sc $2, 0($4)    # encoding: [0x00,0x00,0x82,0xe0]
# MIPS1-ERR: :[[@LINE-3]]:3: error: instruction requires a CPU feature not currently enabled
# R5900-ERR: :[[@LINE-4]]:3: error: instruction requires a CPU feature not currently enabled
  sync
# CHECK: sync            # encoding: [0x00,0x00,0x00,0x0f]
# R5900: sync            # encoding: [0x0f,0x00,0x00,0x00]
# MIPS1-ERR: :[[@LINE-3]]:3: error: instruction requires a CPU feature not currently enabled
