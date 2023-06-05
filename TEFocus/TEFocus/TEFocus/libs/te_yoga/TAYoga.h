

#pragma once

#include <assert.h>
#include <math.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef __cplusplus
#include <stdbool.h>
#endif

#include "TAYGEnums.h"
#include "TAYGMacros.h"
#include "TAYGValue.h"

TA_YG_EXTERN_C_BEGIN

typedef struct TAYGSize {
  float width;
  float height;
} TAYGSize;

typedef struct TAYGConfig* TAYGConfigRef;

typedef struct TAYGNode* TAYGNodeRef;
typedef const struct TAYGNode* TAYGNodeConstRef;

typedef TAYGSize (*TAYGMeasureFunc)(
    TAYGNodeRef node,
    float width,
    TAYGMeasureMode widthMode,
    float height,
    TAYGMeasureMode heightMode);
typedef float (*TAYGBaselineFunc)(TAYGNodeRef node, float width, float height);
typedef void (*TAYGDirtiedFunc)(TAYGNodeRef node);
typedef void (*TAYGPrintFunc)(TAYGNodeRef node);
typedef void (*TAYGNodeCleanupFunc)(TAYGNodeRef node);
typedef int (*TAYGLogger)(
    TAYGConfigRef config,
    TAYGNodeRef node,
    TAYGLogLevel level,
    const char* format,
    va_list args);
typedef TAYGNodeRef (
    *TAYGCloneNodeFunc)(TAYGNodeRef oldNode, TAYGNodeRef owner, int childIndex);

// TAYGNode
WIN_EXPORT TAYGNodeRef TAYGNodeNew(void);
WIN_EXPORT TAYGNodeRef TAYGNodeNewWithConfig(TAYGConfigRef config);
WIN_EXPORT TAYGNodeRef TAYGNodeClone(TAYGNodeRef node);
WIN_EXPORT void TAYGNodeFree(TAYGNodeRef node);
WIN_EXPORT void TAYGNodeFreeRecursiveWithCleanupFunc(
    TAYGNodeRef node,
    TAYGNodeCleanupFunc cleanup);
WIN_EXPORT void TAYGNodeFreeRecursive(TAYGNodeRef node);
WIN_EXPORT void TAYGNodeReset(TAYGNodeRef node);

WIN_EXPORT void TAYGNodeInsertChild(
    TAYGNodeRef node,
    TAYGNodeRef child,
    uint32_t index);

WIN_EXPORT void TAYGNodeSwapChild(
    TAYGNodeRef node,
    TAYGNodeRef child,
    uint32_t index);

WIN_EXPORT void TAYGNodeRemoveChild(TAYGNodeRef node, TAYGNodeRef child);
WIN_EXPORT void TAYGNodeRemoveAllChildren(TAYGNodeRef node);
WIN_EXPORT TAYGNodeRef TAYGNodeGetChild(TAYGNodeRef node, uint32_t index);
WIN_EXPORT TAYGNodeRef TAYGNodeGetOwner(TAYGNodeRef node);
WIN_EXPORT TAYGNodeRef TAYGNodeGetParent(TAYGNodeRef node);
WIN_EXPORT uint32_t TAYGNodeGetChildCount(TAYGNodeRef node);
WIN_EXPORT void TAYGNodeSetChildren(
    TAYGNodeRef owner,
    const TAYGNodeRef children[],
    uint32_t count);

WIN_EXPORT void TAYGNodeSetIsReferenceBaseline(
    TAYGNodeRef node,
    bool ta_isReferenceBaseline);

WIN_EXPORT bool TAYGNodeIsReferenceBaseline(TAYGNodeRef node);

WIN_EXPORT void TAYGNodeCalculateLayout(
    TAYGNodeRef node,
    float availableWidth,
    float availableHeight,
    TAYGDirection ownerDirection);

// Mark a node as dirty. Only valid for nodes with a custom measure function
// set.
//
// TAYoga knows when to mark all other nodes as dirty but because nodes with
// measure functions depend on information not known to TAYoga they must perform
// this dirty marking manually.
WIN_EXPORT void TAYGNodeMarkDirty(TAYGNodeRef node);

// Marks the current node and all its descendants as dirty.
//
// Intended to be used for TAYoga benchmarks. Don't use in production, as calling
// `YGCalculateLayout` will cause the recalculation of each and every node.
WIN_EXPORT void TAYGNodeMarkDirtyAndPropogateToDescendants(TAYGNodeRef node);

WIN_EXPORT void TAYGNodePrint(TAYGNodeRef node, TAYGPrintOptions options);

WIN_EXPORT bool TAYGFloatIsUndefined(float value);

WIN_EXPORT bool TAYGNodeCanUseCachedMeasurement(
    TAYGMeasureMode widthMode,
    float width,
    TAYGMeasureMode heightMode,
    float height,
    TAYGMeasureMode lastWidthMode,
    float lastWidth,
    TAYGMeasureMode lastHeightMode,
    float lastHeight,
    float lastComputedWidth,
    float lastComputedHeight,
    float marginRow,
    float marginColumn,
    TAYGConfigRef config);

WIN_EXPORT void TAYGNodeCopyStyle(TAYGNodeRef dstNode, TAYGNodeRef srcNode);

WIN_EXPORT void* TAYGNodeGetContext(TAYGNodeRef node);
WIN_EXPORT void TAYGNodeSetContext(TAYGNodeRef node, void* context);
void TAYGConfigSetPrintTreeFlag(TAYGConfigRef config, bool enabled);
bool TAYGNodeHasMeasureFunc(TAYGNodeRef node);
WIN_EXPORT void TAYGNodeSetMeasureFunc(TAYGNodeRef node, TAYGMeasureFunc measureFunc);
bool TAYGNodeHasBaselineFunc(TAYGNodeRef node);
void TAYGNodeSetBaselineFunc(TAYGNodeRef node, TAYGBaselineFunc baselineFunc);
TAYGDirtiedFunc TAYGNodeGetDirtiedFunc(TAYGNodeRef node);
void TAYGNodeSetDirtiedFunc(TAYGNodeRef node, TAYGDirtiedFunc dirtiedFunc);
void TAYGNodeSetPrintFunc(TAYGNodeRef node, TAYGPrintFunc printFunc);
WIN_EXPORT bool TAYGNodeGetHasNewLayout(TAYGNodeRef node);
WIN_EXPORT void TAYGNodeSetHasNewLayout(TAYGNodeRef node, bool hasNewLayout);
TAYGNodeType TAYGNodeGetNodeType(TAYGNodeRef node);
void TAYGNodeSetNodeType(TAYGNodeRef node, TAYGNodeType nodeType);
WIN_EXPORT bool TAYGNodeIsDirty(TAYGNodeRef node);
bool TAYGNodeLayoutGetDidUseLegacyFlag(TAYGNodeRef node);

WIN_EXPORT void TAYGNodeStyleSetDirection(TAYGNodeRef node, TAYGDirection direction);
WIN_EXPORT TAYGDirection TAYGNodeStyleGetDirection(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetFlexDirection(
    TAYGNodeRef node,
    TAYGFlexDirection flexDirection);
WIN_EXPORT TAYGFlexDirection TAYGNodeStyleGetFlexDirection(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetJustifyContent(
    TAYGNodeRef node,
    TAYGJustify justifyContent);
WIN_EXPORT TAYGJustify TAYGNodeStyleGetJustifyContent(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetAlignContent(
    TAYGNodeRef node,
    TAYGAlign alignContent);
WIN_EXPORT TAYGAlign TAYGNodeStyleGetAlignContent(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetAlignItems(TAYGNodeRef node, TAYGAlign alignItems);
WIN_EXPORT TAYGAlign TAYGNodeStyleGetAlignItems(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetAlignSelf(TAYGNodeRef node, TAYGAlign alignSelf);
WIN_EXPORT TAYGAlign TAYGNodeStyleGetAlignSelf(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetPositionType(
    TAYGNodeRef node,
    TAYGPositionType positionType);
WIN_EXPORT TAYGPositionType TAYGNodeStyleGetPositionType(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetFlexWrap(TAYGNodeRef node, TAYGWrap flexWrap);
WIN_EXPORT TAYGWrap TAYGNodeStyleGetFlexWrap(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetOverflow(TAYGNodeRef node, TAYGOverflow overflow);
WIN_EXPORT TAYGOverflow TAYGNodeStyleGetOverflow(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetDisplay(TAYGNodeRef node, TAYGDisplay display);
WIN_EXPORT TAYGDisplay TAYGNodeStyleGetDisplay(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetFlex(TAYGNodeRef node, float flex);
WIN_EXPORT float TAYGNodeStyleGetFlex(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetFlexGrow(TAYGNodeRef node, float flexGrow);
WIN_EXPORT float TAYGNodeStyleGetFlexGrow(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetFlexShrink(TAYGNodeRef node, float flexShrink);
WIN_EXPORT float TAYGNodeStyleGetFlexShrink(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetFlexBasis(TAYGNodeRef node, float flexBasis);
WIN_EXPORT void TAYGNodeStyleSetFlexBasisPercent(TAYGNodeRef node, float flexBasis);
WIN_EXPORT void TAYGNodeStyleSetFlexBasisAuto(TAYGNodeRef node);
WIN_EXPORT TAYGValue TAYGNodeStyleGetFlexBasis(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetPosition(
    TAYGNodeRef node,
    TAYGEdge edge,
    float position);
WIN_EXPORT void TAYGNodeStyleSetPositionPercent(
    TAYGNodeRef node,
    TAYGEdge edge,
    float position);
WIN_EXPORT TAYGValue TAYGNodeStyleGetPosition(TAYGNodeConstRef node, TAYGEdge edge);

WIN_EXPORT void TAYGNodeStyleSetMargin(TAYGNodeRef node, TAYGEdge edge, float margin);
WIN_EXPORT void TAYGNodeStyleSetMarginPercent(
    TAYGNodeRef node,
    TAYGEdge edge,
    float margin);
WIN_EXPORT void TAYGNodeStyleSetMarginAuto(TAYGNodeRef node, TAYGEdge edge);
WIN_EXPORT TAYGValue TAYGNodeStyleGetMargin(TAYGNodeConstRef node, TAYGEdge edge);

WIN_EXPORT void TAYGNodeStyleSetPadding(
    TAYGNodeRef node,
    TAYGEdge edge,
    float padding);
WIN_EXPORT void TAYGNodeStyleSetPaddingPercent(
    TAYGNodeRef node,
    TAYGEdge edge,
    float padding);
WIN_EXPORT TAYGValue TAYGNodeStyleGetPadding(TAYGNodeConstRef node, TAYGEdge edge);

WIN_EXPORT void TAYGNodeStyleSetBorder(TAYGNodeRef node, TAYGEdge edge, float border);
WIN_EXPORT float TAYGNodeStyleGetBorder(TAYGNodeConstRef node, TAYGEdge edge);

WIN_EXPORT void TAYGNodeStyleSetWidth(TAYGNodeRef node, float width);
WIN_EXPORT void TAYGNodeStyleSetWidthPercent(TAYGNodeRef node, float width);
WIN_EXPORT void TAYGNodeStyleSetWidthAuto(TAYGNodeRef node);
WIN_EXPORT TAYGValue TAYGNodeStyleGetWidth(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetHeight(TAYGNodeRef node, float height);
WIN_EXPORT void TAYGNodeStyleSetHeightPercent(TAYGNodeRef node, float height);
WIN_EXPORT void TAYGNodeStyleSetHeightAuto(TAYGNodeRef node);
WIN_EXPORT TAYGValue TAYGNodeStyleGetHeight(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetMinWidth(TAYGNodeRef node, float minWidth);
WIN_EXPORT void TAYGNodeStyleSetMinWidthPercent(TAYGNodeRef node, float minWidth);
WIN_EXPORT TAYGValue TAYGNodeStyleGetMinWidth(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetMinHeight(TAYGNodeRef node, float minHeight);
WIN_EXPORT void TAYGNodeStyleSetMinHeightPercent(TAYGNodeRef node, float minHeight);
WIN_EXPORT TAYGValue TAYGNodeStyleGetMinHeight(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetMaxWidth(TAYGNodeRef node, float maxWidth);
WIN_EXPORT void TAYGNodeStyleSetMaxWidthPercent(TAYGNodeRef node, float maxWidth);
WIN_EXPORT TAYGValue TAYGNodeStyleGetMaxWidth(TAYGNodeConstRef node);

WIN_EXPORT void TAYGNodeStyleSetMaxHeight(TAYGNodeRef node, float maxHeight);
WIN_EXPORT void TAYGNodeStyleSetMaxHeightPercent(TAYGNodeRef node, float maxHeight);
WIN_EXPORT TAYGValue TAYGNodeStyleGetMaxHeight(TAYGNodeConstRef node);

// TAYoga specific properties, not compatible with flexbox specification Aspect
// ratio control the size of the undefined dimension of a node. Aspect ratio is
// encoded as a floating point value width/height. e.g. A value of 2 leads to a
// node with a width twice the size of its height while a value of 0.5 gives the
// opposite effect.
//
// - On a node with a set width/height aspect ratio control the size of the
//   unset dimension
// - On a node with a set flex basis aspect ratio controls the size of the node
//   in the cross axis if unset
// - On a node with a measure function aspect ratio works as though the measure
//   function measures the flex basis
// - On a node with flex grow/shrink aspect ratio controls the size of the node
//   in the cross axis if unset
// - Aspect ratio takes min/max dimensions into account
WIN_EXPORT void TAYGNodeStyleSetAspectRatio(TAYGNodeRef node, float aspectRatio);
WIN_EXPORT float TAYGNodeStyleGetAspectRatio(TAYGNodeConstRef node);

WIN_EXPORT float TAYGNodeLayoutGetLeft(TAYGNodeRef node);
WIN_EXPORT float TAYGNodeLayoutGetTop(TAYGNodeRef node);
WIN_EXPORT float TAYGNodeLayoutGetRight(TAYGNodeRef node);
WIN_EXPORT float TAYGNodeLayoutGetBottom(TAYGNodeRef node);
WIN_EXPORT float TAYGNodeLayoutGetWidth(TAYGNodeRef node);
WIN_EXPORT float TAYGNodeLayoutGetHeight(TAYGNodeRef node);
WIN_EXPORT TAYGDirection TAYGNodeLayoutGetDirection(TAYGNodeRef node);
WIN_EXPORT bool TAYGNodeLayoutGetHadOverflow(TAYGNodeRef node);
bool TAYGNodeLayoutGetDidLegacyStretchFlagAffectLayout(TAYGNodeRef node);

// Get the computed values for these nodes after performing layout. If they were
// set using point values then the returned value will be the same as
// YGNodeStyleGetXXX. However if they were set using a percentage value then the
// returned value is the computed value used during layout.
WIN_EXPORT float TAYGNodeLayoutGetMargin(TAYGNodeRef node, TAYGEdge edge);
WIN_EXPORT float TAYGNodeLayoutGetBorder(TAYGNodeRef node, TAYGEdge edge);
WIN_EXPORT float TAYGNodeLayoutGetPadding(TAYGNodeRef node, TAYGEdge edge);

WIN_EXPORT void TAYGConfigSetLogger(TAYGConfigRef config, TAYGLogger logger);
WIN_EXPORT void TAYGAssert(bool condition, const char* message);
WIN_EXPORT void TAYGAssertWithNode(
    TAYGNodeRef node,
    bool condition,
    const char* message);
WIN_EXPORT void TAYGAssertWithConfig(
    TAYGConfigRef config,
    bool condition,
    const char* message);
// Set this to number of pixels in 1 point to round calculation results If you
// want to avoid rounding - set PointScaleFactor to 0
WIN_EXPORT void TAYGConfigSetPointScaleFactor(
    TAYGConfigRef config,
    float pixelsInPoint);
void TAYGConfigSetShouldDiffLayoutWithoutLegacyStretchBehaviour(
    TAYGConfigRef config,
    bool shouldDiffLayout);

// TAYoga previously had an error where containers would take the maximum space
// possible instead of the minimum like they are supposed to. In practice this
// resulted in implicit behaviour similar to align-self: stretch; Because this
// was such a long-standing bug we must allow legacy users to switch back to
// this behaviour.
WIN_EXPORT void TAYGConfigSetUseLegacyStretchBehaviour(
    TAYGConfigRef config,
    bool useLegacyStretchBehaviour);

// TAYGConfig
WIN_EXPORT TAYGConfigRef TAYGConfigNew(void);
WIN_EXPORT void TAYGConfigFree(TAYGConfigRef config);
WIN_EXPORT void TAYGConfigCopy(TAYGConfigRef dest, TAYGConfigRef src);
WIN_EXPORT int32_t TAYGConfigGetInstanceCount(void);

WIN_EXPORT void TAYGConfigSetExperimentalFeatureEnabled(
    TAYGConfigRef config,
    TAYGExperimentalFeature feature,
    bool enabled);
WIN_EXPORT bool TAYGConfigIsExperimentalFeatureEnabledfaults(
    TAYGConfigRef config,
    TAYGExperimentalFeature feature);

// Using the web defaults is the preferred configuration for new projects. Usage
// of non web defaults should be considered as legacy.
WIN_EXPORT void TAYGConfigSetUseWebDefaults(TAYGConfigRef config, bool enabled);
WIN_EXPORT bool TAYGConfigGetUseWebDefaults(TAYGConfigRef config);

WIN_EXPORT void TAYGConfigSetCloneNodeFunc(
    TAYGConfigRef config,
    TAYGCloneNodeFunc callback);

// Export only for C#
WIN_EXPORT TAYGConfigRef TAYGConfigGetDefault(void);

WIN_EXPORT void TAYGConfigSetContext(TAYGConfigRef config, void* context);
WIN_EXPORT void* TAYGConfigGetContext(TAYGConfigRef config);

WIN_EXPORT float TAYGRoundValueToPixelGrid(
    double value,
    double pointScaleFactor,
    bool forceCeil,
    bool forceFloor);

TA_YG_EXTERN_C_END

#ifdef __cplusplus

#include <functional>
#include <vector>

// Calls f on each node in the tree including the given node argument.
void TAYGTraversePreOrder(
    TAYGNodeRef node,
    std::function<void(TAYGNodeRef node)>&& f);

void TAYGNodeSetChildren(TAYGNodeRef owner, const std::vector<TAYGNodeRef>& children);

#endif
