
#pragma once

#include <math.h>
#include "TAYGEnums.h"
#include "TAYGMacros.h"

#if defined(_MSC_VER) && defined(__clang__)
#define COMPILING_WITH_CLANG_ON_WINDOWS
#endif
#if defined(COMPILING_WITH_CLANG_ON_WINDOWS)
#include <limits>
constexpr float TAYGUndefined = std::numeric_limits<float>::quiet_NaN();
#else
TA_YG_EXTERN_C_BEGIN

// Not defined in MSVC++
#ifndef NAN
static const uint32_t __nan = 0x7fc00000;
#define NAN (*(const float*) __nan)
#endif

#define TAYGUndefined NAN
#endif

typedef struct TAYGValue {
  float value;
  TAYGUnit unit;
} TAYGValue;

TA_YOGA_EXPORT extern const TAYGValue TAYGValueAuto;
TA_YOGA_EXPORT extern const TAYGValue TAYGValueUndefined;
TA_YOGA_EXPORT extern const TAYGValue TAYGValueZero;

#if !defined(COMPILING_WITH_CLANG_ON_WINDOWS)
TA_YG_EXTERN_C_END
#endif
#undef COMPILING_WITH_CLANG_ON_WINDOWS

#ifdef __cplusplus

inline bool operator==(const TAYGValue& lhs, const TAYGValue& rhs) {
  if (lhs.unit != rhs.unit) {
    return false;
  }

  switch (lhs.unit) {
    case TAYGUnitUndefined:
    case TAYGUnitAuto:
      return true;
    case TAYGUnitPoint:
    case TAYGUnitPercent:
      return lhs.value == rhs.value;
  }

  return false;
}

inline bool operator!=(const TAYGValue& lhs, const TAYGValue& rhs) {
  return !(lhs == rhs);
}

inline TAYGValue operator-(const TAYGValue& value) {
  return {-value.value, value.unit};
}

namespace thinkingdatalayout {
namespace ta_yoga {
namespace literals {

inline TAYGValue operator"" _pt(long double value) {
  return TAYGValue{static_cast<float>(value), TAYGUnitPoint};
}
inline TAYGValue operator"" _pt(unsigned long long value) {
  return operator"" _pt(static_cast<long double>(value));
}

inline TAYGValue operator"" _percent(long double value) {
  return TAYGValue{static_cast<float>(value), TAYGUnitPercent};
}
inline TAYGValue operator"" _percent(unsigned long long value) {
  return operator"" _percent(static_cast<long double>(value));
}

} // namespace literals
} // namespace ta_yoga
} // namespace thinkingdatalayout

#endif
