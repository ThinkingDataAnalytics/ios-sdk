
#pragma once
#include "TABitUtils.h"
#include "TAYGFloatOptional.h"
#include "TAYoga-internal.h"

using namespace thinkingdatalayout::ta_yoga;

struct TAYGLayout {
  std::array<float, 4> position = {};
  std::array<float, 2> dimensions = {{TAYGUndefined, TAYGUndefined}};
  std::array<float, 4> margin = {};
  std::array<float, 4> border = {};
  std::array<float, 4> padding = {};

private:
  static constexpr size_t directionOffset = 0;
  static constexpr size_t didUseLegacyFlagOffset =
      directionOffset + thinkingdatalayout::ta_yoga::detail::bitWidthFn<TAYGDirection>();
  static constexpr size_t doesLegacyStretchFlagAffectsLayoutOffset =
      didUseLegacyFlagOffset + 1;
  static constexpr size_t hadOverflowOffset =
      doesLegacyStretchFlagAffectsLayoutOffset + 1;
  uint8_t flags = 0;

public:
  uint32_t computedFlexBasisGeneration = 0;
  TAYGFloatOptional computedFlexBasis = {};

  // Instead of recomputing the entire layout every single time, we cache some
  // information to break early when nothing changed
  uint32_t generationCount = 0;
  TAYGDirection lastOwnerDirection = TAYGDirectionInherit;

  uint32_t nextCachedMeasurementsIndex = 0;
  std::array<TAYGCachedMeasurement, YG_MAX_CACHED_RESULT_COUNT>
      cachedMeasurements = {};
  std::array<float, 2> measuredDimensions = {{TAYGUndefined, TAYGUndefined}};

  TAYGCachedMeasurement cachedLayout = TAYGCachedMeasurement();

  TAYGDirection direction() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGDirection>(
        flags, directionOffset);
  }

  void setDirection(TAYGDirection direction) {
    thinkingdatalayout::ta_yoga::detail::setEnumData<TAYGDirection>(
        flags, directionOffset, direction);
  }

  bool didUseLegacyFlag() const {
    return thinkingdatalayout::ta_yoga::detail::getBooleanData(
        flags, didUseLegacyFlagOffset);
  }

  void setDidUseLegacyFlag(bool val) {
    thinkingdatalayout::ta_yoga::detail::setBooleanData(flags, didUseLegacyFlagOffset, val);
  }

  bool doesLegacyStretchFlagAffectsLayout() const {
    return thinkingdatalayout::ta_yoga::detail::getBooleanData(
        flags, doesLegacyStretchFlagAffectsLayoutOffset);
  }

  void setDoesLegacyStretchFlagAffectsLayout(bool val) {
    thinkingdatalayout::ta_yoga::detail::setBooleanData(
        flags, doesLegacyStretchFlagAffectsLayoutOffset, val);
  }

  bool hadOverflow() const {
    return thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, hadOverflowOffset);
  }
  void setHadOverflow(bool hadOverflow) {
    thinkingdatalayout::ta_yoga::detail::setBooleanData(
        flags, hadOverflowOffset, hadOverflow);
  }

  bool operator==(TAYGLayout layout) const;
  bool operator!=(TAYGLayout layout) const { return !(*this == layout); }
};
