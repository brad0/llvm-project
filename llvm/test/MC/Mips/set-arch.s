# RUN: llvm-mc %s -triple=mipsel-unknown-linux -show-encoding -mcpu=mips32 | \
# RUN:   FileCheck %s

    .text
    .set arch=mips1
    add         $2, $2, $2
    .set arch=mips2
    ll          $2, -2($2)
    .set arch=mips3
    dadd        $2, $2, $2
    .set arch=mips4
    ldxc1       $f8, $2($4)
    .set arch=mips5
    luxc1       $f19, $2($4)
    .set arch=mips32
    clo         $2, $2
    .set arch=mips32r2
    rotr        $2, $2, 15
    .set arch=mips32
    .set arch=mips32r3
    rotr        $2, $2, 15
    .set arch=mips32
    .set arch=mips32r5
    rotr        $2, $2, 15
    .set arch=mips32r6
    mod         $2, $4, $6
    .set arch=mips64
    daddi       $2, $2, 10
    .set arch=mips64r2
    drotr32     $1, $14, 15
    .set arch=mips64
    .set arch=mips64r3
    drotr32     $1, $14, 15
    .set arch=mips64
    .set arch=mips64r5
    drotr32     $1, $14, 15
    .set arch=mips64r6
    mod         $2, $4, $6
    .set arch=octeon
    baddu $9, $6, $7
    .set arch=octeon+
    saa         $2, ($5)
    .set arch=r2000
    add         $2, $2, $2
    .set arch=r3000
    add         $2, $2, $2
    .set arch=r6000
    ll          $2, -2($2)
    .set arch=r4000
    dadd        $2, $2, $2
    .set arch=r4400
    dadd        $2, $2, $2
    .set arch=r4600
    dadd        $2, $2, $2
    .set arch=orion
    dadd        $2, $2, $2
    .set arch=r4700
    dadd        $2, $2, $2
    .set arch=vr4300
    dadd        $2, $2, $2
    .set arch=loongson2e
    dadd        $2, $2, $2
    .set arch=loongson2f
    dadd        $2, $2, $2

# CHECK: .set arch=mips1
# CHECK: add         $2, $2, $2
# CHECK: .set arch=mips2
# CHECK: ll          $2, -2($2)
# CHECK: .set arch=mips3
# CHECK: dadd        $2, $2, $2
# CHECK: .set arch=mips4
# CHECK: ldxc1       $f8, $2($4)
# CHECK: .set arch=mips5
# CHECK: luxc1       $f19, $2($4)
# CHECK: .set arch=mips32
# CHECK: clo         $2, $2
# CHECK: .set arch=mips32r2
# CHECK: rotr        $2, $2, 15
# CHECK: .set arch=mips32r6
# CHECK: mod         $2, $4, $6
# CHECK: .set arch=mips64
# CHECK: daddi       $2, $2, 10
# CHECK: .set arch=mips64r2
# CHECK: drotr32     $1, $14, 15
# CHECK: .set arch=mips64r6
# CHECK: mod         $2, $4, $6
# CHECK: .set arch=octeon
# CHECK: baddu $9, $6, $7
# CHECK: .set arch=octeon+
# CHECK: saa         $2, ($5)
# CHECK: .set arch=r2000
# CHECK: add         $2, $2, $2
# CHECK: .set arch=r3000
# CHECK: add         $2, $2, $2
# CHECK: .set arch=r6000
# CHECK: ll          $2, -2($2)
# CHECK: .set arch=r4000
# CHECK: dadd        $2, $2, $2
# CHECK: .set arch=r4400
# CHECK: dadd        $2, $2, $2
# CHECK: .set arch=r4600
# CHECK: dadd        $2, $2, $2
# CHECK: .set arch=orion
# CHECK: dadd        $2, $2, $2
# CHECK: .set arch=r4700
# CHECK: dadd        $2, $2, $2
# CHECK: .set arch=vr4300
# CHECK: dadd        $2, $2, $2
# CHECK: .set arch=loongson2e
# CHECK: dadd        $2, $2, $2
# CHECK: .set arch=loongson2f
# CHECK: dadd        $2, $2, $2
