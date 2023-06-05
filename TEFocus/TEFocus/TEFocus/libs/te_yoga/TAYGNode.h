
#pragma once

#ifdef __cplusplus

#include <cstdint>
#include <stdio.h>
#include "TABitUtils.h"
#include "TACompactValue.h"
#include "TAYGConfig.h"
#include "TAYGLayout.h"
#include "TAYGStyle.h"
#include "TAYGMacros.h"
#include "TAYoga-internal.h"

TAYGConfigRef TAYGConfigGetDefault();

struct TA_YOGA_EXPORT TAYGNode {
  using TAMeasureWithContextFn =
      TAYGSize (*)(TAYGNode*, float, TAYGMeasureMode, float, TAYGMeasureMode, void*);
  using TABaselineWithContextFn = float (*)(TAYGNode*, float, float, void*);
  using TAPrintWithContextFn = void (*)(TAYGNode*, void*);

private:
  static constexpr size_t hasNewLayout_ = 0;
  static constexpr size_t isReferenceBaseline_ = 1;
  static constexpr size_t isDirty_ = 2;
  static constexpr size_t nodeType_ = 3;
  static constexpr size_t measureUsesContext_ = 4;
  static constexpr size_t baselineUsesContext_ = 5;
  static constexpr size_t printUsesContext_ = 6;
  static constexpr size_t useWebDefaults_ = 7;

  void* context_ = nullptr;
  uint8_t flags = 1;
  uint8_t reserved_ = 0;
  union {
    TAYGMeasureFunc noContext;
    TAMeasureWithContextFn withContext;
  } measure_ = {nullptr};
  union {
    TAYGBaselineFunc noContext;
    TABaselineWithContextFn withContext;
  } baseline_ = {nullptr};
  union {
    TAYGPrintFunc noContext;
    TAPrintWithContextFn withContext;
  } print_ = {nullptr};
  TAYGDirtiedFunc dirtied_ = nullptr;
  TATAYGStyle style_ = {};
  TAYGLayout layout_ = {};
  uint32_t lineIndex_ = 0;
  TAYGNodeRef owner_ = nullptr;
  TAYGVector children_ = {};
  TAYGConfigRef config_;
  std::array<TAYGValue, 2> resolvedDimensions_ = {
      {TAYGValueUndefined, TAYGValueUndefined}};

  TAYGFloatOptional relativePosition(
      const TAYGFlexDirection axis,
      const float axisSize) const;

  void setMeasureFunc(decltype(measure_));
  void setBaselineFunc(decltype(baseline_));

  void useWebDefaults() {
    thinkingdatalayout::ta_yoga::detail::setBooleanData(flags, useWebDefaults_, true);
    style_.flexDirection() = TAYGFlexDirectionRow;
    style_.alignContent() = TAYGAlignStretch;
  }

  // DANGER DANGER DANGER!
  // If the node assigned to has children, we'd either have to deallocate
  // them (potentially incorrect) or ignore them (danger of leaks). Only ever
  // use this after checking that there are no children.
  // DO NOT CHANGE THE VISIBILITY OF THIS METHOD!
  TAYGNode& operator=(TAYGNode&&) = default;

  using TACompactValue = thinkingdatalayout::ta_yoga::detail::TACompactValue;

public:
  TAYGNode() : TAYGNode{TAYGConfigGetDefault()} {}
  explicit TAYGNode(const TAYGConfigRef config) : config_{config} {
    if (config->useWebDefaults) {
      useWebDefaults();
    }
  };
  ~TAYGNode() = default; // cleanup of owner/children relationships in TAYGNodeFree

  TAYGNode(TAYGNode&&);

  // Does not expose true value semantics, as children are not cloned eagerly.
  // Should we remove this?
  TAYGNode(const TAYGNode& node) = default;

  // for RB fabric
  TAYGNode(const TAYGNode& node, TAYGConfigRef config);

  // assignment means potential leaks of existing children, or alternatively
  // freeing unowned memory, double free, or freeing stack memory.
  TAYGNode& operator=(const TAYGNode&) = delete;

  // Getters
  void* getContext() const { return context_; }

  uint8_t& reserved() { return reserved_; }
  uint8_t reserved() const { return reserved_; }

  void print(void*);

  bool getHasNewLayout() const {
    return thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, hasNewLayout_);
  }

  TAYGNodeType getNodeType() const {
    return thinkingdatalayout::ta_yoga::detail::getEnumData<TAYGNodeType>(flags, nodeType_);
  }

  bool hasMeasureFunc() const noexcept { return measure_.noContext != nullptr; }

  TAYGSize measure(float, TAYGMeasureMode, float, TAYGMeasureMode, void*);

  bool hasBaselineFunc() const noexcept {
    return baseline_.noContext != nullptr;
  }

  float baseline(float width, float height, void* layoutContext);

  TAYGDirtiedFunc getDirtied() const { return dirtied_; }

  // For Performance reasons passing as reference.
  TATAYGStyle& getStyle() { return style_; }

  const TATAYGStyle& getStyle() const { return style_; }

  // For Performance reasons passing as reference.
  TAYGLayout& getLayout() { return layout_; }

  const TAYGLayout& getLayout() const { return layout_; }

  uint32_t getLineIndex() const { return lineIndex_; }

  bool ta_isReferenceBaseline() {
    return thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, isReferenceBaseline_);
  }

  // returns the TAYGNodeRef that owns this TAYGNode. An owner is used to identify
  // the YogaTree that a TAYGNode belongs to. This method will return the parent
  // of the TAYGNode when a TAYGNode only belongs to one YogaTree or nullptr when
  // the TAYGNode is shared between two or more YogaTrees.
  TAYGNodeRef getOwner() const { return owner_; }

  // Deprecated, use getOwner() instead.
  TAYGNodeRef getParent() const { return getOwner(); }

  const TAYGVector& getChildren() const { return children_; }

  // Applies a callback to all children, after cloning them if they are not
  // owned.
  template <typename T>
  void iterChildrenAfterCloningIfNeeded(T callback, void* cloneContext) {
    int i = 0;
    for (TAYGNodeRef& child : children_) {
      if (child->getOwner() != this) {
        child = config_->cloneNode(child, this, i, cloneContext);
        child->setOwner(this);
      }
      i += 1;

      callback(child, cloneContext);
    }
  }

  TAYGNodeRef getChild(uint32_t index) const { return children_.at(index); }

  TAYGConfigRef getConfig() const { return config_; }

  bool isDirty() const {
    return thinkingdatalayout::ta_yoga::detail::getBooleanData(flags, isDirty_);
  }

  std::array<TAYGValue, 2> getResolvedDimensions() const {
    return resolvedDimensions_;
  }

  TAYGValue getResolvedDimension(int index) const {
    return resolvedDimensions_[index];
  }

  static TACompactValue computeEdgeValueForColumn(
      const TATAYGStyle::Edges& edges,
      TAYGEdge edge,
      TACompactValue defaultValue);

  static TACompactValue computeEdgeValueForRow(
      const TATAYGStyle::Edges& edges,
      TAYGEdge rowEdge,
      TAYGEdge edge,
      TACompactValue defaultValue);

  // Methods related to positions, margin, padding and border
  TAYGFloatOptional getLeadingPosition(
      const TAYGFlexDirection axis,
      const float axisSize) const;
  bool isLeadingPositionDefined(const TAYGFlexDirection axis) const;
  bool isTrailingPosDefined(const TAYGFlexDirection axis) const;
  TAYGFloatOptional getTrailingPosition(
      const TAYGFlexDirection axis,
      const float axisSize) const;
  TAYGFloatOptional getLeadingMargin(
      const TAYGFlexDirection axis,
      const float widthSize) const;
  TAYGFloatOptional getTrailingMargin(
      const TAYGFlexDirection axis,
      const float widthSize) const;
  float getLeadingBorder(const TAYGFlexDirection flexDirection) const;
  float getTrailingBorder(const TAYGFlexDirection flexDirection) const;
  TAYGFloatOptional getLeadingPadding(
      const TAYGFlexDirection axis,
      const float widthSize) const;
  TAYGFloatOptional getTrailingPadding(
      const TAYGFlexDirection axis,
      const float widthSize) const;
  TAYGFloatOptional getLeadingPaddingAndBorder(
      const TAYGFlexDirection axis,
      const float widthSize) const;
  TAYGFloatOptional getTrailingPaddingAndBorder(
      const TAYGFlexDirection axis,
      const float widthSize) const;
  TAYGFloatOptional getMarginForAxis(
      const TAYGFlexDirection axis,
      const float widthSize) const;
  // Setters

  void setContext(void* context) { context_ = context; }

  void setPrintFunc(TAYGPrintFunc printFunc) {
    print_.noContext = printFunc;
    thinkingdatalayout::ta_yoga::detail::setBooleanData(flags, printUsesContext_, false);
  }
  void setPrintFunc(TAPrintWithContextFn printFunc) {
    print_.withContext = printFunc;
    thinkingdatalayout::ta_yoga::detail::setBooleanData(flags, printUsesContext_, true);
  }
  void setPrintFunc(std::nullptr_t) { setPrintFunc(TAYGPrintFunc{nullptr}); }

  void setHasNewLayout(bool hasNewLayout) {
    thinkingdatalayout::ta_yoga::detail::setBooleanData(flags, hasNewLayout_, hasNewLayout);
  }

  void setNodeType(TAYGNodeType nodeType) {
    return thinkingdatalayout::ta_yoga::detail::setEnumData<TAYGNodeType>(
        flags, nodeType_, nodeType);
  }

  void setMeasureFunc(TAYGMeasureFunc measureFunc);
  void setMeasureFunc(TAMeasureWithContextFn);
  void setMeasureFunc(std::nullptr_t) {
    return setMeasureFunc(TAYGMeasureFunc{nullptr});
  }

  void setBaselineFunc(TAYGBaselineFunc baseLineFunc) {
    thinkingdatalayout::ta_yoga::detail::setBooleanData(flags, baselineUsesContext_, false);
    baseline_.noContext = baseLineFunc;
  }
  void setBaselineFunc(TABaselineWithContextFn baseLineFunc) {
    thinkingdatalayout::ta_yoga::detail::setBooleanData(flags, baselineUsesContext_, true);
    baseline_.withContext = baseLineFunc;
  }
  void setBaselineFunc(std::nullptr_t) {
    return setBaselineFunc(TAYGBaselineFunc{nullptr});
  }

  void setDirtiedFunc(TAYGDirtiedFunc dirtiedFunc) { dirtied_ = dirtiedFunc; }

  void setStyle(const TATAYGStyle& style) { style_ = style; }

  void setLayout(const TAYGLayout& layout) { layout_ = layout; }

  void setLineIndex(uint32_t lineIndex) { lineIndex_ = lineIndex; }

  void setIsReferenceBaseline(bool ta_isReferenceBaseline) {
    thinkingdatalayout::ta_yoga::detail::setBooleanData(
        flags, isReferenceBaseline_, ta_isReferenceBaseline);
  }

  void setOwner(TAYGNodeRef owner) { owner_ = owner; }

  void setChildren(const TAYGVector& children) { children_ = children; }

  // TODO: rvalue override for setChildren

  TA_YG_DEPRECATED void setConfig(TAYGConfigRef config) { config_ = config; }

  void setDirty(bool isDirty);
  void setLayoutLastOwnerDirection(TAYGDirection direction);
  void setLayoutComputedFlexBasis(const TAYGFloatOptional computedFlexBasis);
  void setLayoutComputedFlexBasisGeneration(
      uint32_t computedFlexBasisGeneration);
  void setLayoutMeasuredDimension(float measuredDimension, int index);
  void setLayoutHadOverflow(bool hadOverflow);
  void setLayoutDimension(float dimension, int index);
  void setLayoutDirection(TAYGDirection direction);
  void setLayoutMargin(float margin, int index);
  void setLayoutBorder(float border, int index);
  void setLayoutPadding(float padding, int index);
  void setLayoutPosition(float position, int index);
  void setPosition(
      const TAYGDirection direction,
      const float mainSize,
      const float crossSize,
      const float ownerWidth);
  void setLayoutDoesLegacyFlagAffectsLayout(bool doesLegacyFlagAffectsLayout);
  void setLayoutDidUseLegacyFlag(bool didUseLegacyFlag);
  void markDirtyAndPropogateDownwards();

  // Other methods
  TAYGValue marginLeadingValue(const TAYGFlexDirection axis) const;
  TAYGValue marginTrailingValue(const TAYGFlexDirection axis) const;
  TAYGValue resolveFlexBasisPtr() const;
  void resolveDimension();
  TAYGDirection resolveDirection(const TAYGDirection ownerDirection);
  void clearChildren();
  /// Replaces the occurrences of oldChild with newChild
  void replaceChild(TAYGNodeRef oldChild, TAYGNodeRef newChild);
  void replaceChild(TAYGNodeRef child, uint32_t index);
  void insertChild(TAYGNodeRef child, uint32_t index);
  /// Removes the first occurrence of child
  bool removeChild(TAYGNodeRef child);
  void removeChild(uint32_t index);

  void cloneChildrenIfNeeded(void*);
  void markDirtyAndPropogate();
  float resolveFlexGrow() const;
  float resolveFlexShrink() const;
  bool isNodeFlexible();
  bool didUseLegacyFlag();
  bool isLayoutTreeEqualToNode(const TAYGNode& node) const;
  void reset();
};

#endif
