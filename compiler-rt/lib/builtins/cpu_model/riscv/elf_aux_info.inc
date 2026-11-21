static int initRISCVFeatureBits(unsigned long long features[],
                                void *PlatformArgs) {
  unsigned long hwcap = 0, hwcap2 = 0;

  if (elf_aux_info(AT_HWCAP, &hwcap, sizeof(hwcap)) != 0)
    hwcap = 0;
#ifdef AT_HWCAP2
  if (elf_aux_info(AT_HWCAP2, &hwcap2, sizeof(hwcap2)) != 0)
    hwcap2 = 0;
#endif

  initRISCVHWCAPFeatures(features, hwcap, hwcap2);
  return 0;
}
