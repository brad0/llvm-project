//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// Check that the register infos used by NativeProcessOpenBSD match the layout
// of the structures that OpenBSD's ptrace(2) returns, since the register
// contexts access registers by their byte_offset into those structures.

// clang-format off
#include <sys/types.h>
#include <machine/reg.h>
// clang-format on

#include "gmock/gmock.h"
#include "gtest/gtest.h"

#include "Register/Arch/lldb-x86-register-enums.h"
#include "Register/OpenBSD/RegisterInfoOpenBSD_x86_64.h"

#include <cstddef>

using namespace lldb;
using namespace lldb_private;

static std::pair<size_t, size_t> GetRegParams(RegisterInfoInterface &ctx,
                                              uint32_t reg) {
  const RegisterInfo &info = ctx.GetRegisterInfo()[reg];
  return {info.byte_offset, info.byte_size};
}

#define EXPECT_REG(reg, offset, size)                                          \
  EXPECT_THAT(GetRegParams(reg_ctx, reg), ::testing::Pair(offset, size))

#if defined(__x86_64__)

#define EXPECT_GPR_X86_64(regname)                                             \
  EXPECT_REG(lldb_##regname##_x86_64, offsetof(reg, r_##regname),              \
             sizeof(reg::r_##regname))
#define EXPECT_FPR_X86_64(regname, offset, size)                               \
  EXPECT_REG(lldb_##regname##_x86_64, base_offset + (offset), size)

TEST(RegisterInfoOpenBSDTest, x86_64) {
  ArchSpec arch{"x86_64-unknown-openbsd"};
  RegisterInfoOpenBSD_x86_64 reg_ctx{arch};

  EXPECT_EQ(reg_ctx.GetGPRSize(), sizeof(reg));

  EXPECT_GPR_X86_64(rdi);
  EXPECT_GPR_X86_64(rsi);
  EXPECT_GPR_X86_64(rdx);
  EXPECT_GPR_X86_64(rcx);
  EXPECT_GPR_X86_64(r8);
  EXPECT_GPR_X86_64(r9);
  EXPECT_GPR_X86_64(r10);
  EXPECT_GPR_X86_64(r11);
  EXPECT_GPR_X86_64(r12);
  EXPECT_GPR_X86_64(r13);
  EXPECT_GPR_X86_64(r14);
  EXPECT_GPR_X86_64(r15);
  EXPECT_GPR_X86_64(rbp);
  EXPECT_GPR_X86_64(rbx);
  EXPECT_GPR_X86_64(rax);
  EXPECT_GPR_X86_64(rsp);
  EXPECT_GPR_X86_64(rip);
  EXPECT_GPR_X86_64(rflags);
  EXPECT_GPR_X86_64(cs);
  EXPECT_GPR_X86_64(ss);
  EXPECT_GPR_X86_64(ds);
  EXPECT_GPR_X86_64(es);
  EXPECT_GPR_X86_64(fs);
  EXPECT_GPR_X86_64(gs);

  // struct fpreg is the FXSAVE area. fctrl is its first field and gives the
  // offset of the whole area.
  EXPECT_EQ(sizeof(fpreg), 512u);
  size_t base_offset = reg_ctx.GetRegisterInfo()[lldb_fctrl_x86_64].byte_offset;

  EXPECT_FPR_X86_64(fctrl, offsetof(fxsave64, fx_fcw), 2);
  EXPECT_FPR_X86_64(fstat, offsetof(fxsave64, fx_fsw), 2);
  // TODO: This is a known bug, the abridged ftag is 8 bits in length.
  EXPECT_FPR_X86_64(ftag, offsetof(fxsave64, fx_ftw), 2);
  EXPECT_FPR_X86_64(fop, offsetof(fxsave64, fx_fop), 2);
  // fioff/fiseg and fooff/foseg are the two halves of FIP and FDP.
  EXPECT_FPR_X86_64(fioff, offsetof(fxsave64, fx_rip), 4);
  EXPECT_FPR_X86_64(fiseg, offsetof(fxsave64, fx_rip) + 4, 4);
  EXPECT_FPR_X86_64(fip, offsetof(fxsave64, fx_rip), 8);
  EXPECT_FPR_X86_64(fooff, offsetof(fxsave64, fx_rdp), 4);
  EXPECT_FPR_X86_64(foseg, offsetof(fxsave64, fx_rdp) + 4, 4);
  EXPECT_FPR_X86_64(fdp, offsetof(fxsave64, fx_rdp), 8);
  EXPECT_FPR_X86_64(mxcsr, offsetof(fxsave64, fx_mxcsr), 4);
  EXPECT_FPR_X86_64(mxcsrmask, offsetof(fxsave64, fx_mxcsr_mask), 4);

  for (uint32_t i = 0; i < 8; ++i) {
    const size_t st =
        offsetof(fxsave64, fx_st) + i * sizeof(fxsave64::fx_st[0]);
    EXPECT_REG(lldb_st0_x86_64 + i, base_offset + st, 10u) << "st" << i;
    EXPECT_REG(lldb_mm0_x86_64 + i, base_offset + st, 8u) << "mm" << i;
  }
  for (uint32_t i = 0; i < 16; ++i)
    EXPECT_REG(lldb_xmm0_x86_64 + i,
               base_offset + offsetof(fxsave64, fx_xmm) +
                   i * sizeof(fxsave64::fx_xmm[0]),
               sizeof(fxsave64::fx_xmm[0]))
        << "xmm" << i;
}

#endif // defined(__x86_64__)
