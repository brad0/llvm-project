! RUN: not llvm-mc %s -triple=sparc   -show-encoding 2>&1 | FileCheck %s --check-prefix=SPARC32 \
! RUN:   --implicit-check-not=error:
! RUN: llvm-mc %s -triple sparc64 -show-encoding | FileCheck %s --check-prefix=SPARC64
! RUN: llvm-mc %s -triple sparcv9 -show-encoding | FileCheck %s --check-prefix=SPARCV9

        ! SPARC32:       :[[#@LINE+5]]:9: error: unknown directive
        ! SPARC32-NEXT:  .xword 65536
        ! SPARC32-NEXT:  ^

        ! SPARC64:  .xword 65536
        .xword 65536

        ! SPARC32:       :[[#@LINE+2]]:9: error: unknown directive
        ! SPARCV9:  .xword 65536
        .xword 65536
