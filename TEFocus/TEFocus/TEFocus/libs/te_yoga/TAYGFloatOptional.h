
#pragma once

#include <cmath>
#include <limits>
#include "TAYoga-internal.h"

struct TAYGFloatOptional {
private:
  float value_ = std::numeric_limits<float>::quiet_NaN();

public:
  explicit constexpr TAYGFloatOptional(float value) : value_(value) {}
  constexpr TAYGFloatOptional() = default;

  // returns the wrapped value, or a value x with YGIsUndefined(x) == true
  constexpr float unwrap() const { return value_; }

  bool isUndefined() const { return std::isnan(value_); }
};

// operators take TAYGFloatOptional by value, as it is a 32bit value

inline bool operator==(TAYGFloatOptional lhs, TAYGFloatOptional rhs) {
  return lhs.unwrap() == rhs.unwrap() ||
      (lhs.isUndefined() && rhs.isUndefined());
}
inline bool operator!=(TAYGFloatOptional lhs, TAYGFloatOptional rhs) {
  return !(lhs == rhs);
}

inline bool operator==(TAYGFloatOptional lhs, float rhs) {
  return lhs == TAYGFloatOptional{rhs};
}
inline bool operator!=(TAYGFloatOptional lhs, float rhs) {
  return !(lhs == rhs);
}

inline bool operator==(float lhs, TAYGFloatOptional rhs) {
  return rhs == lhs;
}
inline bool operator!=(float lhs, TAYGFloatOptional rhs) {
  return !(lhs == rhs);
}

inline TAYGFloatOptional operator+(TAYGFloatOptional lhs, TAYGFloatOptional rhs) {
  return TAYGFloatOptional{lhs.unwrap() + rhs.unwrap()};
}

inline bool operator>(TAYGFloatOptional lhs, TAYGFloatOptional rhs) {
  return lhs.unwrap() > rhs.unwrap();
}

inline bool operator<(TAYGFloatOptional lhs, TAYGFloatOptional rhs) {
  return lhs.unwrap() < rhs.unwrap();
}

inline bool operator>=(TAYGFloatOptional lhs, TAYGFloatOptional rhs) {
  return lhs > rhs || lhs == rhs;
}

inline bool operator<=(TAYGFloatOptional lhs, TAYGFloatOptional rhs) {
  return lhs < rhs || lhs == rhs;
}
