; RUN: split-file %s %t
; RUN: llc -mtriple=mips64el-unknown-linux-gnuabi64 -relocation-model=pic \
; RUN:   -mips-tail-calls=1 < %t/local.ll | FileCheck %s --check-prefix=LOCAL
; RUN: llc -mtriple=mips64el-unknown-linux-gnuabin32 -relocation-model=pic \
; RUN:   -mips-tail-calls=1 < %t/local.ll | FileCheck %s --check-prefix=LOCAL
; RUN: not --crash llc -mtriple=mips64el-unknown-linux-gnuabi64 \
; RUN:   -relocation-model=pic -mips-tail-calls=1 < %t/external.ll 2>&1 \
; RUN:   | FileCheck %s --check-prefix=EXTERNAL
; RUN: not --crash llc -mtriple=mips64el-unknown-linux-gnuabin32 \
; RUN:   -relocation-model=pic -mips-tail-calls=1 < %t/external.ll 2>&1 \
; RUN:   | FileCheck %s --check-prefix=EXTERNAL

; N32 and N64 have $gp callee-saved, so PIC code can only tail call functions
; that bind locally. A lazy binding stub would see the wrong $gp.

; EXTERNAL: LLVM ERROR: failed to perform tail call elimination on a call site marked musttail

;--- local.ll
declare hidden i32 @hidden(i32)

define i32 @test_hidden(i32 %x) {
; LOCAL-LABEL: test_hidden:
; LOCAL-NOT:   jalr
; LOCAL:       jr $25
  %ret = musttail call i32 @hidden(i32 %x)
  ret i32 %ret
}

define internal i32 @internal(i32 %x) {
  ret i32 %x
}

define i32 @test_internal(i32 %x) {
; LOCAL-LABEL: test_internal:
; LOCAL-NOT:   jalr
; LOCAL:       jr $25
  %ret = musttail call i32 @internal(i32 %x)
  ret i32 %ret
}

;--- external.ll
declare i32 @external(i32)

define i32 @test_external(i32 %x) {
  %ret = musttail call i32 @external(i32 %x)
  ret i32 %ret
}
