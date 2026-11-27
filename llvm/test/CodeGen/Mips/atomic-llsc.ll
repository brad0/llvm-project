; RUN: llc -mtriple=mipsel-linux-gnu -mcpu=mips1 -mattr=+llsc < %s \
; RUN:   | FileCheck %s --check-prefixes=LLSC,LLSC32
; RUN: llc -mtriple=mipsel-linux-gnu -mcpu=r5900 -mattr=+llsc < %s \
; RUN:   | FileCheck %s --check-prefixes=LLSC,LLSC32
; RUN: llc -mtriple=mips64el-linux-gnuabi64 -mcpu=r5900 -mattr=+llsc < %s \
; RUN:   | FileCheck %s --check-prefixes=LLSC,R5900-N64
; RUN: llc -mtriple=mipsel-linux-gnu -mcpu=mips32 -mattr=+nollsc < %s \
; RUN:   | FileCheck %s --check-prefix=NOLLSC
; RUN: llc -mtriple=mipsel-linux-gnu -mcpu=mips1 -mattr=+llsc -filetype=obj \
; RUN:   < %s -o /dev/null

; MIPS I and the R5900 have no ll and sc, but with +llsc they are used anyway,
; as when the kernel emulates them. The R5900 has no lld and scd either, so
; 64-bit atomic operations stay libcalls there. With +nollsc, ll, sc and sync
; are not used at all, and as with GCC, fences are only compiler barriers.

define i32 @rmw32(ptr %p, i32 %v) {
; LLSC-LABEL:   rmw32:
; LLSC:           sync
; LLSC:           ll
; LLSC:           sc
; LLSC-NOT:       jal
; NOLLSC-LABEL: rmw32:
; NOLLSC:         jal __atomic_fetch_add_4
  %r = atomicrmw add ptr %p, i32 %v seq_cst
  ret i32 %r
}

define i32 @cas32(ptr %p, i32 %o, i32 %n) {
; LLSC-LABEL:   cas32:
; LLSC:           ll
; LLSC:           sc
; LLSC-NOT:       jal
; NOLLSC-LABEL: cas32:
; NOLLSC:         jal __atomic_compare_exchange_4
  %r = cmpxchg ptr %p, i32 %o, i32 %n seq_cst seq_cst
  %v = extractvalue { i32, i1 } %r, 0
  ret i32 %v
}

define i64 @rmw64(ptr %p, i64 %v) {
; LLSC32-LABEL:    rmw64:
; LLSC32:            jal __atomic_fetch_add_8
; R5900-N64-LABEL: rmw64:
; R5900-N64:         jal __atomic_fetch_add_8
; NOLLSC-LABEL:    rmw64:
; NOLLSC:            jal __atomic_fetch_add_8
  %r = atomicrmw add ptr %p, i64 %v seq_cst
  ret i64 %r
}

define void @fence() {
; LLSC-LABEL:   fence:
; LLSC:           sync
; NOLLSC-LABEL: fence:
; NOLLSC-NOT:     sync
; NOLLSC:         .end fence
  fence seq_cst
  ret void
}
