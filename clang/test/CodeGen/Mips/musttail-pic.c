// RUN: %clang_cc1 %s -triple mips64el-unknown-linux-gnuabi64 -pic-level 2 \
// RUN:   -fhalf-no-semantic-interposition -o /dev/null -emit-llvm -verify=n64
// RUN: %clang_cc1 %s -triple mipsel-unknown-linux-gnu -pic-level 2 \
// RUN:   -fhalf-no-semantic-interposition -o /dev/null -emit-llvm -verify=o32

// Test musttail behavior in PIC mode with semantic interposition.
// N64 can only tail call functions that bind locally. O32 has no such limit.

// o32-no-diagnostics

int external_defined(int i) { return i; }
static int static_func(int i) { return i; }
__attribute__((visibility("hidden"))) int hidden_defined(int i) { return i; }

int call_external(int i) {
  // n64-error@+1 {{'musttail' attribute for this call is impossible because calls to preemptible functions cannot be tail called in MIPS N32/N64 PIC code}}
  [[clang::musttail]] return external_defined(i);
}

int call_static(int i) {
  [[clang::musttail]] return static_func(i);
}

int call_hidden(int i) {
  [[clang::musttail]] return hidden_defined(i);
}
