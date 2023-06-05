
#pragma once

#include "TAYGValue.h"
#include "TAYGMacros.h"
#include <cmath>
#include <cstdint>
#include <limits>

static_assert(
    std::numeric_limits<float>::is_iec559,
    "thinkingdatalayout::ta_yoga::detail::TACompactValue only works with IEEE754 floats");

#ifdef YOGA_COMPACT_VALUE_TEST
#define VISIBLE_FOR_TESTING public:
#else
#define VISIBLE_FOR_TESTING private:
#endif

namespace thinkingdatalayout {
namespace ta_yoga {
namespace detail {

// This class stores TAYGValue in 32 bits.
// - The value does not matter for Undefined and Auto. NaNs are used for their
//   representation.
// - To differentiate between Point and Percent, one exponent bit is used.
//   Supported the range [0x40, 0xbf] (0xbf is inclusive for point, but
//   exclusive for percent).
// - Value ranges:
//   points:  1.08420217e-19f to 36893485948395847680
//            0x00000000         0x3fffffff
//   percent: 1.08420217e-19f to 18446742974197923840
//            0x40000000         0x7f7fffff
// - Zero is supported, negative zero is not
// - values outside of the representable range are clamped
class TA_YOGA_EXPORT TACompactValue {
  friend constexpr bool operator==(TACompactValue, TACompactValue) noexcept;

public:
  static constexpr auto TALOWER_BOUND = 1.08420217e-19f;
  static constexpr auto TAUPPER_BOUND_POINT = 36893485948395847680.0f;
  static constexpr auto TAUPPER_BOUND_PERCENT = 18446742974197923840.0f;

  template <TAYGUnit Unit>
  static TACompactValue of(float value) noexcept {
    if (value == 0.0f || (value < TALOWER_BOUND && value > -TALOWER_BOUND)) {
      constexpr auto zero =
          Unit == TAYGUnitPercent ? ZERO_BITS_PERCENT : ZERO_BITS_POINT;
      return {TAPayload{zero}};
    }

    constexpr auto upperBound =
        Unit == TAYGUnitPercent ? TAUPPER_BOUND_PERCENT : TAUPPER_BOUND_POINT;
    if (value > upperBound || value < -upperBound) {
      value = copysignf(upperBound, value);
    }

    uint32_t unitBit = Unit == TAYGUnitPercent ? TAPERCENT_BIT : 0;
    auto data = TAPayload{value};
    data.repr -= BIAS;
    data.repr |= unitBit;
    return {data};
  }

  template <TAYGUnit Unit>
  static TACompactValue ofMaybe(float value) noexcept {
    return std::isnan(value) || std::isinf(value) ? ofUndefined()
                                                  : of<Unit>(value);
  }

  static constexpr TACompactValue ofZero() noexcept {
    return TACompactValue{TAPayload{ZERO_BITS_POINT}};
  }

  static constexpr TACompactValue ofUndefined() noexcept {
    return TACompactValue{};
  }

  static constexpr TACompactValue ofAuto() noexcept {
    return TACompactValue{TAPayload{TAAUTO_BITS}};
  }

  constexpr TACompactValue() noexcept
      : payload_(std::numeric_limits<float>::quiet_NaN()) {}

  TACompactValue(const TAYGValue& x) noexcept : payload_(uint32_t{0}) {
    switch (x.unit) {
      case TAYGUnitUndefined:
        *this = ofUndefined();
        break;
      case TAYGUnitAuto:
        *this = ofAuto();
        break;
      case TAYGUnitPoint:
        *this = of<TAYGUnitPoint>(x.value);
        break;
      case TAYGUnitPercent:
        *this = of<TAYGUnitPercent>(x.value);
        break;
    }
  }

  operator TAYGValue() const noexcept {
    switch (payload_.repr) {
      case TAAUTO_BITS:
        return TAYGValueAuto;
      case ZERO_BITS_POINT:
        return TAYGValue{0.0f, TAYGUnitPoint};
      case ZERO_BITS_PERCENT:
        return TAYGValue{0.0f, TAYGUnitPercent};
    }

    if (std::isnan(payload_.value)) {
      return TAYGValueUndefined;
    }

    auto data = payload_;
    data.repr &= ~TAPERCENT_BIT;
    data.repr += BIAS;

    return TAYGValue{
        data.value, payload_.repr & 0x40000000 ? TAYGUnitPercent : TAYGUnitPoint};
  }

  bool isUndefined() const noexcept {
    return (
        payload_.repr != TAAUTO_BITS && payload_.repr != ZERO_BITS_POINT &&
        payload_.repr != ZERO_BITS_PERCENT && std::isnan(payload_.value));
  }

  bool isAuto() const noexcept { return payload_.repr == TAAUTO_BITS; }

private:
  union TAPayload {
    float value;
    uint32_t repr;
    TAPayload() = delete;
    constexpr TAPayload(uint32_t r) : repr(r) {}
    constexpr TAPayload(float v) : value(v) {}
  };

  static constexpr uint32_t BIAS = 0x20000000;
  static constexpr uint32_t TAPERCENT_BIT = 0x40000000;

  // these are signaling NaNs with specific bit pattern as payload they will be
  // silenced whenever going through an FPU operation on ARM + x86
  static constexpr uint32_t TAAUTO_BITS = 0x7faaaaaa;
  static constexpr uint32_t ZERO_BITS_POINT = 0x7f8f0f0f;
  static constexpr uint32_t ZERO_BITS_PERCENT = 0x7f80f0f0;

  constexpr TACompactValue(TAPayload data) noexcept : payload_(data) {}

  TAPayload payload_;

  VISIBLE_FOR_TESTING uint32_t repr() { return payload_.repr; }
};

template <>
TACompactValue TACompactValue::of<TAYGUnitUndefined>(float) noexcept = delete;
template <>
TACompactValue TACompactValue::of<TAYGUnitAuto>(float) noexcept = delete;
template <>
TACompactValue TACompactValue::ofMaybe<TAYGUnitUndefined>(float) noexcept = delete;
template <>
TACompactValue TACompactValue::ofMaybe<TAYGUnitAuto>(float) noexcept = delete;

constexpr bool operator==(TACompactValue a, TACompactValue b) noexcept {
  return a.payload_.repr == b.payload_.repr;
}

constexpr bool operator!=(TACompactValue a, TACompactValue b) noexcept {
  return !(a == b);
}

} // namespace detail
} // namespace ta_yoga
} // namespace thinkingdatalayout
