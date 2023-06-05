
#pragma once
#include "TAYGNode.h"
#include "TAYoga-internal.h"
#include "TACompactValue.h"

struct TAYGCollectFlexItemsRowValues {
  uint32_t itemsOnLine;
  float sizeConsumedOnCurrentLine;
  float totalFlexGrowFactors;
  float totalFlexShrinkScaledFactors;
  uint32_t endOfLineIndex;
  std::vector<TAYGNodeRef> relativeChildren;
  float remainingFreeSpace;
  // The size of the mainDim for the row after considering size, padding, margin
  // and border of flex items. This is used to calculate maxLineDim after going
  // through all the rows to decide on the main axis size of owner.
  float mainDim;
  // The size of the crossDim for the row after considering size, padding,
  // margin and border of flex items. Used for calculating containers crossSize.
  float crossDim;
};

bool TAYGValueEqual(const TAYGValue& a, const TAYGValue& b);
inline bool TAYGValueEqual(
    thinkingdatalayout::ta_yoga::detail::TACompactValue a,
    thinkingdatalayout::ta_yoga::detail::TACompactValue b) {
  return TAYGValueEqual((TAYGValue) a, (TAYGValue) b);
}

// This custom float equality function returns true if either absolute
// difference between two floats is less than 0.0001f or both are undefined.
bool TAYGFloatsEqual(const float a, const float b);

bool TAYGDoubleEqual(const double a, const double b);

float TAYGFloatMax(const float a, const float b);

TAYGFloatOptional TAYGFloatOptionalMax(
    const TAYGFloatOptional op1,
    const TAYGFloatOptional op2);

float TAYGFloatMin(const float a, const float b);

// This custom float comparison function compares the array of float with
// TAYGFloatsEqual, as the default float comparison operator will not work(Look
// at the comments of TAYGFloatsEqual function).
template <std::size_t size>
bool TAYGFloatArrayEqual(
    const std::array<float, size>& val1,
    const std::array<float, size>& val2) {
  bool areEqual = true;
  for (std::size_t i = 0; i < size && areEqual; ++i) {
    areEqual = TAYGFloatsEqual(val1[i], val2[i]);
  }
  return areEqual;
}

// This function returns 0 if TAYGFloatIsUndefined(val) is true and val otherwise
float TAYGFloatSanitize(const float val);

TAYGFlexDirection TAYGFlexDirectionCross(
    const TAYGFlexDirection flexDirection,
    const TAYGDirection direction);

inline bool TAYGFlexDirectionIsRow(const TAYGFlexDirection flexDirection) {
  return flexDirection == TAYGFlexDirectionRow ||
      flexDirection == TAYGFlexDirectionRowReverse;
}

inline TAYGFloatOptional TAYGResolveValue(
    const TAYGValue value,
    const float ownerSize) {
  switch (value.unit) {
    case TAYGUnitPoint:
      return TAYGFloatOptional{value.value};
    case TAYGUnitPercent:
      return TAYGFloatOptional{value.value * ownerSize * 0.01f};
    default:
      return TAYGFloatOptional{};
  }
}

inline TAYGFloatOptional TAYGResolveValue(
    ta_yoga::detail::TACompactValue value,
    float ownerSize) {
  return TAYGResolveValue((TAYGValue) value, ownerSize);
}

inline bool TAYGFlexDirectionIsColumn(const TAYGFlexDirection flexDirection) {
  return flexDirection == TAYGFlexDirectionColumn ||
      flexDirection == YGFlexDirectionColumnReverse;
}

inline TAYGFlexDirection TAYGResolveFlexDirection(
    const TAYGFlexDirection flexDirection,
    const TAYGDirection direction) {
  if (direction == TAYGDirectionRTL) {
    if (flexDirection == TAYGFlexDirectionRow) {
      return TAYGFlexDirectionRowReverse;
    } else if (flexDirection == TAYGFlexDirectionRowReverse) {
      return TAYGFlexDirectionRow;
    }
  }

  return flexDirection;
}

inline TAYGFloatOptional TAYGResolveValueMargin(
    ta_yoga::detail::TACompactValue value,
    const float ownerSize) {
  return value.isAuto() ? TAYGFloatOptional{0} : TAYGResolveValue(value, ownerSize);
}

void ta_throwLogicalErrorWithMessage(const char* message);
