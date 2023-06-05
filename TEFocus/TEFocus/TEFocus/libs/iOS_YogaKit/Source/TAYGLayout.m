
#import "UIView+TAYoga.h"
#import "TAYGLayout+Private.h"

#define TA_YG_PROPERTY(type, lowercased_name, capitalized_name)      \
  -(type)lowercased_name {                                        \
    return TAYGNodeStyleGet##capitalized_name(self.node);           \
  }                                                               \
                                                                  \
  -(void)set##capitalized_name : (type)lowercased_name {          \
    TAYGNodeStyleSet##capitalized_name(self.node, lowercased_name); \
  }

#define TA_YG_VALUE_PROPERTY(lowercased_name, capitalized_name)                \
  -(TAYGValue)lowercased_name {                                               \
    return TAYGNodeStyleGet##capitalized_name(self.node);                     \
  }                                                                         \
                                                                            \
  -(void)set##capitalized_name : (TAYGValue)lowercased_name {                 \
    switch (lowercased_name.unit) {                                         \
      case TAYGUnitUndefined:                                                 \
        TAYGNodeStyleSet##capitalized_name(self.node, lowercased_name.value); \
        break;                                                              \
      case TAYGUnitPoint:                                                     \
        TAYGNodeStyleSet##capitalized_name(self.node, lowercased_name.value); \
        break;                                                              \
      case TAYGUnitPercent:                                                   \
        TAYGNodeStyleSet##capitalized_name##Percent(                          \
            self.node, lowercased_name.value);                              \
        break;                                                              \
      default:                                                              \
        NSAssert(NO, @"Not implemented");                                   \
    }                                                                       \
  }

#define TA_YG_AUTO_VALUE_PROPERTY(lowercased_name, capitalized_name)           \
  -(TAYGValue)lowercased_name {                                               \
    return TAYGNodeStyleGet##capitalized_name(self.node);                     \
  }                                                                         \
                                                                            \
  -(void)set##capitalized_name : (TAYGValue)lowercased_name {                 \
    switch (lowercased_name.unit) {                                         \
      case TAYGUnitPoint:                                                     \
        TAYGNodeStyleSet##capitalized_name(self.node, lowercased_name.value); \
        break;                                                              \
      case TAYGUnitPercent:                                                   \
        TAYGNodeStyleSet##capitalized_name##Percent(                          \
            self.node, lowercased_name.value);                              \
        break;                                                              \
      case TAYGUnitAuto:                                                      \
        TAYGNodeStyleSet##capitalized_name##Auto(self.node);                  \
        break;                                                              \
      default:                                                              \
        NSAssert(NO, @"Not implemented");                                   \
    }                                                                       \
  }

#define TA_YG_EDGE_PROPERTY_GETTER(                             \
    type, lowercased_name, capitalized_name, property, edge) \
  -(type)lowercased_name {                                   \
    return TAYGNodeStyleGet##property(self.node, edge);        \
  }

#define TA_YG_EDGE_PROPERTY_SETTER(                                \
    lowercased_name, capitalized_name, property, edge)          \
  -(void)set##capitalized_name : (CGFloat)lowercased_name {     \
    TAYGNodeStyleSet##property(self.node, edge, lowercased_name); \
  }

#define TA_YG_EDGE_PROPERTY(lowercased_name, capitalized_name, property, edge) \
  TA_YG_EDGE_PROPERTY_GETTER(                                                  \
      CGFloat, lowercased_name, capitalized_name, property, edge)           \
  TA_YG_EDGE_PROPERTY_SETTER(lowercased_name, capitalized_name, property, edge)

#define TA_YG_VALUE_EDGE_PROPERTY_SETTER(                                       \
    objc_lowercased_name, objc_capitalized_name, c_name, edge)               \
  -(void)set##objc_capitalized_name : (TAYGValue)objc_lowercased_name {        \
    switch (objc_lowercased_name.unit) {                                     \
      case TAYGUnitUndefined:                                                  \
        TAYGNodeStyleSet##c_name(self.node, edge, objc_lowercased_name.value); \
        break;                                                               \
      case TAYGUnitPoint:                                                      \
        TAYGNodeStyleSet##c_name(self.node, edge, objc_lowercased_name.value); \
        break;                                                               \
      case TAYGUnitPercent:                                                    \
        TAYGNodeStyleSet##c_name##Percent(                                     \
            self.node, edge, objc_lowercased_name.value);                    \
        break;                                                               \
      default:                                                               \
        NSAssert(NO, @"Not implemented");                                    \
    }                                                                        \
  }

#define TA_YG_VALUE_EDGE_PROPERTY(                                   \
    lowercased_name, capitalized_name, property, edge)            \
  TA_YG_EDGE_PROPERTY_GETTER(                                        \
      TAYGValue, lowercased_name, capitalized_name, property, edge) \
  TA_YG_VALUE_EDGE_PROPERTY_SETTER(                                  \
      lowercased_name, capitalized_name, property, edge)

#define TA_YG_VALUE_EDGES_PROPERTIES(lowercased_name, capitalized_name) \
  TA_YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Left,                                         \
      capitalized_name##Left,                                        \
      capitalized_name,                                              \
      TAYGEdgeLeft)                                                    \
  TA_YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Top,                                          \
      capitalized_name##Top,                                         \
      capitalized_name,                                              \
      TAYGEdgeTop)                                                     \
  TA_YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Right,                                        \
      capitalized_name##Right,                                       \
      capitalized_name,                                              \
      TAYGEdgeRight)                                                   \
  TA_YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Bottom,                                       \
      capitalized_name##Bottom,                                      \
      capitalized_name,                                              \
      TAYGEdgeBottom)                                                  \
  TA_YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Start,                                        \
      capitalized_name##Start,                                       \
      capitalized_name,                                              \
      TAYGEdgeStart)                                                   \
  TA_YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##End,                                          \
      capitalized_name##End,                                         \
      capitalized_name,                                              \
      TAYGEdgeEnd)                                                     \
  TA_YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Horizontal,                                   \
      capitalized_name##Horizontal,                                  \
      capitalized_name,                                              \
      TAYGEdgeHorizontal)                                              \
  TA_YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Vertical,                                     \
      capitalized_name##Vertical,                                    \
      capitalized_name,                                              \
      TAYGEdgeVertical)                                                \
  TA_YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name, capitalized_name, capitalized_name, TAYGEdgeAll)

TAYGValue TAYGPointValue(CGFloat value) {
  return (TAYGValue){.value = value, .unit = TAYGUnitPoint};
}

TAYGValue TAYGPercentValue(CGFloat value) {
  return (TAYGValue){.value = value, .unit = TAYGUnitPercent};
}

static TAYGConfigRef globalConfig;

@interface TAYGLayout ()

@property(nonatomic, weak, readonly) UIView* view;
@property(nonatomic, assign, readonly) BOOL isUIView;

@end

@implementation TAYGLayout

@synthesize isEnabled = _isEnabled;
@synthesize isIncludedInLayout = _isIncludedInLayout;
@synthesize node = _node;

+ (void)initialize {
  globalConfig = TAYGConfigNew();
  TAYGConfigSetExperimentalFeatureEnabled(
      globalConfig, TAYGExperimentalFeatureWebFlexBasis, true);
  TAYGConfigSetPointScaleFactor(globalConfig, [UIScreen mainScreen].scale);
}

- (instancetype)initWithView:(UIView*)view {
  if (self = [super init]) {
    _view = view;
    _node = TAYGNodeNewWithConfig(globalConfig);
    TAYGNodeSetContext(_node, (__bridge void*)view);
    _isEnabled = NO;
    _isIncludedInLayout = YES;
    _isUIView = [view isMemberOfClass:[UIView class]];
  }

  return self;
}

- (void)dealloc {
  TAYGNodeFree(self.node);
}

- (BOOL)isDirty {
  return TAYGNodeIsDirty(self.node);
}

- (void)markDirty {
  if (self.isDirty || !self.isLeaf) {
    return;
  }

  // TAYoga is not happy if we try to mark a node as "dirty" before we have set
  // the measure function. Since we already know that this is a leaf,
  // this *should* be fine. Forgive me Hack Gods.
  const TAYGNodeRef node = self.node;
  if (!TAYGNodeHasMeasureFunc(node)) {
    TAYGNodeSetMeasureFunc(node, YGMeasureView);
  }

  TAYGNodeMarkDirty(node);
}

- (NSUInteger)numberOfChildren {
  return TAYGNodeGetChildCount(self.node);
}

- (BOOL)isLeaf {
  NSAssert(
      [NSThread isMainThread],
      @"This method must be called on the main thread.");
  if (self.isEnabled) {
    for (UIView* subview in self.view.subviews) {
      TAYGLayout* const ta_yoga = subview.ta_yoga;
      if (ta_yoga.isEnabled && ta_yoga.isIncludedInLayout) {
        return NO;
      }
    }
  }

  return YES;
}

#pragma mark - Style

- (TAYGPositionType)position {
  return TAYGNodeStyleGetPositionType(self.node);
}

- (void)setPosition:(TAYGPositionType)position {
  TAYGNodeStyleSetPositionType(self.node, position);
}

TA_YG_PROPERTY(TAYGDirection, direction, Direction)
TA_YG_PROPERTY(TAYGFlexDirection, flexDirection, FlexDirection)
TA_YG_PROPERTY(TAYGJustify, justifyContent, JustifyContent)
TA_YG_PROPERTY(TAYGAlign, alignContent, AlignContent)
TA_YG_PROPERTY(TAYGAlign, alignItems, AlignItems)
TA_YG_PROPERTY(TAYGAlign, alignSelf, AlignSelf)
TA_YG_PROPERTY(TAYGWrap, flexWrap, FlexWrap)
TA_YG_PROPERTY(TAYGOverflow, overflow, Overflow)
TA_YG_PROPERTY(TAYGDisplay, display, Display)

TA_YG_PROPERTY(CGFloat, flex, Flex)
TA_YG_PROPERTY(CGFloat, flexGrow, FlexGrow)
TA_YG_PROPERTY(CGFloat, flexShrink, FlexShrink)
TA_YG_AUTO_VALUE_PROPERTY(flexBasis, FlexBasis)

TA_YG_VALUE_EDGE_PROPERTY(left, Left, Position, TAYGEdgeLeft)
TA_YG_VALUE_EDGE_PROPERTY(top, Top, Position, TAYGEdgeTop)
TA_YG_VALUE_EDGE_PROPERTY(right, Right, Position, TAYGEdgeRight)
TA_YG_VALUE_EDGE_PROPERTY(bottom, Bottom, Position, TAYGEdgeBottom)
TA_YG_VALUE_EDGE_PROPERTY(start, Start, Position, TAYGEdgeStart)
TA_YG_VALUE_EDGE_PROPERTY(end, End, Position, TAYGEdgeEnd)
TA_YG_VALUE_EDGES_PROPERTIES(margin, Margin)
TA_YG_VALUE_EDGES_PROPERTIES(padding, Padding)

TA_YG_EDGE_PROPERTY(borderLeftWidth, BorderLeftWidth, Border, TAYGEdgeLeft)
TA_YG_EDGE_PROPERTY(borderTopWidth, BorderTopWidth, Border, TAYGEdgeTop)
TA_YG_EDGE_PROPERTY(borderRightWidth, BorderRightWidth, Border, TAYGEdgeRight)
TA_YG_EDGE_PROPERTY(borderBottomWidth, BorderBottomWidth, Border, TAYGEdgeBottom)
TA_YG_EDGE_PROPERTY(borderStartWidth, BorderStartWidth, Border, TAYGEdgeStart)
TA_YG_EDGE_PROPERTY(borderEndWidth, BorderEndWidth, Border, TAYGEdgeEnd)
TA_YG_EDGE_PROPERTY(borderWidth, BorderWidth, Border, TAYGEdgeAll)

TA_YG_AUTO_VALUE_PROPERTY(width, Width)
TA_YG_AUTO_VALUE_PROPERTY(height, Height)
TA_YG_VALUE_PROPERTY(minWidth, MinWidth)
TA_YG_VALUE_PROPERTY(minHeight, MinHeight)
TA_YG_VALUE_PROPERTY(maxWidth, MaxWidth)
TA_YG_VALUE_PROPERTY(maxHeight, MaxHeight)
TA_YG_PROPERTY(CGFloat, aspectRatio, AspectRatio)

#pragma mark - Layout and Sizing

- (TAYGDirection)resolvedDirection {
  return TAYGNodeLayoutGetDirection(self.node);
}

- (void)applyLayout {
  [self calculateLayoutWithSize:self.view.bounds.size];
  YGApplyLayoutToViewHierarchy(self.view, NO);
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin {
  [self calculateLayoutWithSize:self.view.bounds.size];
  YGApplyLayoutToViewHierarchy(self.view, preserveOrigin);
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin
               dimensionFlexibility:
                   (YGDimensionFlexibility)dimensionFlexibility {
  CGSize size = self.view.bounds.size;
  if (dimensionFlexibility & YGDimensionFlexibilityFlexibleWidth) {
    size.width = TAYGUndefined;
  }
  if (dimensionFlexibility & YGDimensionFlexibilityFlexibleHeight) {
    size.height = TAYGUndefined;
  }
  [self calculateLayoutWithSize:size];
  YGApplyLayoutToViewHierarchy(self.view, preserveOrigin);
}

- (CGSize)intrinsicSize {
  const CGSize constrainedSize = {
      .width = TAYGUndefined,
      .height = TAYGUndefined,
  };
  return [self calculateLayoutWithSize:constrainedSize];
}

- (CGSize)calculateLayoutWithSize:(CGSize)size {
  NSAssert([NSThread isMainThread], @"TAYoga calculation must be done on main.");
  NSAssert(self.isEnabled, @"TAYoga is not enabled for this view.");

  YGAttachNodesFromViewHierachy(self.view);

  const TAYGNodeRef node = self.node;
  TAYGNodeCalculateLayout(
      node, size.width, size.height, TAYGNodeStyleGetDirection(node));

  return (CGSize){
      .width = TAYGNodeLayoutGetWidth(node),
      .height = TAYGNodeLayoutGetHeight(node),
  };
}

#pragma mark - Private

static TAYGSize YGMeasureView(
    TAYGNodeRef node,
    float width,
    TAYGMeasureMode widthMode,
    float height,
    TAYGMeasureMode heightMode) {
  const CGFloat constrainedWidth =
      (widthMode == TAYGMeasureModeUndefined) ? CGFLOAT_MAX : width;
  const CGFloat constrainedHeight =
      (heightMode == TAYGMeasureModeUndefined) ? CGFLOAT_MAX : height;

  UIView* view = (__bridge UIView*)TAYGNodeGetContext(node);
  CGSize sizeThatFits = CGSizeZero;

  // The default implementation of sizeThatFits: returns the existing size of
  // the view. That means that if we want to layout an empty UIView, which
  // already has got a frame set, its measured size should be CGSizeZero, but
  // UIKit returns the existing size.
  //
  // See https://github.com/thinkingdatalayout/ta_yoga/issues/606 for more information.
  if (!view.ta_yoga.isUIView || [view.subviews count] > 0) {
    sizeThatFits = [view sizeThatFits:(CGSize){
                                          .width = constrainedWidth,
                                          .height = constrainedHeight,
                                      }];
  }

  return (TAYGSize){
      .width = YGSanitizeMeasurement(
          constrainedWidth, sizeThatFits.width, widthMode),
      .height = YGSanitizeMeasurement(
          constrainedHeight, sizeThatFits.height, heightMode),
  };
}

static CGFloat YGSanitizeMeasurement(
    CGFloat constrainedSize,
    CGFloat measuredSize,
    TAYGMeasureMode measureMode) {
  CGFloat result;
  if (measureMode == TAYGMeasureModeExactly) {
    result = constrainedSize;
  } else if (measureMode == TAYGMeasureModeAtMost) {
    result = MIN(constrainedSize, measuredSize);
  } else {
    result = measuredSize;
  }

  return result;
}

static BOOL YGNodeHasExactSameChildren(
    const TAYGNodeRef node,
    NSArray<UIView*>* subviews) {
  if (TAYGNodeGetChildCount(node) != subviews.count) {
    return NO;
  }

  for (int i = 0; i < subviews.count; i++) {
    if (TAYGNodeGetChild(node, i) != subviews[i].ta_yoga.node) {
      return NO;
    }
  }

  return YES;
}

static void YGAttachNodesFromViewHierachy(UIView* const view) {
  TAYGLayout* const ta_yoga = view.ta_yoga;
  const TAYGNodeRef node = ta_yoga.node;

  // Only leaf nodes should have a measure function
  if (ta_yoga.isLeaf) {
    YGRemoveAllChildren(node);
    TAYGNodeSetMeasureFunc(node, YGMeasureView);
  } else {
    TAYGNodeSetMeasureFunc(node, NULL);

    NSMutableArray<UIView*>* subviewsToInclude =
        [[NSMutableArray alloc] initWithCapacity:view.subviews.count];
    for (UIView* subview in view.subviews) {
      if (subview.ta_yoga.isEnabled && subview.ta_yoga.isIncludedInLayout) {
        [subviewsToInclude addObject:subview];
      }
    }

    if (!YGNodeHasExactSameChildren(node, subviewsToInclude)) {
      YGRemoveAllChildren(node);
      for (int i = 0; i < subviewsToInclude.count; i++) {
        TAYGNodeInsertChild(node, subviewsToInclude[i].ta_yoga.node, i);
      }
    }

    for (UIView* const subview in subviewsToInclude) {
      YGAttachNodesFromViewHierachy(subview);
    }
  }
}

static void YGRemoveAllChildren(const TAYGNodeRef node) {
  if (node == NULL) {
    return;
  }

  TAYGNodeRemoveAllChildren(node);
}

static CGFloat YGRoundPixelValue(CGFloat value) {
  static CGFloat scale;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^() {
    scale = [UIScreen mainScreen].scale;
  });

  return roundf(value * scale) / scale;
}

static void YGApplyLayoutToViewHierarchy(UIView* view, BOOL preserveOrigin) {
  NSCAssert(
      [NSThread isMainThread],
      @"Framesetting should only be done on the main thread.");

  const TAYGLayout* ta_yoga = view.ta_yoga;

  if (!ta_yoga.isIncludedInLayout) {
    return;
  }

  TAYGNodeRef node = ta_yoga.node;
  const CGPoint topLeft = {
      TAYGNodeLayoutGetLeft(node),
      TAYGNodeLayoutGetTop(node),
  };

  const CGPoint bottomRight = {
      topLeft.x + TAYGNodeLayoutGetWidth(node),
      topLeft.y + TAYGNodeLayoutGetHeight(node),
  };

  const CGPoint origin = preserveOrigin ? view.frame.origin : CGPointZero;
  view.frame = (CGRect){
      .origin =
          {
              .x = YGRoundPixelValue(topLeft.x + origin.x),
              .y = YGRoundPixelValue(topLeft.y + origin.y),
          },
      .size =
          {
              .width = YGRoundPixelValue(bottomRight.x) -
                  YGRoundPixelValue(topLeft.x),
              .height = YGRoundPixelValue(bottomRight.y) -
                  YGRoundPixelValue(topLeft.y),
          },
  };

  if (!ta_yoga.isLeaf) {
    for (NSUInteger i = 0; i < view.subviews.count; i++) {
      YGApplyLayoutToViewHierarchy(view.subviews[i], NO);
    }
  }
}

@end
