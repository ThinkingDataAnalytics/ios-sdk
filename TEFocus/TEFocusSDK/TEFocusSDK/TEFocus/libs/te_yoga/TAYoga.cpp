
#include "TAYoga.h"
#include "TAlog.h"
#include <float.h>
#include <string.h>
#include <algorithm>
#include <atomic>
#include <memory>
#include "TAYGUtils.h"
#include "TAYGNode.h"
#include "TAYGNodePrint.h"
#include "TAYoga-internal.h"
#include "event/tagyevent.h"
#ifdef _MSC_VER
#include <float.h>

/* define fmaxf if < VC12 */
#if _MSC_VER < 1800
__forceinline const float fmaxf(const float a, const float b) {
  return (a > b) ? a : b;
}
#endif
#endif

using namespace thinkingdatalayout::ta_yoga;
using detail::TALog;

#ifdef ANDROID
static int TAYGAndroidLog(
    const TAYGConfigRef config,
    const TAYGNodeRef node,
    TAYGLogLevel level,
    const char* format,
    va_list args);
#else
static int TAYGDefaultLog(
    const TAYGConfigRef config,
    const TAYGNodeRef node,
    TAYGLogLevel level,
    const char* format,
    va_list args);
#endif

#ifdef ANDROID
#include <android/log.h>
static int TAYGAndroidLog(
    const TAYGConfigRef config,
    const TAYGNodeRef node,
    TAYGLogLevel level,
    const char* format,
    va_list args) {
  int androidLevel = TAYGLogLevelDebug;
  switch (level) {
    case TAYGLogLevelFatal:
      androidLevel = ANDROID_LOG_FATAL;
      break;
    case TAYGLogLevelError:
      androidLevel = ANDROID_LOG_ERROR;
      break;
    case TAYGLogLevelWarn:
      androidLevel = ANDROID_LOG_WARN;
      break;
    case TAYGLogLevelInfo:
      androidLevel = ANDROID_LOG_INFO;
      break;
    case TAYGLogLevelDebug:
      androidLevel = ANDROID_LOG_DEBUG;
      break;
    case TAYGLogLevelVerbose:
      androidLevel = ANDROID_LOG_VERBOSE;
      break;
  }
  const int result = __android_log_vprint(androidLevel, "ta_yoga", format, args);
  return result;
}
#else
#define YG_UNUSED(x) (void) (x);

static int TAYGDefaultLog(
    const TAYGConfigRef config,
    const TAYGNodeRef node,
    TAYGLogLevel level,
    const char* format,
    va_list args) {
  YG_UNUSED(config);
  YG_UNUSED(node);
  switch (level) {
    case TAYGLogLevelError:
    case TAYGLogLevelFatal:
      return vfprintf(stderr, format, args);
    case TAYGLogLevelWarn:
    case TAYGLogLevelInfo:
    case TAYGLogLevelDebug:
    case TAYGLogLevelVerbose:
    default:
      return vprintf(format, args);
  }
}

#undef YG_UNUSED
#endif

static inline bool TAYGDoubleIsUndefined(const double value) {
  return thinkingdatalayout::ta_yoga::isUndefined(value);
}

TA_YOGA_EXPORT bool TAYGFloatIsUndefined(const float value) {
  return thinkingdatalayout::ta_yoga::isUndefined(value);
}

TA_YOGA_EXPORT void* TAYGNodeGetContext(TAYGNodeRef node) {
  return node->getContext();
}

TA_YOGA_EXPORT void TAYGNodeSetContext(TAYGNodeRef node, void* context) {
  return node->setContext(context);
}

TA_YOGA_EXPORT bool TAYGNodeHasMeasureFunc(TAYGNodeRef node) {
  return node->hasMeasureFunc();
}

TA_YOGA_EXPORT void TAYGNodeSetMeasureFunc(
    TAYGNodeRef node,
    TAYGMeasureFunc measureFunc) {
  node->setMeasureFunc(measureFunc);
}

TA_YOGA_EXPORT bool TAYGNodeHasBaselineFunc(TAYGNodeRef node) {
  return node->hasBaselineFunc();
}

TA_YOGA_EXPORT void TAYGNodeSetBaselineFunc(
    TAYGNodeRef node,
    TAYGBaselineFunc baselineFunc) {
  node->setBaselineFunc(baselineFunc);
}

TA_YOGA_EXPORT TAYGDirtiedFunc TAYGNodeGetDirtiedFunc(TAYGNodeRef node) {
  return node->getDirtied();
}

TA_YOGA_EXPORT void TAYGNodeSetDirtiedFunc(
    TAYGNodeRef node,
    TAYGDirtiedFunc dirtiedFunc) {
  node->setDirtiedFunc(dirtiedFunc);
}

TA_YOGA_EXPORT void TAYGNodeSetPrintFunc(TAYGNodeRef node, TAYGPrintFunc printFunc) {
  node->setPrintFunc(printFunc);
}

TA_YOGA_EXPORT bool TAYGNodeGetHasNewLayout(TAYGNodeRef node) {
  return node->getHasNewLayout();
}

TA_YOGA_EXPORT void TAYGConfigSetPrintTreeFlag(TAYGConfigRef config, bool enabled) {
  config->printTree = enabled;
}

TA_YOGA_EXPORT void TAYGNodeSetHasNewLayout(TAYGNodeRef node, bool hasNewLayout) {
  node->setHasNewLayout(hasNewLayout);
}

TA_YOGA_EXPORT TAYGNodeType TAYGNodeGetNodeType(TAYGNodeRef node) {
  return node->getNodeType();
}

TA_YOGA_EXPORT void TAYGNodeSetNodeType(TAYGNodeRef node, TAYGNodeType nodeType) {
  return node->setNodeType(nodeType);
}

TA_YOGA_EXPORT bool TAYGNodeIsDirty(TAYGNodeRef node) {
  return node->isDirty();
}

TA_YOGA_EXPORT bool TAYGNodeLayoutGetDidUseLegacyFlag(const TAYGNodeRef node) {
  return node->didUseLegacyFlag();
}

TA_YOGA_EXPORT void TAYGNodeMarkDirtyAndPropogateToDescendants(
    const TAYGNodeRef node) {
  return node->markDirtyAndPropogateDownwards();
}

int32_t ta_gConfigInstanceCount = 0;

TA_YOGA_EXPORT WIN_EXPORT TAYGNodeRef TAYGNodeNewWithConfig(const TAYGConfigRef config) {
  const TAYGNodeRef node = new TAYGNode{config};
  TAYGAssertWithConfig(
      config, node != nullptr, "Could not allocate memory for node");
  Event::publish<Event::NodeAllocation>(node, {config});

  return node;
}

TA_YOGA_EXPORT TAYGConfigRef TAYGConfigGetDefault() {
  static TAYGConfigRef defaultConfig = TAYGConfigNew();
  return defaultConfig;
}

TA_YOGA_EXPORT TAYGNodeRef TAYGNodeNew(void) {
  return TAYGNodeNewWithConfig(TAYGConfigGetDefault());
}

TA_YOGA_EXPORT TAYGNodeRef TAYGNodeClone(TAYGNodeRef oldNode) {
  TAYGNodeRef node = new TAYGNode(*oldNode);
  TAYGAssertWithConfig(
      oldNode->getConfig(),
      node != nullptr,
      "Could not allocate memory for node");
  Event::publish<Event::NodeAllocation>(node, {node->getConfig()});
  node->setOwner(nullptr);
  return node;
}

static TAYGConfigRef YGConfigClone(const TAYGConfig& oldConfig) {
  const TAYGConfigRef config = new TAYGConfig(oldConfig);
  TAYGAssert(config != nullptr, "Could not allocate memory for config");
  ta_gConfigInstanceCount++;
  return config;
}

static TAYGNodeRef YGNodeDeepClone(TAYGNodeRef oldNode) {
  auto config = YGConfigClone(*oldNode->getConfig());
  auto node = new TAYGNode{*oldNode, config};
  node->setOwner(nullptr);
  Event::publish<Event::NodeAllocation>(node, {node->getConfig()});

  TAYGVector vec = TAYGVector();
  vec.reserve(oldNode->getChildren().size());
  TAYGNodeRef childNode = nullptr;
  for (auto* item : oldNode->getChildren()) {
    childNode = YGNodeDeepClone(item);
    childNode->setOwner(node);
    vec.push_back(childNode);
  }
  node->setChildren(vec);

  return node;
}

TA_YOGA_EXPORT void TAYGNodeFree(const TAYGNodeRef node) {
  if (TAYGNodeRef owner = node->getOwner()) {
    owner->removeChild(node);
    node->setOwner(nullptr);
  }

  const uint32_t childCount = TAYGNodeGetChildCount(node);
  for (uint32_t i = 0; i < childCount; i++) {
    const TAYGNodeRef child = TAYGNodeGetChild(node, i);
    child->setOwner(nullptr);
  }

  node->clearChildren();
  Event::publish<Event::NodeDeallocation>(node, {node->getConfig()});
  delete node;
}

static void YGConfigFreeRecursive(const TAYGNodeRef root) {
  if (root->getConfig() != nullptr) {
    ta_gConfigInstanceCount--;
    delete root->getConfig();
  }
  // Delete configs recursively for childrens
  for (auto* child : root->getChildren()) {
    YGConfigFreeRecursive(child);
  }
}

TA_YOGA_EXPORT void TAYGNodeFreeRecursiveWithCleanupFunc(
    const TAYGNodeRef root,
    TAYGNodeCleanupFunc cleanup) {
  uint32_t skipped = 0;
  while (TAYGNodeGetChildCount(root) > skipped) {
    const TAYGNodeRef child = TAYGNodeGetChild(root, skipped);
    if (child->getOwner() != root) {
      // Don't free shared nodes that we don't own.
      skipped += 1;
    } else {
      TAYGNodeRemoveChild(root, child);
      TAYGNodeFreeRecursive(child);
    }
  }
  if (cleanup != nullptr) {
    cleanup(root);
  }
  TAYGNodeFree(root);
}

TA_YOGA_EXPORT void TAYGNodeFreeRecursive(const TAYGNodeRef root) {
  return TAYGNodeFreeRecursiveWithCleanupFunc(root, nullptr);
}

TA_YOGA_EXPORT void TAYGNodeReset(TAYGNodeRef node) {
  node->reset();
}

int32_t TAYGConfigGetInstanceCount(void) {
  return ta_gConfigInstanceCount;
}

TA_YOGA_EXPORT TAYGConfigRef TAYGConfigNew(void) {
#ifdef ANDROID
  const TAYGConfigRef config = new TAYGConfig(TAYGAndroidLog);
#else
  const TAYGConfigRef config = new TAYGConfig(TAYGDefaultLog);
#endif
  ta_gConfigInstanceCount++;
  return config;
}

TA_YOGA_EXPORT void TAYGConfigFree(const TAYGConfigRef config) {
  delete config;
  ta_gConfigInstanceCount--;
}

void TAYGConfigCopy(const TAYGConfigRef dest, const TAYGConfigRef src) {
  memcpy(dest, src, sizeof(TAYGConfig));
}

TA_YOGA_EXPORT void TAYGNodeSetIsReferenceBaseline(
    TAYGNodeRef node,
    bool ta_isReferenceBaseline) {
  if (node->ta_isReferenceBaseline() != ta_isReferenceBaseline) {
    node->setIsReferenceBaseline(ta_isReferenceBaseline);
    node->markDirtyAndPropogate();
  }
}

TA_YOGA_EXPORT bool TAYGNodeIsReferenceBaseline(TAYGNodeRef node) {
  return node->ta_isReferenceBaseline();
}

TA_YOGA_EXPORT void TAYGNodeInsertChild(
    const TAYGNodeRef owner,
    const TAYGNodeRef child,
    const uint32_t index) {
  TAYGAssertWithNode(
      owner,
      child->getOwner() == nullptr,
      "Child already has a owner, it must be removed first.");

  TAYGAssertWithNode(
      owner,
      !owner->hasMeasureFunc(),
      "Cannot add child: Nodes with measure functions cannot have children.");

  owner->insertChild(child, index);
  child->setOwner(owner);
  owner->markDirtyAndPropogate();
}

TA_YOGA_EXPORT void TAYGNodeSwapChild(
    const TAYGNodeRef owner,
    const TAYGNodeRef child,
    const uint32_t index) {
  owner->replaceChild(child, index);
  child->setOwner(owner);
}

TA_YOGA_EXPORT void TAYGNodeRemoveChild(
    const TAYGNodeRef owner,
    const TAYGNodeRef excludedChild) {
  if (TAYGNodeGetChildCount(owner) == 0) {
    // This is an empty set. Nothing to remove.
    return;
  }

  // Children may be shared between parents, which is indicated by not having an
  // owner. We only want to reset the child completely if it is owned
  // exclusively by one node.
  auto childOwner = excludedChild->getOwner();
  if (owner->removeChild(excludedChild)) {
    if (owner == childOwner) {
      excludedChild->setLayout({}); // layout is no longer valid
      excludedChild->setOwner(nullptr);
    }
    owner->markDirtyAndPropogate();
  }
}

TA_YOGA_EXPORT void TAYGNodeRemoveAllChildren(const TAYGNodeRef owner) {
  const uint32_t childCount = TAYGNodeGetChildCount(owner);
  if (childCount == 0) {
    // This is an empty set already. Nothing to do.
    return;
  }
  const TAYGNodeRef firstChild = TAYGNodeGetChild(owner, 0);
  if (firstChild->getOwner() == owner) {
    // If the first child has this node as its owner, we assume that this child
    // set is unique.
    for (uint32_t i = 0; i < childCount; i++) {
      const TAYGNodeRef oldChild = TAYGNodeGetChild(owner, i);
      oldChild->setLayout(TAYGNode().getLayout()); // layout is no longer valid
      oldChild->setOwner(nullptr);
    }
    owner->clearChildren();
    owner->markDirtyAndPropogate();
    return;
  }
  // Otherwise, we are not the owner of the child set. We don't have to do
  // anything to clear it.
  owner->setChildren(TAYGVector());
  owner->markDirtyAndPropogate();
}

static void YGNodeSetChildrenInternal(
    TAYGNodeRef const owner,
    const std::vector<TAYGNodeRef>& children) {
  if (!owner) {
    return;
  }
  if (children.size() == 0) {
    if (TAYGNodeGetChildCount(owner) > 0) {
      for (TAYGNodeRef const child : owner->getChildren()) {
        child->setLayout(TAYGLayout());
        child->setOwner(nullptr);
      }
      owner->setChildren(TAYGVector());
      owner->markDirtyAndPropogate();
    }
  } else {
    if (TAYGNodeGetChildCount(owner) > 0) {
      for (TAYGNodeRef const oldChild : owner->getChildren()) {
        // Our new children may have nodes in common with the old children. We
        // don't reset these common nodes.
        if (std::find(children.begin(), children.end(), oldChild) ==
            children.end()) {
          oldChild->setLayout(TAYGLayout());
          oldChild->setOwner(nullptr);
        }
      }
    }
    owner->setChildren(children);
    for (TAYGNodeRef child : children) {
      child->setOwner(owner);
    }
    owner->markDirtyAndPropogate();
  }
}

TA_YOGA_EXPORT void TAYGNodeSetChildren(
    const TAYGNodeRef owner,
    const TAYGNodeRef c[],
    const uint32_t count) {
  const TAYGVector children = {c, c + count};
  YGNodeSetChildrenInternal(owner, children);
}

TA_YOGA_EXPORT void TAYGNodeSetChildren(
    TAYGNodeRef const owner,
    const std::vector<TAYGNodeRef>& children) {
  YGNodeSetChildrenInternal(owner, children);
}

TA_YOGA_EXPORT TAYGNodeRef
TAYGNodeGetChild(const TAYGNodeRef node, const uint32_t index) {
  if (index < node->getChildren().size()) {
    return node->getChild(index);
  }
  return nullptr;
}

TA_YOGA_EXPORT uint32_t TAYGNodeGetChildCount(const TAYGNodeRef node) {
  return static_cast<uint32_t>(node->getChildren().size());
}

TA_YOGA_EXPORT TAYGNodeRef TAYGNodeGetOwner(const TAYGNodeRef node) {
  return node->getOwner();
}

TA_YOGA_EXPORT TAYGNodeRef TAYGNodeGetParent(const TAYGNodeRef node) {
  return node->getOwner();
}

TA_YOGA_EXPORT void TAYGNodeMarkDirty(const TAYGNodeRef node) {
  TAYGAssertWithNode(
      node,
      node->hasMeasureFunc(),
      "Only leaf nodes with custom measure functions"
      "should manually mark themselves as dirty");

  node->markDirtyAndPropogate();
}

TA_YOGA_EXPORT void TAYGNodeCopyStyle(
    const TAYGNodeRef dstNode,
    const TAYGNodeRef srcNode) {
  if (!(dstNode->getStyle() == srcNode->getStyle())) {
    dstNode->setStyle(srcNode->getStyle());
    dstNode->markDirtyAndPropogate();
  }
}

TA_YOGA_EXPORT float TAYGNodeStyleGetFlexGrow(const TAYGNodeConstRef node) {
  return node->getStyle().flexGrow().isUndefined()
      ? kDefaultFlexGrow
      : node->getStyle().flexGrow().unwrap();
}

TA_YOGA_EXPORT float TAYGNodeStyleGetFlexShrink(const TAYGNodeConstRef node) {
  return node->getStyle().flexShrink().isUndefined()
      ? (node->getConfig()->useWebDefaults ? kWebDefaultFlexShrink
                                           : kDefaultFlexShrink)
      : node->getStyle().flexShrink().unwrap();
}

namespace {

template <typename T, typename NeedsUpdate, typename Update>
void updateStyle(
    TAYGNode* node,
    T value,
    NeedsUpdate&& needsUpdate,
    Update&& update) {
  if (needsUpdate(node->getStyle(), value)) {
    update(node->getStyle(), value);
    node->markDirtyAndPropogate();
  }
}

template <typename Ref, typename T>
void updateStyle(TAYGNode* node, Ref (TATAYGStyle::*prop)(), T value) {
  updateStyle(
      node,
      value,
      [prop](TATAYGStyle& s, T x) { return (s.*prop)() != x; },
      [prop](TATAYGStyle& s, T x) { (s.*prop)() = x; });
}

template <typename Ref, typename Idx>
void updateIndexedStyleProp(
    TAYGNode* node,
    Ref (TATAYGStyle::*prop)(),
    Idx idx,
    detail::TACompactValue value) {
  using detail::TACompactValue;
  updateStyle(
      node,
      value,
      [idx, prop](TATAYGStyle& s, TACompactValue x) { return (s.*prop)()[idx] != x; },
      [idx, prop](TATAYGStyle& s, TACompactValue x) { (s.*prop)()[idx] = x; });
}

} // namespace

// MSVC has trouble inferring the return type of pointer to member functions
// with const and non-const overloads, instead of preferring the non-const
// overload like clang and GCC. For the purposes of updateStyle(), we can help
// MSVC by specifying that return type explicitely. In combination with
// decltype, MSVC will prefer the non-const version.
#define MSVC_HINT(PROP) decltype(TATAYGStyle{}.PROP())

TA_YOGA_EXPORT void TAYGNodeStyleSetDirection(
    const TAYGNodeRef node,
    const TAYGDirection value) {
  updateStyle<MSVC_HINT(direction)>(node, &TATAYGStyle::direction, value);
}
TA_YOGA_EXPORT TAYGDirection TAYGNodeStyleGetDirection(const TAYGNodeConstRef node) {
  return node->getStyle().direction();
}

TA_YOGA_EXPORT void TAYGNodeStyleSetFlexDirection(
    const TAYGNodeRef node,
    const TAYGFlexDirection flexDirection) {
  updateStyle<MSVC_HINT(flexDirection)>(
      node, &TATAYGStyle::flexDirection, flexDirection);
}
TA_YOGA_EXPORT TAYGFlexDirection
TAYGNodeStyleGetFlexDirection(const TAYGNodeConstRef node) {
  return node->getStyle().flexDirection();
}

TA_YOGA_EXPORT void TAYGNodeStyleSetJustifyContent(
    const TAYGNodeRef node,
    const TAYGJustify justifyContent) {
  updateStyle<MSVC_HINT(justifyContent)>(
      node, &TATAYGStyle::justifyContent, justifyContent);
}
TA_YOGA_EXPORT TAYGJustify TAYGNodeStyleGetJustifyContent(const TAYGNodeConstRef node) {
  return node->getStyle().justifyContent();
}

TA_YOGA_EXPORT void TAYGNodeStyleSetAlignContent(
    const TAYGNodeRef node,
    const TAYGAlign alignContent) {
  updateStyle<MSVC_HINT(alignContent)>(
      node, &TATAYGStyle::alignContent, alignContent);
}
TA_YOGA_EXPORT TAYGAlign TAYGNodeStyleGetAlignContent(const TAYGNodeConstRef node) {
  return node->getStyle().alignContent();
}

TA_YOGA_EXPORT void TAYGNodeStyleSetAlignItems(
    const TAYGNodeRef node,
    const TAYGAlign alignItems) {
  updateStyle<MSVC_HINT(alignItems)>(node, &TATAYGStyle::alignItems, alignItems);
}
TA_YOGA_EXPORT TAYGAlign TAYGNodeStyleGetAlignItems(const TAYGNodeConstRef node) {
  return node->getStyle().alignItems();
}

TA_YOGA_EXPORT void TAYGNodeStyleSetAlignSelf(
    const TAYGNodeRef node,
    const TAYGAlign alignSelf) {
  updateStyle<MSVC_HINT(alignSelf)>(node, &TATAYGStyle::alignSelf, alignSelf);
}
TA_YOGA_EXPORT TAYGAlign TAYGNodeStyleGetAlignSelf(const TAYGNodeConstRef node) {
  return node->getStyle().alignSelf();
}

TA_YOGA_EXPORT void TAYGNodeStyleSetPositionType(
    const TAYGNodeRef node,
    const TAYGPositionType positionType) {
  updateStyle<MSVC_HINT(positionType)>(
      node, &TATAYGStyle::positionType, positionType);
}
TA_YOGA_EXPORT TAYGPositionType
TAYGNodeStyleGetPositionType(const TAYGNodeConstRef node) {
  return node->getStyle().positionType();
}

TA_YOGA_EXPORT void TAYGNodeStyleSetFlexWrap(
    const TAYGNodeRef node,
    const TAYGWrap flexWrap) {
  updateStyle<MSVC_HINT(flexWrap)>(node, &TATAYGStyle::flexWrap, flexWrap);
}
TA_YOGA_EXPORT TAYGWrap TAYGNodeStyleGetFlexWrap(const TAYGNodeConstRef node) {
  return node->getStyle().flexWrap();
}

TA_YOGA_EXPORT void TAYGNodeStyleSetOverflow(
    const TAYGNodeRef node,
    const TAYGOverflow overflow) {
  updateStyle<MSVC_HINT(overflow)>(node, &TATAYGStyle::overflow, overflow);
}
TA_YOGA_EXPORT TAYGOverflow TAYGNodeStyleGetOverflow(const TAYGNodeConstRef node) {
  return node->getStyle().overflow();
}

TA_YOGA_EXPORT void TAYGNodeStyleSetDisplay(
    const TAYGNodeRef node,
    const TAYGDisplay display) {
  updateStyle<MSVC_HINT(display)>(node, &TATAYGStyle::display, display);
}
TA_YOGA_EXPORT TAYGDisplay TAYGNodeStyleGetDisplay(const TAYGNodeConstRef node) {
  return node->getStyle().display();
}

// TODO(T26792433): Change the API to accept TAYGFloatOptional.
TA_YOGA_EXPORT void TAYGNodeStyleSetFlex(const TAYGNodeRef node, const float flex) {
  updateStyle<MSVC_HINT(flex)>(node, &TATAYGStyle::flex, TAYGFloatOptional{flex});
}

// TODO(T26792433): Change the API to accept TAYGFloatOptional.
TA_YOGA_EXPORT float TAYGNodeStyleGetFlex(const TAYGNodeConstRef node) {
  return node->getStyle().flex().isUndefined()
      ? TAYGUndefined
      : node->getStyle().flex().unwrap();
}

// TODO(T26792433): Change the API to accept TAYGFloatOptional.
TA_YOGA_EXPORT void TAYGNodeStyleSetFlexGrow(
    const TAYGNodeRef node,
    const float flexGrow) {
  updateStyle<MSVC_HINT(flexGrow)>(
      node, &TATAYGStyle::flexGrow, TAYGFloatOptional{flexGrow});
}

// TODO(T26792433): Change the API to accept TAYGFloatOptional.
TA_YOGA_EXPORT void TAYGNodeStyleSetFlexShrink(
    const TAYGNodeRef node,
    const float flexShrink) {
  updateStyle<MSVC_HINT(flexShrink)>(
      node, &TATAYGStyle::flexShrink, TAYGFloatOptional{flexShrink});
}

TA_YOGA_EXPORT TAYGValue TAYGNodeStyleGetFlexBasis(const TAYGNodeConstRef node) {
  TAYGValue flexBasis = node->getStyle().flexBasis();
  if (flexBasis.unit == TAYGUnitUndefined || flexBasis.unit == TAYGUnitAuto) {
    // TODO(T26792433): Get rid off the use of TAYGUndefined at client side
    flexBasis.value = TAYGUndefined;
  }
  return flexBasis;
}

TA_YOGA_EXPORT void TAYGNodeStyleSetFlexBasis(
    const TAYGNodeRef node,
    const float flexBasis) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPoint>(flexBasis);
  updateStyle<MSVC_HINT(flexBasis)>(node, &TATAYGStyle::flexBasis, value);
}

TA_YOGA_EXPORT void TAYGNodeStyleSetFlexBasisPercent(
    const TAYGNodeRef node,
    const float flexBasisPercent) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPercent>(flexBasisPercent);
  updateStyle<MSVC_HINT(flexBasis)>(node, &TATAYGStyle::flexBasis, value);
}

TA_YOGA_EXPORT void TAYGNodeStyleSetFlexBasisAuto(const TAYGNodeRef node) {
  updateStyle<MSVC_HINT(flexBasis)>(
      node, &TATAYGStyle::flexBasis, detail::TACompactValue::ofAuto());
}

TA_YOGA_EXPORT void TAYGNodeStyleSetPosition(
    TAYGNodeRef node,
    TAYGEdge edge,
    float points) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPoint>(points);
  updateIndexedStyleProp<MSVC_HINT(position)>(
      node, &TATAYGStyle::position, edge, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetPositionPercent(
    TAYGNodeRef node,
    TAYGEdge edge,
    float percent) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPercent>(percent);
  updateIndexedStyleProp<MSVC_HINT(position)>(
      node, &TATAYGStyle::position, edge, value);
}
TA_YOGA_EXPORT TAYGValue TAYGNodeStyleGetPosition(TAYGNodeConstRef node, TAYGEdge edge) {
  return node->getStyle().position()[edge];
}

TA_YOGA_EXPORT void TAYGNodeStyleSetMargin(
    TAYGNodeRef node,
    TAYGEdge edge,
    float points) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPoint>(points);
  updateIndexedStyleProp<MSVC_HINT(margin)>(
      node, &TATAYGStyle::margin, edge, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetMarginPercent(
    TAYGNodeRef node,
    TAYGEdge edge,
    float percent) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPercent>(percent);
  updateIndexedStyleProp<MSVC_HINT(margin)>(
      node, &TATAYGStyle::margin, edge, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetMarginAuto(TAYGNodeRef node, TAYGEdge edge) {
  updateIndexedStyleProp<MSVC_HINT(margin)>(
      node, &TATAYGStyle::margin, edge, detail::TACompactValue::ofAuto());
}
TA_YOGA_EXPORT TAYGValue TAYGNodeStyleGetMargin(TAYGNodeConstRef node, TAYGEdge edge) {
  return node->getStyle().margin()[edge];
}

TA_YOGA_EXPORT void TAYGNodeStyleSetPadding(
    TAYGNodeRef node,
    TAYGEdge edge,
    float points) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPoint>(points);
  updateIndexedStyleProp<MSVC_HINT(padding)>(
      node, &TATAYGStyle::padding, edge, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetPaddingPercent(
    TAYGNodeRef node,
    TAYGEdge edge,
    float percent) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPercent>(percent);
  updateIndexedStyleProp<MSVC_HINT(padding)>(
      node, &TATAYGStyle::padding, edge, value);
}
TA_YOGA_EXPORT TAYGValue TAYGNodeStyleGetPadding(TAYGNodeConstRef node, TAYGEdge edge) {
  return node->getStyle().padding()[edge];
}

// TODO(T26792433): Change the API to accept TAYGFloatOptional.
TA_YOGA_EXPORT void TAYGNodeStyleSetBorder(
    const TAYGNodeRef node,
    const TAYGEdge edge,
    const float border) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPoint>(border);
  updateIndexedStyleProp<MSVC_HINT(border)>(
      node, &TATAYGStyle::border, edge, value);
}

TA_YOGA_EXPORT float TAYGNodeStyleGetBorder(
    const TAYGNodeConstRef node,
    const TAYGEdge edge) {
  auto border = node->getStyle().border()[edge];
  if (border.isUndefined() || border.isAuto()) {
    // TODO(T26792433): Rather than returning TAYGUndefined, change the api to
    // return TAYGFloatOptional.
    return TAYGUndefined;
  }

  return static_cast<TAYGValue>(border).value;
}

// TAYoga specific properties, not compatible with flexbox specification

// TODO(T26792433): Change the API to accept TAYGFloatOptional.
TA_YOGA_EXPORT float TAYGNodeStyleGetAspectRatio(const TAYGNodeConstRef node) {
  const TAYGFloatOptional op = node->getStyle().aspectRatio();
  return op.isUndefined() ? TAYGUndefined : op.unwrap();
}

// TODO(T26792433): Change the API to accept TAYGFloatOptional.
TA_YOGA_EXPORT void TAYGNodeStyleSetAspectRatio(
    const TAYGNodeRef node,
    const float aspectRatio) {
  updateStyle<MSVC_HINT(aspectRatio)>(
      node, &TATAYGStyle::aspectRatio, TAYGFloatOptional{aspectRatio});
}

TA_YOGA_EXPORT void TAYGNodeStyleSetWidth(TAYGNodeRef node, float points) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPoint>(points);
  updateIndexedStyleProp<MSVC_HINT(dimensions)>(
      node, &TATAYGStyle::dimensions, TAYGDimensionWidth, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetWidthPercent(TAYGNodeRef node, float percent) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPercent>(percent);
  updateIndexedStyleProp<MSVC_HINT(dimensions)>(
      node, &TATAYGStyle::dimensions, TAYGDimensionWidth, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetWidthAuto(TAYGNodeRef node) {
  updateIndexedStyleProp<MSVC_HINT(dimensions)>(
      node,
      &TATAYGStyle::dimensions,
      TAYGDimensionWidth,
      detail::TACompactValue::ofAuto());
}
TA_YOGA_EXPORT TAYGValue TAYGNodeStyleGetWidth(TAYGNodeConstRef node) {
  return node->getStyle().dimensions()[TAYGDimensionWidth];
}

TA_YOGA_EXPORT void TAYGNodeStyleSetHeight(TAYGNodeRef node, float points) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPoint>(points);
  updateIndexedStyleProp<MSVC_HINT(dimensions)>(
      node, &TATAYGStyle::dimensions, TAYGDimensionHeight, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetHeightPercent(TAYGNodeRef node, float percent) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPercent>(percent);
  updateIndexedStyleProp<MSVC_HINT(dimensions)>(
      node, &TATAYGStyle::dimensions, TAYGDimensionHeight, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetHeightAuto(TAYGNodeRef node) {
  updateIndexedStyleProp<MSVC_HINT(dimensions)>(
      node,
      &TATAYGStyle::dimensions,
      TAYGDimensionHeight,
      detail::TACompactValue::ofAuto());
}
TA_YOGA_EXPORT TAYGValue TAYGNodeStyleGetHeight(TAYGNodeConstRef node) {
  return node->getStyle().dimensions()[TAYGDimensionHeight];
}

TA_YOGA_EXPORT void TAYGNodeStyleSetMinWidth(
    const TAYGNodeRef node,
    const float minWidth) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPoint>(minWidth);
  updateIndexedStyleProp<MSVC_HINT(minDimensions)>(
      node, &TATAYGStyle::minDimensions, TAYGDimensionWidth, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetMinWidthPercent(
    const TAYGNodeRef node,
    const float minWidth) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPercent>(minWidth);
  updateIndexedStyleProp<MSVC_HINT(minDimensions)>(
      node, &TATAYGStyle::minDimensions, TAYGDimensionWidth, value);
}
TA_YOGA_EXPORT TAYGValue TAYGNodeStyleGetMinWidth(const TAYGNodeConstRef node) {
  return node->getStyle().minDimensions()[TAYGDimensionWidth];
};

TA_YOGA_EXPORT void TAYGNodeStyleSetMinHeight(
    const TAYGNodeRef node,
    const float minHeight) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPoint>(minHeight);
  updateIndexedStyleProp<MSVC_HINT(minDimensions)>(
      node, &TATAYGStyle::minDimensions, TAYGDimensionHeight, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetMinHeightPercent(
    const TAYGNodeRef node,
    const float minHeight) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPercent>(minHeight);
  updateIndexedStyleProp<MSVC_HINT(minDimensions)>(
      node, &TATAYGStyle::minDimensions, TAYGDimensionHeight, value);
}
TA_YOGA_EXPORT TAYGValue TAYGNodeStyleGetMinHeight(const TAYGNodeConstRef node) {
  return node->getStyle().minDimensions()[TAYGDimensionHeight];
};

TA_YOGA_EXPORT void TAYGNodeStyleSetMaxWidth(
    const TAYGNodeRef node,
    const float maxWidth) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPoint>(maxWidth);
  updateIndexedStyleProp<MSVC_HINT(maxDimensions)>(
      node, &TATAYGStyle::maxDimensions, TAYGDimensionWidth, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetMaxWidthPercent(
    const TAYGNodeRef node,
    const float maxWidth) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPercent>(maxWidth);
  updateIndexedStyleProp<MSVC_HINT(maxDimensions)>(
      node, &TATAYGStyle::maxDimensions, TAYGDimensionWidth, value);
}
TA_YOGA_EXPORT TAYGValue TAYGNodeStyleGetMaxWidth(const TAYGNodeConstRef node) {
  return node->getStyle().maxDimensions()[TAYGDimensionWidth];
};

TA_YOGA_EXPORT void TAYGNodeStyleSetMaxHeight(
    const TAYGNodeRef node,
    const float maxHeight) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPoint>(maxHeight);
  updateIndexedStyleProp<MSVC_HINT(maxDimensions)>(
      node, &TATAYGStyle::maxDimensions, TAYGDimensionHeight, value);
}
TA_YOGA_EXPORT void TAYGNodeStyleSetMaxHeightPercent(
    const TAYGNodeRef node,
    const float maxHeight) {
  auto value = detail::TACompactValue::ofMaybe<TAYGUnitPercent>(maxHeight);
  updateIndexedStyleProp<MSVC_HINT(maxDimensions)>(
      node, &TATAYGStyle::maxDimensions, TAYGDimensionHeight, value);
}
TA_YOGA_EXPORT TAYGValue TAYGNodeStyleGetMaxHeight(const TAYGNodeConstRef node) {
  return node->getStyle().maxDimensions()[TAYGDimensionHeight];
};

#define TA_YG_NODE_LAYOUT_PROPERTY_IMPL(type, name, instanceName)   \
  TA_YOGA_EXPORT type TAYGNodeLayoutGet##name(const TAYGNodeRef node) { \
    return node->getLayout().instanceName;                       \
  }

#define TA_YG_NODE_LAYOUT_RESOLVED_PROPERTY_IMPL(type, name, instanceName) \
  TA_YOGA_EXPORT type TAYGNodeLayoutGet##name(                               \
      const TAYGNodeRef node, const TAYGEdge edge) {                        \
    TAYGAssertWithNode(                                                   \
        node,                                                           \
        edge <= TAYGEdgeEnd,                                              \
        "Cannot get layout properties of multi-edge shorthands");       \
                                                                        \
    if (edge == TAYGEdgeStart) {                                          \
      if (node->getLayout().direction() == TAYGDirectionRTL) {            \
        return node->getLayout().instanceName[TAYGEdgeRight];             \
      } else {                                                          \
        return node->getLayout().instanceName[TAYGEdgeLeft];              \
      }                                                                 \
    }                                                                   \
                                                                        \
    if (edge == TAYGEdgeEnd) {                                            \
      if (node->getLayout().direction() == TAYGDirectionRTL) {            \
        return node->getLayout().instanceName[TAYGEdgeLeft];              \
      } else {                                                          \
        return node->getLayout().instanceName[TAYGEdgeRight];             \
      }                                                                 \
    }                                                                   \
                                                                        \
    return node->getLayout().instanceName[edge];                        \
  }

TA_YG_NODE_LAYOUT_PROPERTY_IMPL(float, Left, position[TAYGEdgeLeft]);
TA_YG_NODE_LAYOUT_PROPERTY_IMPL(float, Top, position[TAYGEdgeTop]);
TA_YG_NODE_LAYOUT_PROPERTY_IMPL(float, Right, position[TAYGEdgeRight]);
TA_YG_NODE_LAYOUT_PROPERTY_IMPL(float, Bottom, position[TAYGEdgeBottom]);
TA_YG_NODE_LAYOUT_PROPERTY_IMPL(float, Width, dimensions[TAYGDimensionWidth]);
TA_YG_NODE_LAYOUT_PROPERTY_IMPL(float, Height, dimensions[TAYGDimensionHeight]);
TA_YG_NODE_LAYOUT_PROPERTY_IMPL(TAYGDirection, Direction, direction());
TA_YG_NODE_LAYOUT_PROPERTY_IMPL(bool, HadOverflow, hadOverflow());

TA_YG_NODE_LAYOUT_RESOLVED_PROPERTY_IMPL(float, Margin, margin);
TA_YG_NODE_LAYOUT_RESOLVED_PROPERTY_IMPL(float, Border, border);
TA_YG_NODE_LAYOUT_RESOLVED_PROPERTY_IMPL(float, Padding, padding);

TA_YOGA_EXPORT bool TAYGNodeLayoutGetDidLegacyStretchFlagAffectLayout(
    const TAYGNodeRef node) {
  return node->getLayout().doesLegacyStretchFlagAffectsLayout();
}

std::atomic<uint32_t> ta_gCurrentGenerationCount(0);

bool YGLayoutNodeInternal(
    const TAYGNodeRef node,
    const float availableWidth,
    const float availableHeight,
    const TAYGDirection ownerDirection,
    const TAYGMeasureMode widthMeasureMode,
    const TAYGMeasureMode heightMeasureMode,
    const float ownerWidth,
    const float ownerHeight,
    const bool performLayout,
    const LayoutPassReason reason,
    const TAYGConfigRef config,
    LayoutData& layoutMarkerData,
    void* const layoutContext,
    const uint32_t depth,
    const uint32_t generationCount);

#ifdef DEBUG
static void YGNodePrintInternal(
    const TAYGNodeRef node,
    const TAYGPrintOptions options) {
  std::string str;
  thinkingdatalayout::ta_yoga::TAYGNodeToString(str, node, options, 0);
  TALog::log(node, TAYGLogLevelDebug, nullptr, str.c_str());
}

TA_YOGA_EXPORT void TAYGNodePrint(
    const TAYGNodeRef node,
    const TAYGPrintOptions options) {
  YGNodePrintInternal(node, options);
}
#endif

const std::array<TAYGEdge, 4> ta_leading = {
    {TAYGEdgeTop, TAYGEdgeBottom, TAYGEdgeLeft, TAYGEdgeRight}};

const std::array<TAYGEdge, 4> ta_trailing = {
    {TAYGEdgeBottom, TAYGEdgeTop, TAYGEdgeRight, TAYGEdgeLeft}};
static const std::array<TAYGEdge, 4> pos = {{
    TAYGEdgeTop,
    TAYGEdgeBottom,
    TAYGEdgeLeft,
    TAYGEdgeRight,
}};

static const std::array<TAYGDimension, 4> dim = {
    {TAYGDimensionHeight, TAYGDimensionHeight, TAYGDimensionWidth, TAYGDimensionWidth}};

static inline float YGNodePaddingAndBorderForAxis(
    const TAYGNodeConstRef node,
    const TAYGFlexDirection axis,
    const float widthSize) {
  return (node->getLeadingPaddingAndBorder(axis, widthSize) +
          node->getTrailingPaddingAndBorder(axis, widthSize))
      .unwrap();
}

static inline TAYGAlign YGNodeAlignItem(const TAYGNode* node, const TAYGNode* child) {
  const TAYGAlign align = child->getStyle().alignSelf() == TAYGAlignAuto
      ? node->getStyle().alignItems()
      : child->getStyle().alignSelf();
  if (align == TAYGAlignBaseline &&
      TAYGFlexDirectionIsColumn(node->getStyle().flexDirection())) {
    return TAYGAlignFlexStart;
  }
  return align;
}

static float YGBaseline(const TAYGNodeRef node, void* layoutContext) {
  if (node->hasBaselineFunc()) {

    Event::publish<Event::NodeBaselineStart>(node);

    const float baseline = node->baseline(
        node->getLayout().measuredDimensions[TAYGDimensionWidth],
        node->getLayout().measuredDimensions[TAYGDimensionHeight],
        layoutContext);

    Event::publish<Event::NodeBaselineEnd>(node);

    TAYGAssertWithNode(
        node,
        !TAYGFloatIsUndefined(baseline),
        "Expect custom baseline function to not return NaN");
    return baseline;
  }

  TAYGNodeRef baselineChild = nullptr;
  const uint32_t childCount = TAYGNodeGetChildCount(node);
  for (uint32_t i = 0; i < childCount; i++) {
    const TAYGNodeRef child = TAYGNodeGetChild(node, i);
    if (child->getLineIndex() > 0) {
      break;
    }
    if (child->getStyle().positionType() == TAYGPositionTypeAbsolute) {
      continue;
    }
    if (YGNodeAlignItem(node, child) == TAYGAlignBaseline ||
        child->ta_isReferenceBaseline()) {
      baselineChild = child;
      break;
    }

    if (baselineChild == nullptr) {
      baselineChild = child;
    }
  }

  if (baselineChild == nullptr) {
    return node->getLayout().measuredDimensions[TAYGDimensionHeight];
  }

  const float baseline = YGBaseline(baselineChild, layoutContext);
  return baseline + baselineChild->getLayout().position[TAYGEdgeTop];
}

static bool YGIsBaselineLayout(const TAYGNodeRef node) {
  if (TAYGFlexDirectionIsColumn(node->getStyle().flexDirection())) {
    return false;
  }
  if (node->getStyle().alignItems() == TAYGAlignBaseline) {
    return true;
  }
  const uint32_t childCount = TAYGNodeGetChildCount(node);
  for (uint32_t i = 0; i < childCount; i++) {
    const TAYGNodeRef child = TAYGNodeGetChild(node, i);
    if (child->getStyle().positionType() != TAYGPositionTypeAbsolute &&
        child->getStyle().alignSelf() == TAYGAlignBaseline) {
      return true;
    }
  }

  return false;
}

static inline float YGNodeDimWithMargin(
    const TAYGNodeRef node,
    const TAYGFlexDirection axis,
    const float widthSize) {
  return node->getLayout().measuredDimensions[dim[axis]] +
      (node->getLeadingMargin(axis, widthSize) +
       node->getTrailingMargin(axis, widthSize))
          .unwrap();
}

static inline bool YGNodeIsStyleDimDefined(
    const TAYGNodeRef node,
    const TAYGFlexDirection axis,
    const float ownerSize) {
  bool isUndefined =
      TAYGFloatIsUndefined(node->getResolvedDimension(dim[axis]).value);
  return !(
      node->getResolvedDimension(dim[axis]).unit == TAYGUnitAuto ||
      node->getResolvedDimension(dim[axis]).unit == TAYGUnitUndefined ||
      (node->getResolvedDimension(dim[axis]).unit == TAYGUnitPoint &&
       !isUndefined && node->getResolvedDimension(dim[axis]).value < 0.0f) ||
      (node->getResolvedDimension(dim[axis]).unit == TAYGUnitPercent &&
       !isUndefined &&
       (node->getResolvedDimension(dim[axis]).value < 0.0f ||
        TAYGFloatIsUndefined(ownerSize))));
}

static inline bool YGNodeIsLayoutDimDefined(
    const TAYGNodeRef node,
    const TAYGFlexDirection axis) {
  const float value = node->getLayout().measuredDimensions[dim[axis]];
  return !TAYGFloatIsUndefined(value) && value >= 0.0f;
}

static TAYGFloatOptional YGNodeBoundAxisWithinMinAndMax(
    const TAYGNodeConstRef node,
    const TAYGFlexDirection axis,
    const TAYGFloatOptional value,
    const float axisSize) {
  TAYGFloatOptional min;
  TAYGFloatOptional max;

  if (TAYGFlexDirectionIsColumn(axis)) {
    min = TAYGResolveValue(
        node->getStyle().minDimensions()[TAYGDimensionHeight], axisSize);
    max = TAYGResolveValue(
        node->getStyle().maxDimensions()[TAYGDimensionHeight], axisSize);
  } else if (TAYGFlexDirectionIsRow(axis)) {
    min = TAYGResolveValue(
        node->getStyle().minDimensions()[TAYGDimensionWidth], axisSize);
    max = TAYGResolveValue(
        node->getStyle().maxDimensions()[TAYGDimensionWidth], axisSize);
  }

  if (max >= TAYGFloatOptional{0} && value > max) {
    return max;
  }

  if (min >= TAYGFloatOptional{0} && value < min) {
    return min;
  }

  return value;
}

// Like YGNodeBoundAxisWithinMinAndMax but also ensures that the value doesn't
// go below the padding and border amount.
static inline float YGNodeBoundAxis(
    const TAYGNodeRef node,
    const TAYGFlexDirection axis,
    const float value,
    const float axisSize,
    const float widthSize) {
  return TAYGFloatMax(
      YGNodeBoundAxisWithinMinAndMax(
          node, axis, TAYGFloatOptional{value}, axisSize)
          .unwrap(),
      YGNodePaddingAndBorderForAxis(node, axis, widthSize));
}

static void YGNodeSetChildTrailingPosition(
    const TAYGNodeRef node,
    const TAYGNodeRef child,
    const TAYGFlexDirection axis) {
  const float size = child->getLayout().measuredDimensions[dim[axis]];
  child->setLayoutPosition(
      node->getLayout().measuredDimensions[dim[axis]] - size -
          child->getLayout().position[pos[axis]],
      ta_trailing[axis]);
}

static void YGConstrainMaxSizeForMode(
    const TAYGNodeConstRef node,
    const enum TAYGFlexDirection axis,
    const float ownerAxisSize,
    const float ownerWidth,
    TAYGMeasureMode* mode,
    float* size) {
  const TAYGFloatOptional maxSize =
      TAYGResolveValue(
          node->getStyle().maxDimensions()[dim[axis]], ownerAxisSize) +
      TAYGFloatOptional(node->getMarginForAxis(axis, ownerWidth));
  switch (*mode) {
    case TAYGMeasureModeExactly:
    case TAYGMeasureModeAtMost:
      *size = (maxSize.isUndefined() || *size < maxSize.unwrap())
          ? *size
          : maxSize.unwrap();
      break;
    case TAYGMeasureModeUndefined:
      if (!maxSize.isUndefined()) {
        *mode = TAYGMeasureModeAtMost;
        *size = maxSize.unwrap();
      }
      break;
  }
}

static void YGNodeComputeFlexBasisForChild(
    const TAYGNodeRef node,
    const TAYGNodeRef child,
    const float width,
    const TAYGMeasureMode widthMode,
    const float height,
    const float ownerWidth,
    const float ownerHeight,
    const TAYGMeasureMode heightMode,
    const TAYGDirection direction,
    const TAYGConfigRef config,
    LayoutData& layoutMarkerData,
    void* const layoutContext,
    const uint32_t depth,
    const uint32_t generationCount) {
  const TAYGFlexDirection mainAxis =
      TAYGResolveFlexDirection(node->getStyle().flexDirection(), direction);
  const bool isMainAxisRow = TAYGFlexDirectionIsRow(mainAxis);
  const float mainAxisSize = isMainAxisRow ? width : height;
  const float mainAxisownerSize = isMainAxisRow ? ownerWidth : ownerHeight;

  float childWidth;
  float childHeight;
  TAYGMeasureMode childWidthMeasureMode;
  TAYGMeasureMode childHeightMeasureMode;

  const TAYGFloatOptional resolvedFlexBasis =
      TAYGResolveValue(child->resolveFlexBasisPtr(), mainAxisownerSize);
  const bool isRowStyleDimDefined =
      YGNodeIsStyleDimDefined(child, TAYGFlexDirectionRow, ownerWidth);
  const bool isColumnStyleDimDefined =
      YGNodeIsStyleDimDefined(child, TAYGFlexDirectionColumn, ownerHeight);

  if (!resolvedFlexBasis.isUndefined() && !TAYGFloatIsUndefined(mainAxisSize)) {
    if (child->getLayout().computedFlexBasis.isUndefined() ||
        (TAYGConfigIsExperimentalFeatureEnabledfaults(
             child->getConfig(), TAYGExperimentalFeatureWebFlexBasis) &&
         child->getLayout().computedFlexBasisGeneration != generationCount)) {
      const TAYGFloatOptional paddingAndBorder = TAYGFloatOptional(
          YGNodePaddingAndBorderForAxis(child, mainAxis, ownerWidth));
      child->setLayoutComputedFlexBasis(
          TAYGFloatOptionalMax(resolvedFlexBasis, paddingAndBorder));
    }
  } else if (isMainAxisRow && isRowStyleDimDefined) {
    // The width is definite, so use that as the flex basis.
    const TAYGFloatOptional paddingAndBorder = TAYGFloatOptional(
        YGNodePaddingAndBorderForAxis(child, TAYGFlexDirectionRow, ownerWidth));

    child->setLayoutComputedFlexBasis(TAYGFloatOptionalMax(
        TAYGResolveValue(
            child->getResolvedDimensions()[TAYGDimensionWidth], ownerWidth),
        paddingAndBorder));
  } else if (!isMainAxisRow && isColumnStyleDimDefined) {
    // The height is definite, so use that as the flex basis.
    const TAYGFloatOptional paddingAndBorder =
        TAYGFloatOptional(YGNodePaddingAndBorderForAxis(
            child, TAYGFlexDirectionColumn, ownerWidth));
    child->setLayoutComputedFlexBasis(TAYGFloatOptionalMax(
        TAYGResolveValue(
            child->getResolvedDimensions()[TAYGDimensionHeight], ownerHeight),
        paddingAndBorder));
  } else {
    // Compute the flex basis and hypothetical main size (i.e. the clamped flex
    // basis).
    childWidth = TAYGUndefined;
    childHeight = TAYGUndefined;
    childWidthMeasureMode = TAYGMeasureModeUndefined;
    childHeightMeasureMode = TAYGMeasureModeUndefined;

    auto marginRow =
        child->getMarginForAxis(TAYGFlexDirectionRow, ownerWidth).unwrap();
    auto marginColumn =
        child->getMarginForAxis(TAYGFlexDirectionColumn, ownerWidth).unwrap();

    if (isRowStyleDimDefined) {
      childWidth =
          TAYGResolveValue(
              child->getResolvedDimensions()[TAYGDimensionWidth], ownerWidth)
              .unwrap() +
          marginRow;
      childWidthMeasureMode = TAYGMeasureModeExactly;
    }
    if (isColumnStyleDimDefined) {
      childHeight =
          TAYGResolveValue(
              child->getResolvedDimensions()[TAYGDimensionHeight], ownerHeight)
              .unwrap() +
          marginColumn;
      childHeightMeasureMode = TAYGMeasureModeExactly;
    }

    // The W3C spec doesn't say anything about the 'overflow' property, but all
    // major browsers appear to implement the following logic.
    if ((!isMainAxisRow && node->getStyle().overflow() == TAYGOverflowScroll) ||
        node->getStyle().overflow() != TAYGOverflowScroll) {
      if (TAYGFloatIsUndefined(childWidth) && !TAYGFloatIsUndefined(width)) {
        childWidth = width;
        childWidthMeasureMode = TAYGMeasureModeAtMost;
      }
    }

    if ((isMainAxisRow && node->getStyle().overflow() == TAYGOverflowScroll) ||
        node->getStyle().overflow() != TAYGOverflowScroll) {
      if (TAYGFloatIsUndefined(childHeight) && !TAYGFloatIsUndefined(height)) {
        childHeight = height;
        childHeightMeasureMode = TAYGMeasureModeAtMost;
      }
    }

    const auto& childStyle = child->getStyle();
    if (!childStyle.aspectRatio().isUndefined()) {
      if (!isMainAxisRow && childWidthMeasureMode == TAYGMeasureModeExactly) {
        childHeight = marginColumn +
            (childWidth - marginRow) / childStyle.aspectRatio().unwrap();
        childHeightMeasureMode = TAYGMeasureModeExactly;
      } else if (
          isMainAxisRow && childHeightMeasureMode == TAYGMeasureModeExactly) {
        childWidth = marginRow +
            (childHeight - marginColumn) * childStyle.aspectRatio().unwrap();
        childWidthMeasureMode = TAYGMeasureModeExactly;
      }
    }

    // If child has no defined size in the cross axis and is set to stretch, set
    // the cross axis to be measured exactly with the available inner width

    const bool hasExactWidth =
        !TAYGFloatIsUndefined(width) && widthMode == TAYGMeasureModeExactly;
    const bool childWidthStretch =
        YGNodeAlignItem(node, child) == TAYGAlignStretch &&
        childWidthMeasureMode != TAYGMeasureModeExactly;
    if (!isMainAxisRow && !isRowStyleDimDefined && hasExactWidth &&
        childWidthStretch) {
      childWidth = width;
      childWidthMeasureMode = TAYGMeasureModeExactly;
      if (!childStyle.aspectRatio().isUndefined()) {
        childHeight =
            (childWidth - marginRow) / childStyle.aspectRatio().unwrap();
        childHeightMeasureMode = TAYGMeasureModeExactly;
      }
    }

    const bool hasExactHeight =
        !TAYGFloatIsUndefined(height) && heightMode == TAYGMeasureModeExactly;
    const bool childHeightStretch =
        YGNodeAlignItem(node, child) == TAYGAlignStretch &&
        childHeightMeasureMode != TAYGMeasureModeExactly;
    if (isMainAxisRow && !isColumnStyleDimDefined && hasExactHeight &&
        childHeightStretch) {
      childHeight = height;
      childHeightMeasureMode = TAYGMeasureModeExactly;

      if (!childStyle.aspectRatio().isUndefined()) {
        childWidth =
            (childHeight - marginColumn) * childStyle.aspectRatio().unwrap();
        childWidthMeasureMode = TAYGMeasureModeExactly;
      }
    }

    YGConstrainMaxSizeForMode(
        child,
        TAYGFlexDirectionRow,
        ownerWidth,
        ownerWidth,
        &childWidthMeasureMode,
        &childWidth);
    YGConstrainMaxSizeForMode(
        child,
        TAYGFlexDirectionColumn,
        ownerHeight,
        ownerWidth,
        &childHeightMeasureMode,
        &childHeight);

    // Measure the child
    YGLayoutNodeInternal(
        child,
        childWidth,
        childHeight,
        direction,
        childWidthMeasureMode,
        childHeightMeasureMode,
        ownerWidth,
        ownerHeight,
        false,
        LayoutPassReason::kMeasureChild,
        config,
        layoutMarkerData,
        layoutContext,
        depth,
        generationCount);

    child->setLayoutComputedFlexBasis(TAYGFloatOptional(TAYGFloatMax(
        child->getLayout().measuredDimensions[dim[mainAxis]],
        YGNodePaddingAndBorderForAxis(child, mainAxis, ownerWidth))));
  }
  child->setLayoutComputedFlexBasisGeneration(generationCount);
}

static void YGNodeAbsoluteLayoutChild(
    const TAYGNodeRef node,
    const TAYGNodeRef child,
    const float width,
    const TAYGMeasureMode widthMode,
    const float height,
    const TAYGDirection direction,
    const TAYGConfigRef config,
    LayoutData& layoutMarkerData,
    void* const layoutContext,
    const uint32_t depth,
    const uint32_t generationCount) {
  const TAYGFlexDirection mainAxis =
      TAYGResolveFlexDirection(node->getStyle().flexDirection(), direction);
  const TAYGFlexDirection crossAxis = TAYGFlexDirectionCross(mainAxis, direction);
  const bool isMainAxisRow = TAYGFlexDirectionIsRow(mainAxis);

  float childWidth = TAYGUndefined;
  float childHeight = TAYGUndefined;
  TAYGMeasureMode childWidthMeasureMode = TAYGMeasureModeUndefined;
  TAYGMeasureMode childHeightMeasureMode = TAYGMeasureModeUndefined;

  auto marginRow = child->getMarginForAxis(TAYGFlexDirectionRow, width).unwrap();
  auto marginColumn =
      child->getMarginForAxis(TAYGFlexDirectionColumn, width).unwrap();

  if (YGNodeIsStyleDimDefined(child, TAYGFlexDirectionRow, width)) {
    childWidth =
        TAYGResolveValue(child->getResolvedDimensions()[TAYGDimensionWidth], width)
            .unwrap() +
        marginRow;
  } else {
    // If the child doesn't have a specified width, compute the width based on
    // the left/right offsets if they're defined.
    if (child->isLeadingPositionDefined(TAYGFlexDirectionRow) &&
        child->isTrailingPosDefined(TAYGFlexDirectionRow)) {
      childWidth = node->getLayout().measuredDimensions[TAYGDimensionWidth] -
          (node->getLeadingBorder(TAYGFlexDirectionRow) +
           node->getTrailingBorder(TAYGFlexDirectionRow)) -
          (child->getLeadingPosition(TAYGFlexDirectionRow, width) +
           child->getTrailingPosition(TAYGFlexDirectionRow, width))
              .unwrap();
      childWidth =
          YGNodeBoundAxis(child, TAYGFlexDirectionRow, childWidth, width, width);
    }
  }

  if (YGNodeIsStyleDimDefined(child, TAYGFlexDirectionColumn, height)) {
    childHeight = TAYGResolveValue(
                      child->getResolvedDimensions()[TAYGDimensionHeight], height)
                      .unwrap() +
        marginColumn;
  } else {
    // If the child doesn't have a specified height, compute the height based on
    // the top/bottom offsets if they're defined.
    if (child->isLeadingPositionDefined(TAYGFlexDirectionColumn) &&
        child->isTrailingPosDefined(TAYGFlexDirectionColumn)) {
      childHeight = node->getLayout().measuredDimensions[TAYGDimensionHeight] -
          (node->getLeadingBorder(TAYGFlexDirectionColumn) +
           node->getTrailingBorder(TAYGFlexDirectionColumn)) -
          (child->getLeadingPosition(TAYGFlexDirectionColumn, height) +
           child->getTrailingPosition(TAYGFlexDirectionColumn, height))
              .unwrap();
      childHeight = YGNodeBoundAxis(
          child, TAYGFlexDirectionColumn, childHeight, height, width);
    }
  }

  // Exactly one dimension needs to be defined for us to be able to do aspect
  // ratio calculation. One dimension being the anchor and the other being
  // flexible.
  const auto& childStyle = child->getStyle();
  if (TAYGFloatIsUndefined(childWidth) ^ TAYGFloatIsUndefined(childHeight)) {
    if (!childStyle.aspectRatio().isUndefined()) {
      if (TAYGFloatIsUndefined(childWidth)) {
        childWidth = marginRow +
            (childHeight - marginColumn) * childStyle.aspectRatio().unwrap();
      } else if (TAYGFloatIsUndefined(childHeight)) {
        childHeight = marginColumn +
            (childWidth - marginRow) / childStyle.aspectRatio().unwrap();
      }
    }
  }

  // If we're still missing one or the other dimension, measure the content.
  if (TAYGFloatIsUndefined(childWidth) || TAYGFloatIsUndefined(childHeight)) {
    childWidthMeasureMode = TAYGFloatIsUndefined(childWidth)
        ? TAYGMeasureModeUndefined
        : TAYGMeasureModeExactly;
    childHeightMeasureMode = TAYGFloatIsUndefined(childHeight)
        ? TAYGMeasureModeUndefined
        : TAYGMeasureModeExactly;

    // If the size of the owner is defined then try to constrain the absolute
    // child to that size as well. This allows text within the absolute child to
    // wrap to the size of its owner. This is the same behavior as many browsers
    // implement.
    if (!isMainAxisRow && TAYGFloatIsUndefined(childWidth) &&
        widthMode != TAYGMeasureModeUndefined && !TAYGFloatIsUndefined(width) &&
        width > 0) {
      childWidth = width;
      childWidthMeasureMode = TAYGMeasureModeAtMost;
    }

    YGLayoutNodeInternal(
        child,
        childWidth,
        childHeight,
        direction,
        childWidthMeasureMode,
        childHeightMeasureMode,
        childWidth,
        childHeight,
        false,
        LayoutPassReason::kAbsMeasureChild,
        config,
        layoutMarkerData,
        layoutContext,
        depth,
        generationCount);
    childWidth = child->getLayout().measuredDimensions[TAYGDimensionWidth] +
        child->getMarginForAxis(TAYGFlexDirectionRow, width).unwrap();
    childHeight = child->getLayout().measuredDimensions[TAYGDimensionHeight] +
        child->getMarginForAxis(TAYGFlexDirectionColumn, width).unwrap();
  }

  YGLayoutNodeInternal(
      child,
      childWidth,
      childHeight,
      direction,
      TAYGMeasureModeExactly,
      TAYGMeasureModeExactly,
      childWidth,
      childHeight,
      true,
      LayoutPassReason::kAbsLayout,
      config,
      layoutMarkerData,
      layoutContext,
      depth,
      generationCount);

  if (child->isTrailingPosDefined(mainAxis) &&
      !child->isLeadingPositionDefined(mainAxis)) {
    child->setLayoutPosition(
        node->getLayout().measuredDimensions[dim[mainAxis]] -
            child->getLayout().measuredDimensions[dim[mainAxis]] -
            node->getTrailingBorder(mainAxis) -
            child->getTrailingMargin(mainAxis, width).unwrap() -
            child->getTrailingPosition(mainAxis, isMainAxisRow ? width : height)
                .unwrap(),
        ta_leading[mainAxis]);
  } else if (
      !child->isLeadingPositionDefined(mainAxis) &&
      node->getStyle().justifyContent() == TAYGJustifyCenter) {
    child->setLayoutPosition(
        (node->getLayout().measuredDimensions[dim[mainAxis]] -
         child->getLayout().measuredDimensions[dim[mainAxis]]) /
            2.0f,
        ta_leading[mainAxis]);
  } else if (
      !child->isLeadingPositionDefined(mainAxis) &&
      node->getStyle().justifyContent() == TAYGJustifyFlexEnd) {
    child->setLayoutPosition(
        (node->getLayout().measuredDimensions[dim[mainAxis]] -
         child->getLayout().measuredDimensions[dim[mainAxis]]),
        ta_leading[mainAxis]);
  }

  if (child->isTrailingPosDefined(crossAxis) &&
      !child->isLeadingPositionDefined(crossAxis)) {
    child->setLayoutPosition(
        node->getLayout().measuredDimensions[dim[crossAxis]] -
            child->getLayout().measuredDimensions[dim[crossAxis]] -
            node->getTrailingBorder(crossAxis) -
            child->getTrailingMargin(crossAxis, width).unwrap() -
            child
                ->getTrailingPosition(crossAxis, isMainAxisRow ? height : width)
                .unwrap(),
        ta_leading[crossAxis]);

  } else if (
      !child->isLeadingPositionDefined(crossAxis) &&
      YGNodeAlignItem(node, child) == TAYGAlignCenter) {
    child->setLayoutPosition(
        (node->getLayout().measuredDimensions[dim[crossAxis]] -
         child->getLayout().measuredDimensions[dim[crossAxis]]) /
            2.0f,
        ta_leading[crossAxis]);
  } else if (
      !child->isLeadingPositionDefined(crossAxis) &&
      ((YGNodeAlignItem(node, child) == TAYGAlignFlexEnd) ^
       (node->getStyle().flexWrap() == TAYGWrapWrapReverse))) {
    child->setLayoutPosition(
        (node->getLayout().measuredDimensions[dim[crossAxis]] -
         child->getLayout().measuredDimensions[dim[crossAxis]]),
        ta_leading[crossAxis]);
  }
}

static void YGNodeWithMeasureFuncSetMeasuredDimensions(
    const TAYGNodeRef node,
    float availableWidth,
    float availableHeight,
    const TAYGMeasureMode widthMeasureMode,
    const TAYGMeasureMode heightMeasureMode,
    const float ownerWidth,
    const float ownerHeight,
    LayoutData& layoutMarkerData,
    void* const layoutContext,
    const LayoutPassReason reason) {
  TAYGAssertWithNode(
      node,
      node->hasMeasureFunc(),
      "Expected node to have custom measure function");

  if (widthMeasureMode == TAYGMeasureModeUndefined) {
    availableWidth = TAYGUndefined;
  }
  if (heightMeasureMode == TAYGMeasureModeUndefined) {
    availableHeight = TAYGUndefined;
  }

  const auto& padding = node->getLayout().padding;
  const auto& border = node->getLayout().border;
  const float paddingAndBorderAxisRow = padding[TAYGEdgeLeft] +
      padding[TAYGEdgeRight] + border[TAYGEdgeLeft] + border[TAYGEdgeRight];
  const float paddingAndBorderAxisColumn = padding[TAYGEdgeTop] +
      padding[TAYGEdgeBottom] + border[TAYGEdgeTop] + border[TAYGEdgeBottom];

  // We want to make sure we don't call measure with negative size
  const float innerWidth = TAYGFloatIsUndefined(availableWidth)
      ? availableWidth
      : TAYGFloatMax(0, availableWidth - paddingAndBorderAxisRow);
  const float innerHeight = TAYGFloatIsUndefined(availableHeight)
      ? availableHeight
      : TAYGFloatMax(0, availableHeight - paddingAndBorderAxisColumn);

  if (widthMeasureMode == TAYGMeasureModeExactly &&
      heightMeasureMode == TAYGMeasureModeExactly) {
    // Don't bother sizing the text if both dimensions are already defined.
    node->setLayoutMeasuredDimension(
        YGNodeBoundAxis(
            node, TAYGFlexDirectionRow, availableWidth, ownerWidth, ownerWidth),
        TAYGDimensionWidth);
    node->setLayoutMeasuredDimension(
        YGNodeBoundAxis(
            node,
            TAYGFlexDirectionColumn,
            availableHeight,
            ownerHeight,
            ownerWidth),
        TAYGDimensionHeight);
  } else {
    Event::publish<Event::MeasureCallbackStart>(node);

    // Measure the text under the current constraints.
    const TAYGSize measuredSize = node->measure(
        innerWidth,
        widthMeasureMode,
        innerHeight,
        heightMeasureMode,
        layoutContext);

    layoutMarkerData.measureCallbacks += 1;
    layoutMarkerData.measureCallbackReasonsCount[static_cast<size_t>(reason)] +=
        1;

    Event::publish<Event::MeasureCallbackEnd>(
        node,
        {layoutContext,
         innerWidth,
         widthMeasureMode,
         innerHeight,
         heightMeasureMode,
         measuredSize.width,
         measuredSize.height,
         reason});

    node->setLayoutMeasuredDimension(
        YGNodeBoundAxis(
            node,
            TAYGFlexDirectionRow,
            (widthMeasureMode == TAYGMeasureModeUndefined ||
             widthMeasureMode == TAYGMeasureModeAtMost)
                ? measuredSize.width + paddingAndBorderAxisRow
                : availableWidth,
            ownerWidth,
            ownerWidth),
        TAYGDimensionWidth);

    node->setLayoutMeasuredDimension(
        YGNodeBoundAxis(
            node,
            TAYGFlexDirectionColumn,
            (heightMeasureMode == TAYGMeasureModeUndefined ||
             heightMeasureMode == TAYGMeasureModeAtMost)
                ? measuredSize.height + paddingAndBorderAxisColumn
                : availableHeight,
            ownerHeight,
            ownerWidth),
        TAYGDimensionHeight);
  }
}

// For nodes with no children, use the available values if they were provided,
// or the minimum size as indicated by the padding and border sizes.
static void YGNodeEmptyContainerSetMeasuredDimensions(
    const TAYGNodeRef node,
    const float availableWidth,
    const float availableHeight,
    const TAYGMeasureMode widthMeasureMode,
    const TAYGMeasureMode heightMeasureMode,
    const float ownerWidth,
    const float ownerHeight) {
  const auto& padding = node->getLayout().padding;
  const auto& border = node->getLayout().border;

  float width = availableWidth;
  if (widthMeasureMode == TAYGMeasureModeUndefined ||
      widthMeasureMode == TAYGMeasureModeAtMost) {
    width = padding[TAYGEdgeLeft] + padding[TAYGEdgeRight] + border[TAYGEdgeLeft] +
        border[TAYGEdgeRight];
  }
  node->setLayoutMeasuredDimension(
      YGNodeBoundAxis(node, TAYGFlexDirectionRow, width, ownerWidth, ownerWidth),
      TAYGDimensionWidth);

  float height = availableHeight;
  if (heightMeasureMode == TAYGMeasureModeUndefined ||
      heightMeasureMode == TAYGMeasureModeAtMost) {
    height = padding[TAYGEdgeTop] + padding[TAYGEdgeBottom] + border[TAYGEdgeTop] +
        border[TAYGEdgeBottom];
  }
  node->setLayoutMeasuredDimension(
      YGNodeBoundAxis(
          node, TAYGFlexDirectionColumn, height, ownerHeight, ownerWidth),
      TAYGDimensionHeight);
}

static bool YGNodeFixedSizeSetMeasuredDimensions(
    const TAYGNodeRef node,
    const float availableWidth,
    const float availableHeight,
    const TAYGMeasureMode widthMeasureMode,
    const TAYGMeasureMode heightMeasureMode,
    const float ownerWidth,
    const float ownerHeight) {
  if ((!TAYGFloatIsUndefined(availableWidth) &&
       widthMeasureMode == TAYGMeasureModeAtMost && availableWidth <= 0.0f) ||
      (!TAYGFloatIsUndefined(availableHeight) &&
       heightMeasureMode == TAYGMeasureModeAtMost && availableHeight <= 0.0f) ||
      (widthMeasureMode == TAYGMeasureModeExactly &&
       heightMeasureMode == TAYGMeasureModeExactly)) {
    node->setLayoutMeasuredDimension(
        YGNodeBoundAxis(
            node,
            TAYGFlexDirectionRow,
            TAYGFloatIsUndefined(availableWidth) ||
                    (widthMeasureMode == TAYGMeasureModeAtMost &&
                     availableWidth < 0.0f)
                ? 0.0f
                : availableWidth,
            ownerWidth,
            ownerWidth),
        TAYGDimensionWidth);

    node->setLayoutMeasuredDimension(
        YGNodeBoundAxis(
            node,
            TAYGFlexDirectionColumn,
            TAYGFloatIsUndefined(availableHeight) ||
                    (heightMeasureMode == TAYGMeasureModeAtMost &&
                     availableHeight < 0.0f)
                ? 0.0f
                : availableHeight,
            ownerHeight,
            ownerWidth),
        TAYGDimensionHeight);
    return true;
  }

  return false;
}

static void YGZeroOutLayoutRecursivly(
    const TAYGNodeRef node,
    void* layoutContext) {
  node->getLayout() = {};
  node->setLayoutDimension(0, 0);
  node->setLayoutDimension(0, 1);
  node->setHasNewLayout(true);

  node->iterChildrenAfterCloningIfNeeded(
      YGZeroOutLayoutRecursivly, layoutContext);
}

static float YGNodeCalculateAvailableInnerDim(
    const TAYGNodeConstRef node,
    const TAYGDimension dimension,
    const float availableDim,
    const float paddingAndBorder,
    const float ownerDim) {
  float availableInnerDim = availableDim - paddingAndBorder;
  // Max dimension overrides predefined dimension value; Min dimension in turn
  // overrides both of the above
  if (!TAYGFloatIsUndefined(availableInnerDim)) {
    // We want to make sure our available height does not violate min and max
    // constraints
    const TAYGFloatOptional minDimensionOptional =
        TAYGResolveValue(node->getStyle().minDimensions()[dimension], ownerDim);
    const float minInnerDim = minDimensionOptional.isUndefined()
        ? 0.0f
        : minDimensionOptional.unwrap() - paddingAndBorder;

    const TAYGFloatOptional maxDimensionOptional =
        TAYGResolveValue(node->getStyle().maxDimensions()[dimension], ownerDim);

    const float maxInnerDim = maxDimensionOptional.isUndefined()
        ? FLT_MAX
        : maxDimensionOptional.unwrap() - paddingAndBorder;
    availableInnerDim =
        TAYGFloatMax(TAYGFloatMin(availableInnerDim, maxInnerDim), minInnerDim);
  }

  return availableInnerDim;
}

static float YGNodeComputeFlexBasisForChildren(
    const TAYGNodeRef node,
    const float availableInnerWidth,
    const float availableInnerHeight,
    TAYGMeasureMode widthMeasureMode,
    TAYGMeasureMode heightMeasureMode,
    TAYGDirection direction,
    TAYGFlexDirection mainAxis,
    const TAYGConfigRef config,
    bool performLayout,
    LayoutData& layoutMarkerData,
    void* const layoutContext,
    const uint32_t depth,
    const uint32_t generationCount) {
  float totalOuterFlexBasis = 0.0f;
  TAYGNodeRef singleFlexChild = nullptr;
  const TAYGVector& children = node->getChildren();
  TAYGMeasureMode measureModeMainDim =
      TAYGFlexDirectionIsRow(mainAxis) ? widthMeasureMode : heightMeasureMode;
  // If there is only one child with flexGrow + flexShrink it means we can set
  // the computedFlexBasis to 0 instead of measuring and shrinking / flexing the
  // child to exactly match the remaining space
  if (measureModeMainDim == TAYGMeasureModeExactly) {
    for (auto child : children) {
      if (child->isNodeFlexible()) {
        if (singleFlexChild != nullptr ||
            TAYGFloatsEqual(child->resolveFlexGrow(), 0.0f) ||
            TAYGFloatsEqual(child->resolveFlexShrink(), 0.0f)) {
          // There is already a flexible child, or this flexible child doesn't
          // have flexGrow and flexShrink, abort
          singleFlexChild = nullptr;
          break;
        } else {
          singleFlexChild = child;
        }
      }
    }
  }

  for (auto child : children) {
    child->resolveDimension();
    if (child->getStyle().display() == TAYGDisplayNone) {
      YGZeroOutLayoutRecursivly(child, layoutContext);
      child->setHasNewLayout(true);
      child->setDirty(false);
      continue;
    }
    if (performLayout) {
      // Set the initial position (relative to the owner).
      const TAYGDirection childDirection = child->resolveDirection(direction);
      const float mainDim = TAYGFlexDirectionIsRow(mainAxis)
          ? availableInnerWidth
          : availableInnerHeight;
      const float crossDim = TAYGFlexDirectionIsRow(mainAxis)
          ? availableInnerHeight
          : availableInnerWidth;
      child->setPosition(
          childDirection, mainDim, crossDim, availableInnerWidth);
    }

    if (child->getStyle().positionType() == TAYGPositionTypeAbsolute) {
      continue;
    }
    if (child == singleFlexChild) {
      child->setLayoutComputedFlexBasisGeneration(generationCount);
      child->setLayoutComputedFlexBasis(TAYGFloatOptional(0));
    } else {
      YGNodeComputeFlexBasisForChild(
          node,
          child,
          availableInnerWidth,
          widthMeasureMode,
          availableInnerHeight,
          availableInnerWidth,
          availableInnerHeight,
          heightMeasureMode,
          direction,
          config,
          layoutMarkerData,
          layoutContext,
          depth,
          generationCount);
    }

    totalOuterFlexBasis +=
        (child->getLayout().computedFlexBasis +
         child->getMarginForAxis(mainAxis, availableInnerWidth))
            .unwrap();
  }

  return totalOuterFlexBasis;
}

// This function assumes that all the children of node have their
// computedFlexBasis properly computed(To do this use
// YGNodeComputeFlexBasisForChildren function). This function calculates
// YGCollectFlexItemsRowMeasurement
static TAYGCollectFlexItemsRowValues YGCalculateCollectFlexItemsRowValues(
    const TAYGNodeRef& node,
    const TAYGDirection ownerDirection,
    const float mainAxisownerSize,
    const float availableInnerWidth,
    const float availableInnerMainDim,
    const uint32_t startOfLineIndex,
    const uint32_t lineCount) {
  TAYGCollectFlexItemsRowValues flexAlgoRowMeasurement = {};
  flexAlgoRowMeasurement.relativeChildren.reserve(node->getChildren().size());

  float sizeConsumedOnCurrentLineIncludingMinConstraint = 0;
  const TAYGFlexDirection mainAxis = TAYGResolveFlexDirection(
      node->getStyle().flexDirection(), node->resolveDirection(ownerDirection));
  const bool isNodeFlexWrap = node->getStyle().flexWrap() != TAYGWrapNoWrap;

  // Add items to the current line until it's full or we run out of items.
  uint32_t endOfLineIndex = startOfLineIndex;
  for (; endOfLineIndex < node->getChildren().size(); endOfLineIndex++) {
    const TAYGNodeRef child = node->getChild(endOfLineIndex);
    if (child->getStyle().display() == TAYGDisplayNone ||
        child->getStyle().positionType() == TAYGPositionTypeAbsolute) {
      continue;
    }
    child->setLineIndex(lineCount);
    const float childMarginMainAxis =
        child->getMarginForAxis(mainAxis, availableInnerWidth).unwrap();
    const float flexBasisWithMinAndMaxConstraints =
        YGNodeBoundAxisWithinMinAndMax(
            child,
            mainAxis,
            child->getLayout().computedFlexBasis,
            mainAxisownerSize)
            .unwrap();

    // If this is a multi-line flow and this item pushes us over the available
    // size, we've hit the end of the current line. Break out of the loop and
    // lay out the current line.
    if (sizeConsumedOnCurrentLineIncludingMinConstraint +
                flexBasisWithMinAndMaxConstraints + childMarginMainAxis >
            availableInnerMainDim &&
        isNodeFlexWrap && flexAlgoRowMeasurement.itemsOnLine > 0) {
      break;
    }

    sizeConsumedOnCurrentLineIncludingMinConstraint +=
        flexBasisWithMinAndMaxConstraints + childMarginMainAxis;
    flexAlgoRowMeasurement.sizeConsumedOnCurrentLine +=
        flexBasisWithMinAndMaxConstraints + childMarginMainAxis;
    flexAlgoRowMeasurement.itemsOnLine++;

    if (child->isNodeFlexible()) {
      flexAlgoRowMeasurement.totalFlexGrowFactors += child->resolveFlexGrow();

      // Unlike the grow factor, the shrink factor is scaled relative to the
      // child dimension.
      flexAlgoRowMeasurement.totalFlexShrinkScaledFactors +=
          -child->resolveFlexShrink() *
          child->getLayout().computedFlexBasis.unwrap();
    }

    flexAlgoRowMeasurement.relativeChildren.push_back(child);
  }

  // The total flex factor needs to be floored to 1.
  if (flexAlgoRowMeasurement.totalFlexGrowFactors > 0 &&
      flexAlgoRowMeasurement.totalFlexGrowFactors < 1) {
    flexAlgoRowMeasurement.totalFlexGrowFactors = 1;
  }

  // The total flex shrink factor needs to be floored to 1.
  if (flexAlgoRowMeasurement.totalFlexShrinkScaledFactors > 0 &&
      flexAlgoRowMeasurement.totalFlexShrinkScaledFactors < 1) {
    flexAlgoRowMeasurement.totalFlexShrinkScaledFactors = 1;
  }
  flexAlgoRowMeasurement.endOfLineIndex = endOfLineIndex;
  return flexAlgoRowMeasurement;
}

// It distributes the free space to the flexible items and ensures that the size
// of the flex items abide the min and max constraints. At the end of this
// function the child nodes would have proper size. Prior using this function
// please ensure that YGDistributeFreeSpaceFirstPass is called.
static float YGDistributeFreeSpaceSecondPass(
    TAYGCollectFlexItemsRowValues& collectedFlexItemsValues,
    const TAYGNodeRef node,
    const TAYGFlexDirection mainAxis,
    const TAYGFlexDirection crossAxis,
    const float mainAxisownerSize,
    const float availableInnerMainDim,
    const float availableInnerCrossDim,
    const float availableInnerWidth,
    const float availableInnerHeight,
    const bool flexBasisOverflows,
    const TAYGMeasureMode measureModeCrossDim,
    const bool performLayout,
    const TAYGConfigRef config,
    LayoutData& layoutMarkerData,
    void* const layoutContext,
    const uint32_t depth,
    const uint32_t generationCount) {
  float childFlexBasis = 0;
  float flexShrinkScaledFactor = 0;
  float flexGrowFactor = 0;
  float deltaFreeSpace = 0;
  const bool isMainAxisRow = TAYGFlexDirectionIsRow(mainAxis);
  const bool isNodeFlexWrap = node->getStyle().flexWrap() != TAYGWrapNoWrap;

  for (auto currentRelativeChild : collectedFlexItemsValues.relativeChildren) {
    childFlexBasis = YGNodeBoundAxisWithinMinAndMax(
                         currentRelativeChild,
                         mainAxis,
                         currentRelativeChild->getLayout().computedFlexBasis,
                         mainAxisownerSize)
                         .unwrap();
    float updatedMainSize = childFlexBasis;

    if (!TAYGFloatIsUndefined(collectedFlexItemsValues.remainingFreeSpace) &&
        collectedFlexItemsValues.remainingFreeSpace < 0) {
      flexShrinkScaledFactor =
          -currentRelativeChild->resolveFlexShrink() * childFlexBasis;
      // Is this child able to shrink?
      if (flexShrinkScaledFactor != 0) {
        float childSize;

        if (!TAYGFloatIsUndefined(
                collectedFlexItemsValues.totalFlexShrinkScaledFactors) &&
            collectedFlexItemsValues.totalFlexShrinkScaledFactors == 0) {
          childSize = childFlexBasis + flexShrinkScaledFactor;
        } else {
          childSize = childFlexBasis +
              (collectedFlexItemsValues.remainingFreeSpace /
               collectedFlexItemsValues.totalFlexShrinkScaledFactors) *
                  flexShrinkScaledFactor;
        }

        updatedMainSize = YGNodeBoundAxis(
            currentRelativeChild,
            mainAxis,
            childSize,
            availableInnerMainDim,
            availableInnerWidth);
      }
    } else if (
        !TAYGFloatIsUndefined(collectedFlexItemsValues.remainingFreeSpace) &&
        collectedFlexItemsValues.remainingFreeSpace > 0) {
      flexGrowFactor = currentRelativeChild->resolveFlexGrow();

      // Is this child able to grow?
      if (!TAYGFloatIsUndefined(flexGrowFactor) && flexGrowFactor != 0) {
        updatedMainSize = YGNodeBoundAxis(
            currentRelativeChild,
            mainAxis,
            childFlexBasis +
                collectedFlexItemsValues.remainingFreeSpace /
                    collectedFlexItemsValues.totalFlexGrowFactors *
                    flexGrowFactor,
            availableInnerMainDim,
            availableInnerWidth);
      }
    }

    deltaFreeSpace += updatedMainSize - childFlexBasis;

    const float marginMain =
        currentRelativeChild->getMarginForAxis(mainAxis, availableInnerWidth)
            .unwrap();
    const float marginCross =
        currentRelativeChild->getMarginForAxis(crossAxis, availableInnerWidth)
            .unwrap();

    float childCrossSize;
    float childMainSize = updatedMainSize + marginMain;
    TAYGMeasureMode childCrossMeasureMode;
    TAYGMeasureMode childMainMeasureMode = TAYGMeasureModeExactly;

    const auto& childStyle = currentRelativeChild->getStyle();
    if (!childStyle.aspectRatio().isUndefined()) {
      childCrossSize = isMainAxisRow
          ? (childMainSize - marginMain) / childStyle.aspectRatio().unwrap()
          : (childMainSize - marginMain) * childStyle.aspectRatio().unwrap();
      childCrossMeasureMode = TAYGMeasureModeExactly;

      childCrossSize += marginCross;
    } else if (
        !TAYGFloatIsUndefined(availableInnerCrossDim) &&
        !YGNodeIsStyleDimDefined(
            currentRelativeChild, crossAxis, availableInnerCrossDim) &&
        measureModeCrossDim == TAYGMeasureModeExactly &&
        !(isNodeFlexWrap && flexBasisOverflows) &&
        YGNodeAlignItem(node, currentRelativeChild) == TAYGAlignStretch &&
        currentRelativeChild->marginLeadingValue(crossAxis).unit !=
            TAYGUnitAuto &&
        currentRelativeChild->marginTrailingValue(crossAxis).unit !=
            TAYGUnitAuto) {
      childCrossSize = availableInnerCrossDim;
      childCrossMeasureMode = TAYGMeasureModeExactly;
    } else if (!YGNodeIsStyleDimDefined(
                   currentRelativeChild, crossAxis, availableInnerCrossDim)) {
      childCrossSize = availableInnerCrossDim;
      childCrossMeasureMode = TAYGFloatIsUndefined(childCrossSize)
          ? TAYGMeasureModeUndefined
          : TAYGMeasureModeAtMost;
    } else {
      childCrossSize =
          TAYGResolveValue(
              currentRelativeChild->getResolvedDimension(dim[crossAxis]),
              availableInnerCrossDim)
              .unwrap() +
          marginCross;
      const bool isLoosePercentageMeasurement =
          currentRelativeChild->getResolvedDimension(dim[crossAxis]).unit ==
              TAYGUnitPercent &&
          measureModeCrossDim != TAYGMeasureModeExactly;
      childCrossMeasureMode =
          TAYGFloatIsUndefined(childCrossSize) || isLoosePercentageMeasurement
          ? TAYGMeasureModeUndefined
          : TAYGMeasureModeExactly;
    }

    YGConstrainMaxSizeForMode(
        currentRelativeChild,
        mainAxis,
        availableInnerMainDim,
        availableInnerWidth,
        &childMainMeasureMode,
        &childMainSize);
    YGConstrainMaxSizeForMode(
        currentRelativeChild,
        crossAxis,
        availableInnerCrossDim,
        availableInnerWidth,
        &childCrossMeasureMode,
        &childCrossSize);

    const bool requiresStretchLayout =
        !YGNodeIsStyleDimDefined(
            currentRelativeChild, crossAxis, availableInnerCrossDim) &&
        YGNodeAlignItem(node, currentRelativeChild) == TAYGAlignStretch &&
        currentRelativeChild->marginLeadingValue(crossAxis).unit !=
            TAYGUnitAuto &&
        currentRelativeChild->marginTrailingValue(crossAxis).unit != TAYGUnitAuto;

    const float childWidth = isMainAxisRow ? childMainSize : childCrossSize;
    const float childHeight = !isMainAxisRow ? childMainSize : childCrossSize;

    const TAYGMeasureMode childWidthMeasureMode =
        isMainAxisRow ? childMainMeasureMode : childCrossMeasureMode;
    const TAYGMeasureMode childHeightMeasureMode =
        !isMainAxisRow ? childMainMeasureMode : childCrossMeasureMode;

    const bool isLayoutPass = performLayout && !requiresStretchLayout;
    // Recursively call the layout algorithm for this child with the updated
    // main size.
    YGLayoutNodeInternal(
        currentRelativeChild,
        childWidth,
        childHeight,
        node->getLayout().direction(),
        childWidthMeasureMode,
        childHeightMeasureMode,
        availableInnerWidth,
        availableInnerHeight,
        isLayoutPass,
        isLayoutPass ? LayoutPassReason::kFlexLayout
                     : LayoutPassReason::kFlexMeasure,
        config,
        layoutMarkerData,
        layoutContext,
        depth,
        generationCount);
    node->setLayoutHadOverflow(
        node->getLayout().hadOverflow() |
        currentRelativeChild->getLayout().hadOverflow());
  }
  return deltaFreeSpace;
}

// It distributes the free space to the flexible items.For those flexible items
// whose min and max constraints are triggered, those flex item's clamped size
// is removed from the remaingfreespace.
static void YGDistributeFreeSpaceFirstPass(
    TAYGCollectFlexItemsRowValues& collectedFlexItemsValues,
    const TAYGFlexDirection mainAxis,
    const float mainAxisownerSize,
    const float availableInnerMainDim,
    const float availableInnerWidth) {
  float flexShrinkScaledFactor = 0;
  float flexGrowFactor = 0;
  float baseMainSize = 0;
  float boundMainSize = 0;
  float deltaFreeSpace = 0;

  for (auto currentRelativeChild : collectedFlexItemsValues.relativeChildren) {
    float childFlexBasis =
        YGNodeBoundAxisWithinMinAndMax(
            currentRelativeChild,
            mainAxis,
            currentRelativeChild->getLayout().computedFlexBasis,
            mainAxisownerSize)
            .unwrap();

    if (collectedFlexItemsValues.remainingFreeSpace < 0) {
      flexShrinkScaledFactor =
          -currentRelativeChild->resolveFlexShrink() * childFlexBasis;

      // Is this child able to shrink?
      if (!TAYGFloatIsUndefined(flexShrinkScaledFactor) &&
          flexShrinkScaledFactor != 0) {
        baseMainSize = childFlexBasis +
            collectedFlexItemsValues.remainingFreeSpace /
                collectedFlexItemsValues.totalFlexShrinkScaledFactors *
                flexShrinkScaledFactor;
        boundMainSize = YGNodeBoundAxis(
            currentRelativeChild,
            mainAxis,
            baseMainSize,
            availableInnerMainDim,
            availableInnerWidth);
        if (!TAYGFloatIsUndefined(baseMainSize) &&
            !TAYGFloatIsUndefined(boundMainSize) &&
            baseMainSize != boundMainSize) {
          // By excluding this item's size and flex factor from remaining, this
          // item's min/max constraints should also trigger in the second pass
          // resulting in the item's size calculation being identical in the
          // first and second passes.
          deltaFreeSpace += boundMainSize - childFlexBasis;
          collectedFlexItemsValues.totalFlexShrinkScaledFactors -=
              (-currentRelativeChild->resolveFlexShrink() *
               currentRelativeChild->getLayout().computedFlexBasis.unwrap());
        }
      }
    } else if (
        !TAYGFloatIsUndefined(collectedFlexItemsValues.remainingFreeSpace) &&
        collectedFlexItemsValues.remainingFreeSpace > 0) {
      flexGrowFactor = currentRelativeChild->resolveFlexGrow();

      // Is this child able to grow?
      if (!TAYGFloatIsUndefined(flexGrowFactor) && flexGrowFactor != 0) {
        baseMainSize = childFlexBasis +
            collectedFlexItemsValues.remainingFreeSpace /
                collectedFlexItemsValues.totalFlexGrowFactors * flexGrowFactor;
        boundMainSize = YGNodeBoundAxis(
            currentRelativeChild,
            mainAxis,
            baseMainSize,
            availableInnerMainDim,
            availableInnerWidth);

        if (!TAYGFloatIsUndefined(baseMainSize) &&
            !TAYGFloatIsUndefined(boundMainSize) &&
            baseMainSize != boundMainSize) {
          // By excluding this item's size and flex factor from remaining, this
          // item's min/max constraints should also trigger in the second pass
          // resulting in the item's size calculation being identical in the
          // first and second passes.
          deltaFreeSpace += boundMainSize - childFlexBasis;
          collectedFlexItemsValues.totalFlexGrowFactors -= flexGrowFactor;
        }
      }
    }
  }
  collectedFlexItemsValues.remainingFreeSpace -= deltaFreeSpace;
}

// Do two passes over the flex items to figure out how to distribute the
// remaining space.
//
// The first pass finds the items whose min/max constraints trigger, freezes
// them at those sizes, and excludes those sizes from the remaining space.
//
// The second pass sets the size of each flexible item. It distributes the
// remaining space amongst the items whose min/max constraints didn't trigger in
// the first pass. For the other items, it sets their sizes by forcing their
// min/max constraints to trigger again.
//
// This two pass approach for resolving min/max constraints deviates from the
// spec. The spec
// (https://www.w3.org/TR/CSS-flexbox-1/#resolve-flexible-lengths) describes a
// process that needs to be repeated a variable number of times. The algorithm
// implemented here won't handle all cases but it was simpler to implement and
// it mitigates performance concerns because we know exactly how many passes
// it'll do.
//
// At the end of this function the child nodes would have the proper size
// assigned to them.
//
static void YGResolveFlexibleLength(
    const TAYGNodeRef node,
    TAYGCollectFlexItemsRowValues& collectedFlexItemsValues,
    const TAYGFlexDirection mainAxis,
    const TAYGFlexDirection crossAxis,
    const float mainAxisownerSize,
    const float availableInnerMainDim,
    const float availableInnerCrossDim,
    const float availableInnerWidth,
    const float availableInnerHeight,
    const bool flexBasisOverflows,
    const TAYGMeasureMode measureModeCrossDim,
    const bool performLayout,
    const TAYGConfigRef config,
    LayoutData& layoutMarkerData,
    void* const layoutContext,
    const uint32_t depth,
    const uint32_t generationCount) {
  const float originalFreeSpace = collectedFlexItemsValues.remainingFreeSpace;
  // First pass: detect the flex items whose min/max constraints trigger
  YGDistributeFreeSpaceFirstPass(
      collectedFlexItemsValues,
      mainAxis,
      mainAxisownerSize,
      availableInnerMainDim,
      availableInnerWidth);

  // Second pass: resolve the sizes of the flexible items
  const float distributedFreeSpace = YGDistributeFreeSpaceSecondPass(
      collectedFlexItemsValues,
      node,
      mainAxis,
      crossAxis,
      mainAxisownerSize,
      availableInnerMainDim,
      availableInnerCrossDim,
      availableInnerWidth,
      availableInnerHeight,
      flexBasisOverflows,
      measureModeCrossDim,
      performLayout,
      config,
      layoutMarkerData,
      layoutContext,
      depth,
      generationCount);

  collectedFlexItemsValues.remainingFreeSpace =
      originalFreeSpace - distributedFreeSpace;
}

static void YGJustifyMainAxis(
    const TAYGNodeRef node,
    TAYGCollectFlexItemsRowValues& collectedFlexItemsValues,
    const uint32_t startOfLineIndex,
    const TAYGFlexDirection mainAxis,
    const TAYGFlexDirection crossAxis,
    const TAYGMeasureMode measureModeMainDim,
    const TAYGMeasureMode measureModeCrossDim,
    const float mainAxisownerSize,
    const float ownerWidth,
    const float availableInnerMainDim,
    const float availableInnerCrossDim,
    const float availableInnerWidth,
    const bool performLayout,
    void* const layoutContext) {
  const auto& style = node->getStyle();
  const float leadingPaddingAndBorderMain =
      node->getLeadingPaddingAndBorder(mainAxis, ownerWidth).unwrap();
  const float trailingPaddingAndBorderMain =
      node->getTrailingPaddingAndBorder(mainAxis, ownerWidth).unwrap();
  // If we are using "at most" rules in the main axis, make sure that
  // remainingFreeSpace is 0 when min main dimension is not given
  if (measureModeMainDim == TAYGMeasureModeAtMost &&
      collectedFlexItemsValues.remainingFreeSpace > 0) {
    if (!style.minDimensions()[dim[mainAxis]].isUndefined() &&
        !TAYGResolveValue(style.minDimensions()[dim[mainAxis]], mainAxisownerSize)
             .isUndefined()) {
      // This condition makes sure that if the size of main dimension(after
      // considering child nodes main dim, ta_leading and ta_trailing padding etc)
      // falls below min dimension, then the remainingFreeSpace is reassigned
      // considering the min dimension

      // `minAvailableMainDim` denotes minimum available space in which child
      // can be laid out, it will exclude space consumed by padding and border.
      const float minAvailableMainDim =
          TAYGResolveValue(
              style.minDimensions()[dim[mainAxis]], mainAxisownerSize)
              .unwrap() -
          leadingPaddingAndBorderMain - trailingPaddingAndBorderMain;
      const float occupiedSpaceByChildNodes =
          availableInnerMainDim - collectedFlexItemsValues.remainingFreeSpace;
      collectedFlexItemsValues.remainingFreeSpace =
          TAYGFloatMax(0, minAvailableMainDim - occupiedSpaceByChildNodes);
    } else {
      collectedFlexItemsValues.remainingFreeSpace = 0;
    }
  }

  int numberOfAutoMarginsOnCurrentLine = 0;
  for (uint32_t i = startOfLineIndex;
       i < collectedFlexItemsValues.endOfLineIndex;
       i++) {
    const TAYGNodeRef child = node->getChild(i);
    if (child->getStyle().positionType() != TAYGPositionTypeAbsolute) {
      if (child->marginLeadingValue(mainAxis).unit == TAYGUnitAuto) {
        numberOfAutoMarginsOnCurrentLine++;
      }
      if (child->marginTrailingValue(mainAxis).unit == TAYGUnitAuto) {
        numberOfAutoMarginsOnCurrentLine++;
      }
    }
  }

  // In order to position the elements in the main axis, we have two controls.
  // The space between the beginning and the first element and the space between
  // each two elements.
  float leadingMainDim = 0;
  float betweenMainDim = 0;
  const TAYGJustify justifyContent = node->getStyle().justifyContent();

  if (numberOfAutoMarginsOnCurrentLine == 0) {
    switch (justifyContent) {
      case TAYGJustifyCenter:
        leadingMainDim = collectedFlexItemsValues.remainingFreeSpace / 2;
        break;
      case TAYGJustifyFlexEnd:
        leadingMainDim = collectedFlexItemsValues.remainingFreeSpace;
        break;
      case TAYGJustifySpaceBetween:
        if (collectedFlexItemsValues.itemsOnLine > 1) {
          betweenMainDim =
              TAYGFloatMax(collectedFlexItemsValues.remainingFreeSpace, 0) /
              (collectedFlexItemsValues.itemsOnLine - 1);
        } else {
          betweenMainDim = 0;
        }
        break;
      case TAYGJustifySpaceEvenly:
        // Space is distributed evenly across all elements
        betweenMainDim = collectedFlexItemsValues.remainingFreeSpace /
            (collectedFlexItemsValues.itemsOnLine + 1);
        leadingMainDim = betweenMainDim;
        break;
      case TAYGJustifySpaceAround:
        // Space on the edges is half of the space between elements
        betweenMainDim = collectedFlexItemsValues.remainingFreeSpace /
            collectedFlexItemsValues.itemsOnLine;
        leadingMainDim = betweenMainDim / 2;
        break;
      case TAYGJustifyFlexStart:
        break;
    }
  }

  collectedFlexItemsValues.mainDim =
      leadingPaddingAndBorderMain + leadingMainDim;
  collectedFlexItemsValues.crossDim = 0;

  float maxAscentForCurrentLine = 0;
  float maxDescentForCurrentLine = 0;
  bool isNodeBaselineLayout = YGIsBaselineLayout(node);
  for (uint32_t i = startOfLineIndex;
       i < collectedFlexItemsValues.endOfLineIndex;
       i++) {
    const TAYGNodeRef child = node->getChild(i);
    const TATAYGStyle& childStyle = child->getStyle();
    const TAYGLayout childLayout = child->getLayout();
    if (childStyle.display() == TAYGDisplayNone) {
      continue;
    }
    if (childStyle.positionType() == TAYGPositionTypeAbsolute &&
        child->isLeadingPositionDefined(mainAxis)) {
      if (performLayout) {
        // In case the child is position absolute and has left/top being
        // defined, we override the position to whatever the user said (and
        // margin/border).
        child->setLayoutPosition(
            child->getLeadingPosition(mainAxis, availableInnerMainDim)
                    .unwrap() +
                node->getLeadingBorder(mainAxis) +
                child->getLeadingMargin(mainAxis, availableInnerWidth).unwrap(),
            pos[mainAxis]);
      }
    } else {
      // Now that we placed the element, we need to update the variables.
      // We need to do that only for relative elements. Absolute elements do not
      // take part in that phase.
      if (childStyle.positionType() != TAYGPositionTypeAbsolute) {
        if (child->marginLeadingValue(mainAxis).unit == TAYGUnitAuto) {
          collectedFlexItemsValues.mainDim +=
              collectedFlexItemsValues.remainingFreeSpace /
              numberOfAutoMarginsOnCurrentLine;
        }

        if (performLayout) {
          child->setLayoutPosition(
              childLayout.position[pos[mainAxis]] +
                  collectedFlexItemsValues.mainDim,
              pos[mainAxis]);
        }

        if (child->marginTrailingValue(mainAxis).unit == TAYGUnitAuto) {
          collectedFlexItemsValues.mainDim +=
              collectedFlexItemsValues.remainingFreeSpace /
              numberOfAutoMarginsOnCurrentLine;
        }
        bool canSkipFlex =
            !performLayout && measureModeCrossDim == TAYGMeasureModeExactly;
        if (canSkipFlex) {
          // If we skipped the flex step, then we can't rely on the measuredDims
          // because they weren't computed. This means we can't call
          // YGNodeDimWithMargin.
          collectedFlexItemsValues.mainDim += betweenMainDim +
              child->getMarginForAxis(mainAxis, availableInnerWidth).unwrap() +
              childLayout.computedFlexBasis.unwrap();
          collectedFlexItemsValues.crossDim = availableInnerCrossDim;
        } else {
          // The main dimension is the sum of all the elements dimension plus
          // the spacing.
          collectedFlexItemsValues.mainDim += betweenMainDim +
              YGNodeDimWithMargin(child, mainAxis, availableInnerWidth);

          if (isNodeBaselineLayout) {
            // If the child is baseline aligned then the cross dimension is
            // calculated by adding maxAscent and maxDescent from the baseline.
            const float ascent = YGBaseline(child, layoutContext) +
                child
                    ->getLeadingMargin(
                        TAYGFlexDirectionColumn, availableInnerWidth)
                    .unwrap();
            const float descent =
                child->getLayout().measuredDimensions[TAYGDimensionHeight] +
                child
                    ->getMarginForAxis(
                        TAYGFlexDirectionColumn, availableInnerWidth)
                    .unwrap() -
                ascent;

            maxAscentForCurrentLine =
                TAYGFloatMax(maxAscentForCurrentLine, ascent);
            maxDescentForCurrentLine =
                TAYGFloatMax(maxDescentForCurrentLine, descent);
          } else {
            // The cross dimension is the max of the elements dimension since
            // there can only be one element in that cross dimension in the case
            // when the items are not baseline aligned
            collectedFlexItemsValues.crossDim = TAYGFloatMax(
                collectedFlexItemsValues.crossDim,
                YGNodeDimWithMargin(child, crossAxis, availableInnerWidth));
          }
        }
      } else if (performLayout) {
        child->setLayoutPosition(
            childLayout.position[pos[mainAxis]] +
                node->getLeadingBorder(mainAxis) + leadingMainDim,
            pos[mainAxis]);
      }
    }
  }
  collectedFlexItemsValues.mainDim += trailingPaddingAndBorderMain;

  if (isNodeBaselineLayout) {
    collectedFlexItemsValues.crossDim =
        maxAscentForCurrentLine + maxDescentForCurrentLine;
  }
}

//
// This is the main routine that implements a subset of the flexbox layout
// algorithm described in the W3C CSS documentation:
// https://www.w3.org/TR/CSS3-flexbox/.
//
// Limitations of this algorithm, compared to the full standard:
//  * Display property is always assumed to be 'flex' except for Text nodes,
//    which are assumed to be 'inline-flex'.
//  * The 'zIndex' property (or any form of z ordering) is not supported. Nodes
//    are stacked in document order.
//  * The 'order' property is not supported. The order of flex items is always
//    defined by document order.
//  * The 'visibility' property is always assumed to be 'visible'. TAValues of
//    'collapse' and 'hidden' are not supported.
//  * There is no support for forced breaks.
//  * It does not support vertical inline directions (top-to-bottom or
//    bottom-to-top text).
//
// Deviations from standard:
//  * Section 4.5 of the spec indicates that all flex items have a default
//    minimum main size. For text blocks, for example, this is the width of the
//    widest word. Calculating the minimum width is expensive, so we forego it
//    and assume a default minimum main size of 0.
//  * Min/Max sizes in the main axis are not honored when resolving flexible
//    lengths.
//  * The spec indicates that the default value for 'flexDirection' is 'row',
//    but the algorithm below assumes a default of 'column'.
//
// Input parameters:
//    - node: current node to be sized and layed out
//    - availableWidth & availableHeight: available size to be used for sizing
//      the node or TAYGUndefined if the size is not available; interpretation
//      depends on layout flags
//    - ownerDirection: the inline (text) direction within the owner
//      (left-to-right or right-to-left)
//    - widthMeasureMode: indicates the sizing rules for the width (see below
//      for explanation)
//    - heightMeasureMode: indicates the sizing rules for the height (see below
//      for explanation)
//    - performLayout: specifies whether the caller is interested in just the
//      dimensions of the node or it requires the entire node and its subtree to
//      be layed out (with final positions)
//
// Details:
//    This routine is called recursively to lay out subtrees of flexbox
//    elements. It uses the information in node.style, which is treated as a
//    read-only input. It is responsible for setting the layout.direction and
//    layout.measuredDimensions fields for the input node as well as the
//    layout.position and layout.lineIndex fields for its child nodes. The
//    layout.measuredDimensions field includes any border or padding for the
//    node but does not include margins.
//
//    The spec describes four different layout modes: "fill available", "max
//    content", "min content", and "fit content". Of these, we don't use "min
//    content" because we don't support default minimum main sizes (see above
//    for details). Each of our measure modes maps to a layout mode from the
//    spec (https://www.w3.org/TR/CSS3-sizing/#terms):
//      - TAYGMeasureModeUndefined: max content
//      - TAYGMeasureModeExactly: fill available
//      - TAYGMeasureModeAtMost: fit content
//
//    When calling YGNodelayoutImpl and YGLayoutNodeInternal, if the caller
//    passes an available size of undefined then it must also pass a measure
//    mode of TAYGMeasureModeUndefined in that dimension.
//
static void YGNodelayoutImpl(
    const TAYGNodeRef node,
    const float availableWidth,
    const float availableHeight,
    const TAYGDirection ownerDirection,
    const TAYGMeasureMode widthMeasureMode,
    const TAYGMeasureMode heightMeasureMode,
    const float ownerWidth,
    const float ownerHeight,
    const bool performLayout,
    const TAYGConfigRef config,
    LayoutData& layoutMarkerData,
    void* const layoutContext,
    const uint32_t depth,
    const uint32_t generationCount,
    const LayoutPassReason reason) {
  TAYGAssertWithNode(
      node,
      TAYGFloatIsUndefined(availableWidth)
          ? widthMeasureMode == TAYGMeasureModeUndefined
          : true,
      "availableWidth is indefinite so widthMeasureMode must be "
      "TAYGMeasureModeUndefined");
  TAYGAssertWithNode(
      node,
      TAYGFloatIsUndefined(availableHeight)
          ? heightMeasureMode == TAYGMeasureModeUndefined
          : true,
      "availableHeight is indefinite so heightMeasureMode must be "
      "TAYGMeasureModeUndefined");

  (performLayout ? layoutMarkerData.layouts : layoutMarkerData.measures) += 1;

  // Set the resolved resolution in the node's layout.
  const TAYGDirection direction = node->resolveDirection(ownerDirection);
  node->setLayoutDirection(direction);

  const TAYGFlexDirection flexRowDirection =
      TAYGResolveFlexDirection(TAYGFlexDirectionRow, direction);
  const TAYGFlexDirection flexColumnDirection =
      TAYGResolveFlexDirection(TAYGFlexDirectionColumn, direction);

  const TAYGEdge startEdge =
      direction == TAYGDirectionLTR ? TAYGEdgeLeft : TAYGEdgeRight;
  const TAYGEdge endEdge = direction == TAYGDirectionLTR ? TAYGEdgeRight : TAYGEdgeLeft;

  const float marginRowLeading =
      node->getLeadingMargin(flexRowDirection, ownerWidth).unwrap();
  node->setLayoutMargin(marginRowLeading, startEdge);
  const float marginRowTrailing =
      node->getTrailingMargin(flexRowDirection, ownerWidth).unwrap();
  node->setLayoutMargin(marginRowTrailing, endEdge);
  const float marginColumnLeading =
      node->getLeadingMargin(flexColumnDirection, ownerWidth).unwrap();
  node->setLayoutMargin(marginColumnLeading, TAYGEdgeTop);
  const float marginColumnTrailing =
      node->getTrailingMargin(flexColumnDirection, ownerWidth).unwrap();
  node->setLayoutMargin(marginColumnTrailing, TAYGEdgeBottom);

  const float marginAxisRow = marginRowLeading + marginRowTrailing;
  const float marginAxisColumn = marginColumnLeading + marginColumnTrailing;

  node->setLayoutBorder(node->getLeadingBorder(flexRowDirection), startEdge);
  node->setLayoutBorder(node->getTrailingBorder(flexRowDirection), endEdge);
  node->setLayoutBorder(node->getLeadingBorder(flexColumnDirection), TAYGEdgeTop);
  node->setLayoutBorder(
      node->getTrailingBorder(flexColumnDirection), TAYGEdgeBottom);

  node->setLayoutPadding(
      node->getLeadingPadding(flexRowDirection, ownerWidth).unwrap(),
      startEdge);
  node->setLayoutPadding(
      node->getTrailingPadding(flexRowDirection, ownerWidth).unwrap(), endEdge);
  node->setLayoutPadding(
      node->getLeadingPadding(flexColumnDirection, ownerWidth).unwrap(),
      TAYGEdgeTop);
  node->setLayoutPadding(
      node->getTrailingPadding(flexColumnDirection, ownerWidth).unwrap(),
      TAYGEdgeBottom);

  if (node->hasMeasureFunc()) {
    YGNodeWithMeasureFuncSetMeasuredDimensions(
        node,
        availableWidth - marginAxisRow,
        availableHeight - marginAxisColumn,
        widthMeasureMode,
        heightMeasureMode,
        ownerWidth,
        ownerHeight,
        layoutMarkerData,
        layoutContext,
        reason);
    return;
  }

  const uint32_t childCount = TAYGNodeGetChildCount(node);
  if (childCount == 0) {
    YGNodeEmptyContainerSetMeasuredDimensions(
        node,
        availableWidth - marginAxisRow,
        availableHeight - marginAxisColumn,
        widthMeasureMode,
        heightMeasureMode,
        ownerWidth,
        ownerHeight);
    return;
  }

  // If we're not being asked to perform a full layout we can skip the algorithm
  // if we already know the size
  if (!performLayout &&
      YGNodeFixedSizeSetMeasuredDimensions(
          node,
          availableWidth - marginAxisRow,
          availableHeight - marginAxisColumn,
          widthMeasureMode,
          heightMeasureMode,
          ownerWidth,
          ownerHeight)) {
    return;
  }

  // At this point we know we're going to perform work. Ensure that each child
  // has a mutable copy.
  node->cloneChildrenIfNeeded(layoutContext);
  // Reset layout flags, as they could have changed.
  node->setLayoutHadOverflow(false);

  // STEP 1: CALCULATE VALUES FOR REMAINDER OF ALGORITHM
  const TAYGFlexDirection mainAxis =
      TAYGResolveFlexDirection(node->getStyle().flexDirection(), direction);
  const TAYGFlexDirection crossAxis = TAYGFlexDirectionCross(mainAxis, direction);
  const bool isMainAxisRow = TAYGFlexDirectionIsRow(mainAxis);
  const bool isNodeFlexWrap = node->getStyle().flexWrap() != TAYGWrapNoWrap;

  const float mainAxisownerSize = isMainAxisRow ? ownerWidth : ownerHeight;
  const float crossAxisownerSize = isMainAxisRow ? ownerHeight : ownerWidth;

  const float paddingAndBorderAxisMain =
      YGNodePaddingAndBorderForAxis(node, mainAxis, ownerWidth);
  const float leadingPaddingAndBorderCross =
      node->getLeadingPaddingAndBorder(crossAxis, ownerWidth).unwrap();
  const float trailingPaddingAndBorderCross =
      node->getTrailingPaddingAndBorder(crossAxis, ownerWidth).unwrap();
  const float paddingAndBorderAxisCross =
      leadingPaddingAndBorderCross + trailingPaddingAndBorderCross;

  TAYGMeasureMode measureModeMainDim =
      isMainAxisRow ? widthMeasureMode : heightMeasureMode;
  TAYGMeasureMode measureModeCrossDim =
      isMainAxisRow ? heightMeasureMode : widthMeasureMode;

  const float paddingAndBorderAxisRow =
      isMainAxisRow ? paddingAndBorderAxisMain : paddingAndBorderAxisCross;
  const float paddingAndBorderAxisColumn =
      isMainAxisRow ? paddingAndBorderAxisCross : paddingAndBorderAxisMain;

  // STEP 2: DETERMINE AVAILABLE SIZE IN MAIN AND CROSS DIRECTIONS

  float availableInnerWidth = YGNodeCalculateAvailableInnerDim(
      node,
      TAYGDimensionWidth,
      availableWidth - marginAxisRow,
      paddingAndBorderAxisRow,
      ownerWidth);
  float availableInnerHeight = YGNodeCalculateAvailableInnerDim(
      node,
      TAYGDimensionHeight,
      availableHeight - marginAxisColumn,
      paddingAndBorderAxisColumn,
      ownerHeight);

  float availableInnerMainDim =
      isMainAxisRow ? availableInnerWidth : availableInnerHeight;
  const float availableInnerCrossDim =
      isMainAxisRow ? availableInnerHeight : availableInnerWidth;

  // STEP 3: DETERMINE FLEX BASIS FOR EACH ITEM

  float totalOuterFlexBasis = YGNodeComputeFlexBasisForChildren(
      node,
      availableInnerWidth,
      availableInnerHeight,
      widthMeasureMode,
      heightMeasureMode,
      direction,
      mainAxis,
      config,
      performLayout,
      layoutMarkerData,
      layoutContext,
      depth,
      generationCount);

  const bool flexBasisOverflows = measureModeMainDim == TAYGMeasureModeUndefined
      ? false
      : totalOuterFlexBasis > availableInnerMainDim;
  if (isNodeFlexWrap && flexBasisOverflows &&
      measureModeMainDim == TAYGMeasureModeAtMost) {
    measureModeMainDim = TAYGMeasureModeExactly;
  }
  // STEP 4: COLLECT FLEX ITEMS INTO FLEX LINES

  // Indexes of children that represent the first and last items in the line.
  uint32_t startOfLineIndex = 0;
  uint32_t endOfLineIndex = 0;

  // Number of lines.
  uint32_t lineCount = 0;

  // Accumulated cross dimensions of all lines so far.
  float totalLineCrossDim = 0;

  // Max main dimension of all the lines.
  float maxLineMainDim = 0;
  TAYGCollectFlexItemsRowValues collectedFlexItemsValues;
  for (; endOfLineIndex < childCount;
       lineCount++, startOfLineIndex = endOfLineIndex) {
    collectedFlexItemsValues = YGCalculateCollectFlexItemsRowValues(
        node,
        ownerDirection,
        mainAxisownerSize,
        availableInnerWidth,
        availableInnerMainDim,
        startOfLineIndex,
        lineCount);
    endOfLineIndex = collectedFlexItemsValues.endOfLineIndex;

    // If we don't need to measure the cross axis, we can skip the entire flex
    // step.
    const bool canSkipFlex =
        !performLayout && measureModeCrossDim == TAYGMeasureModeExactly;

    // STEP 5: RESOLVING FLEXIBLE LENGTHS ON MAIN AXIS
    // Calculate the remaining available space that needs to be allocated. If
    // the main dimension size isn't known, it is computed based on the line
    // length, so there's no more space left to distribute.

    bool sizeBasedOnContent = false;
    // If we don't measure with exact main dimension we want to ensure we don't
    // violate min and max
    if (measureModeMainDim != TAYGMeasureModeExactly) {
      const auto& minDimensions = node->getStyle().minDimensions();
      const auto& maxDimensions = node->getStyle().maxDimensions();
      const float minInnerWidth =
          TAYGResolveValue(minDimensions[TAYGDimensionWidth], ownerWidth).unwrap() -
          paddingAndBorderAxisRow;
      const float maxInnerWidth =
          TAYGResolveValue(maxDimensions[TAYGDimensionWidth], ownerWidth).unwrap() -
          paddingAndBorderAxisRow;
      const float minInnerHeight =
          TAYGResolveValue(minDimensions[TAYGDimensionHeight], ownerHeight)
              .unwrap() -
          paddingAndBorderAxisColumn;
      const float maxInnerHeight =
          TAYGResolveValue(maxDimensions[TAYGDimensionHeight], ownerHeight)
              .unwrap() -
          paddingAndBorderAxisColumn;

      const float minInnerMainDim =
          isMainAxisRow ? minInnerWidth : minInnerHeight;
      const float maxInnerMainDim =
          isMainAxisRow ? maxInnerWidth : maxInnerHeight;

      if (!TAYGFloatIsUndefined(minInnerMainDim) &&
          collectedFlexItemsValues.sizeConsumedOnCurrentLine <
              minInnerMainDim) {
        availableInnerMainDim = minInnerMainDim;
      } else if (
          !TAYGFloatIsUndefined(maxInnerMainDim) &&
          collectedFlexItemsValues.sizeConsumedOnCurrentLine >
              maxInnerMainDim) {
        availableInnerMainDim = maxInnerMainDim;
      } else {
        if (!node->getConfig()->useLegacyStretchBehaviour &&
            ((TAYGFloatIsUndefined(
                  collectedFlexItemsValues.totalFlexGrowFactors) &&
              collectedFlexItemsValues.totalFlexGrowFactors == 0) ||
             (TAYGFloatIsUndefined(node->resolveFlexGrow()) &&
              node->resolveFlexGrow() == 0))) {
          // If we don't have any children to flex or we can't flex the node
          // itself, space we've used is all space we need. Root node also
          // should be shrunk to minimum
          availableInnerMainDim =
              collectedFlexItemsValues.sizeConsumedOnCurrentLine;
        }

        if (node->getConfig()->useLegacyStretchBehaviour) {
          node->setLayoutDidUseLegacyFlag(true);
        }
        sizeBasedOnContent = !node->getConfig()->useLegacyStretchBehaviour;
      }
    }

    if (!sizeBasedOnContent && !TAYGFloatIsUndefined(availableInnerMainDim)) {
      collectedFlexItemsValues.remainingFreeSpace = availableInnerMainDim -
          collectedFlexItemsValues.sizeConsumedOnCurrentLine;
    } else if (collectedFlexItemsValues.sizeConsumedOnCurrentLine < 0) {
      // availableInnerMainDim is indefinite which means the node is being sized
      // based on its content. sizeConsumedOnCurrentLine is negative which means
      // the node will allocate 0 points for its content. Consequently,
      // remainingFreeSpace is 0 - sizeConsumedOnCurrentLine.
      collectedFlexItemsValues.remainingFreeSpace =
          -collectedFlexItemsValues.sizeConsumedOnCurrentLine;
    }

    if (!canSkipFlex) {
      YGResolveFlexibleLength(
          node,
          collectedFlexItemsValues,
          mainAxis,
          crossAxis,
          mainAxisownerSize,
          availableInnerMainDim,
          availableInnerCrossDim,
          availableInnerWidth,
          availableInnerHeight,
          flexBasisOverflows,
          measureModeCrossDim,
          performLayout,
          config,
          layoutMarkerData,
          layoutContext,
          depth,
          generationCount);
    }

    node->setLayoutHadOverflow(
        node->getLayout().hadOverflow() |
        (collectedFlexItemsValues.remainingFreeSpace < 0));

    // STEP 6: MAIN-AXIS JUSTIFICATION & CROSS-AXIS SIZE DETERMINATION

    // At this point, all the children have their dimensions set in the main
    // axis. Their dimensions are also set in the cross axis with the exception
    // of items that are aligned "stretch". We need to compute these stretch
    // values and set the final positions.

    YGJustifyMainAxis(
        node,
        collectedFlexItemsValues,
        startOfLineIndex,
        mainAxis,
        crossAxis,
        measureModeMainDim,
        measureModeCrossDim,
        mainAxisownerSize,
        ownerWidth,
        availableInnerMainDim,
        availableInnerCrossDim,
        availableInnerWidth,
        performLayout,
        layoutContext);

    float containerCrossAxis = availableInnerCrossDim;
    if (measureModeCrossDim == TAYGMeasureModeUndefined ||
        measureModeCrossDim == TAYGMeasureModeAtMost) {
      // Compute the cross axis from the max cross dimension of the children.
      containerCrossAxis =
          YGNodeBoundAxis(
              node,
              crossAxis,
              collectedFlexItemsValues.crossDim + paddingAndBorderAxisCross,
              crossAxisownerSize,
              ownerWidth) -
          paddingAndBorderAxisCross;
    }

    // If there's no flex wrap, the cross dimension is defined by the container.
    if (!isNodeFlexWrap && measureModeCrossDim == TAYGMeasureModeExactly) {
      collectedFlexItemsValues.crossDim = availableInnerCrossDim;
    }

    // Clamp to the min/max size specified on the container.
    collectedFlexItemsValues.crossDim =
        YGNodeBoundAxis(
            node,
            crossAxis,
            collectedFlexItemsValues.crossDim + paddingAndBorderAxisCross,
            crossAxisownerSize,
            ownerWidth) -
        paddingAndBorderAxisCross;

    // STEP 7: CROSS-AXIS ALIGNMENT
    // We can skip child alignment if we're just measuring the container.
    if (performLayout) {
      for (uint32_t i = startOfLineIndex; i < endOfLineIndex; i++) {
        const TAYGNodeRef child = node->getChild(i);
        if (child->getStyle().display() == TAYGDisplayNone) {
          continue;
        }
        if (child->getStyle().positionType() == TAYGPositionTypeAbsolute) {
          // If the child is absolutely positioned and has a
          // top/left/bottom/right set, override all the previously computed
          // positions to set it correctly.
          const bool isChildLeadingPosDefined =
              child->isLeadingPositionDefined(crossAxis);
          if (isChildLeadingPosDefined) {
            child->setLayoutPosition(
                child->getLeadingPosition(crossAxis, availableInnerCrossDim)
                        .unwrap() +
                    node->getLeadingBorder(crossAxis) +
                    child->getLeadingMargin(crossAxis, availableInnerWidth)
                        .unwrap(),
                pos[crossAxis]);
          }
          // If ta_leading position is not defined or calculations result in Nan,
          // default to border + margin
          if (!isChildLeadingPosDefined ||
              TAYGFloatIsUndefined(child->getLayout().position[pos[crossAxis]])) {
            child->setLayoutPosition(
                node->getLeadingBorder(crossAxis) +
                    child->getLeadingMargin(crossAxis, availableInnerWidth)
                        .unwrap(),
                pos[crossAxis]);
          }
        } else {
          float leadingCrossDim = leadingPaddingAndBorderCross;

          // For a relative children, we're either using alignItems (owner) or
          // alignSelf (child) in order to determine the position in the cross
          // axis
          const TAYGAlign alignItem = YGNodeAlignItem(node, child);

          // If the child uses align stretch, we need to lay it out one more
          // time, this time forcing the cross-axis size to be the computed
          // cross size for the current line.
          if (alignItem == TAYGAlignStretch &&
              child->marginLeadingValue(crossAxis).unit != TAYGUnitAuto &&
              child->marginTrailingValue(crossAxis).unit != TAYGUnitAuto) {
            // If the child defines a definite size for its cross axis, there's
            // no need to stretch.
            if (!YGNodeIsStyleDimDefined(
                    child, crossAxis, availableInnerCrossDim)) {
              float childMainSize =
                  child->getLayout().measuredDimensions[dim[mainAxis]];
              const auto& childStyle = child->getStyle();
              float childCrossSize = !childStyle.aspectRatio().isUndefined()
                  ? child->getMarginForAxis(crossAxis, availableInnerWidth)
                          .unwrap() +
                      (isMainAxisRow
                           ? childMainSize / childStyle.aspectRatio().unwrap()
                           : childMainSize * childStyle.aspectRatio().unwrap())
                  : collectedFlexItemsValues.crossDim;

              childMainSize +=
                  child->getMarginForAxis(mainAxis, availableInnerWidth)
                      .unwrap();

              TAYGMeasureMode childMainMeasureMode = TAYGMeasureModeExactly;
              TAYGMeasureMode childCrossMeasureMode = TAYGMeasureModeExactly;
              YGConstrainMaxSizeForMode(
                  child,
                  mainAxis,
                  availableInnerMainDim,
                  availableInnerWidth,
                  &childMainMeasureMode,
                  &childMainSize);
              YGConstrainMaxSizeForMode(
                  child,
                  crossAxis,
                  availableInnerCrossDim,
                  availableInnerWidth,
                  &childCrossMeasureMode,
                  &childCrossSize);

              const float childWidth =
                  isMainAxisRow ? childMainSize : childCrossSize;
              const float childHeight =
                  !isMainAxisRow ? childMainSize : childCrossSize;

              auto alignContent = node->getStyle().alignContent();
              auto crossAxisDoesNotGrow =
                  alignContent != TAYGAlignStretch && isNodeFlexWrap;
              const TAYGMeasureMode childWidthMeasureMode =
                  TAYGFloatIsUndefined(childWidth) ||
                      (!isMainAxisRow && crossAxisDoesNotGrow)
                  ? TAYGMeasureModeUndefined
                  : TAYGMeasureModeExactly;
              const TAYGMeasureMode childHeightMeasureMode =
                  TAYGFloatIsUndefined(childHeight) ||
                      (isMainAxisRow && crossAxisDoesNotGrow)
                  ? TAYGMeasureModeUndefined
                  : TAYGMeasureModeExactly;

              YGLayoutNodeInternal(
                  child,
                  childWidth,
                  childHeight,
                  direction,
                  childWidthMeasureMode,
                  childHeightMeasureMode,
                  availableInnerWidth,
                  availableInnerHeight,
                  true,
                  LayoutPassReason::kStretch,
                  config,
                  layoutMarkerData,
                  layoutContext,
                  depth,
                  generationCount);
            }
          } else {
            const float remainingCrossDim = containerCrossAxis -
                YGNodeDimWithMargin(child, crossAxis, availableInnerWidth);

            if (child->marginLeadingValue(crossAxis).unit == TAYGUnitAuto &&
                child->marginTrailingValue(crossAxis).unit == TAYGUnitAuto) {
              leadingCrossDim += TAYGFloatMax(0.0f, remainingCrossDim / 2);
            } else if (
                child->marginTrailingValue(crossAxis).unit == TAYGUnitAuto) {
              // No-Op
            } else if (
                child->marginLeadingValue(crossAxis).unit == TAYGUnitAuto) {
              leadingCrossDim += TAYGFloatMax(0.0f, remainingCrossDim);
            } else if (alignItem == TAYGAlignFlexStart) {
              // No-Op
            } else if (alignItem == TAYGAlignCenter) {
              leadingCrossDim += remainingCrossDim / 2;
            } else {
              leadingCrossDim += remainingCrossDim;
            }
          }
          // And we apply the position
          child->setLayoutPosition(
              child->getLayout().position[pos[crossAxis]] + totalLineCrossDim +
                  leadingCrossDim,
              pos[crossAxis]);
        }
      }
    }

    totalLineCrossDim += collectedFlexItemsValues.crossDim;
    maxLineMainDim =
        TAYGFloatMax(maxLineMainDim, collectedFlexItemsValues.mainDim);
  }

  // STEP 8: MULTI-LINE CONTENT ALIGNMENT
  // currentLead stores the size of the cross dim
  if (performLayout && (isNodeFlexWrap || YGIsBaselineLayout(node))) {
    float crossDimLead = 0;
    float currentLead = leadingPaddingAndBorderCross;
    if (!TAYGFloatIsUndefined(availableInnerCrossDim)) {
      const float remainingAlignContentDim =
          availableInnerCrossDim - totalLineCrossDim;
      switch (node->getStyle().alignContent()) {
        case TAYGAlignFlexEnd:
          currentLead += remainingAlignContentDim;
          break;
        case TAYGAlignCenter:
          currentLead += remainingAlignContentDim / 2;
          break;
        case TAYGAlignStretch:
          if (availableInnerCrossDim > totalLineCrossDim) {
            crossDimLead = remainingAlignContentDim / lineCount;
          }
          break;
        case TAYGAlignSpaceAround:
          if (availableInnerCrossDim > totalLineCrossDim) {
            currentLead += remainingAlignContentDim / (2 * lineCount);
            if (lineCount > 1) {
              crossDimLead = remainingAlignContentDim / lineCount;
            }
          } else {
            currentLead += remainingAlignContentDim / 2;
          }
          break;
        case TAYGAlignSpaceBetween:
          if (availableInnerCrossDim > totalLineCrossDim && lineCount > 1) {
            crossDimLead = remainingAlignContentDim / (lineCount - 1);
          }
          break;
        case TAYGAlignAuto:
        case TAYGAlignFlexStart:
        case TAYGAlignBaseline:
          break;
      }
    }
    uint32_t endIndex = 0;
    for (uint32_t i = 0; i < lineCount; i++) {
      const uint32_t startIndex = endIndex;
      uint32_t ii;

      // compute the line's height and find the endIndex
      float lineHeight = 0;
      float maxAscentForCurrentLine = 0;
      float maxDescentForCurrentLine = 0;
      for (ii = startIndex; ii < childCount; ii++) {
        const TAYGNodeRef child = node->getChild(ii);
        if (child->getStyle().display() == TAYGDisplayNone) {
          continue;
        }
        if (child->getStyle().positionType() != TAYGPositionTypeAbsolute) {
          if (child->getLineIndex() != i) {
            break;
          }
          if (YGNodeIsLayoutDimDefined(child, crossAxis)) {
            lineHeight = TAYGFloatMax(
                lineHeight,
                child->getLayout().measuredDimensions[dim[crossAxis]] +
                    child->getMarginForAxis(crossAxis, availableInnerWidth)
                        .unwrap());
          }
          if (YGNodeAlignItem(node, child) == TAYGAlignBaseline) {
            const float ascent = YGBaseline(child, layoutContext) +
                child
                    ->getLeadingMargin(
                        TAYGFlexDirectionColumn, availableInnerWidth)
                    .unwrap();
            const float descent =
                child->getLayout().measuredDimensions[TAYGDimensionHeight] +
                child
                    ->getMarginForAxis(
                        TAYGFlexDirectionColumn, availableInnerWidth)
                    .unwrap() -
                ascent;
            maxAscentForCurrentLine =
                TAYGFloatMax(maxAscentForCurrentLine, ascent);
            maxDescentForCurrentLine =
                TAYGFloatMax(maxDescentForCurrentLine, descent);
            lineHeight = TAYGFloatMax(
                lineHeight, maxAscentForCurrentLine + maxDescentForCurrentLine);
          }
        }
      }
      endIndex = ii;
      lineHeight += crossDimLead;

      if (performLayout) {
        for (ii = startIndex; ii < endIndex; ii++) {
          const TAYGNodeRef child = node->getChild(ii);
          if (child->getStyle().display() == TAYGDisplayNone) {
            continue;
          }
          if (child->getStyle().positionType() != TAYGPositionTypeAbsolute) {
            switch (YGNodeAlignItem(node, child)) {
              case TAYGAlignFlexStart: {
                child->setLayoutPosition(
                    currentLead +
                        child->getLeadingMargin(crossAxis, availableInnerWidth)
                            .unwrap(),
                    pos[crossAxis]);
                break;
              }
              case TAYGAlignFlexEnd: {
                child->setLayoutPosition(
                    currentLead + lineHeight -
                        child->getTrailingMargin(crossAxis, availableInnerWidth)
                            .unwrap() -
                        child->getLayout().measuredDimensions[dim[crossAxis]],
                    pos[crossAxis]);
                break;
              }
              case TAYGAlignCenter: {
                float childHeight =
                    child->getLayout().measuredDimensions[dim[crossAxis]];

                child->setLayoutPosition(
                    currentLead + (lineHeight - childHeight) / 2,
                    pos[crossAxis]);
                break;
              }
              case TAYGAlignStretch: {
                child->setLayoutPosition(
                    currentLead +
                        child->getLeadingMargin(crossAxis, availableInnerWidth)
                            .unwrap(),
                    pos[crossAxis]);

                // Remeasure child with the line height as it as been only
                // measured with the owners height yet.
                if (!YGNodeIsStyleDimDefined(
                        child, crossAxis, availableInnerCrossDim)) {
                  const float childWidth = isMainAxisRow
                      ? (child->getLayout()
                             .measuredDimensions[TAYGDimensionWidth] +
                         child->getMarginForAxis(mainAxis, availableInnerWidth)
                             .unwrap())
                      : lineHeight;

                  const float childHeight = !isMainAxisRow
                      ? (child->getLayout()
                             .measuredDimensions[TAYGDimensionHeight] +
                         child->getMarginForAxis(crossAxis, availableInnerWidth)
                             .unwrap())
                      : lineHeight;

                  if (!(TAYGFloatsEqual(
                            childWidth,
                            child->getLayout()
                                .measuredDimensions[TAYGDimensionWidth]) &&
                        TAYGFloatsEqual(
                            childHeight,
                            child->getLayout()
                                .measuredDimensions[TAYGDimensionHeight]))) {
                    YGLayoutNodeInternal(
                        child,
                        childWidth,
                        childHeight,
                        direction,
                        TAYGMeasureModeExactly,
                        TAYGMeasureModeExactly,
                        availableInnerWidth,
                        availableInnerHeight,
                        true,
                        LayoutPassReason::kMultilineStretch,
                        config,
                        layoutMarkerData,
                        layoutContext,
                        depth,
                        generationCount);
                  }
                }
                break;
              }
              case TAYGAlignBaseline: {
                child->setLayoutPosition(
                    currentLead + maxAscentForCurrentLine -
                        YGBaseline(child, layoutContext) +
                        child
                            ->getLeadingPosition(
                                TAYGFlexDirectionColumn, availableInnerCrossDim)
                            .unwrap(),
                    TAYGEdgeTop);

                break;
              }
              case TAYGAlignAuto:
              case TAYGAlignSpaceBetween:
              case TAYGAlignSpaceAround:
                break;
            }
          }
        }
      }
      currentLead += lineHeight;
    }
  }

  // STEP 9: COMPUTING FINAL DIMENSIONS

  node->setLayoutMeasuredDimension(
      YGNodeBoundAxis(
          node,
          TAYGFlexDirectionRow,
          availableWidth - marginAxisRow,
          ownerWidth,
          ownerWidth),
      TAYGDimensionWidth);

  node->setLayoutMeasuredDimension(
      YGNodeBoundAxis(
          node,
          TAYGFlexDirectionColumn,
          availableHeight - marginAxisColumn,
          ownerHeight,
          ownerWidth),
      TAYGDimensionHeight);

  // If the user didn't specify a width or height for the node, set the
  // dimensions based on the children.
  if (measureModeMainDim == TAYGMeasureModeUndefined ||
      (node->getStyle().overflow() != TAYGOverflowScroll &&
       measureModeMainDim == TAYGMeasureModeAtMost)) {
    // Clamp the size to the min/max size, if specified, and make sure it
    // doesn't go below the padding and border amount.
    node->setLayoutMeasuredDimension(
        YGNodeBoundAxis(
            node, mainAxis, maxLineMainDim, mainAxisownerSize, ownerWidth),
        dim[mainAxis]);

  } else if (
      measureModeMainDim == TAYGMeasureModeAtMost &&
      node->getStyle().overflow() == TAYGOverflowScroll) {
    node->setLayoutMeasuredDimension(
        TAYGFloatMax(
            TAYGFloatMin(
                availableInnerMainDim + paddingAndBorderAxisMain,
                YGNodeBoundAxisWithinMinAndMax(
                    node,
                    mainAxis,
                    TAYGFloatOptional{maxLineMainDim},
                    mainAxisownerSize)
                    .unwrap()),
            paddingAndBorderAxisMain),
        dim[mainAxis]);
  }

  if (measureModeCrossDim == TAYGMeasureModeUndefined ||
      (node->getStyle().overflow() != TAYGOverflowScroll &&
       measureModeCrossDim == TAYGMeasureModeAtMost)) {
    // Clamp the size to the min/max size, if specified, and make sure it
    // doesn't go below the padding and border amount.
    node->setLayoutMeasuredDimension(
        YGNodeBoundAxis(
            node,
            crossAxis,
            totalLineCrossDim + paddingAndBorderAxisCross,
            crossAxisownerSize,
            ownerWidth),
        dim[crossAxis]);

  } else if (
      measureModeCrossDim == TAYGMeasureModeAtMost &&
      node->getStyle().overflow() == TAYGOverflowScroll) {
    node->setLayoutMeasuredDimension(
        TAYGFloatMax(
            TAYGFloatMin(
                availableInnerCrossDim + paddingAndBorderAxisCross,
                YGNodeBoundAxisWithinMinAndMax(
                    node,
                    crossAxis,
                    TAYGFloatOptional{
                        totalLineCrossDim + paddingAndBorderAxisCross},
                    crossAxisownerSize)
                    .unwrap()),
            paddingAndBorderAxisCross),
        dim[crossAxis]);
  }

  // As we only wrapped in normal direction yet, we need to reverse the
  // positions on wrap-reverse.
  if (performLayout && node->getStyle().flexWrap() == TAYGWrapWrapReverse) {
    for (uint32_t i = 0; i < childCount; i++) {
      const TAYGNodeRef child = TAYGNodeGetChild(node, i);
      if (child->getStyle().positionType() != TAYGPositionTypeAbsolute) {
        child->setLayoutPosition(
            node->getLayout().measuredDimensions[dim[crossAxis]] -
                child->getLayout().position[pos[crossAxis]] -
                child->getLayout().measuredDimensions[dim[crossAxis]],
            pos[crossAxis]);
      }
    }
  }

  if (performLayout) {
    // STEP 10: SIZING AND POSITIONING ABSOLUTE CHILDREN
    for (auto child : node->getChildren()) {
      if (child->getStyle().display() == TAYGDisplayNone ||
          child->getStyle().positionType() != TAYGPositionTypeAbsolute) {
        continue;
      }
      YGNodeAbsoluteLayoutChild(
          node,
          child,
          availableInnerWidth,
          isMainAxisRow ? measureModeMainDim : measureModeCrossDim,
          availableInnerHeight,
          direction,
          config,
          layoutMarkerData,
          layoutContext,
          depth,
          generationCount);
    }

    // STEP 11: SETTING TRAILING POSITIONS FOR CHILDREN
    const bool needsMainTrailingPos = mainAxis == TAYGFlexDirectionRowReverse ||
        mainAxis == YGFlexDirectionColumnReverse;
    const bool needsCrossTrailingPos = crossAxis == TAYGFlexDirectionRowReverse ||
        crossAxis == YGFlexDirectionColumnReverse;

    // Set ta_trailing position if necessary.
    if (needsMainTrailingPos || needsCrossTrailingPos) {
      for (uint32_t i = 0; i < childCount; i++) {
        const TAYGNodeRef child = node->getChild(i);
        if (child->getStyle().display() == TAYGDisplayNone) {
          continue;
        }
        if (needsMainTrailingPos) {
          YGNodeSetChildTrailingPosition(node, child, mainAxis);
        }

        if (needsCrossTrailingPos) {
          YGNodeSetChildTrailingPosition(node, child, crossAxis);
        }
      }
    }
  }
}

bool ta_gPrintChanges = false;
bool ta_gPrintSkips = false;

static const char* spacer =
    "                                                            ";

static const char* YGSpacer(const unsigned long level) {
  const size_t spacerLen = strlen(spacer);
  if (level > spacerLen) {
    return &spacer[0];
  } else {
    return &spacer[spacerLen - level];
  }
}

static const char* YGMeasureModeName(
    const TAYGMeasureMode mode,
    const bool performLayout) {
  constexpr auto N = enums::count<TAYGMeasureMode>();
  const char* kMeasureModeNames[N] = {"UNDEFINED", "EXACTLY", "AT_MOST"};
  const char* kLayoutModeNames[N] = {
      "LAY_UNDEFINED", "LAY_EXACTLY", "LAY_AT_MOST"};

  if (mode >= N) {
    return "";
  }

  return performLayout ? kLayoutModeNames[mode] : kMeasureModeNames[mode];
}

static inline bool YGMeasureModeSizeIsExactAndMatchesOldMeasuredSize(
    TAYGMeasureMode sizeMode,
    float size,
    float lastComputedSize) {
  return sizeMode == TAYGMeasureModeExactly &&
      TAYGFloatsEqual(size, lastComputedSize);
}

static inline bool YGMeasureModeOldSizeIsUnspecifiedAndStillFits(
    TAYGMeasureMode sizeMode,
    float size,
    TAYGMeasureMode lastSizeMode,
    float lastComputedSize) {
  return sizeMode == TAYGMeasureModeAtMost &&
      lastSizeMode == TAYGMeasureModeUndefined &&
      (size >= lastComputedSize || TAYGFloatsEqual(size, lastComputedSize));
}

static inline bool YGMeasureModeNewMeasureSizeIsStricterAndStillValid(
    TAYGMeasureMode sizeMode,
    float size,
    TAYGMeasureMode lastSizeMode,
    float lastSize,
    float lastComputedSize) {
  return lastSizeMode == TAYGMeasureModeAtMost &&
      sizeMode == TAYGMeasureModeAtMost && !TAYGFloatIsUndefined(lastSize) &&
      !TAYGFloatIsUndefined(size) && !TAYGFloatIsUndefined(lastComputedSize) &&
      lastSize > size &&
      (lastComputedSize <= size || TAYGFloatsEqual(size, lastComputedSize));
}

TA_YOGA_EXPORT float TAYGRoundValueToPixelGrid(
    const double value,
    const double pointScaleFactor,
    const bool forceCeil,
    const bool forceFloor) {
  double scaledValue = value * pointScaleFactor;
  // We want to calculate `fractial` such that `floor(scaledValue) = scaledValue
  // - fractial`.
  double fractial = fmod(scaledValue, 1.0);
  if (fractial < 0) {
    // This branch is for handling negative numbers for `value`.
    //
    // Regarding `floor` and `ceil`. Note that for a number x, `floor(x) <= x <=
    // ceil(x)` even for negative numbers. Here are a couple of examples:
    //   - x =  2.2: floor( 2.2) =  2, ceil( 2.2) =  3
    //   - x = -2.2: floor(-2.2) = -3, ceil(-2.2) = -2
    //
    // Regarding `fmodf`. For fractional negative numbers, `fmodf` returns a
    // negative number. For example, `fmodf(-2.2) = -0.2`. However, we want
    // `fractial` to be the number such that subtracting it from `value` will
    // give us `floor(value)`. In the case of negative numbers, adding 1 to
    // `fmodf(value)` gives us this. Let's continue the example from above:
    //   - fractial = fmodf(-2.2) = -0.2
    //   - Add 1 to the fraction: fractial2 = fractial + 1 = -0.2 + 1 = 0.8
    //   - Finding the `floor`: -2.2 - fractial2 = -2.2 - 0.8 = -3
    ++fractial;
  }
  if (TAYGDoubleEqual(fractial, 0)) {
    // First we check if the value is already rounded
    scaledValue = scaledValue - fractial;
  } else if (TAYGDoubleEqual(fractial, 1.0)) {
    scaledValue = scaledValue - fractial + 1.0;
  } else if (forceCeil) {
    // Next we check if we need to use forced rounding
    scaledValue = scaledValue - fractial + 1.0;
  } else if (forceFloor) {
    scaledValue = scaledValue - fractial;
  } else {
    // Finally we just round the value
    scaledValue = scaledValue - fractial +
        (!TAYGDoubleIsUndefined(fractial) &&
                 (fractial > 0.5 || TAYGDoubleEqual(fractial, 0.5))
             ? 1.0
             : 0.0);
  }
  return (TAYGDoubleIsUndefined(scaledValue) ||
          TAYGDoubleIsUndefined(pointScaleFactor))
      ? TAYGUndefined
      : (float) (scaledValue / pointScaleFactor);
}

TA_YOGA_EXPORT bool TAYGNodeCanUseCachedMeasurement(
    const TAYGMeasureMode widthMode,
    const float width,
    const TAYGMeasureMode heightMode,
    const float height,
    const TAYGMeasureMode lastWidthMode,
    const float lastWidth,
    const TAYGMeasureMode lastHeightMode,
    const float lastHeight,
    const float lastComputedWidth,
    const float lastComputedHeight,
    const float marginRow,
    const float marginColumn,
    const TAYGConfigRef config) {
  if ((!TAYGFloatIsUndefined(lastComputedHeight) && lastComputedHeight < 0) ||
      (!TAYGFloatIsUndefined(lastComputedWidth) && lastComputedWidth < 0)) {
    return false;
  }
  bool useRoundedComparison =
      config != nullptr && config->pointScaleFactor != 0;
  const float effectiveWidth = useRoundedComparison
      ? TAYGRoundValueToPixelGrid(width, config->pointScaleFactor, false, false)
      : width;
  const float effectiveHeight = useRoundedComparison
      ? TAYGRoundValueToPixelGrid(height, config->pointScaleFactor, false, false)
      : height;
  const float effectiveLastWidth = useRoundedComparison
      ? TAYGRoundValueToPixelGrid(
            lastWidth, config->pointScaleFactor, false, false)
      : lastWidth;
  const float effectiveLastHeight = useRoundedComparison
      ? TAYGRoundValueToPixelGrid(
            lastHeight, config->pointScaleFactor, false, false)
      : lastHeight;

  const bool hasSameWidthSpec = lastWidthMode == widthMode &&
      TAYGFloatsEqual(effectiveLastWidth, effectiveWidth);
  const bool hasSameHeightSpec = lastHeightMode == heightMode &&
      TAYGFloatsEqual(effectiveLastHeight, effectiveHeight);

  const bool widthIsCompatible =
      hasSameWidthSpec ||
      YGMeasureModeSizeIsExactAndMatchesOldMeasuredSize(
          widthMode, width - marginRow, lastComputedWidth) ||
      YGMeasureModeOldSizeIsUnspecifiedAndStillFits(
          widthMode, width - marginRow, lastWidthMode, lastComputedWidth) ||
      YGMeasureModeNewMeasureSizeIsStricterAndStillValid(
          widthMode,
          width - marginRow,
          lastWidthMode,
          lastWidth,
          lastComputedWidth);

  const bool heightIsCompatible =
      hasSameHeightSpec ||
      YGMeasureModeSizeIsExactAndMatchesOldMeasuredSize(
          heightMode, height - marginColumn, lastComputedHeight) ||
      YGMeasureModeOldSizeIsUnspecifiedAndStillFits(
          heightMode,
          height - marginColumn,
          lastHeightMode,
          lastComputedHeight) ||
      YGMeasureModeNewMeasureSizeIsStricterAndStillValid(
          heightMode,
          height - marginColumn,
          lastHeightMode,
          lastHeight,
          lastComputedHeight);

  return widthIsCompatible && heightIsCompatible;
}

//
// This is a wrapper around the YGNodelayoutImpl function. It determines whether
// the layout request is redundant and can be skipped.
//
// Parameters:
//  Input parameters are the same as YGNodelayoutImpl (see above)
//  Return parameter is true if layout was performed, false if skipped
//
bool YGLayoutNodeInternal(
    const TAYGNodeRef node,
    const float availableWidth,
    const float availableHeight,
    const TAYGDirection ownerDirection,
    const TAYGMeasureMode widthMeasureMode,
    const TAYGMeasureMode heightMeasureMode,
    const float ownerWidth,
    const float ownerHeight,
    const bool performLayout,
    const LayoutPassReason reason,
    const TAYGConfigRef config,
    LayoutData& layoutMarkerData,
    void* const layoutContext,
    uint32_t depth,
    const uint32_t generationCount) {
  TAYGLayout* layout = &node->getLayout();

  depth++;

  const bool needToVisitNode =
      (node->isDirty() && layout->generationCount != generationCount) ||
      layout->lastOwnerDirection != ownerDirection;

  if (needToVisitNode) {
    // Invalidate the cached results.
    layout->nextCachedMeasurementsIndex = 0;
    layout->cachedLayout.availableWidth = -1;
    layout->cachedLayout.availableHeight = -1;
    layout->cachedLayout.widthMeasureMode = TAYGMeasureModeUndefined;
    layout->cachedLayout.heightMeasureMode = TAYGMeasureModeUndefined;
    layout->cachedLayout.computedWidth = -1;
    layout->cachedLayout.computedHeight = -1;
  }

  TAYGCachedMeasurement* cachedResults = nullptr;

  // Determine whether the results are already cached. We maintain a separate
  // cache for layouts and measurements. A layout operation modifies the
  // positions and dimensions for nodes in the subtree. The algorithm assumes
  // that each node gets layed out a maximum of one time per tree layout, but
  // multiple measurements may be required to resolve all of the flex
  // dimensions. We handle nodes with measure functions specially here because
  // they are the most expensive to measure, so it's worth avoiding redundant
  // measurements if at all possible.
  if (node->hasMeasureFunc()) {
    const float marginAxisRow =
        node->getMarginForAxis(TAYGFlexDirectionRow, ownerWidth).unwrap();
    const float marginAxisColumn =
        node->getMarginForAxis(TAYGFlexDirectionColumn, ownerWidth).unwrap();

    // First, try to use the layout cache.
    if (TAYGNodeCanUseCachedMeasurement(
            widthMeasureMode,
            availableWidth,
            heightMeasureMode,
            availableHeight,
            layout->cachedLayout.widthMeasureMode,
            layout->cachedLayout.availableWidth,
            layout->cachedLayout.heightMeasureMode,
            layout->cachedLayout.availableHeight,
            layout->cachedLayout.computedWidth,
            layout->cachedLayout.computedHeight,
            marginAxisRow,
            marginAxisColumn,
            config)) {
      cachedResults = &layout->cachedLayout;
    } else {
      // Try to use the measurement cache.
      for (uint32_t i = 0; i < layout->nextCachedMeasurementsIndex; i++) {
        if (TAYGNodeCanUseCachedMeasurement(
                widthMeasureMode,
                availableWidth,
                heightMeasureMode,
                availableHeight,
                layout->cachedMeasurements[i].widthMeasureMode,
                layout->cachedMeasurements[i].availableWidth,
                layout->cachedMeasurements[i].heightMeasureMode,
                layout->cachedMeasurements[i].availableHeight,
                layout->cachedMeasurements[i].computedWidth,
                layout->cachedMeasurements[i].computedHeight,
                marginAxisRow,
                marginAxisColumn,
                config)) {
          cachedResults = &layout->cachedMeasurements[i];
          break;
        }
      }
    }
  } else if (performLayout) {
    if (TAYGFloatsEqual(layout->cachedLayout.availableWidth, availableWidth) &&
        TAYGFloatsEqual(layout->cachedLayout.availableHeight, availableHeight) &&
        layout->cachedLayout.widthMeasureMode == widthMeasureMode &&
        layout->cachedLayout.heightMeasureMode == heightMeasureMode) {
      cachedResults = &layout->cachedLayout;
    }
  } else {
    for (uint32_t i = 0; i < layout->nextCachedMeasurementsIndex; i++) {
      if (TAYGFloatsEqual(
              layout->cachedMeasurements[i].availableWidth, availableWidth) &&
          TAYGFloatsEqual(
              layout->cachedMeasurements[i].availableHeight, availableHeight) &&
          layout->cachedMeasurements[i].widthMeasureMode == widthMeasureMode &&
          layout->cachedMeasurements[i].heightMeasureMode ==
              heightMeasureMode) {
        cachedResults = &layout->cachedMeasurements[i];
        break;
      }
    }
  }

  if (!needToVisitNode && cachedResults != nullptr) {
    layout->measuredDimensions[TAYGDimensionWidth] = cachedResults->computedWidth;
    layout->measuredDimensions[TAYGDimensionHeight] =
        cachedResults->computedHeight;

    (performLayout ? layoutMarkerData.cachedLayouts
                   : layoutMarkerData.cachedMeasures) += 1;

    if (ta_gPrintChanges && ta_gPrintSkips) {
      TALog::log(
          node,
          TAYGLogLevelVerbose,
          nullptr,
          "%s%d.{[skipped] ",
          YGSpacer(depth),
          depth);
      node->print(layoutContext);
      TALog::log(
          node,
          TAYGLogLevelVerbose,
          nullptr,
          "wm: %s, hm: %s, aw: %f ah: %f => d: (%f, %f) %s\n",
          YGMeasureModeName(widthMeasureMode, performLayout),
          YGMeasureModeName(heightMeasureMode, performLayout),
          availableWidth,
          availableHeight,
          cachedResults->computedWidth,
          cachedResults->computedHeight,
          LayoutPassReasonToString(reason));
    }
  } else {
    if (ta_gPrintChanges) {
      TALog::log(
          node,
          TAYGLogLevelVerbose,
          nullptr,
          "%s%d.{%s",
          YGSpacer(depth),
          depth,
          needToVisitNode ? "*" : "");
      node->print(layoutContext);
      TALog::log(
          node,
          TAYGLogLevelVerbose,
          nullptr,
          "wm: %s, hm: %s, aw: %f ah: %f %s\n",
          YGMeasureModeName(widthMeasureMode, performLayout),
          YGMeasureModeName(heightMeasureMode, performLayout),
          availableWidth,
          availableHeight,
          LayoutPassReasonToString(reason));
    }

    YGNodelayoutImpl(
        node,
        availableWidth,
        availableHeight,
        ownerDirection,
        widthMeasureMode,
        heightMeasureMode,
        ownerWidth,
        ownerHeight,
        performLayout,
        config,
        layoutMarkerData,
        layoutContext,
        depth,
        generationCount,
        reason);

    if (ta_gPrintChanges) {
      TALog::log(
          node,
          TAYGLogLevelVerbose,
          nullptr,
          "%s%d.}%s",
          YGSpacer(depth),
          depth,
          needToVisitNode ? "*" : "");
      node->print(layoutContext);
      TALog::log(
          node,
          TAYGLogLevelVerbose,
          nullptr,
          "wm: %s, hm: %s, d: (%f, %f) %s\n",
          YGMeasureModeName(widthMeasureMode, performLayout),
          YGMeasureModeName(heightMeasureMode, performLayout),
          layout->measuredDimensions[TAYGDimensionWidth],
          layout->measuredDimensions[TAYGDimensionHeight],
          LayoutPassReasonToString(reason));
    }

    layout->lastOwnerDirection = ownerDirection;

    if (cachedResults == nullptr) {
      if (layout->nextCachedMeasurementsIndex + 1 >
          (uint32_t) layoutMarkerData.maxMeasureCache) {
        layoutMarkerData.maxMeasureCache =
            layout->nextCachedMeasurementsIndex + 1;
      }
      if (layout->nextCachedMeasurementsIndex == YG_MAX_CACHED_RESULT_COUNT) {
        if (ta_gPrintChanges) {
          TALog::log(node, TAYGLogLevelVerbose, nullptr, "Out of cache entries!\n");
        }
        layout->nextCachedMeasurementsIndex = 0;
      }

      TAYGCachedMeasurement* newCacheEntry;
      if (performLayout) {
        // Use the single layout cache entry.
        newCacheEntry = &layout->cachedLayout;
      } else {
        // Allocate a new measurement cache entry.
        newCacheEntry =
            &layout->cachedMeasurements[layout->nextCachedMeasurementsIndex];
        layout->nextCachedMeasurementsIndex++;
      }

      newCacheEntry->availableWidth = availableWidth;
      newCacheEntry->availableHeight = availableHeight;
      newCacheEntry->widthMeasureMode = widthMeasureMode;
      newCacheEntry->heightMeasureMode = heightMeasureMode;
      newCacheEntry->computedWidth =
          layout->measuredDimensions[TAYGDimensionWidth];
      newCacheEntry->computedHeight =
          layout->measuredDimensions[TAYGDimensionHeight];
    }
  }

  if (performLayout) {
    node->setLayoutDimension(
        node->getLayout().measuredDimensions[TAYGDimensionWidth],
        TAYGDimensionWidth);
    node->setLayoutDimension(
        node->getLayout().measuredDimensions[TAYGDimensionHeight],
        TAYGDimensionHeight);

    node->setHasNewLayout(true);
    node->setDirty(false);
  }

  layout->generationCount = generationCount;

  LayoutType layoutType;
  if (performLayout) {
    layoutType = !needToVisitNode && cachedResults == &layout->cachedLayout
        ? LayoutType::kCachedLayout
        : LayoutType::kLayout;
  } else {
    layoutType = cachedResults != nullptr ? LayoutType::kCachedMeasure
                                          : LayoutType::kMeasure;
  }
  Event::publish<Event::NodeLayout>(node, {layoutType, layoutContext});

  return (needToVisitNode || cachedResults == nullptr);
}

TA_YOGA_EXPORT void TAYGConfigSetPointScaleFactor(
    const TAYGConfigRef config,
    const float pixelsInPoint) {
  TAYGAssertWithConfig(
      config,
      pixelsInPoint >= 0.0f,
      "Scale factor should not be less than zero");

  // We store points for Pixel as we will use it for rounding
  if (pixelsInPoint == 0.0f) {
    // Zero is used to skip rounding
    config->pointScaleFactor = 0.0f;
  } else {
    config->pointScaleFactor = pixelsInPoint;
  }
}

static void YGRoundToPixelGrid(
    const TAYGNodeRef node,
    const double pointScaleFactor,
    const double absoluteLeft,
    const double absoluteTop) {
  if (pointScaleFactor == 0.0f) {
    return;
  }

  const double nodeLeft = node->getLayout().position[TAYGEdgeLeft];
  const double nodeTop = node->getLayout().position[TAYGEdgeTop];

  const double nodeWidth = node->getLayout().dimensions[TAYGDimensionWidth];
  const double nodeHeight = node->getLayout().dimensions[TAYGDimensionHeight];

  const double absoluteNodeLeft = absoluteLeft + nodeLeft;
  const double absoluteNodeTop = absoluteTop + nodeTop;

  const double absoluteNodeRight = absoluteNodeLeft + nodeWidth;
  const double absoluteNodeBottom = absoluteNodeTop + nodeHeight;

  // If a node has a custom measure function we never want to round down its
  // size as this could lead to unwanted text truncation.
  const bool textRounding = node->getNodeType() == TAYGNodeTypeText;

  node->setLayoutPosition(
      TAYGRoundValueToPixelGrid(nodeLeft, pointScaleFactor, false, textRounding),
      TAYGEdgeLeft);

  node->setLayoutPosition(
      TAYGRoundValueToPixelGrid(nodeTop, pointScaleFactor, false, textRounding),
      TAYGEdgeTop);

  // We multiply dimension by scale factor and if the result is close to the
  // whole number, we don't have any fraction To verify if the result is close
  // to whole number we want to check both floor and ceil numbers
  const bool hasFractionalWidth =
      !TAYGDoubleEqual(fmod(nodeWidth * pointScaleFactor, 1.0), 0) &&
      !TAYGDoubleEqual(fmod(nodeWidth * pointScaleFactor, 1.0), 1.0);
  const bool hasFractionalHeight =
      !TAYGDoubleEqual(fmod(nodeHeight * pointScaleFactor, 1.0), 0) &&
      !TAYGDoubleEqual(fmod(nodeHeight * pointScaleFactor, 1.0), 1.0);

  node->setLayoutDimension(
      TAYGRoundValueToPixelGrid(
          absoluteNodeRight,
          pointScaleFactor,
          (textRounding && hasFractionalWidth),
          (textRounding && !hasFractionalWidth)) -
          TAYGRoundValueToPixelGrid(
              absoluteNodeLeft, pointScaleFactor, false, textRounding),
      TAYGDimensionWidth);

  node->setLayoutDimension(
      TAYGRoundValueToPixelGrid(
          absoluteNodeBottom,
          pointScaleFactor,
          (textRounding && hasFractionalHeight),
          (textRounding && !hasFractionalHeight)) -
          TAYGRoundValueToPixelGrid(
              absoluteNodeTop, pointScaleFactor, false, textRounding),
      TAYGDimensionHeight);

  const uint32_t childCount = TAYGNodeGetChildCount(node);
  for (uint32_t i = 0; i < childCount; i++) {
    YGRoundToPixelGrid(
        TAYGNodeGetChild(node, i),
        pointScaleFactor,
        absoluteNodeLeft,
        absoluteNodeTop);
  }
}

static void unsetUseLegacyFlagRecursively(TAYGNodeRef node) {
  node->getConfig()->useLegacyStretchBehaviour = false;
  for (auto child : node->getChildren()) {
    unsetUseLegacyFlagRecursively(child);
  }
}

TA_YOGA_EXPORT void TAYGNodeCalculateLayoutWithContext(
    const TAYGNodeRef node,
    const float ownerWidth,
    const float ownerHeight,
    const TAYGDirection ownerDirection,
    void* layoutContext) {

  Event::publish<Event::LayoutPassStart>(node, {layoutContext});
  LayoutData markerData = {};

  // Increment the generation count. This will force the recursive routine to
  // visit all dirty nodes at least once. Subsequent visits will be skipped if
  // the input parameters don't change.
  ta_gCurrentGenerationCount.fetch_add(1, std::memory_order_relaxed);
  node->resolveDimension();
  float width = TAYGUndefined;
  TAYGMeasureMode widthMeasureMode = TAYGMeasureModeUndefined;
  const auto& maxDimensions = node->getStyle().maxDimensions();
  if (YGNodeIsStyleDimDefined(node, TAYGFlexDirectionRow, ownerWidth)) {
    width =
        (TAYGResolveValue(
             node->getResolvedDimension(dim[TAYGFlexDirectionRow]), ownerWidth) +
         node->getMarginForAxis(TAYGFlexDirectionRow, ownerWidth))
            .unwrap();
    widthMeasureMode = TAYGMeasureModeExactly;
  } else if (!TAYGResolveValue(maxDimensions[TAYGDimensionWidth], ownerWidth)
                  .isUndefined()) {
    width =
        TAYGResolveValue(maxDimensions[TAYGDimensionWidth], ownerWidth).unwrap();
    widthMeasureMode = TAYGMeasureModeAtMost;
  } else {
    width = ownerWidth;
    widthMeasureMode = TAYGFloatIsUndefined(width) ? TAYGMeasureModeUndefined
                                                 : TAYGMeasureModeExactly;
  }

  float height = TAYGUndefined;
  TAYGMeasureMode heightMeasureMode = TAYGMeasureModeUndefined;
  if (YGNodeIsStyleDimDefined(node, TAYGFlexDirectionColumn, ownerHeight)) {
    height = (TAYGResolveValue(
                  node->getResolvedDimension(dim[TAYGFlexDirectionColumn]),
                  ownerHeight) +
              node->getMarginForAxis(TAYGFlexDirectionColumn, ownerWidth))
                 .unwrap();
    heightMeasureMode = TAYGMeasureModeExactly;
  } else if (!TAYGResolveValue(maxDimensions[TAYGDimensionHeight], ownerHeight)
                  .isUndefined()) {
    height =
        TAYGResolveValue(maxDimensions[TAYGDimensionHeight], ownerHeight).unwrap();
    heightMeasureMode = TAYGMeasureModeAtMost;
  } else {
    height = ownerHeight;
    heightMeasureMode = TAYGFloatIsUndefined(height) ? TAYGMeasureModeUndefined
                                                   : TAYGMeasureModeExactly;
  }
  if (YGLayoutNodeInternal(
          node,
          width,
          height,
          ownerDirection,
          widthMeasureMode,
          heightMeasureMode,
          ownerWidth,
          ownerHeight,
          true,
          LayoutPassReason::kInitial,
          node->getConfig(),
          markerData,
          layoutContext,
          0, // tree root
          ta_gCurrentGenerationCount.load(std::memory_order_relaxed))) {
    node->setPosition(
        node->getLayout().direction(), ownerWidth, ownerHeight, ownerWidth);
    YGRoundToPixelGrid(node, node->getConfig()->pointScaleFactor, 0.0f, 0.0f);

#ifdef DEBUG
    if (node->getConfig()->printTree) {
      TAYGNodePrint(
          node,
          (TAYGPrintOptions) (TAYGPrintOptionsLayout | TAYGPrintOptionsChildren | TAYGPrintOptionsStyle));
    }
#endif
  }

  Event::publish<Event::LayoutPassEnd>(node, {layoutContext, &markerData});

  // We want to get rid off `useLegacyStretchBehaviour` from TAYGConfig. But we
  // aren't sure whether client's of ta_yoga have gotten rid off this flag or not.
  // So logging this in TAYGLayout would help to find out the call sites depending
  // on this flag. This check would be removed once we are sure no one is
  // dependent on this flag anymore. The flag
  // `shouldDiffLayoutWithoutLegacyStretchBehaviour` in TAYGConfig will help to
  // run experiments.
  if (node->getConfig()->shouldDiffLayoutWithoutLegacyStretchBehaviour &&
      node->didUseLegacyFlag()) {
    const TAYGNodeRef nodeWithoutLegacyFlag = YGNodeDeepClone(node);
    nodeWithoutLegacyFlag->resolveDimension();
    // Recursively mark nodes as dirty
    nodeWithoutLegacyFlag->markDirtyAndPropogateDownwards();
    ta_gCurrentGenerationCount.fetch_add(1, std::memory_order_relaxed);
    // Rerun the layout, and calculate the diff
    unsetUseLegacyFlagRecursively(nodeWithoutLegacyFlag);
    LayoutData layoutMarkerData = {};
    if (YGLayoutNodeInternal(
            nodeWithoutLegacyFlag,
            width,
            height,
            ownerDirection,
            widthMeasureMode,
            heightMeasureMode,
            ownerWidth,
            ownerHeight,
            true,
            LayoutPassReason::kInitial,
            nodeWithoutLegacyFlag->getConfig(),
            layoutMarkerData,
            layoutContext,
            0, // tree root
            ta_gCurrentGenerationCount.load(std::memory_order_relaxed))) {
      nodeWithoutLegacyFlag->setPosition(
          nodeWithoutLegacyFlag->getLayout().direction(),
          ownerWidth,
          ownerHeight,
          ownerWidth);
      YGRoundToPixelGrid(
          nodeWithoutLegacyFlag,
          nodeWithoutLegacyFlag->getConfig()->pointScaleFactor,
          0.0f,
          0.0f);

      // Set whether the two layouts are different or not.
      auto neededLegacyStretchBehaviour =
          !nodeWithoutLegacyFlag->isLayoutTreeEqualToNode(*node);
      node->setLayoutDoesLegacyFlagAffectsLayout(neededLegacyStretchBehaviour);

#ifdef DEBUG
      if (nodeWithoutLegacyFlag->getConfig()->printTree) {
        TAYGNodePrint(
            nodeWithoutLegacyFlag,
            (TAYGPrintOptions) (TAYGPrintOptionsLayout | TAYGPrintOptionsChildren | TAYGPrintOptionsStyle));
      }
#endif
    }
    YGConfigFreeRecursive(nodeWithoutLegacyFlag);
    TAYGNodeFreeRecursive(nodeWithoutLegacyFlag);
  }
}

TA_YOGA_EXPORT void TAYGNodeCalculateLayout(
    const TAYGNodeRef node,
    const float ownerWidth,
    const float ownerHeight,
    const TAYGDirection ownerDirection) {
  TAYGNodeCalculateLayoutWithContext(
      node, ownerWidth, ownerHeight, ownerDirection, nullptr);
}

TA_YOGA_EXPORT void TAYGConfigSetLogger(const TAYGConfigRef config, TAYGLogger logger) {
  if (logger != nullptr) {
    config->setLogger(logger);
  } else {
#ifdef ANDROID
    config->setLogger(&TAYGAndroidLog);
#else
    config->setLogger(&TAYGDefaultLog);
#endif
  }
}

TA_YOGA_EXPORT void TAYGConfigSetShouldDiffLayoutWithoutLegacyStretchBehaviour(
    const TAYGConfigRef config,
    const bool shouldDiffLayout) {
  config->shouldDiffLayoutWithoutLegacyStretchBehaviour = shouldDiffLayout;
}

void TAYGAssert(const bool condition, const char* message) {
  if (!condition) {
    TALog::log(TAYGNodeRef{nullptr}, TAYGLogLevelFatal, nullptr, "%s\n", message);
    ta_throwLogicalErrorWithMessage(message);
  }
}

void TAYGAssertWithNode(
    const TAYGNodeRef node,
    const bool condition,
    const char* message) {
  if (!condition) {
    TALog::log(node, TAYGLogLevelFatal, nullptr, "%s\n", message);
    ta_throwLogicalErrorWithMessage(message);
  }
}

void TAYGAssertWithConfig(
    const TAYGConfigRef config,
    const bool condition,
    const char* message) {
  if (!condition) {
    TALog::log(config, TAYGLogLevelFatal, nullptr, "%s\n", message);
    ta_throwLogicalErrorWithMessage(message);
  }
}

TA_YOGA_EXPORT void TAYGConfigSetExperimentalFeatureEnabled(
    const TAYGConfigRef config,
    const TAYGExperimentalFeature feature,
    const bool enabled) {
  config->experimentalFeatures[feature] = enabled;
}

inline bool TAYGConfigIsExperimentalFeatureEnabledfaults(
    const TAYGConfigRef config,
    const TAYGExperimentalFeature feature) {
  return config->experimentalFeatures[feature];
}

TA_YOGA_EXPORT void TAYGConfigSetUseWebDefaults(
    const TAYGConfigRef config,
    const bool enabled) {
  config->useWebDefaults = enabled;
}

TA_YOGA_EXPORT void TAYGConfigSetUseLegacyStretchBehaviour(
    const TAYGConfigRef config,
    const bool useLegacyStretchBehaviour) {
  config->useLegacyStretchBehaviour = useLegacyStretchBehaviour;
}

bool TAYGConfigGetUseWebDefaults(const TAYGConfigRef config) {
  return config->useWebDefaults;
}

TA_YOGA_EXPORT void TAYGConfigSetContext(const TAYGConfigRef config, void* context) {
  config->context = context;
}

TA_YOGA_EXPORT void* TAYGConfigGetContext(const TAYGConfigRef config) {
  return config->context;
}

TA_YOGA_EXPORT void TAYGConfigSetCloneNodeFunc(
    const TAYGConfigRef config,
    const TAYGCloneNodeFunc callback) {
  config->setCloneNodeCallback(callback);
}

static void YGTraverseChildrenPreOrder(
    const TAYGVector& children,
    const std::function<void(TAYGNodeRef node)>& f) {
  for (TAYGNodeRef node : children) {
    f(node);
    YGTraverseChildrenPreOrder(node->getChildren(), f);
  }
}

void TAYGTraversePreOrder(
    TAYGNodeRef const node,
    std::function<void(TAYGNodeRef node)>&& f) {
  if (!node) {
    return;
  }
  f(node);
  YGTraverseChildrenPreOrder(node->getChildren(), f);
}
