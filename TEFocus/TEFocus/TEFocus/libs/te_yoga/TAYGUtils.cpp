
#include "TAYGUtils.h"
#include <stdexcept>

using namespace thinkingdatalayout;

TAYGFlexDirection TAYGFlexDirectionCross(
    const TAYGFlexDirection flexDirection,
    const TAYGDirection direction) {
  return TAYGFlexDirectionIsColumn(flexDirection)
      ? TAYGResolveFlexDirection(TAYGFlexDirectionRow, direction)
      : TAYGFlexDirectionColumn;
}

float TAYGFloatMax(const float a, const float b) {
  if (!ta_yoga::isUndefined(a) && !ta_yoga::isUndefined(b)) {
    return fmaxf(a, b);
  }
  return ta_yoga::isUndefined(a) ? b : a;
}

float TAYGFloatMin(const float a, const float b) {
  if (!ta_yoga::isUndefined(a) && !ta_yoga::isUndefined(b)) {
    return fminf(a, b);
  }

  return ta_yoga::isUndefined(a) ? b : a;
}

bool TAYGValueEqual(const TAYGValue& a, const TAYGValue& b) {
  if (a.unit != b.unit) {
    return false;
  }

  if (a.unit == TAYGUnitUndefined ||
      (ta_yoga::isUndefined(a.value) && ta_yoga::isUndefined(b.value))) {
    return true;
  }

  return fabs(a.value - b.value) < 0.0001f;
}

bool TAYGFloatsEqual(const float a, const float b) {
  if (!ta_yoga::isUndefined(a) && !ta_yoga::isUndefined(b)) {
    return fabs(a - b) < 0.0001f;
  }
  return ta_yoga::isUndefined(a) && ta_yoga::isUndefined(b);
}

bool TAYGDoubleEqual(const double a, const double b) {
  if (!ta_yoga::isUndefined(a) && !ta_yoga::isUndefined(b)) {
    return fabs(a - b) < 0.0001;
  }
  return ta_yoga::isUndefined(a) && ta_yoga::isUndefined(b);
}

float TAYGFloatSanitize(const float val) {
  return ta_yoga::isUndefined(val) ? 0 : val;
}

TAYGFloatOptional TAYGFloatOptionalMax(TAYGFloatOptional op1, TAYGFloatOptional op2) {
  if (op1 >= op2) {
    return op1;
  }
  if (op2 > op1) {
    return op2;
  }
  return op1.isUndefined() ? op2 : op1;
}

void ta_throwLogicalErrorWithMessage(const char* message) {
  throw std::logic_error(message);
}
