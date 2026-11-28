// Check passing Mips ABI options to the backend.
//
// RUN: %clang --target=mips-linux-gnu -### -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS32R2-O32 %s
// RUN: %clang --target=mips64-linux-gnu -mips32r2 -mabi=32 -### -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS32R2-O32 %s
// MIPS32R2-O32: "-target-cpu" "mips32r2"
// MIPS32R2-O32: "-target-abi" "o32"
//
// RUN: %clang --target=mips64-linux-gnu -### -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS64R2-N64 %s
// RUN: %clang --target=mips-img-linux-gnu -mips64r2 -### -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS64R2-N64 %s
// RUN: %clang --target=mips-mti-linux-gnu -mips64r2 -### -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS64R2-N64 %s
// RUN: %clang --target=mips-linux-gnu -mips64r2 -mabi=64 -### -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS64R2-N64 %s
// MIPS64R2-N64: "-target-cpu" "mips64r2"
// MIPS64R2-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips64-linux-gnu -### -mips64r3 -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS64R3-N64 %s
// RUN: %clang --target=mips-img-linux-gnu -mips64r3 -### -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS64R3-N64 %s
// RUN: %clang --target=mips-mti-linux-gnu -mips64r3 -### -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS64R3-N64 %s
// MIPS64R3-N64: "-target-cpu" "mips64r3"
// MIPS64R3-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -mabi=32 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ABI-32 %s
// MIPS-ABI-32: "-target-cpu" "mips32r2"
// MIPS-ABI-32: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -mabi=o32 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ABI-O32 %s
// MIPS-ABI-O32: "-target-cpu" "mips32r2"
// MIPS-ABI-O32: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -mabi=n32 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ABI-N32 %s
// MIPS-ABI-N32: "-target-cpu" "mips64r2"
// MIPS-ABI-N32: "-target-abi" "n32"
//
// RUN: %clang --target=mips64-linux-gnu -### -c %s \
// RUN:        -mabi=64 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ABI-64 %s
// MIPS-ABI-64: "-target-cpu" "mips64r2"
// MIPS-ABI-64: "-target-abi" "n64"
//
// RUN: %clang --target=mips64-linux-gnu -### -c %s \
// RUN:        -mabi=n64 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ABI-N64 %s
// MIPS-ABI-N64: "-target-cpu" "mips64r2"
// MIPS-ABI-N64: "-target-abi" "n64"
//
// RUN: not %clang --target=mips64-linux-gnu -c %s \
// RUN:        -mabi=o64 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ABI-O64 %s
// MIPS-ABI-O64: error: unknown target ABI 'o64'
//
// RUN: not %clang --target=mips-linux-gnu -c %s \
// RUN:        -mabi=unknown 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ABI-UNKNOWN %s
// MIPS-ABI-UNKNOWN: error: unknown target ABI 'unknown'
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=mips1 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-1 %s
// MIPS-ARCH-1: "-target-cpu" "mips1"
// MIPS-ARCH-1: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=mips2 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-2 %s
// MIPS-ARCH-2: "-target-cpu" "mips2"
// MIPS-ARCH-2: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=r2000 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R2000 %s
// MIPS-ARCH-R2000: "-target-cpu" "r2000"
// MIPS-ARCH-R2000-NOT: "+fpxx"
// MIPS-ARCH-R2000: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=r3000 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R3000 %s
// MIPS-ARCH-R3000: "-target-cpu" "r3000"
// MIPS-ARCH-R3000-NOT: "+fpxx"
// MIPS-ARCH-R3000: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=r6000 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R6000 %s
// MIPS-ARCH-R6000: "-target-cpu" "r6000"
// MIPS-ARCH-R6000: "-target-feature" "+fpxx"
// MIPS-ARCH-R6000: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=mips3 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-3 %s
// MIPS-ARCH-3: "-target-cpu" "mips3"
// MIPS-ARCH-3: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=r4000 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R4000 %s
// MIPS-ARCH-R4000: "-target-cpu" "r4000"
// MIPS-ARCH-R4000: "-target-feature" "+fpxx"
// MIPS-ARCH-R4000: "-target-abi" "o32"
// RUN: %clang --target=mips64-linux-gnuabi64 -### -c %s \
// RUN:        -march=r4000 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R4000-N64 %s
// MIPS-ARCH-R4000-N64: "-target-cpu" "r4000"
// MIPS-ARCH-R4000-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=r4400 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R4400 %s
// MIPS-ARCH-R4400: "-target-cpu" "r4400"
// MIPS-ARCH-R4400: "-target-feature" "+fpxx"
// MIPS-ARCH-R4400: "-target-abi" "o32"
// RUN: %clang --target=mips64-linux-gnuabi64 -### -c %s \
// RUN:        -march=r4400 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R4400-N64 %s
// MIPS-ARCH-R4400-N64: "-target-cpu" "r4400"
// MIPS-ARCH-R4400-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=r4600 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R4600 %s
// MIPS-ARCH-R4600: "-target-cpu" "r4600"
// MIPS-ARCH-R4600: "-target-feature" "+fpxx"
// MIPS-ARCH-R4600: "-target-abi" "o32"
// RUN: %clang --target=mips64-linux-gnuabi64 -### -c %s \
// RUN:        -march=r4600 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R4600-N64 %s
// MIPS-ARCH-R4600-N64: "-target-cpu" "r4600"
// MIPS-ARCH-R4600-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=orion 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-ORION %s
// MIPS-ARCH-ORION: "-target-cpu" "orion"
// MIPS-ARCH-ORION: "-target-feature" "+fpxx"
// MIPS-ARCH-ORION: "-target-abi" "o32"
// RUN: %clang --target=mips64-linux-gnuabi64 -### -c %s \
// RUN:        -march=orion 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-ORION-N64 %s
// MIPS-ARCH-ORION-N64: "-target-cpu" "orion"
// MIPS-ARCH-ORION-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=r4700 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R4700 %s
// MIPS-ARCH-R4700: "-target-cpu" "r4700"
// MIPS-ARCH-R4700: "-target-feature" "+fpxx"
// MIPS-ARCH-R4700: "-target-abi" "o32"
// RUN: %clang --target=mips64-linux-gnuabi64 -### -c %s \
// RUN:        -march=r4700 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R4700-N64 %s
// MIPS-ARCH-R4700-N64: "-target-cpu" "r4700"
// MIPS-ARCH-R4700-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=vr4300 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-VR4300 %s
// MIPS-ARCH-VR4300: "-target-cpu" "vr4300"
// MIPS-ARCH-VR4300: "-target-feature" "+fpxx"
// MIPS-ARCH-VR4300: "-target-abi" "o32"
// RUN: %clang --target=mips64-linux-gnuabi64 -### -c %s \
// RUN:        -march=vr4300 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-VR4300-N64 %s
// MIPS-ARCH-VR4300-N64: "-target-cpu" "vr4300"
// MIPS-ARCH-VR4300-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=loongson2e 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-LOONGSON2E %s
// MIPS-ARCH-LOONGSON2E: "-target-cpu" "loongson2e"
// MIPS-ARCH-LOONGSON2E: "-target-feature" "+fpxx"
// MIPS-ARCH-LOONGSON2E: "-target-abi" "o32"
// RUN: %clang --target=mips64-linux-gnuabi64 -### -c %s \
// RUN:        -march=loongson2e 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-LOONGSON2E-N64 %s
// MIPS-ARCH-LOONGSON2E-N64: "-target-cpu" "loongson2e"
// MIPS-ARCH-LOONGSON2E-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=loongson2f 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-LOONGSON2F %s
// MIPS-ARCH-LOONGSON2F: "-target-cpu" "loongson2f"
// MIPS-ARCH-LOONGSON2F: "-target-feature" "+fpxx"
// MIPS-ARCH-LOONGSON2F: "-target-abi" "o32"
// RUN: %clang --target=mips64-linux-gnuabi64 -### -c %s \
// RUN:        -march=loongson2f 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-LOONGSON2F-N64 %s
// MIPS-ARCH-LOONGSON2F-N64: "-target-cpu" "loongson2f"
// MIPS-ARCH-LOONGSON2F-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=mips4 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-4 %s
// MIPS-ARCH-4: "-target-cpu" "mips4"
// MIPS-ARCH-4: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=r10000 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R10000 %s
// MIPS-ARCH-R10000: "-target-cpu" "r10000"
// MIPS-ARCH-R10000: "-target-feature" "+fpxx"
// MIPS-ARCH-R10000: "-target-abi" "o32"
//
// RUN: %clang --target=mips64-linux-gnuabi64 -### -c %s \
// RUN:        -march=r10000 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-R10000-N64 %s
// MIPS-ARCH-R10000-N64: "-target-cpu" "r10000"
// MIPS-ARCH-R10000-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=74kf 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-74KF %s
// MIPS-ARCH-74KF: "-target-cpu" "74kf"
// MIPS-ARCH-74KF: "-target-feature" "+fpxx"
// MIPS-ARCH-74KF: "-target-abi" "o32"
//
// RUN: %clang --target=mips64-linux-gnuabi64 -### -c %s \
// RUN:        -march=5kf 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-5KF %s
// MIPS-ARCH-5KF: "-target-cpu" "5kf"
// MIPS-ARCH-5KF: "-target-abi" "n64"
//
// RUN: %clang --target=mips64-linux-gnuabi64 -### -c %s \
// RUN:        -march=p6600 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-P6600 %s
// MIPS-ARCH-P6600: "-target-cpu" "p6600"
// MIPS-ARCH-P6600: "-target-abi" "n64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=mips5 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-5 %s
// MIPS-ARCH-5: "-target-cpu" "mips5"
// MIPS-ARCH-5: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=mips32 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-32 %s
// MIPS-ARCH-32: "-target-cpu" "mips32"
// MIPS-ARCH-32: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=mips32r2 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-32R2 %s
// MIPS-ARCH-32R2: "-target-cpu" "mips32r2"
// MIPS-ARCH-32R2: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=p5600 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-P5600 %s
// MIPS-ARCH-P5600: "-target-cpu" "p5600"
// MIPS-ARCH-P5600: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=p5600 -mmsa -mnan=2008 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-P5600-MSA %s
// MIPS-ARCH-P5600-MSA: "-target-cpu" "p5600"
// MIPS-ARCH-P5600-MSA: "-target-feature" "+msa"
// MIPS-ARCH-P5600-MSA: "-target-feature" "+fp64"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=p5600 -mmsa -mnan=2008 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-P5600-NAN2008 %s
// MIPS-ARCH-P5600-NAN2008: "-target-cpu" "p5600"
// MIPS-ARCH-P5600-NAN2008: "-target-feature" "+nan2008"
// MIPS-ARCH-P5600-NAN2008: "-target-feature" "+abs2008"
//
// RUN: not %clang --target=mips-linux-gnu -c %s \
// RUN:        -march=p5600 -mabi=64 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-P5600-N64 %s
// MIPS-ARCH-P5600-N64: error: ABI 'n64' is not supported on CPU 'p5600'
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=i6400 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-I6400 %s
// MIPS-ARCH-I6400: "-target-cpu" "i6400"
// MIPS-ARCH-I6400: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=i6400 -mabi=64 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-I6400-N64 %s
// MIPS-ARCH-I6400-N64: "-target-cpu" "i6400"
// MIPS-ARCH-I6400-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips64-linux-gnu -### -c %s \
// RUN:        -march=i6400 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS64-ARCH-I6400 %s
// MIPS64-ARCH-I6400: "-target-cpu" "i6400"
// MIPS64-ARCH-I6400: "-target-abi" "n64"
//
// RUN: %clang --target=mips64-linux-gnu -### -c %s \
// RUN:        -march=i6400 -mabi=32 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS64-ARCH-I6400-O32 %s
// MIPS64-ARCH-I6400-O32: "-target-cpu" "i6400"
// MIPS64-ARCH-I6400-O32: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=i6500 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-I6500 %s
// MIPS-ARCH-I6500: "-target-cpu" "i6500"
// MIPS-ARCH-I6500: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=i6500 -mabi=64 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-I6500-N64 %s
// MIPS-ARCH-I6500-N64: "-target-cpu" "i6500"
// MIPS-ARCH-I6500-N64: "-target-abi" "n64"
//
// RUN: %clang --target=mips64-linux-gnu -### -c %s \
// RUN:        -march=i6500 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS64-ARCH-I6500 %s
// MIPS64-ARCH-I6500: "-target-cpu" "i6500"
// MIPS64-ARCH-I6500: "-target-abi" "n64"
//
// RUN: %clang --target=mips64-linux-gnu -### -c %s \
// RUN:        -march=i6500 -mabi=32 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS64-ARCH-I6500-O32 %s
// MIPS64-ARCH-I6500-O32: "-target-cpu" "i6500"
// MIPS54-ARCH-I6500-O32: "-target-abi" "o32"
//
// RUN: %clang --target=mips-linux-gnu -### -c %s \
// RUN:        -march=mips64 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-3264 %s
// MIPS-ARCH-3264: "-target-cpu" "mips64"
// MIPS-ARCH-3264: "-target-abi" "o32"
//
// RUN: %clang --target=mips64-linux-gnu -### -c %s \
// RUN:        -march=mips64 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-64 %s
// MIPS-ARCH-64: "-target-cpu" "mips64"
// MIPS-ARCH-64: "-target-abi" "n64"
//
// RUN: %clang --target=mips64-linux-gnu -### -c %s \
// RUN:        -march=mips64r2 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-64R2 %s
// MIPS-ARCH-64R2: "-target-cpu" "mips64r2"
// MIPS-ARCH-64R2: "-target-abi" "n64"
//
// RUN: %clang --target=mips64-linux-gnu -### -c %s \
// RUN:        -march=octeon 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-OCTEON %s
// MIPS-ARCH-OCTEON: "-target-cpu" "octeon"
// MIPS-ARCH-OCTEON: "-target-abi" "n64"
//
// RUN: %clang --target=mips64-linux-gnu -### -c %s \
// RUN:        -march=octeon+ 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-OCTEONP %s
// MIPS-ARCH-OCTEONP: "-target-cpu" "octeon+"
// MIPS-ARCH-OCTEONP: "-target-abi" "n64"
//
// RUN: not %clang --target=mips64-linux-gnu -c %s \
// RUN:        -march=mips32 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-6432 %s
// MIPS-ARCH-6432: error: ABI 'n64' is not supported on CPU 'mips32'
//
// RUN: not %clang --target=mips-linux-gnu -c %s \
// RUN:        -march=unknown 2>&1 \
// RUN:   | FileCheck -check-prefix=MIPS-ARCH-UNKNOWN %s
// MIPS-ARCH-UNKNOWN: error: unknown target CPU 'unknown'

// Check adjusting of target triple accordingly to `-mabi` option.
// RUN: %clang --target=mips64-linux-gnuabi64 -mabi=32 -### %s 2>&1 \
// RUN:   | FileCheck -check-prefix=TARGET-O32 %s
// TARGET-O32: "-triple" "mips-unknown-linux-gnu"
// TARGET-O32: "-target-cpu" "mips32r2"
// TARGET-O32: "-target-abi" "o32"
// TARGET-O32: ld{{(.exe)?}}"
// TARGET-O32: "-m" "elf32btsmip"

// RUN: %clang --target=mips-linux-gnu -mabi=n32 -### %s 2>&1 \
// RUN:   | FileCheck -check-prefix=TARGET-N32 %s
// TARGET-N32: "-triple" "mips64-unknown-linux-gnuabin32"
// TARGET-N32: "-target-cpu" "mips64r2"
// TARGET-N32: "-target-abi" "n32"
// TARGET-N32: ld{{(.exe)?}}"
// TARGET-N32: "-m" "elf32btsmipn32"

// RUN: %clang --target=mips-linux-gnu -mabi=64 -### %s 2>&1 \
// RUN:   | FileCheck -check-prefix=TARGET-N64 %s
// TARGET-N64: "-triple" "mips64-unknown-linux-gnuabi64"
// TARGET-N64: "-target-cpu" "mips64r2"
// TARGET-N64: "-target-abi" "n64"
// TARGET-N64: ld{{(.exe)?}}"
// TARGET-N64: "-m" "elf64btsmip"
