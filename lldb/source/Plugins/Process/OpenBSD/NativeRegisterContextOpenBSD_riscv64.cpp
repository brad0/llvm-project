//===-- NativeRegisterContextOpenBSD_riscv64.cpp --------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#if defined(__riscv) && __riscv_xlen == 64

#include "NativeRegisterContextOpenBSD_riscv64.h"

#include "lldb/Utility/DataBufferHeap.h"
#include "lldb/Utility/RegisterValue.h"
#include "lldb/Utility/Status.h"
#include "llvm/Support/ErrorHandling.h"

#include "Plugins/Process/OpenBSD/NativeProcessOpenBSD.h"
#include "Register/Arch/lldb-riscv-register-enums.h"
#include "Register/Common/RegisterInfo_riscv64.h"

// clang-format off
#include <sys/types.h>
#include <sys/ptrace.h>
// clang-format on

#include <cinttypes>
#include <cstring>

using namespace lldb;
using namespace lldb_private;
using namespace lldb_private::process_openbsd;

std::unique_ptr<NativeRegisterContextOpenBSD>
NativeRegisterContextOpenBSD::CreateHostNativeRegisterContextOpenBSD(
    const ArchSpec &target_arch, NativeThreadProtocol &native_thread) {
  return std::make_unique<NativeRegisterContextOpenBSD_riscv64>(target_arch,
                                                                native_thread);
}

static RegisterInfoInterface *
CreateRegisterInfoInterface(const ArchSpec &target_arch) {
  // OpenBSD/riscv64 requires the F and D extensions.
  return new RegisterInfo_riscv64(target_arch,
                                  RegisterInfo_riscv64::eRegsetMaskFP);
}

NativeRegisterContextOpenBSD_riscv64::NativeRegisterContextOpenBSD_riscv64(
    const ArchSpec &target_arch, NativeThreadProtocol &native_thread)
    : NativeRegisterContextOpenBSD(native_thread,
                                   CreateRegisterInfoInterface(target_arch)),
      m_gpr(), m_fpr() {}

RegisterInfo_riscv64 &
NativeRegisterContextOpenBSD_riscv64::GetRegisterInfo() const {
  return static_cast<RegisterInfo_riscv64 &>(*m_register_info_interface_up);
}

uint32_t NativeRegisterContextOpenBSD_riscv64::GetRegisterSetCount() const {
  return GetRegisterInfo().GetRegisterSetCount();
}

const RegisterSet *
NativeRegisterContextOpenBSD_riscv64::GetRegisterSet(uint32_t set_index) const {
  return GetRegisterInfo().GetRegisterSet(set_index);
}

uint32_t NativeRegisterContextOpenBSD_riscv64::GetUserRegisterCount() const {
  uint32_t count = 0;
  for (uint32_t set_index = 0; set_index < GetRegisterSetCount(); ++set_index)
    count += GetRegisterSet(set_index)->num_registers;
  return count;
}

std::optional<NativeRegisterContextOpenBSD_riscv64::RegSetKind>
NativeRegisterContextOpenBSD_riscv64::GetSetForNativeRegNum(
    uint32_t reg_num) const {
  if (GetRegisterInfo().GetRegisterSetFromRegisterIndex(reg_num) ==
      RegisterInfo_riscv64::GPRegSet)
    return GPRegSet;
  if (GetRegisterInfo().IsFPReg(reg_num))
    return FPRegSet;
  return std::nullopt;
}

Status NativeRegisterContextOpenBSD_riscv64::ReadRegisterSet(RegSetKind set) {
  switch (set) {
  case GPRegSet:
    return NativeProcessOpenBSD::PtraceWrapper(PT_GETREGS, m_thread.GetID(),
                                               &m_gpr);
  case FPRegSet:
    return NativeProcessOpenBSD::PtraceWrapper(PT_GETFPREGS, m_thread.GetID(),
                                               &m_fpr);
  }
  llvm_unreachable("NativeRegisterContextOpenBSD_riscv64::ReadRegisterSet");
}

Status NativeRegisterContextOpenBSD_riscv64::WriteRegisterSet(RegSetKind set) {
  switch (set) {
  case GPRegSet:
    return NativeProcessOpenBSD::PtraceWrapper(PT_SETREGS, m_thread.GetID(),
                                               &m_gpr);
  case FPRegSet:
    return NativeProcessOpenBSD::PtraceWrapper(PT_SETFPREGS, m_thread.GetID(),
                                               &m_fpr);
  }
  llvm_unreachable("NativeRegisterContextOpenBSD_riscv64::WriteRegisterSet");
}

// Returns where a register is kept in struct reg or struct fpreg, or nullptr
// for x0, which is not stored since it is always zero.
uint8_t *
NativeRegisterContextOpenBSD_riscv64::GetRegisterData(uint32_t reg_num) {
  uint64_t *data = nullptr;

  if (reg_num == gpr_pc_riscv)
    data = &m_gpr.r_sepc;
  else if (reg_num == gpr_ra_riscv)
    data = &m_gpr.r_ra;
  else if (reg_num == gpr_sp_riscv)
    data = &m_gpr.r_sp;
  else if (reg_num == gpr_gp_riscv)
    data = &m_gpr.r_gp;
  else if (reg_num == gpr_tp_riscv)
    data = &m_gpr.r_tp;
  else if (reg_num >= gpr_t0_riscv && reg_num <= gpr_t2_riscv)
    data = &m_gpr.r_t[reg_num - gpr_t0_riscv];
  else if (reg_num >= gpr_fp_riscv && reg_num <= gpr_s1_riscv)
    data = &m_gpr.r_s[reg_num - gpr_fp_riscv];
  else if (reg_num >= gpr_a0_riscv && reg_num <= gpr_a7_riscv)
    data = &m_gpr.r_a[reg_num - gpr_a0_riscv];
  else if (reg_num >= gpr_s2_riscv && reg_num <= gpr_s11_riscv)
    data = &m_gpr.r_s[2 + reg_num - gpr_s2_riscv];
  else if (reg_num >= gpr_t3_riscv && reg_num <= gpr_t6_riscv)
    data = &m_gpr.r_t[3 + reg_num - gpr_t3_riscv];
  else if (reg_num >= fpr_f0_riscv && reg_num <= fpr_f31_riscv)
    data = &m_fpr.fp_f[reg_num - fpr_f0_riscv];
  else if (reg_num == fpr_fcsr_riscv)
    // fcsr is 32 bits, the low half of fp_fcsr.
    data = &m_fpr.fp_fcsr;

  return reinterpret_cast<uint8_t *>(data);
}

Status
NativeRegisterContextOpenBSD_riscv64::ReadRegister(const RegisterInfo *reg_info,
                                                   RegisterValue &reg_value) {
  if (!reg_info)
    return Status::FromErrorString("reg_info NULL");

  const uint32_t reg = reg_info->kinds[lldb::eRegisterKindLLDB];
  if (reg == LLDB_INVALID_REGNUM)
    return Status::FromErrorStringWithFormat(
        "no lldb regnum for %s",
        reg_info->name ? reg_info->name : "<unknown register>");

  if (reg == gpr_x0_riscv) {
    reg_value.SetUInt(0, reg_info->byte_size);
    return Status();
  }

  std::optional<RegSetKind> set = GetSetForNativeRegNum(reg);
  uint8_t *data = GetRegisterData(reg);
  if (!set || !data)
    return Status::FromErrorStringWithFormat(
        "register \"%s\" is in unrecognized set", reg_info->name);

  Status error = ReadRegisterSet(*set);
  if (error.Fail())
    return error;

  reg_value.SetBytes(data, reg_info->byte_size, endian::InlHostByteOrder());
  return error;
}

Status NativeRegisterContextOpenBSD_riscv64::WriteRegister(
    const RegisterInfo *reg_info, const RegisterValue &reg_value) {
  if (!reg_info)
    return Status::FromErrorString("reg_info NULL");

  const uint32_t reg = reg_info->kinds[lldb::eRegisterKindLLDB];
  if (reg == LLDB_INVALID_REGNUM)
    return Status::FromErrorStringWithFormat(
        "no lldb regnum for %s",
        reg_info->name ? reg_info->name : "<unknown register>");

  // Writes to x0 are discarded, as on the hardware.
  if (reg == gpr_x0_riscv)
    return Status();

  std::optional<RegSetKind> set = GetSetForNativeRegNum(reg);
  uint8_t *data = GetRegisterData(reg);
  if (!set || !data)
    return Status::FromErrorStringWithFormat(
        "register \"%s\" is in unrecognized set", reg_info->name);

  Status error = ReadRegisterSet(*set);
  if (error.Fail())
    return error;

  if (reg_value.GetByteSize() < reg_info->byte_size)
    return Status::FromErrorStringWithFormat(
        "value for register \"%s\" is too short", reg_info->name);

  ::memcpy(data, reg_value.GetBytes(), reg_info->byte_size);

  return WriteRegisterSet(*set);
}

Status NativeRegisterContextOpenBSD_riscv64::ReadAllRegisterValues(
    lldb::WritableDataBufferSP &data_sp) {
  Status error = ReadRegisterSet(GPRegSet);
  if (error.Fail())
    return error;

  error = ReadRegisterSet(FPRegSet);
  if (error.Fail())
    return error;

  data_sp.reset(new DataBufferHeap(sizeof(m_gpr) + sizeof(m_fpr), 0));
  uint8_t *dst = data_sp->GetBytes();
  ::memcpy(dst, &m_gpr, sizeof(m_gpr));
  ::memcpy(dst + sizeof(m_gpr), &m_fpr, sizeof(m_fpr));

  return error;
}

Status NativeRegisterContextOpenBSD_riscv64::WriteAllRegisterValues(
    const lldb::DataBufferSP &data_sp) {
  if (!data_sp)
    return Status::FromErrorStringWithFormat(
        "NativeRegisterContextOpenBSD_riscv64::%s invalid data_sp provided",
        __FUNCTION__);

  const size_t size = sizeof(m_gpr) + sizeof(m_fpr);
  if (data_sp->GetByteSize() != size)
    return Status::FromErrorStringWithFormat(
        "NativeRegisterContextOpenBSD_riscv64::%s data_sp contained "
        "mismatched data size, expected %zu, actual %" PRIu64,
        __FUNCTION__, size, data_sp->GetByteSize());

  const uint8_t *src = data_sp->GetBytes();
  if (src == nullptr)
    return Status::FromErrorStringWithFormat(
        "NativeRegisterContextOpenBSD_riscv64::%s "
        "DataBuffer::GetBytes() returned a null pointer",
        __FUNCTION__);

  ::memcpy(&m_gpr, src, sizeof(m_gpr));
  ::memcpy(&m_fpr, src + sizeof(m_gpr), sizeof(m_fpr));

  Status error = WriteRegisterSet(GPRegSet);
  if (error.Fail())
    return error;

  return WriteRegisterSet(FPRegSet);
}

#endif // defined(__riscv) && __riscv_xlen == 64
