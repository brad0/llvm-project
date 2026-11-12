//===- SPIRVTargetTransformInfo.cpp - SPIR-V specific TTI -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "SPIRVTargetTransformInfo.h"
#include "SPIRVSubtarget.h"
#include "llvm/IR/IntrinsicsSPIRV.h"

using namespace llvm;

InstructionCost
llvm::SPIRVTTIImpl::getIntrinsicInstrCost(const IntrinsicCostAttributes &ICA,
                                          TTI::TargetCostKind CostKind) const {
  // SPIR-V natively supports OpBitCount, per 3.53.14 in the spec, as such it
  // is reasonable to assume the Op is fast / preferable to the expanded loop.
  // Furthermore, this prevents information being lost if transforms are
  // applied to SPIR-V before lowering to a concrete target.
  if (ICA.getID() == Intrinsic::ctpop) {
    Type *Ty = ICA.getReturnType();
    // Arbitrary bit-width INT is not core SPIR-V.
    if (Ty->isIntegerTy() && isPowerOf2_32(Ty->getIntegerBitWidth()) &&
        Ty->getIntegerBitWidth() <= 64)
      return TTI::TCC_Basic;
  }
  return BaseT::getIntrinsicInstrCost(ICA, CostKind);
}

bool llvm::SPIRVTTIImpl::collectFlatAddressOperands(
    SmallVectorImpl<int> &OpIndexes, Intrinsic::ID IID) const {
  switch (IID) {
  case Intrinsic::spv_generic_cast_to_ptr_explicit:
    OpIndexes.push_back(0);
    return true;
  default:
    return false;
  }
}

Value *llvm::SPIRVTTIImpl::rewriteIntrinsicWithAddressSpace(IntrinsicInst *II,
                                                            Value *OldV,
                                                            Value *NewV) const {
  auto IntrID = II->getIntrinsicID();
  switch (IntrID) {
  case Intrinsic::spv_generic_cast_to_ptr_explicit: {
    unsigned NewAS = NewV->getType()->getPointerAddressSpace();
    unsigned DstAS = II->getType()->getPointerAddressSpace();
    return NewAS == DstAS ? NewV
                          : ConstantPointerNull::get(
                                PointerType::get(NewV->getContext(), DstAS));
  }
  default:
    return nullptr;
  }
}

bool SPIRVTTIImpl::isLegalMaskedGather(Type *DataType, Align Alignment) const {
  return ST->canUseExtension(SPIRV::Extension::SPV_INTEL_masked_gather_scatter);
}

bool SPIRVTTIImpl::isLegalMaskedScatter(Type *DataType, Align Alignment) const {
  return ST->canUseExtension(SPIRV::Extension::SPV_INTEL_masked_gather_scatter);
}
