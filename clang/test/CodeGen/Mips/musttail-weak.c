// RUN: %clang_cc1 %s -triple mips64el-unknown-linux-gnuabi64 -o /dev/null \
// RUN:   -emit-llvm -verify=n64
// RUN: %clang_cc1 %s -triple mipsel-unknown-linux-gnu -o /dev/null \
// RUN:   -emit-llvm -verify=o32

// Test musttail with weak functions.
// Weak functions can be interposed, so they are not considered DSO-local.
// That only matters for N32/N64 PIC code.

// o32-no-diagnostics

__attribute__((weak)) int weak_func(int i) {
  return i;
}

int caller(int i) {
  // n64-error@+1 {{'musttail' attribute for this call is impossible because calls to preemptible functions cannot be tail called in MIPS N32/N64 PIC code}}
  [[clang::musttail]] return weak_func(i);
}
