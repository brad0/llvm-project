// Single-letter extensions in AT_HWCAP use one bit per letter, the same
// encoding on all of the OSes that provide it.
#ifndef HWCAP_ISA_BIT
#define HWCAP_ISA_BIT(c) (1UL << ((c) - 'a'))
#endif
#ifndef HWCAP_ISA_I
#define HWCAP_ISA_I HWCAP_ISA_BIT('i')
#endif
#ifndef HWCAP_ISA_M
#define HWCAP_ISA_M HWCAP_ISA_BIT('m')
#endif
#ifndef HWCAP_ISA_A
#define HWCAP_ISA_A HWCAP_ISA_BIT('a')
#endif
#ifndef HWCAP_ISA_F
#define HWCAP_ISA_F HWCAP_ISA_BIT('f')
#endif
#ifndef HWCAP_ISA_D
#define HWCAP_ISA_D HWCAP_ISA_BIT('d')
#endif
#ifndef HWCAP_ISA_Q
#define HWCAP_ISA_Q HWCAP_ISA_BIT('q')
#endif
#ifndef HWCAP_ISA_C
#define HWCAP_ISA_C HWCAP_ISA_BIT('c')
#endif
#ifndef HWCAP_ISA_B
#define HWCAP_ISA_B HWCAP_ISA_BIT('b')
#endif
#ifndef HWCAP_ISA_V
#define HWCAP_ISA_V HWCAP_ISA_BIT('v')
#endif

static void initRISCVHWCAPFeatures(unsigned long long features[],
                                   unsigned long hwcap, unsigned long hwcap2) {
  SET_SINGLE_RISCV_FEATURE(hwcap & HWCAP_ISA_I, I);
  SET_SINGLE_RISCV_FEATURE(hwcap & HWCAP_ISA_M, M);
  SET_SINGLE_RISCV_FEATURE(hwcap & HWCAP_ISA_A, A);
  SET_SINGLE_RISCV_FEATURE(hwcap & HWCAP_ISA_F, F);
  SET_SINGLE_RISCV_FEATURE(hwcap & HWCAP_ISA_D, D);
  SET_SINGLE_RISCV_FEATURE(hwcap & HWCAP_ISA_Q, Q);
  SET_SINGLE_RISCV_FEATURE(hwcap & HWCAP_ISA_C, C);
  SET_SINGLE_RISCV_FEATURE(hwcap & HWCAP_ISA_B, B);
  SET_SINGLE_RISCV_FEATURE(hwcap & HWCAP_ISA_V, V);

  // Multi-letter extensions are reported in AT_HWCAP2. The bits are not the
  // same between OSes, so only check for the bits the system headers define.
#ifdef HWCAP2_ZBA
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZBA, ZBA);
#endif
#ifdef HWCAP2_ZBB
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZBB, ZBB);
#endif
#ifdef HWCAP2_ZBC
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZBC, ZBC);
#endif
#ifdef HWCAP2_ZBS
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZBS, ZBS);
#endif
#ifdef HWCAP2_ZBKB
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZBKB, ZBKB);
#endif
#ifdef HWCAP2_ZBKC
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZBKC, ZBKC);
#endif
#ifdef HWCAP2_ZBKX
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZBKX, ZBKX);
#endif
#ifdef HWCAP2_ZKND
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZKND, ZKND);
#endif
#ifdef HWCAP2_ZKNE
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZKNE, ZKNE);
#endif
#ifdef HWCAP2_ZKNH
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZKNH, ZKNH);
#endif
#ifdef HWCAP2_ZKSED
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZKSED, ZKSED);
#endif
#ifdef HWCAP2_ZKSH
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZKSH, ZKSH);
#endif
#ifdef HWCAP2_ZKT
  SET_SINGLE_RISCV_FEATURE(hwcap2 & HWCAP2_ZKT, ZKT);
#endif
}
