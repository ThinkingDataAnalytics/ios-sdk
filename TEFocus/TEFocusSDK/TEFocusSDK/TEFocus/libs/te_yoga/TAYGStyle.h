
#pragma once

#ifdef __cplusplus

#include <algorithm>
#include <array>
#include <cstdint>
#include <type_traits>
#include "TACompactValue.h"
#include "TAYGEnums.h"
#include "TAYGFloatOptional.h"
#include "TAYoga-internal.h"
#include "TAYoga.h"
#include "TABitUtils.h"

class TA_YOGA_EXPORT TATAYGStyle {
  template <typename Enum>
  using TAValues =
      thinkingdatalayout::ta_yoga::detail::TAValues<thinkingdatalayout::ta_yoga::enums::count<Enum>()>;
  using TACompactValue = thinkingdatalayout::ta_yoga::detail::TACompactValue;

public:
  using Dimensions = TAValues<TAYGDimension>;
  using Edges = TAValues<TAYGEdge>;

  template <typename T>
  struct BitfieldRef {
    TATAYGStyle& style;
    size_t offset;
    operator T() const {
      return thinkingdatalayout::ta_yoga::detail::getEnumData<T>(style.flags, offset);
    }
    BitfieldRef<T>& operator=(T x) {
      thinkingdatalayout::ta_yoga::detail::setEnumData<T>(style.flags, offset, x);
      return *this;
    }
  };

  template <typename T, T TATAYGStyle::*Prop>
  struct Ref {
    TATAYGStyle& style;
    operator T() const { return style.*Prop; }
    Ref<T, Prop>& operator=(T value) {
      style.*Prop = value;
      return *this;
    }
  };

  template <typename Idx, TAValues<Idx> TATAYGStyle::*Prop>
  struct IdxRef {
    struct Ref {
      TATAYGStyle& style;
      Idx idx;
      operator TACompactValue() const { return (style.*Prop)[idx]; }
      operator TAYGValue() const { return (style.*Prop)[idx]; }
      Ref& operator=(TACompactValue value) {
        (style.*Prop)[idx] = value;
        return *this;
      }
    };

    TATAYGStyle& style;
    IdxRef<Idx, Prop>& operator=(const TAValues<Idx>& values) {
      style.*Prop = values;
      return *this;
    }
    operator const TAValues<Idx>&() const { return style.*Prop; }
    Ref operator[](Idx idx) { return {style, idx}; }
    TACompactValue operator[](Idx idx) const { return (style.*Prop)[idx]; }
  };

  TATAYGStyle() {
    alignContent() = TAYGAlignFlexStart;
    alignItems() = TAYGAlignStretch;
  }
  ~TATAYGStyle() = default;

private:
  static constexpr size_t directionOffset = 0;
  static constexpr size_t flexdirectionOffset =
      directionOffset + thinkingdatalayout::ta_yoga::detail::bitWidthFn<TAYGDirection>();
  static constexpr size_t justifyContentOffset = flexdirectionOffset +
      thinkingdatalayout::ta_yoga::detail::bitWidthFn<TAYGFlexDirection>();
  static constexpr size_t alignContentOffset =
      justifyContentOffset + thinkingdatalayout::ta_yoga::detail::bitWidthFn<TAYGJustify>();
  static constexpr size_t alignItemsOffset =
      alignContentOffset + thinkingdatalayout::ta_yoga::detail::bitWidthFn<TAYGAlign>();
  static constexpr size_t alignSelfOffset =
      alignItemsOffset + thinkingdatalayout::ta_yoga::detail::bitWidthFn<TAYGAlign>();
  static constexpr size_t positionTypeOffset =
      alignSelfOffset + thinkingdatalayout::ta_yoga::detail::bitWidthFn<TAYGAlign>();
  static constexpr size_t flexWrapOffset =
      positionTypeOffset + thinkingdatalayout::ta_yoga::detail::bitWidthFn<TAYGPositionType>();
  static constexpr size_t overflowOffset =
      flexWrapOffset + thinkingdatalayout::ta_yoga::detail::bitWidthFn<TAYGWrap>();
  static constexpr size_t displayOffset =
      overflowOffset + thinkingdatalayout::ta_yoga::detail::bitWidthFn<TAYGOverflow>();

  uint32_t flags = 0;

  TAYGFloatOptional flex_ = {};
  TAYGFloatOptional flexGrow_ = {};
  TAYGFloatOptional flexShrink_ = {};
  TACompactValue flexBasis_ = TACompactValue::ofAuto();
  Edges margin_ = {};
  Edges position_ = {};
  Edges padding_ = {};
  Edges border_ = {};
  Dimensions dimensions_{TACompactValue::ofAuto()};
  Dimensions minDimensions_ = {};
  Dimensions maxDimensions_ = {};
  // TAYoga specific properties, not compatible with flexbox specification
  TAYGFloatOptional aspectRatio_ = {};

public:
  // for library users needing a type
  using ValueRepr = std::remove_reference<decltype(margin_[0])>::type;

  TAYGDirection direction() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGDirection>(
        flags, directionOffset);
  }
  BitfieldRef<TAYGDirection> direction() { return {*this, directionOffset}; }

  TAYGFlexDirection flexDirection() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGFlexDirection>(
        flags, flexdirectionOffset);
  }
  BitfieldRef<TAYGFlexDirection> flexDirection() {
    return {*this, flexdirectionOffset};
  }

  TAYGJustify justifyContent() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGJustify>(
        flags, justifyContentOffset);
  }
  BitfieldRef<TAYGJustify> justifyContent() {
    return {*this, justifyContentOffset};
  }

  TAYGAlign alignContent() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGAlign>(
        flags, alignContentOffset);
  }
  BitfieldRef<TAYGAlign> alignContent() { return {*this, alignContentOffset}; }

  TAYGAlign alignItems() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGAlign>(
        flags, alignItemsOffset);
  }
  BitfieldRef<TAYGAlign> alignItems() { return {*this, alignItemsOffset}; }

  TAYGAlign alignSelf() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGAlign>(flags, alignSelfOffset);
  }
  BitfieldRef<TAYGAlign> alignSelf() { return {*this, alignSelfOffset}; }

  TAYGPositionType positionType() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGPositionType>(
        flags, positionTypeOffset);
  }
  BitfieldRef<TAYGPositionType> positionType() {
    return {*this, positionTypeOffset};
  }

  TAYGWrap flexWrap() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGWrap>(flags, flexWrapOffset);
  }
  BitfieldRef<TAYGWrap> flexWrap() { return {*this, flexWrapOffset}; }

  TAYGOverflow overflow() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGOverflow>(
        flags, overflowOffset);
  }
  BitfieldRef<TAYGOverflow> overflow() { return {*this, overflowOffset}; }

  TAYGDisplay display() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGDisplay>(flags, displayOffset);
  }
  BitfieldRef<TAYGDisplay> display() { return {*this, displayOffset}; }

  TAYGFloatOptional flex() const { return flex_; }
  Ref<TAYGFloatOptional, &TATAYGStyle::flex_> flex() { return {*this}; }

  TAYGFloatOptional flexGrow() const { return flexGrow_; }
  Ref<TAYGFloatOptional, &TATAYGStyle::flexGrow_> flexGrow() { return {*this}; }

  TAYGFloatOptional flexShrink() const { return flexShrink_; }
  Ref<TAYGFloatOptional, &TATAYGStyle::flexShrink_> flexShrink() { return {*this}; }

  TACompactValue flexBasis() const { return flexBasis_; }
  Ref<TACompactValue, &TATAYGStyle::flexBasis_> flexBasis() { return {*this}; }

  const Edges& margin() const { return margin_; }
  IdxRef<TAYGEdge, &TATAYGStyle::margin_> margin() { return {*this}; }

  const Edges& position() const { return position_; }
  IdxRef<TAYGEdge, &TATAYGStyle::position_> position() { return {*this}; }

  const Edges& padding() const { return padding_; }
  IdxRef<TAYGEdge, &TATAYGStyle::padding_> padding() { return {*this}; }

  const Edges& border() const { return border_; }
  IdxRef<TAYGEdge, &TATAYGStyle::border_> border() { return {*this}; }

  const Dimensions& dimensions() const { return dimensions_; }
  IdxRef<TAYGDimension, &TATAYGStyle::dimensions_> dimensions() { return {*this}; }

  const Dimensions& minDimensions() const { return minDimensions_; }
  IdxRef<TAYGDimension, &TATAYGStyle::minDimensions_> minDimensions() {
    return {*this};
  }

  const Dimensions& maxDimensions() const { return maxDimensions_; }
  IdxRef<TAYGDimension, &TATAYGStyle::maxDimensions_> maxDimensions() {
    return {*this};
  }

  // TAYoga specific properties, not compatible with flexbox specification
  TAYGFloatOptional aspectRatio() const { return aspectRatio_; }
  Ref<TAYGFloatOptional, &TATAYGStyle::aspectRatio_> aspectRatio() { return {*this}; }
};

TA_YOGA_EXPORT bool operator==(const TATAYGStyle& lhs, const TATAYGStyle& rhs);
TA_YOGA_EXPORT inline bool operator!=(const TATAYGStyle& lhs, const TATAYGStyle& rhs) {
  return !(lhs == rhs);
}

#endif
