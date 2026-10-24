//===-- NativeRegisterContextOpenBSD_x86_64.h -------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLDB_SOURCE_PLUGINS_PROCESS_OPENBSD_NATIVEREGISTERCONTEXTOPENBSD_X86_64_H
#define LLDB_SOURCE_PLUGINS_PROCESS_OPENBSD_NATIVEREGISTERCONTEXTOPENBSD_X86_64_H

// clang-format off
#include <sys/types.h>
#include <machine/reg.h>
// clang-format on

#include <array>
#include <vector>

#include "Plugins/Process/OpenBSD/NativeRegisterContextOpenBSD.h"
#include "Register/Arch/RegisterContext_x86.h"
#include "Register/Arch/lldb-x86-register-enums.h"

namespace lldb_private {
namespace process_openbsd {

class NativeProcessOpenBSD;

class NativeRegisterContextOpenBSD_x86_64
    : public NativeRegisterContextOpenBSD {
public:
  NativeRegisterContextOpenBSD_x86_64(const ArchSpec &target_arch,
                                      NativeThreadProtocol &native_thread);
  size_t GetGPRSize() override { return sizeof(m_gpr); }
  size_t GetFPRSize() override { return sizeof(m_fpr); }

  uint32_t GetUserRegisterCount() const override;
  uint32_t GetRegisterSetCount() const override;

  const RegisterSet *GetRegisterSet(uint32_t set_index) const override;

  Status ReadRegister(const RegisterInfo *reg_info,
                      RegisterValue &reg_value) override;

  Status WriteRegister(const RegisterInfo *reg_info,
                       const RegisterValue &reg_value) override;

  Status ReadAllRegisterValues(lldb::WritableDataBufferSP &data_sp) override;

  Status WriteAllRegisterValues(const lldb::DataBufferSP &data_sp) override;

protected:
  void *GetGPRBuffer() override { return &m_gpr; }
  void *GetFPRBuffer() override { return &m_fpr; }

private:
  // Private member types.
  enum {
    GPRegSet,
    FPRegSet,
    YMMRegSet,
    MaxRegSet = YMMRegSet,
  };

  // Private member variables.
  struct reg m_gpr;
  struct fpreg m_fpr;
  std::vector<uint8_t> m_xsave;
  std::array<uint32_t, MaxRegSet + 1> m_xsave_offsets;

  int GetSetForNativeRegNum(int reg_num) const;

  int ReadRegisterSet(uint32_t set);
  int WriteRegisterSet(uint32_t set);

  struct YMMSplitPtr {
    void *xmm;
    void *ymm_hi;
  };
  std::optional<YMMSplitPtr> GetYMMSplitReg(uint32_t reg);
};

} // namespace process_openbsd
} // namespace lldb_private

#endif // LLDB_SOURCE_PLUGINS_PROCESS_OPENBSD_NATIVEREGISTERCONTEXTOPENBSD_X86_64_H
