
#pragma once

#include "TAYGMacros.h"

#ifdef __cplusplus
namespace thinkingdatalayout {
namespace ta_yoga {
namespace enums {

template <typename T>
constexpr int count(); // can't use `= delete` due to a defect in clang < 3.9

namespace detail {
template <int... xs>
constexpr int n() {
  return sizeof...(xs);
}
} // namespace detail

} // namespace enums
} // namespace ta_yoga
} // namespace thinkingdatalayout
#endif

#define YG_ENUM_DECL(NAME, ...)                               \
  typedef TA_YG_ENUM_BEGIN(NAME){__VA_ARGS__} TA_YG_ENUM_END(NAME); \
  WIN_EXPORT const char* NAME##ToString(NAME);

#ifdef __cplusplus
#define YG_ENUM_SEQ_DECL(NAME, ...)  \
  YG_ENUM_DECL(NAME, __VA_ARGS__)    \
  TA_YG_EXTERN_C_END                    \
  namespace thinkingdatalayout {               \
  namespace ta_yoga {                   \
  namespace enums {                  \
  template <>                        \
  constexpr int count<NAME>() {      \
    return detail::n<__VA_ARGS__>(); \
  }                                  \
  }                                  \
  }                                  \
  }                                  \
  TA_YG_EXTERN_C_BEGIN
#else
#define YG_ENUM_SEQ_DECL YG_ENUM_DECL
#endif

TA_YG_EXTERN_C_BEGIN

YG_ENUM_SEQ_DECL(
    TAYGAlign,
    TAYGAlignAuto,
    TAYGAlignFlexStart,
    TAYGAlignCenter,
    TAYGAlignFlexEnd,
    TAYGAlignStretch,
    TAYGAlignBaseline,
    TAYGAlignSpaceBetween,
    TAYGAlignSpaceAround);

YG_ENUM_SEQ_DECL(TAYGDimension, TAYGDimensionWidth, TAYGDimensionHeight)

YG_ENUM_SEQ_DECL(
    TAYGDirection,
    TAYGDirectionInherit,
    TAYGDirectionLTR,
    TAYGDirectionRTL)

YG_ENUM_SEQ_DECL(TAYGDisplay, TAYGDisplayFlex, TAYGDisplayNone)

YG_ENUM_SEQ_DECL(
    TAYGEdge,
    TAYGEdgeLeft,
    TAYGEdgeTop,
    TAYGEdgeRight,
    TAYGEdgeBottom,
    TAYGEdgeStart,
    TAYGEdgeEnd,
    TAYGEdgeHorizontal,
    TAYGEdgeVertical,
    TAYGEdgeAll)

YG_ENUM_SEQ_DECL(TAYGExperimentalFeature, TAYGExperimentalFeatureWebFlexBasis)

YG_ENUM_SEQ_DECL(
    TAYGFlexDirection,
    TAYGFlexDirectionColumn,
    YGFlexDirectionColumnReverse,
    TAYGFlexDirectionRow,
    TAYGFlexDirectionRowReverse)

YG_ENUM_SEQ_DECL(
    TAYGJustify,
    TAYGJustifyFlexStart,
    TAYGJustifyCenter,
    TAYGJustifyFlexEnd,
    TAYGJustifySpaceBetween,
    TAYGJustifySpaceAround,
    TAYGJustifySpaceEvenly)

YG_ENUM_SEQ_DECL(
    TAYGLogLevel,
    TAYGLogLevelError,
    TAYGLogLevelWarn,
    TAYGLogLevelInfo,
    TAYGLogLevelDebug,
    TAYGLogLevelVerbose,
    TAYGLogLevelFatal)

YG_ENUM_SEQ_DECL(
    TAYGMeasureMode,
    TAYGMeasureModeUndefined,
    TAYGMeasureModeExactly,
    TAYGMeasureModeAtMost)

YG_ENUM_SEQ_DECL(TAYGNodeType, TAYGNodeTypeDefault, TAYGNodeTypeText)

YG_ENUM_SEQ_DECL(
    TAYGOverflow,
    TAYGOverflowVisible,
    TAYGOverflowHidden,
    TAYGOverflowScroll)

YG_ENUM_SEQ_DECL(
    TAYGPositionType,
    TAYGPositionTypeStatic,
    TAYGPositionTypeRelative,
    TAYGPositionTypeAbsolute)

YG_ENUM_DECL(
    TAYGPrintOptions,
    TAYGPrintOptionsLayout = 1,
    TAYGPrintOptionsStyle = 2,
    TAYGPrintOptionsChildren = 4)

YG_ENUM_SEQ_DECL(
    TAYGUnit,
    TAYGUnitUndefined,
    TAYGUnitPoint,
    TAYGUnitPercent,
    TAYGUnitAuto)

YG_ENUM_SEQ_DECL(TAYGWrap, TAYGWrapNoWrap, TAYGWrapWrap, TAYGWrapWrapReverse)

TA_YG_EXTERN_C_END

#undef YG_ENUM_DECL
#undef YG_ENUM_SEQ_DECL
