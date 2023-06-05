

#include "TAYGNode.h"
#include <algorithm>
#include <iostream>
#include "TACompactValue.h"
#include "TAYGUtils.h"

using namespace thinkingdatalayout;
using thinkingdatalayout::ta_yoga::detail::TACompactValue;

TAYGNode::TAYGNode(TAYGNode&& node) {
  context_ = node.context_;
  flags = node.flags;
  measure_ = node.measure_;
  baseline_ = node.baseline_;
  print_ = node.print_;
  dirtied_ = node.dirtied_;
  style_ = node.style_;
  layout_ = node.layout_;
  lineIndex_ = node.lineIndex_;
  owner_ = node.owner_;
  children_ = std::move(node.children_);
  config_ = node.config_;
  resolvedDimensions_ = node.resolvedDimensions_;
  for (auto c : children_) {
    c->setOwner(this);
  }
}

TAYGNode::TAYGNode(const TAYGNode& node, TAYGConfigRef config) : TAYGNode{node} {
  config_ = config;
  if (config->useWebDefaults) {
    useWebDefaults();
  }
}

void TAYGNode::print(void* printContext) {
  if (print_.noContext != nullptr) {
    if (thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, printUsesContext_)) {
      print_.withContext(this, printContext);
    } else {
      print_.noContext(this);
    }
  }
}

TACompactValue TAYGNode::computeEdgeValueForRow(
    const TATAYGStyle::Edges& edges,
    TAYGEdge rowEdge,
    TAYGEdge edge,
    TACompactValue defaultValue) {
  if (!edges[rowEdge].isUndefined()) {
    return edges[rowEdge];
  } else if (!edges[edge].isUndefined()) {
    return edges[edge];
  } else if (!edges[TAYGEdgeHorizontal].isUndefined()) {
    return edges[TAYGEdgeHorizontal];
  } else if (!edges[TAYGEdgeAll].isUndefined()) {
    return edges[TAYGEdgeAll];
  } else {
    return defaultValue;
  }
}

TACompactValue TAYGNode::computeEdgeValueForColumn(
    const TATAYGStyle::Edges& edges,
    TAYGEdge edge,
    TACompactValue defaultValue) {
  if (!edges[edge].isUndefined()) {
    return edges[edge];
  } else if (!edges[TAYGEdgeVertical].isUndefined()) {
    return edges[TAYGEdgeVertical];
  } else if (!edges[TAYGEdgeAll].isUndefined()) {
    return edges[TAYGEdgeAll];
  } else {
    return defaultValue;
  }
}

TAYGFloatOptional TAYGNode::getLeadingPosition(
    const TAYGFlexDirection axis,
    const float axisSize) const {
  auto leadingPosition = TAYGFlexDirectionIsRow(axis)
      ? computeEdgeValueForRow(
            style_.position(),
            TAYGEdgeStart,
            ta_leading[axis],
            TACompactValue::ofZero())
      : computeEdgeValueForColumn(
            style_.position(), ta_leading[axis], TACompactValue::ofZero());
  return TAYGResolveValue(leadingPosition, axisSize);
}

TAYGFloatOptional TAYGNode::getTrailingPosition(
    const TAYGFlexDirection axis,
    const float axisSize) const {
  auto trailingPosition = TAYGFlexDirectionIsRow(axis)
      ? computeEdgeValueForRow(
            style_.position(),
            TAYGEdgeEnd,
            ta_trailing[axis],
            TACompactValue::ofZero())
      : computeEdgeValueForColumn(
            style_.position(), ta_trailing[axis], TACompactValue::ofZero());
  return TAYGResolveValue(trailingPosition, axisSize);
}

bool TAYGNode::isLeadingPositionDefined(const TAYGFlexDirection axis) const {
  auto leadingPosition = TAYGFlexDirectionIsRow(axis)
      ? computeEdgeValueForRow(
            style_.position(),
            TAYGEdgeStart,
            ta_leading[axis],
            TACompactValue::ofUndefined())
      : computeEdgeValueForColumn(
            style_.position(), ta_leading[axis], TACompactValue::ofUndefined());
  return !leadingPosition.isUndefined();
}

bool TAYGNode::isTrailingPosDefined(const TAYGFlexDirection axis) const {
  auto trailingPosition = TAYGFlexDirectionIsRow(axis)
      ? computeEdgeValueForRow(
            style_.position(),
            TAYGEdgeEnd,
            ta_trailing[axis],
            TACompactValue::ofUndefined())
      : computeEdgeValueForColumn(
            style_.position(), ta_trailing[axis], TACompactValue::ofUndefined());
  return !trailingPosition.isUndefined();
}

TAYGFloatOptional TAYGNode::getLeadingMargin(
    const TAYGFlexDirection axis,
    const float widthSize) const {
  auto leadingMargin = TAYGFlexDirectionIsRow(axis)
      ? computeEdgeValueForRow(
            style_.margin(), TAYGEdgeStart, ta_leading[axis], TACompactValue::ofZero())
      : computeEdgeValueForColumn(
            style_.margin(), ta_leading[axis], TACompactValue::ofZero());
  return TAYGResolveValueMargin(leadingMargin, widthSize);
}

TAYGFloatOptional TAYGNode::getTrailingMargin(
    const TAYGFlexDirection axis,
    const float widthSize) const {
  auto trailingMargin = TAYGFlexDirectionIsRow(axis)
      ? computeEdgeValueForRow(
            style_.margin(), TAYGEdgeEnd, ta_trailing[axis], TACompactValue::ofZero())
      : computeEdgeValueForColumn(
            style_.margin(), ta_trailing[axis], TACompactValue::ofZero());
  return TAYGResolveValueMargin(trailingMargin, widthSize);
}

TAYGFloatOptional TAYGNode::getMarginForAxis(
    const TAYGFlexDirection axis,
    const float widthSize) const {
  return getLeadingMargin(axis, widthSize) + getTrailingMargin(axis, widthSize);
}

TAYGSize TAYGNode::measure(
    float width,
    TAYGMeasureMode widthMode,
    float height,
    TAYGMeasureMode heightMode,
    void* layoutContext) {
  return thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, measureUsesContext_)
      ? measure_.withContext(
            this, width, widthMode, height, heightMode, layoutContext)
      : measure_.noContext(this, width, widthMode, height, heightMode);
}

float TAYGNode::baseline(float width, float height, void* layoutContext) {
  return thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, baselineUsesContext_)
      ? baseline_.withContext(this, width, height, layoutContext)
      : baseline_.noContext(this, width, height);
}

// Setters

void TAYGNode::setMeasureFunc(decltype(TAYGNode::measure_) measureFunc) {
  if (measureFunc.noContext == nullptr) {
    // TODO: t18095186 Move nodeType to opt-in function and mark appropriate
    // places in Litho
    setNodeType(TAYGNodeTypeDefault);
  } else {
    TAYGAssertWithNode(
        this,
        children_.size() == 0,
        "Cannot set measure function: Nodes with measure functions cannot have "
        "children.");
    // TODO: t18095186 Move nodeType to opt-in function and mark appropriate
    // places in Litho
    setNodeType(TAYGNodeTypeText);
  }

  measure_ = measureFunc;
}

void TAYGNode::setMeasureFunc(TAYGMeasureFunc measureFunc) {
  thinkingdatalayout::ta_yoga::detail::setBooleanData(flags, measureUsesContext_, false);
  decltype(TAYGNode::measure_) m;
  m.noContext = measureFunc;
  setMeasureFunc(m);
}

TA_YOGA_EXPORT void TAYGNode::setMeasureFunc(TAMeasureWithContextFn measureFunc) {
  thinkingdatalayout::ta_yoga::detail::setBooleanData(flags, measureUsesContext_, true);
  decltype(TAYGNode::measure_) m;
  m.withContext = measureFunc;
  setMeasureFunc(m);
}

void TAYGNode::replaceChild(TAYGNodeRef child, uint32_t index) {
  children_[index] = child;
}

void TAYGNode::replaceChild(TAYGNodeRef oldChild, TAYGNodeRef newChild) {
  std::replace(children_.begin(), children_.end(), oldChild, newChild);
}

void TAYGNode::insertChild(TAYGNodeRef child, uint32_t index) {
  children_.insert(children_.begin() + index, child);
}

void TAYGNode::setDirty(bool isDirty) {
  if (isDirty == thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, isDirty_)) {
    return;
  }
  thinkingdatalayout::ta_yoga::detail::setBooleanData(flags, isDirty_, isDirty);
  if (isDirty && dirtied_) {
    dirtied_(this);
  }
}

bool TAYGNode::removeChild(TAYGNodeRef child) {
  std::vector<TAYGNodeRef>::iterator p =
      std::find(children_.begin(), children_.end(), child);
  if (p != children_.end()) {
    children_.erase(p);
    return true;
  }
  return false;
}

void TAYGNode::removeChild(uint32_t index) {
  children_.erase(children_.begin() + index);
}

void TAYGNode::setLayoutDirection(TAYGDirection direction) {
  layout_.setDirection(direction);
}

void TAYGNode::setLayoutMargin(float margin, int index) {
  layout_.margin[index] = margin;
}

void TAYGNode::setLayoutBorder(float border, int index) {
  layout_.border[index] = border;
}

void TAYGNode::setLayoutPadding(float padding, int index) {
  layout_.padding[index] = padding;
}

void TAYGNode::setLayoutLastOwnerDirection(TAYGDirection direction) {
  layout_.lastOwnerDirection = direction;
}

void TAYGNode::setLayoutComputedFlexBasis(
    const TAYGFloatOptional computedFlexBasis) {
  layout_.computedFlexBasis = computedFlexBasis;
}

void TAYGNode::setLayoutPosition(float position, int index) {
  layout_.position[index] = position;
}

void TAYGNode::setLayoutComputedFlexBasisGeneration(
    uint32_t computedFlexBasisGeneration) {
  layout_.computedFlexBasisGeneration = computedFlexBasisGeneration;
}

void TAYGNode::setLayoutMeasuredDimension(float measuredDimension, int index) {
  layout_.measuredDimensions[index] = measuredDimension;
}

void TAYGNode::setLayoutHadOverflow(bool hadOverflow) {
  layout_.setHadOverflow(hadOverflow);
}

void TAYGNode::setLayoutDimension(float dimension, int index) {
  layout_.dimensions[index] = dimension;
}

// If both left and right are defined, then use left. Otherwise return +left or
// -right depending on which is defined.
TAYGFloatOptional TAYGNode::relativePosition(
    const TAYGFlexDirection axis,
    const float axisSize) const {
  if (isLeadingPositionDefined(axis)) {
    return getLeadingPosition(axis, axisSize);
  }

  TAYGFloatOptional trailingPosition = getTrailingPosition(axis, axisSize);
  if (!trailingPosition.isUndefined()) {
    trailingPosition = TAYGFloatOptional{-1 * trailingPosition.unwrap()};
  }
  return trailingPosition;
}

void TAYGNode::setPosition(
    const TAYGDirection direction,
    const float mainSize,
    const float crossSize,
    const float ownerWidth) {
  /* Root nodes should be always layouted as LTR, so we don't return negative
   * values. */
  const TAYGDirection directionRespectingRoot =
      owner_ != nullptr ? direction : TAYGDirectionLTR;
  const TAYGFlexDirection mainAxis =
      TAYGResolveFlexDirection(style_.flexDirection(), directionRespectingRoot);
  const TAYGFlexDirection crossAxis =
      TAYGFlexDirectionCross(mainAxis, directionRespectingRoot);

  // Here we should check for `TAYGPositionTypeStatic` and in this case zero inset
  // properties (left, right, top, bottom, begin, end).
  // https://www.w3.org/TR/css-position-3/#valdef-position-static
  const TAYGFloatOptional relativePositionMain =
      relativePosition(mainAxis, mainSize);
  const TAYGFloatOptional relativePositionCross =
      relativePosition(crossAxis, crossSize);

  setLayoutPosition(
      (getLeadingMargin(mainAxis, ownerWidth) + relativePositionMain).unwrap(),
      ta_leading[mainAxis]);
  setLayoutPosition(
      (getTrailingMargin(mainAxis, ownerWidth) + relativePositionMain).unwrap(),
      ta_trailing[mainAxis]);
  setLayoutPosition(
      (getLeadingMargin(crossAxis, ownerWidth) + relativePositionCross)
          .unwrap(),
      ta_leading[crossAxis]);
  setLayoutPosition(
      (getTrailingMargin(crossAxis, ownerWidth) + relativePositionCross)
          .unwrap(),
      ta_trailing[crossAxis]);
}

TAYGValue TAYGNode::marginLeadingValue(const TAYGFlexDirection axis) const {
  if (TAYGFlexDirectionIsRow(axis) &&
      !style_.margin()[TAYGEdgeStart].isUndefined()) {
    return style_.margin()[TAYGEdgeStart];
  } else {
    return style_.margin()[ta_leading[axis]];
  }
}

TAYGValue TAYGNode::marginTrailingValue(const TAYGFlexDirection axis) const {
  if (TAYGFlexDirectionIsRow(axis) && !style_.margin()[TAYGEdgeEnd].isUndefined()) {
    return style_.margin()[TAYGEdgeEnd];
  } else {
    return style_.margin()[ta_trailing[axis]];
  }
}

TAYGValue TAYGNode::resolveFlexBasisPtr() const {
  TAYGValue flexBasis = style_.flexBasis();
  if (flexBasis.unit != TAYGUnitAuto && flexBasis.unit != TAYGUnitUndefined) {
    return flexBasis;
  }
  if (!style_.flex().isUndefined() && style_.flex().unwrap() > 0.0f) {
    return thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, useWebDefaults_)
        ? TAYGValueAuto
        : TAYGValueZero;
  }
  return TAYGValueAuto;
}

void TAYGNode::resolveDimension() {
  using namespace ta_yoga;
  const TATAYGStyle& style = getStyle();
  for (auto dim : {TAYGDimensionWidth, TAYGDimensionHeight}) {
    if (!style.maxDimensions()[dim].isUndefined() &&
        TAYGValueEqual(style.maxDimensions()[dim], style.minDimensions()[dim])) {
      resolvedDimensions_[dim] = style.maxDimensions()[dim];
    } else {
      resolvedDimensions_[dim] = style.dimensions()[dim];
    }
  }
}

TAYGDirection TAYGNode::resolveDirection(const TAYGDirection ownerDirection) {
  if (style_.direction() == TAYGDirectionInherit) {
    return ownerDirection > TAYGDirectionInherit ? ownerDirection
                                               : TAYGDirectionLTR;
  } else {
    return style_.direction();
  }
}

TA_YOGA_EXPORT void TAYGNode::clearChildren() {
  children_.clear();
  children_.shrink_to_fit();
}

// Other Methods

void TAYGNode::cloneChildrenIfNeeded(void* cloneContext) {
  iterChildrenAfterCloningIfNeeded([](TAYGNodeRef, void*) {}, cloneContext);
}

void TAYGNode::markDirtyAndPropogate() {
  if (!thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, isDirty_)) {
    setDirty(true);
    setLayoutComputedFlexBasis(TAYGFloatOptional());
    if (owner_) {
      owner_->markDirtyAndPropogate();
    }
  }
}

void TAYGNode::markDirtyAndPropogateDownwards() {
  thinkingdatalayout::ta_yoga::detail::setBooleanData(flags, isDirty_, true);
  for_each(children_.begin(), children_.end(), [](TAYGNodeRef childNode) {
    childNode->markDirtyAndPropogateDownwards();
  });
}

float TAYGNode::resolveFlexGrow() const {
  // Root nodes flexGrow should always be 0
  if (owner_ == nullptr) {
    return 0.0;
  }
  if (!style_.flexGrow().isUndefined()) {
    return style_.flexGrow().unwrap();
  }
  if (!style_.flex().isUndefined() && style_.flex().unwrap() > 0.0f) {
    return style_.flex().unwrap();
  }
  return kDefaultFlexGrow;
}

float TAYGNode::resolveFlexShrink() const {
  if (owner_ == nullptr) {
    return 0.0;
  }
  if (!style_.flexShrink().isUndefined()) {
    return style_.flexShrink().unwrap();
  }
  if (!thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, useWebDefaults_) &&
      !style_.flex().isUndefined() && style_.flex().unwrap() < 0.0f) {
    return -style_.flex().unwrap();
  }
  return thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, useWebDefaults_)
      ? kWebDefaultFlexShrink
      : kDefaultFlexShrink;
}

bool TAYGNode::isNodeFlexible() {
  return (
      (style_.positionType() != TAYGPositionTypeAbsolute) &&
      (resolveFlexGrow() != 0 || resolveFlexShrink() != 0));
}

float TAYGNode::getLeadingBorder(const TAYGFlexDirection axis) const {
  TAYGValue leadingBorder = TAYGFlexDirectionIsRow(axis)
      ? computeEdgeValueForRow(
            style_.border(), TAYGEdgeStart, ta_leading[axis], TACompactValue::ofZero())
      : computeEdgeValueForColumn(
            style_.border(), ta_leading[axis], TACompactValue::ofZero());
  return fmaxf(leadingBorder.value, 0.0f);
}

float TAYGNode::getTrailingBorder(const TAYGFlexDirection axis) const {
  TAYGValue trailingBorder = TAYGFlexDirectionIsRow(axis)
      ? computeEdgeValueForRow(
            style_.border(), TAYGEdgeEnd, ta_trailing[axis], TACompactValue::ofZero())
      : computeEdgeValueForColumn(
            style_.border(), ta_trailing[axis], TACompactValue::ofZero());
  return fmaxf(trailingBorder.value, 0.0f);
}

TAYGFloatOptional TAYGNode::getLeadingPadding(
    const TAYGFlexDirection axis,
    const float widthSize) const {
  auto leadingPadding = TAYGFlexDirectionIsRow(axis)
      ? computeEdgeValueForRow(
            style_.padding(),
            TAYGEdgeStart,
            ta_leading[axis],
            TACompactValue::ofZero())
      : computeEdgeValueForColumn(
            style_.padding(), ta_leading[axis], TACompactValue::ofZero());
  return TAYGFloatOptionalMax(
      TAYGResolveValue(leadingPadding, widthSize), TAYGFloatOptional(0.0f));
}

TAYGFloatOptional TAYGNode::getTrailingPadding(
    const TAYGFlexDirection axis,
    const float widthSize) const {
  auto trailingPadding = TAYGFlexDirectionIsRow(axis)
      ? computeEdgeValueForRow(
            style_.padding(), TAYGEdgeEnd, ta_trailing[axis], TACompactValue::ofZero())
      : computeEdgeValueForColumn(
            style_.padding(), ta_trailing[axis], TACompactValue::ofZero());
  return TAYGFloatOptionalMax(
      TAYGResolveValue(trailingPadding, widthSize), TAYGFloatOptional(0.0f));
}

TAYGFloatOptional TAYGNode::getLeadingPaddingAndBorder(
    const TAYGFlexDirection axis,
    const float widthSize) const {
  return getLeadingPadding(axis, widthSize) +
      TAYGFloatOptional(getLeadingBorder(axis));
}

TAYGFloatOptional TAYGNode::getTrailingPaddingAndBorder(
    const TAYGFlexDirection axis,
    const float widthSize) const {
  return getTrailingPadding(axis, widthSize) +
      TAYGFloatOptional(getTrailingBorder(axis));
}

bool TAYGNode::didUseLegacyFlag() {
  bool didUseLegacyFlag = layout_.didUseLegacyFlag();
  if (didUseLegacyFlag) {
    return true;
  }
  for (const auto& child : children_) {
    if (child->layout_.didUseLegacyFlag()) {
      didUseLegacyFlag = true;
      break;
    }
  }
  return didUseLegacyFlag;
}

void TAYGNode::setLayoutDoesLegacyFlagAffectsLayout(
    bool doesLegacyFlagAffectsLayout) {
  layout_.setDoesLegacyStretchFlagAffectsLayout(doesLegacyFlagAffectsLayout);
}

void TAYGNode::setLayoutDidUseLegacyFlag(bool didUseLegacyFlag) {
  layout_.setDidUseLegacyFlag(didUseLegacyFlag);
}

bool TAYGNode::isLayoutTreeEqualToNode(const TAYGNode& node) const {
  if (children_.size() != node.children_.size()) {
    return false;
  }
  if (layout_ != node.layout_) {
    return false;
  }
  if (children_.size() == 0) {
    return true;
  }

  bool isLayoutTreeEqual = true;
  TAYGNodeRef otherNodeChildren = nullptr;
  for (std::vector<TAYGNodeRef>::size_type i = 0; i < children_.size(); ++i) {
    otherNodeChildren = node.children_[i];
    isLayoutTreeEqual =
        children_[i]->isLayoutTreeEqualToNode(*otherNodeChildren);
    if (!isLayoutTreeEqual) {
      return false;
    }
  }
  return isLayoutTreeEqual;
}

void TAYGNode::reset() {
  TAYGAssertWithNode(
      this,
      children_.size() == 0,
      "Cannot reset a node which still has children attached");
  TAYGAssertWithNode(
      this, owner_ == nullptr, "Cannot reset a node still attached to a owner");

  clearChildren();

  auto webDefaults =
      thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, useWebDefaults_);
  *this = TAYGNode{getConfig()};
  if (webDefaults) {
    useWebDefaults();
  }
}
