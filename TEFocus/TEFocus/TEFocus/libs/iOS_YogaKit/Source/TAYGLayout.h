
#import <UIKit/UIKit.h>
#import "TAYGEnums.h"
#import "TAYGMacros.h"
#import "TAYoga.h"

TA_YG_EXTERN_C_BEGIN

extern TAYGValue TAYGPointValue(CGFloat value) NS_SWIFT_UNAVAILABLE(
    "Use the swift Int and FloatingPoint extensions instead");
extern TAYGValue TAYGPercentValue(CGFloat value) NS_SWIFT_UNAVAILABLE(
    "Use the swift Int and FloatingPoint extensions instead");

TA_YG_EXTERN_C_END

typedef NS_OPTIONS(NSInteger, YGDimensionFlexibility) {
  YGDimensionFlexibilityFlexibleWidth = 1 << 0,
  YGDimensionFlexibilityFlexibleHeight = 1 << 1,
};

@interface TAYGLayout : NSObject

/**
 Make default init unavailable, as it will not initialise TAYGNode which is
 required for the setters and getters of YGLayout's properties to work properly.
*/
- (instancetype)init
    __attribute__((unavailable("you are not meant to initialise TAYGLayout")));

/**
 Make default init unavailable, as it will not initialise TAYGNode which is
 required for the setters and getters of YGLayout's properties to work properly.
 */
+ (instancetype)new
    __attribute__((unavailable("you are not meant to initialise TAYGLayout")));

/**
  The property that decides if we should include this view when calculating
  layout. Defaults to YES.
 */
@property(nonatomic, readwrite, assign, setter=setIncludedInLayout:)
    BOOL isIncludedInLayout;

/**
 The property that decides during layout/sizing whether or not styling
 properties should be applied. Defaults to NO.
 */
@property(nonatomic, readwrite, assign, setter=setEnabled:) BOOL isEnabled;

@property(nonatomic, readwrite, assign) TAYGDirection direction;
@property(nonatomic, readwrite, assign) TAYGFlexDirection flexDirection;
@property(nonatomic, readwrite, assign) TAYGJustify justifyContent;
@property(nonatomic, readwrite, assign) TAYGAlign alignContent;
@property(nonatomic, readwrite, assign) TAYGAlign alignItems;
@property(nonatomic, readwrite, assign) TAYGAlign alignSelf;
@property(nonatomic, readwrite, assign) TAYGPositionType position;
@property(nonatomic, readwrite, assign) TAYGWrap flexWrap;
@property(nonatomic, readwrite, assign) TAYGOverflow overflow;
@property(nonatomic, readwrite, assign) TAYGDisplay display;

@property(nonatomic, readwrite, assign) CGFloat flex;
@property(nonatomic, readwrite, assign) CGFloat flexGrow;
@property(nonatomic, readwrite, assign) CGFloat flexShrink;
@property(nonatomic, readwrite, assign) TAYGValue flexBasis;

@property(nonatomic, readwrite, assign) TAYGValue left;
@property(nonatomic, readwrite, assign) TAYGValue top;
@property(nonatomic, readwrite, assign) TAYGValue right;
@property(nonatomic, readwrite, assign) TAYGValue bottom;
@property(nonatomic, readwrite, assign) TAYGValue start;
@property(nonatomic, readwrite, assign) TAYGValue end;

@property(nonatomic, readwrite, assign) TAYGValue marginLeft;
@property(nonatomic, readwrite, assign) TAYGValue marginTop;
@property(nonatomic, readwrite, assign) TAYGValue marginRight;
@property(nonatomic, readwrite, assign) TAYGValue marginBottom;
@property(nonatomic, readwrite, assign) TAYGValue marginStart;
@property(nonatomic, readwrite, assign) TAYGValue marginEnd;
@property(nonatomic, readwrite, assign) TAYGValue marginHorizontal;
@property(nonatomic, readwrite, assign) TAYGValue marginVertical;
@property(nonatomic, readwrite, assign) TAYGValue margin;

@property(nonatomic, readwrite, assign) TAYGValue paddingLeft;
@property(nonatomic, readwrite, assign) TAYGValue paddingTop;
@property(nonatomic, readwrite, assign) TAYGValue paddingRight;
@property(nonatomic, readwrite, assign) TAYGValue paddingBottom;
@property(nonatomic, readwrite, assign) TAYGValue paddingStart;
@property(nonatomic, readwrite, assign) TAYGValue paddingEnd;
@property(nonatomic, readwrite, assign) TAYGValue paddingHorizontal;
@property(nonatomic, readwrite, assign) TAYGValue paddingVertical;
@property(nonatomic, readwrite, assign) TAYGValue padding;

@property(nonatomic, readwrite, assign) CGFloat borderLeftWidth;
@property(nonatomic, readwrite, assign) CGFloat borderTopWidth;
@property(nonatomic, readwrite, assign) CGFloat borderRightWidth;
@property(nonatomic, readwrite, assign) CGFloat borderBottomWidth;
@property(nonatomic, readwrite, assign) CGFloat borderStartWidth;
@property(nonatomic, readwrite, assign) CGFloat borderEndWidth;
@property(nonatomic, readwrite, assign) CGFloat borderWidth;

@property(nonatomic, readwrite, assign) TAYGValue width;
@property(nonatomic, readwrite, assign) TAYGValue height;
@property(nonatomic, readwrite, assign) TAYGValue minWidth;
@property(nonatomic, readwrite, assign) TAYGValue minHeight;
@property(nonatomic, readwrite, assign) TAYGValue maxWidth;
@property(nonatomic, readwrite, assign) TAYGValue maxHeight;

// TAYoga specific properties, not compatible with flexbox specification
@property(nonatomic, readwrite, assign) CGFloat aspectRatio;

/**
 Get the resolved direction of this node. This won't be TAYGDirectionInherit
 */
@property(nonatomic, readonly, assign) TAYGDirection resolvedDirection;

/**
 Perform a layout calculation and update the frames of the views in the
 hierarchy with the results. If the origin is not preserved, the root view's
 layout results will applied from {0,0}.
 */
- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin
    NS_SWIFT_NAME(applyLayout(preservingOrigin:));

/**
 Perform a layout calculation and update the frames of the views in the
 hierarchy with the results. If the origin is not preserved, the root view's
 layout results will applied from {0,0}.
 */
- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin
               dimensionFlexibility:(YGDimensionFlexibility)dimensionFlexibility
    NS_SWIFT_NAME(applyLayout(preservingOrigin:dimensionFlexibility:));

/**
 Returns the size of the view if no constraints were given. This could
 equivalent to calling [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
 */
@property(nonatomic, readonly, assign) CGSize intrinsicSize;

/**
  Returns the size of the view based on provided constraints. Pass NaN for an
  unconstrained dimension.
 */
- (CGSize)calculateLayoutWithSize:(CGSize)size
    NS_SWIFT_NAME(calculateLayout(with:));

/**
 Returns the number of children that are using Flexbox.
 */
@property(nonatomic, readonly, assign) NSUInteger numberOfChildren;

/**
 Return a BOOL indiciating whether or not we this node contains any subviews
 that are included in Yoga's layout.
 */
@property(nonatomic, readonly, assign) BOOL isLeaf;

/**
 Return's a BOOL indicating if a view is dirty. When a node is dirty
 it usually indicates that it will be remeasured on the next layout pass.
 */
@property(nonatomic, readonly, assign) BOOL isDirty;

/**
 Mark that a view's layout needs to be recalculated. Only works for leaf views.
 */
- (void)markDirty;

@end
