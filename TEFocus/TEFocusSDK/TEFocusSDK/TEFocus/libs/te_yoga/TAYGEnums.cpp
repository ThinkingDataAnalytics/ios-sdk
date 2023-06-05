
#include "TAYGEnums.h"

const char* TAYGAlignToString(const TAYGAlign value) {
  switch (value) {
    case TAYGAlignAuto:
      return "auto";
    case TAYGAlignFlexStart:
      return "flex-start";
    case TAYGAlignCenter:
      return "center";
    case TAYGAlignFlexEnd:
      return "flex-end";
    case TAYGAlignStretch:
      return "stretch";
    case TAYGAlignBaseline:
      return "baseline";
    case TAYGAlignSpaceBetween:
      return "space-between";
    case TAYGAlignSpaceAround:
      return "space-around";
  }
  return "unknown";
}

const char* TAYGDimensionToString(const TAYGDimension value) {
  switch (value) {
    case TAYGDimensionWidth:
      return "width";
    case TAYGDimensionHeight:
      return "height";
  }
  return "unknown";
}

const char* TAYGDirectionToString(const TAYGDirection value) {
  switch (value) {
    case TAYGDirectionInherit:
      return "inherit";
    case TAYGDirectionLTR:
      return "ltr";
    case TAYGDirectionRTL:
      return "rtl";
  }
  return "unknown";
}

const char* TAYGDisplayToString(const TAYGDisplay value) {
  switch (value) {
    case TAYGDisplayFlex:
      return "flex";
    case TAYGDisplayNone:
      return "none";
  }
  return "unknown";
}

const char* TAYGEdgeToString(const TAYGEdge value) {
  switch (value) {
    case TAYGEdgeLeft:
      return "left";
    case TAYGEdgeTop:
      return "top";
    case TAYGEdgeRight:
      return "right";
    case TAYGEdgeBottom:
      return "bottom";
    case TAYGEdgeStart:
      return "start";
    case TAYGEdgeEnd:
      return "end";
    case TAYGEdgeHorizontal:
      return "horizontal";
    case TAYGEdgeVertical:
      return "vertical";
    case TAYGEdgeAll:
      return "all";
  }
  return "unknown";
}

const char* TAYGExperimentalFeatureToString(const TAYGExperimentalFeature value) {
  switch (value) {
    case TAYGExperimentalFeatureWebFlexBasis:
      return "web-flex-basis";
  }
  return "unknown";
}

const char* TAYGFlexDirectionToString(const TAYGFlexDirection value) {
  switch (value) {
    case TAYGFlexDirectionColumn:
      return "column";
    case YGFlexDirectionColumnReverse:
      return "column-reverse";
    case TAYGFlexDirectionRow:
      return "row";
    case TAYGFlexDirectionRowReverse:
      return "row-reverse";
  }
  return "unknown";
}

const char* TAYGJustifyToString(const TAYGJustify value) {
  switch (value) {
    case TAYGJustifyFlexStart:
      return "flex-start";
    case TAYGJustifyCenter:
      return "center";
    case TAYGJustifyFlexEnd:
      return "flex-end";
    case TAYGJustifySpaceBetween:
      return "space-between";
    case TAYGJustifySpaceAround:
      return "space-around";
    case TAYGJustifySpaceEvenly:
      return "space-evenly";
  }
  return "unknown";
}

const char* TAYGLogLevelToString(const TAYGLogLevel value) {
  switch (value) {
    case TAYGLogLevelError:
      return "error";
    case TAYGLogLevelWarn:
      return "warn";
    case TAYGLogLevelInfo:
      return "info";
    case TAYGLogLevelDebug:
      return "debug";
    case TAYGLogLevelVerbose:
      return "verbose";
    case TAYGLogLevelFatal:
      return "fatal";
  }
  return "unknown";
}

const char* TAYGMeasureModeToString(const TAYGMeasureMode value) {
  switch (value) {
    case TAYGMeasureModeUndefined:
      return "undefined";
    case TAYGMeasureModeExactly:
      return "exactly";
    case TAYGMeasureModeAtMost:
      return "at-most";
  }
  return "unknown";
}

const char* TAYGNodeTypeToString(const TAYGNodeType value) {
  switch (value) {
    case TAYGNodeTypeDefault:
      return "default";
    case TAYGNodeTypeText:
      return "text";
  }
  return "unknown";
}

const char* TAYGOverflowToString(const TAYGOverflow value) {
  switch (value) {
    case TAYGOverflowVisible:
      return "visible";
    case TAYGOverflowHidden:
      return "hidden";
    case TAYGOverflowScroll:
      return "scroll";
  }
  return "unknown";
}

const char* TAYGPositionTypeToString(const TAYGPositionType value) {
  switch (value) {
    case TAYGPositionTypeStatic:
      return "static";
    case TAYGPositionTypeRelative:
      return "relative";
    case TAYGPositionTypeAbsolute:
      return "absolute";
  }
  return "unknown";
}

const char* YGPrintOptionsToString(const TAYGPrintOptions value) {
  switch (value) {
    case TAYGPrintOptionsLayout:
      return "layout";
    case TAYGPrintOptionsStyle:
      return "style";
    case TAYGPrintOptionsChildren:
      return "children";
  }
  return "unknown";
}

const char* YGUnitToString(const TAYGUnit value) {
  switch (value) {
    case TAYGUnitUndefined:
      return "undefined";
    case TAYGUnitPoint:
      return "point";
    case TAYGUnitPercent:
      return "percent";
    case TAYGUnitAuto:
      return "auto";
  }
  return "unknown";
}

const char* TAYGWrapToString(const TAYGWrap value) {
  switch (value) {
    case TAYGWrapNoWrap:
      return "no-wrap";
    case TAYGWrapWrap:
      return "wrap";
    case TAYGWrapWrapReverse:
      return "wrap-reverse";
  }
  return "unknown";
}
