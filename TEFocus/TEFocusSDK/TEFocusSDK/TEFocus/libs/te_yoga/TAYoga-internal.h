
#pragma once
#include <algorithm>
#include <array>
#include <cmath>
#include <vector>
#include "TACompactValue.h"
#include "TAYoga.h"

using TAYGVector = std::vector<TAYGNodeRef>;

TA_YG_EXTERN_C_BEGIN

void TAYGNodeCalculateLayoutWithContext(
    TAYGNodeRef node,
    float availableWidth,
    float availableHeight,
    TAYGDirection ownerDirection,
    void* layoutContext);

TA_YG_EXTERN_C_END

namespace thinkingdatalayout {
namespace ta_yoga {

inline bool isUndefined(float value) {
  return std::isnan(value);
}

inline bool isUndefined(double value) {
  return std::isnan(value);
}

} // namespace ta_yoga
} // namespace thinkingdatalayout

using namespace thinkingdatalayout;

extern const std::array<TAYGEdge, 4> ta_trailing;
extern const std::array<TAYGEdge, 4> ta_leading;
extern const TAYGValue TAYGValueUndefined;
extern const TAYGValue TAYGValueAuto;
extern const TAYGValue TAYGValueZero;

struct TAYGCachedMeasurement {
  float availableWidth;
  float availableHeight;
  TAYGMeasureMode widthMeasureMode;
  TAYGMeasureMode heightMeasureMode;

  float computedWidth;
  float computedHeight;

  TAYGCachedMeasurement()
      : availableWidth(-1),
        availableHeight(-1),
        widthMeasureMode(TAYGMeasureModeUndefined),
        heightMeasureMode(TAYGMeasureModeUndefined),
        computedWidth(-1),
        computedHeight(-1) {}

  bool operator==(TAYGCachedMeasurement measurement) const {
    bool isEqual = widthMeasureMode == measurement.widthMeasureMode &&
        heightMeasureMode == measurement.heightMeasureMode;

    if (!ta_yoga::isUndefined(availableWidth) ||
        !ta_yoga::isUndefined(measurement.availableWidth)) {
      isEqual = isEqual && availableWidth == measurement.availableWidth;
    }
    if (!ta_yoga::isUndefined(availableHeight) ||
        !ta_yoga::isUndefined(measurement.availableHeight)) {
      isEqual = isEqual && availableHeight == measurement.availableHeight;
    }
    if (!ta_yoga::isUndefined(computedWidth) ||
        !ta_yoga::isUndefined(measurement.computedWidth)) {
      isEqual = isEqual && computedWidth == measurement.computedWidth;
    }
    if (!ta_yoga::isUndefined(computedHeight) ||
        !ta_yoga::isUndefined(measurement.computedHeight)) {
      isEqual = isEqual && computedHeight == measurement.computedHeight;
    }

    return isEqual;
  }
};

// This value was chosen based on empirical data:
// 98% of analyzed layouts require less than 8 entries.
#define YG_MAX_CACHED_RESULT_COUNT 8

namespace thinkingdatalayout {
namespace ta_yoga {
namespace detail {

template <size_t Size>
class TAValues {
private:
  std::array<TACompactValue, Size> values_;

public:
  TAValues() = default;
  explicit TAValues(const TAYGValue& defaultValue) noexcept {
    values_.fill(defaultValue);
  }

  const TACompactValue& operator[](size_t i) const noexcept { return values_[i]; }
  TACompactValue& operator[](size_t i) noexcept { return values_[i]; }

  template <size_t I>
  TAYGValue get() const noexcept {
    return std::get<I>(values_);
  }

  template <size_t I>
  void set(TAYGValue& value) noexcept {
    std::get<I>(values_) = value;
  }

  template <size_t I>
  void set(TAYGValue&& value) noexcept {
    set<I>(value);
  }

  bool operator==(const TAValues& other) const noexcept {
    for (size_t i = 0; i < Size; ++i) {
      if (values_[i] != other.values_[i]) {
        return false;
      }
    }
    return true;
  }

  TAValues& operator=(const TAValues& other) = default;
};

} // namespace detail
} // namespace ta_yoga
} // namespace thinkingdatalayout

static const float kDefaultFlexGrow = 0.0f;
static const float kDefaultFlexShrink = 0.0f;
static const float kWebDefaultFlexShrink = 1.0f;

extern bool TAYGFloatsEqual(const float a, const float b);
