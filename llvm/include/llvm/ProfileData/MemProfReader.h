//===- MemProfReader.h - Instrumented memory profiling reader ---*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains support for reading MemProf profiling data.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_PROFILEDATA_MEMPROFREADER_H_
#define LLVM_PROFILEDATA_MEMPROFREADER_H_

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/DebugInfo/Symbolize/SymbolizableModule.h"
#include "llvm/DebugInfo/Symbolize/Symbolize.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/Object/Binary.h"
#include "llvm/Object/ObjectFile.h"
#include "llvm/ProfileData/IndexedMemProfData.h"
#include "llvm/ProfileData/InstrProfReader.h"
#include "llvm/ProfileData/MemProfData.inc"
#include "llvm/ProfileData/MemProfRadixTree.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Error.h"
#include "llvm/Support/MemoryBuffer.h"

#include <functional>

namespace llvm {
namespace memprof {
// A class for memprof profile data populated directly from external
// sources.
class MemProfReader {
public:
  // The MemProfReader only holds memory profile information.
  InstrProfKind getProfileKind() const { return InstrProfKind::MemProf; }

  using GuidMemProfRecordPair = std::pair<GlobalValue::GUID, MemProfRecord>;
  using Iterator = InstrProfIterator<GuidMemProfRecordPair, MemProfReader>;
  Iterator end() { return Iterator(); }
  Iterator begin() {
    Iter = MemProfData.Records.begin();
    return Iterator(this);
  }

  // Take the complete profile data.  Once this function is invoked,
  // MemProfReader no longer owns the MemProf profile.
  IndexedMemProfData takeMemProfData() { return std::move(MemProfData); }

  virtual Error
  readNextRecord(GuidMemProfRecordPair &GuidRecord,
                 std::function<const Frame(const FrameId)> Callback = nullptr) {
    if (MemProfData.Records.empty())
      return make_error<InstrProfError>(instrprof_error::empty_raw_profile);

    if (Iter == MemProfData.Records.end())
      return make_error<InstrProfError>(instrprof_error::eof);

    if (Callback == nullptr)
      Callback = [&](FrameId Id) { return idToFrame(Id); };

    CallStackIdConverter<decltype(MemProfData.CallStacks)> CSIdConv(
        MemProfData.CallStacks, Callback);

    const IndexedMemProfRecord &IndexedRecord = Iter->second;
    GuidRecord = {
        Iter->first,
        IndexedRecord.toMemProfRecord(CSIdConv),
    };
    if (CSIdConv.LastUnmappedId)
      return make_error<InstrProfError>(instrprof_error::hash_mismatch);
    Iter++;
    return Error::success();
  }

  // Allow default construction for derived classes which can populate the
  // contents after construction.
  MemProfReader() = default;
  virtual ~MemProfReader() = default;

  // Initialize the MemProfReader with the given MemProf profile.
  MemProfReader(IndexedMemProfData &&MemProfData)
      : MemProfData(std::move(MemProfData)) {}

protected:
  // A helper method to extract the frame from the IdToFrame map.
  const Frame &idToFrame(const FrameId Id) const {
    auto It = MemProfData.Frames.find(Id);
    assert(It != MemProfData.Frames.end() && "Id not found in map.");
    return It->second;
  }
  // A complete pacakge of the MemProf profile.
  IndexedMemProfData MemProfData;
  // An iterator to the internal function profile data structure.
  llvm::MapVector<GlobalValue::GUID, IndexedMemProfRecord>::iterator Iter;
};

// Map from id (recorded from sanitizer stack depot) to virtual addresses for
// each program counter address in the callstack.
using CallStackMap = llvm::DenseMap<uint64_t, llvm::SmallVector<uint64_t>>;

// Specializes the MemProfReader class to populate the contents from raw binary
// memprof profiles from instrumentation based profiling.
class LLVM_ABI RawMemProfReader final : public MemProfReader {
public:
  RawMemProfReader(const RawMemProfReader &) = delete;
  RawMemProfReader &operator=(const RawMemProfReader &) = delete;
  virtual ~RawMemProfReader() override;

  // Prints the contents of the profile in YAML format.
  void printYAML(raw_ostream &OS);

  // Return true if the \p DataBuffer starts with magic bytes indicating it is
  // a raw binary memprof profile.
  static bool hasFormat(const MemoryBuffer &DataBuffer);
  // Return true if the file at \p Path starts with magic bytes indicating it is
  // a raw binary memprof profile.
  static bool hasFormat(const StringRef Path);

  // Create a RawMemProfReader after sanity checking the contents of the file at
  // \p Path or the \p Buffer. The binary from which the profile has been
  // collected is specified via a path in \p ProfiledBinary.
  static Expected<std::unique_ptr<RawMemProfReader>>
  create(const Twine &Path, StringRef ProfiledBinary, bool KeepName = false);
  static Expected<std::unique_ptr<RawMemProfReader>>
  create(std::unique_ptr<MemoryBuffer> Buffer, StringRef ProfiledBinary,
         bool KeepName = false);

  // Returns a list of build ids recorded in the segment information.
  static std::vector<std::string> peekBuildIds(MemoryBuffer *DataBuffer);

  Error
  readNextRecord(GuidMemProfRecordPair &GuidRecord,
                 std::function<const Frame(const FrameId)> Callback) override;

  // Constructor for unittests only.
  RawMemProfReader(std::unique_ptr<llvm::symbolize::SymbolizableModule> Sym,
                   llvm::SmallVectorImpl<SegmentEntry> &Seg,
                   llvm::MapVector<uint64_t, MemInfoBlock> &Prof,
                   CallStackMap &SM, bool KeepName = false)
      : SegmentInfo(Seg.begin(), Seg.end()), CallstackProfileData(Prof),
        StackMap(SM), KeepSymbolName(KeepName) {
    // We don't call initialize here since there is no raw profile to read. The
    // test should pass in the raw profile as structured data.

    // If there is an error here then the mock symbolizer has not been
    // initialized properly.
    if (Error E = symbolizeAndFilterStackFrames(std::move(Sym)))
      report_fatal_error(std::move(E));
    if (Error E = mapRawProfileToRecords())
      report_fatal_error(std::move(E));
  }

private:
  RawMemProfReader(object::OwningBinary<object::Binary> &&Bin, bool KeepName)
      : Binary(std::move(Bin)), KeepSymbolName(KeepName) {}
  // Initializes the RawMemProfReader with the contents in `DataBuffer`.
  Error initialize(std::unique_ptr<MemoryBuffer> DataBuffer);
  // Read and parse the contents of the `DataBuffer` as a binary format profile.
  Error readRawProfile(std::unique_ptr<MemoryBuffer> DataBuffer);
  // Initialize the segment mapping information for symbolization.
  Error setupForSymbolization();
  // Symbolize and cache all the virtual addresses we encounter in the
  // callstacks from the raw profile. Also prune callstack frames which we can't
  // symbolize or those that belong to the runtime. For profile entries where
  // the entire callstack is pruned, we drop the entry from the profile.
  Error symbolizeAndFilterStackFrames(
      std::unique_ptr<llvm::symbolize::SymbolizableModule> Symbolizer);
  // Construct memprof records for each function and store it in the
  // `FunctionProfileData` map. A function may have allocation profile data or
  // callsite data or both.
  Error mapRawProfileToRecords();

  object::SectionedAddress getModuleOffset(uint64_t VirtualAddress);

  llvm::SmallVector<std::pair<uint64_t, MemInfoBlock>>
  readMemInfoBlocks(const char *Ptr);

  // The profiled binary.
  object::OwningBinary<object::Binary> Binary;
  // Version of raw memprof binary currently being read. Defaults to most up
  // to date version.
  uint64_t MemprofRawVersion = MEMPROF_RAW_VERSION;
  // The preferred load address of the executable segment.
  uint64_t PreferredTextSegmentAddress = 0;
  // The base address of the text segment in the process during profiling.
  uint64_t ProfiledTextSegmentStart = 0;
  // The limit address of the text segment in the process during profiling.
  uint64_t ProfiledTextSegmentEnd = 0;

  // The memory mapped segment information for all executable segments in the
  // profiled binary (filtered from the raw profile using the build id).
  llvm::SmallVector<SegmentEntry, 2> SegmentInfo;

  // A map from callstack id (same as key in CallStackMap below) to the heap
  // information recorded for that allocation context.
  llvm::MapVector<uint64_t, MemInfoBlock> CallstackProfileData;
  CallStackMap StackMap;

  // Cached symbolization from PC to Frame.
  llvm::DenseMap<uint64_t, llvm::SmallVector<FrameId>> SymbolizedFrame;

  // Whether to keep the symbol name for each frame after hashing.
  bool KeepSymbolName = false;
  // A mapping of the hash to symbol name, only used if KeepSymbolName is true.
  llvm::DenseMap<uint64_t, std::string> GuidToSymbolName;
};

class YAMLMemProfReader final : public MemProfReader {
public:
  YAMLMemProfReader() = default;

  // Return true if the \p DataBuffer starts with "---" indicating it is a YAML
  // file.
  LLVM_ABI static bool hasFormat(const MemoryBuffer &DataBuffer);
  // Wrapper around hasFormat above, reading the file instead of the memory
  // buffer.
  LLVM_ABI static bool hasFormat(const StringRef Path);

  // Create a YAMLMemProfReader after sanity checking the contents of the file
  // at \p Path or the \p Buffer.
  LLVM_ABI static Expected<std::unique_ptr<YAMLMemProfReader>>
  create(const Twine &Path);
  LLVM_ABI static Expected<std::unique_ptr<YAMLMemProfReader>>
  create(std::unique_ptr<MemoryBuffer> Buffer);

  LLVM_ABI void parse(StringRef YAMLData);

  std::unique_ptr<memprof::DataAccessProfData> takeDataAccessProfData() {
    return std::move(DataAccessProfileData);
  }

private:
  // Called by `parse` to set data access profiles after parsing them from Yaml
  // files.
  void
  setDataAccessProfileData(std::unique_ptr<memprof::DataAccessProfData> Data) {
    DataAccessProfileData = std::move(Data);
  }

  std::unique_ptr<memprof::DataAccessProfData> DataAccessProfileData;
};
} // namespace memprof
} // namespace llvm

#endif // LLVM_PROFILEDATA_MEMPROFREADER_H_
