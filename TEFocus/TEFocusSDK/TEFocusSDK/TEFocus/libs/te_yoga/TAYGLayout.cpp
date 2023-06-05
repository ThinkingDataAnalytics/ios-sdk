

#include "TAYGLayout.h"
#include "TAYGUtils.h"

using namespace thinkingdatalayout;

bool TAYGLayout::operator==(TAYGLayout layout) const {
  bool isEqual = TAYGFloatArrayEqual(position, layout.position) &&
      TAYGFloatArrayEqual(dimensions, layout.dimensions) &&
      TAYGFloatArrayEqual(margin, layout.margin) &&
      TAYGFloatArrayEqual(border, layout.border) &&
      TAYGFloatArrayEqual(padding, layout.padding) &&
      direction() == layout.direction() &&
      hadOverflow() == layout.hadOverflow() &&
      lastOwnerDirection == layout.lastOwnerDirection &&
      nextCachedMeasurementsIndex == layout.nextCachedMeasurementsIndex &&
      cachedLayout == layout.cachedLayout &&
      computedFlexBasis == layout.computedFlexBasis;

  for (uint32_t i = 0; i < YG_MAX_CACHED_RESULT_COUNT && isEqual; ++i) {
    isEqual = isEqual && cachedMeasurements[i] == layout.cachedMeasurements[i];
  }

  if (!ta_yoga::isUndefined(measuredDimensions[0]) ||
      !ta_yoga::isUndefined(layout.measuredDimensions[0])) {
    isEqual =
        isEqual && (measuredDimensions[0] == layout.measuredDimensions[0]);
  }
  if (!ta_yoga::isUndefined(measuredDimensions[1]) ||
      !ta_yoga::isUndefined(layout.measuredDimensions[1])) {
    isEqual =
        isEqual && (measuredDimensions[1] == layout.measuredDimensions[1]);
  }

  return isEqual;
}
