//===-- NativeRegisterContextOpenBSD_riscv64.h ------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#if defined(__riscv) && __riscv_xlen == 64

#ifndef LLDB_SOURCE_PLUGINS_PROCESS_OPENBSD_NATIVEREGISTERCONTEXTOPENBSD_RISCV64_H
#define LLDB_SOURCE_PLUGINS_PROCESS_OPENBSD_NATIVEREGISTERCONTEXTOPENBSD_RISCV64_H

// clang-format off
#include <sys/types.h>
#include <machine/reg.h>
// clang-format on

#include <optional>

#include "Plugins/Process/OpenBSD/NativeRegisterContextOpenBSD.h"
#include "Register/Common/RegisterInfo_riscv64.h"

namespace lldb_private {
namespace process_openbsd {

class NativeProcessOpenBSD;

class NativeRegisterContextOpenBSD_riscv64
    : public NativeRegisterContextOpenBSD {
public:
  NativeRegisterContextOpenBSD_riscv64(const ArchSpec &target_arch,
                                       NativeThreadProtocol &native_thread);

  uint32_t GetUserRegisterCount() const override;
  uint32_t GetRegisterSetCount() const override;

  const RegisterSet *GetRegisterSet(uint32_t set_index) const override;

  Status ReadRegister(const RegisterInfo *reg_info,
                      RegisterValue &reg_value) override;

  Status WriteRegister(const RegisterInfo *reg_info,
                       const RegisterValue &reg_value) override;

  Status ReadAllRegisterValues(lldb::WritableDataBufferSP &data_sp) override;

  Status WriteAllRegisterValues(const lldb::DataBufferSP &data_sp) override;

private:
  // Private member types.
  enum RegSetKind {
    GPRegSet,
    FPRegSet,
  };

  // Private member variables.
  //
  // OpenBSD's struct reg groups the registers by their ABI names (ra, sp, gp,
  // tp, t0-t6, s0-s11, a0-a7) rather than in x-register order, and has the pc
  // last, so registers are looked up by their number instead of through the
  // register info byte_offset.
  struct reg m_gpr;
  struct fpreg m_fpr;

  std::optional<RegSetKind> GetSetForNativeRegNum(uint32_t reg_num) const;

  Status ReadRegisterSet(RegSetKind set);
  Status WriteRegisterSet(RegSetKind set);

  uint8_t *GetRegisterData(uint32_t reg_num);

  RegisterInfo_riscv64 &GetRegisterInfo() const;
};

} // namespace process_openbsd
} // namespace lldb_private

#endif // LLDB_SOURCE_PLUGINS_PROCESS_OPENBSD_NATIVEREGISTERCONTEXTOPENBSD_RISCV64_H

#endif // defined(__riscv) && __riscv_xlen == 64
