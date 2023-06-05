
#ifdef DEBUG
#include "TAYGNodePrint.h"
#include <stdarg.h>
#include "TAYGEnums.h"
#include "TAYGNode.h"
#include "TAYoga-internal.h"
#include "TAYGUtils.h"

namespace thinkingdatalayout {
namespace ta_yoga {
typedef std::string string;

static void ta_indent(string& base, uint32_t level) {
  for (uint32_t i = 0; i < level; ++i) {
    base.append("  ");
  }
}

static bool ta_areFourValuesEqual(const TATAYGStyle::Edges& four) {
  return TAYGValueEqual(four[0], four[1]) && TAYGValueEqual(four[0], four[2]) &&
      TAYGValueEqual(four[0], four[3]);
}

static void ta_appendFormatedString(string& str, const char* fmt, ...) {
  va_list args;
  va_start(args, fmt);
  va_list argsCopy;
  va_copy(argsCopy, args);
  std::vector<char> buf(1 + vsnprintf(NULL, 0, fmt, args));
  va_end(args);
  vsnprintf(buf.data(), buf.size(), fmt, argsCopy);
  va_end(argsCopy);
  string result = string(buf.begin(), buf.end() - 1);
  str.append(result);
}

static void ta_appendFloatOptionalIfDefined(
    string& base,
    const string key,
    const TAYGFloatOptional num) {
  if (!num.isUndefined()) {
    ta_appendFormatedString(base, "%s: %g; ", key.c_str(), num.unwrap());
  }
}

static void ta_appendNumberIfNotUndefined(
    string& base,
    const string key,
    const TAYGValue number) {
  if (number.unit != TAYGUnitUndefined) {
    if (number.unit == TAYGUnitAuto) {
      base.append(key + ": auto; ");
    } else {
      string unit = number.unit == TAYGUnitPoint ? "px" : "%%";
      ta_appendFormatedString(
          base, "%s: %g%s; ", key.c_str(), number.value, unit.c_str());
    }
  }
}

static void ta_appendNumberIfNotAuto(
    string& base,
    const string& key,
    const TAYGValue number) {
  if (number.unit != TAYGUnitAuto) {
    ta_appendNumberIfNotUndefined(base, key, number);
  }
}

static void ta_appendNumberIfNotZero(
    string& base,
    const string& str,
    const TAYGValue number) {
  if (number.unit == TAYGUnitAuto) {
    base.append(str + ": auto; ");
  } else if (!TAYGFloatsEqual(number.value, 0)) {
    ta_appendNumberIfNotUndefined(base, str, number);
  }
}

static void ta_appendEdges(
    string& base,
    const string& key,
    const TATAYGStyle::Edges& edges) {
  if (ta_areFourValuesEqual(edges)) {
    ta_appendNumberIfNotZero(base, key, edges[TAYGEdgeLeft]);
  } else {
    for (int edge = TAYGEdgeLeft; edge != TAYGEdgeAll; ++edge) {
      string str = key + "-" + TAYGEdgeToString(static_cast<TAYGEdge>(edge));
      ta_appendNumberIfNotZero(base, str, edges[edge]);
    }
  }
}

static void ta_appendEdgeIfNotUndefined(
    string& base,
    const string& str,
    const TATAYGStyle::Edges& edges,
    const TAYGEdge edge) {
  // TODO: this doesn't take RTL / TAYGEdgeStart / TAYGEdgeEnd into account
  auto value = (edge == TAYGEdgeLeft || edge == TAYGEdgeRight)
      ? TAYGNode::computeEdgeValueForRow(
            edges, edge, edge, detail::TACompactValue::ofUndefined())
      : TAYGNode::computeEdgeValueForColumn(
            edges, edge, detail::TACompactValue::ofUndefined());
  ta_appendNumberIfNotUndefined(base, str, value);
}

void TAYGNodeToString(
    std::string& str,
    TAYGNodeRef node,
    TAYGPrintOptions options,
    uint32_t level) {
  ta_indent(str, level);
  ta_appendFormatedString(str, "<div ");

  if (options & TAYGPrintOptionsLayout) {
    ta_appendFormatedString(str, "layout=\"");
    ta_appendFormatedString(
        str, "width: %g; ", node->getLayout().dimensions[TAYGDimensionWidth]);
    ta_appendFormatedString(
        str, "height: %g; ", node->getLayout().dimensions[TAYGDimensionHeight]);
    ta_appendFormatedString(
        str, "top: %g; ", node->getLayout().position[TAYGEdgeTop]);
    ta_appendFormatedString(
        str, "left: %g;", node->getLayout().position[TAYGEdgeLeft]);
    ta_appendFormatedString(str, "\" ");
  }

  if (options & TAYGPrintOptionsStyle) {
    ta_appendFormatedString(str, "style=\"");
    const auto& style = node->getStyle();
    if (style.flexDirection() != TAYGNode().getStyle().flexDirection()) {
      ta_appendFormatedString(
          str,
          "flex-direction: %s; ",
          TAYGFlexDirectionToString(style.flexDirection()));
    }
    if (style.justifyContent() != TAYGNode().getStyle().justifyContent()) {
      ta_appendFormatedString(
          str,
          "justify-content: %s; ",
          TAYGJustifyToString(style.justifyContent()));
    }
    if (style.alignItems() != TAYGNode().getStyle().alignItems()) {
      ta_appendFormatedString(
          str, "align-items: %s; ", TAYGAlignToString(style.alignItems()));
    }
    if (style.alignContent() != TAYGNode().getStyle().alignContent()) {
      ta_appendFormatedString(
          str, "align-content: %s; ", TAYGAlignToString(style.alignContent()));
    }
    if (style.alignSelf() != TAYGNode().getStyle().alignSelf()) {
      ta_appendFormatedString(
          str, "align-self: %s; ", TAYGAlignToString(style.alignSelf()));
    }
    ta_appendFloatOptionalIfDefined(str, "flex-grow", style.flexGrow());
    ta_appendFloatOptionalIfDefined(str, "flex-shrink", style.flexShrink());
    ta_appendNumberIfNotAuto(str, "flex-basis", style.flexBasis());
    ta_appendFloatOptionalIfDefined(str, "flex", style.flex());

    if (style.flexWrap() != TAYGNode().getStyle().flexWrap()) {
      ta_appendFormatedString(
          str, "flex-wrap: %s; ", TAYGWrapToString(style.flexWrap()));
    }

    if (style.overflow() != TAYGNode().getStyle().overflow()) {
      ta_appendFormatedString(
          str, "overflow: %s; ", TAYGOverflowToString(style.overflow()));
    }

    if (style.display() != TAYGNode().getStyle().display()) {
      ta_appendFormatedString(
          str, "display: %s; ", TAYGDisplayToString(style.display()));
    }
    ta_appendEdges(str, "margin", style.margin());
    ta_appendEdges(str, "padding", style.padding());
    ta_appendEdges(str, "border", style.border());

    ta_appendNumberIfNotAuto(str, "width", style.dimensions()[TAYGDimensionWidth]);
    ta_appendNumberIfNotAuto(str, "height", style.dimensions()[TAYGDimensionHeight]);
    ta_appendNumberIfNotAuto(
        str, "max-width", style.maxDimensions()[TAYGDimensionWidth]);
    ta_appendNumberIfNotAuto(
        str, "max-height", style.maxDimensions()[TAYGDimensionHeight]);
    ta_appendNumberIfNotAuto(
        str, "min-width", style.minDimensions()[TAYGDimensionWidth]);
    ta_appendNumberIfNotAuto(
        str, "min-height", style.minDimensions()[TAYGDimensionHeight]);

    if (style.positionType() != TAYGNode().getStyle().positionType()) {
      ta_appendFormatedString(
          str, "position: %s; ", TAYGPositionTypeToString(style.positionType()));
    }

    ta_appendEdgeIfNotUndefined(str, "left", style.position(), TAYGEdgeLeft);
    ta_appendEdgeIfNotUndefined(str, "right", style.position(), TAYGEdgeRight);
    ta_appendEdgeIfNotUndefined(str, "top", style.position(), TAYGEdgeTop);
    ta_appendEdgeIfNotUndefined(str, "bottom", style.position(), TAYGEdgeBottom);
    ta_appendFormatedString(str, "\" ");

    if (node->hasMeasureFunc()) {
      ta_appendFormatedString(str, "has-custom-measure=\"true\"");
    }
  }
  ta_appendFormatedString(str, ">");

  const uint32_t childCount = static_cast<uint32_t>(node->getChildren().size());
  if (options & TAYGPrintOptionsChildren && childCount > 0) {
    for (uint32_t i = 0; i < childCount; i++) {
      ta_appendFormatedString(str, "\n");
      TAYGNodeToString(str, TAYGNodeGetChild(node, i), options, level + 1);
    }
    ta_appendFormatedString(str, "\n");
    ta_indent(str, level);
  }
  ta_appendFormatedString(str, "</div>");
}
} // namespace ta_yoga
} // namespace thinkingdatalayout
#endif
