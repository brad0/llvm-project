// This test uses '<prefix>-SAME: {{^}}' to start matching immediately where the
// previous check finished matching (specifically, caret is not treated as
// matching a start of line when used like this in FileCheck).

// RUN: not %clang_cc1 -triple mips--- -target-cpu not-a-cpu -fsyntax-only %s 2>&1 | FileCheck %s
// CHECK: error: unknown target CPU 'not-a-cpu'
// CHECK-NEXT: note: valid target CPU values are:
// CHECK-SAME: {{^}} mips1
// CHECK-SAME: {{^}}, mips2
// CHECK-SAME: {{^}}, mips3
// CHECK-SAME: {{^}}, mips4
// CHECK-SAME: {{^}}, mips5
// CHECK-SAME: {{^}}, mips32
// CHECK-SAME: {{^}}, mips32r2
// CHECK-SAME: {{^}}, mips32r3
// CHECK-SAME: {{^}}, mips32r5
// CHECK-SAME: {{^}}, mips32r6
// CHECK-SAME: {{^}}, mips64
// CHECK-SAME: {{^}}, mips64r2
// CHECK-SAME: {{^}}, mips64r3
// CHECK-SAME: {{^}}, mips64r5
// CHECK-SAME: {{^}}, mips64r6
// CHECK-SAME: {{^}}, octeon
// CHECK-SAME: {{^}}, octeon+
// CHECK-SAME: {{^}}, p5600
// CHECK-SAME: {{^}}, r5900
// CHECK-SAME: {{^}}, i6400
// CHECK-SAME: {{^}}, i6500
// CHECK-SAME: {{^}}, r2000
// CHECK-SAME: {{^}}, r3000
// CHECK-SAME: {{^}}, r6000
// CHECK-SAME: {{^}}, r4000
// CHECK-SAME: {{^}}, r4400
// CHECK-SAME: {{^}}, r4600
// CHECK-SAME: {{^}}, orion
// CHECK-SAME: {{^}}, r4700
// CHECK-SAME: {{^}}, vr4300
// CHECK-SAME: {{^}}, loongson2e
// CHECK-SAME: {{^}}, loongson2f
// CHECK-SAME: {{^}}, r8000
// CHECK-SAME: {{^}}, r10000
// CHECK-SAME: {{^}}, r12000
// CHECK-SAME: {{^}}, r14000
// CHECK-SAME: {{^}}, r16000
// CHECK-SAME: {{^}}, vr5000
// CHECK-SAME: {{^}}, rm7000
// CHECK-SAME: {{^}}, 24kf2_1
// CHECK-SAME: {{^}}, 24kf
// CHECK-SAME: {{^}}, 24kf1_1
// CHECK-SAME: {{^}}, 24kfx
// CHECK-SAME: {{^}}, 24kx
// CHECK-SAME: {{^}}, 24kef2_1
// CHECK-SAME: {{^}}, 24kef
// CHECK-SAME: {{^}}, 24kef1_1
// CHECK-SAME: {{^}}, 24kefx
// CHECK-SAME: {{^}}, 24kex
// CHECK-SAME: {{^}}, 34kf2_1
// CHECK-SAME: {{^}}, 34kf
// CHECK-SAME: {{^}}, 34kf1_1
// CHECK-SAME: {{^}}, 34kfx
// CHECK-SAME: {{^}}, 34kx
// CHECK-SAME: {{^}}, 1004kf2_1
// CHECK-SAME: {{^}}, 1004kf
// CHECK-SAME: {{^}}, 1004kf1_1
// CHECK-SAME: {{^}}, interaptiv
// CHECK-SAME: {{^}}, 74kf2_1
// CHECK-SAME: {{^}}, 74kf
// CHECK-SAME: {{^}}, 74kf1_1
// CHECK-SAME: {{^}}, 74kfx
// CHECK-SAME: {{^}}, 74kx
// CHECK-SAME: {{^}}, 74kf3_2
// CHECK-SAME: {{^}}, 5kf
// CHECK-SAME: {{^}}, 20kc
// CHECK-SAME: {{^}}, sr71000
// CHECK-SAME: {{^}}, xlp
// CHECK-SAME: {{^}}, p6600
// CHECK-SAME: {{$}}
