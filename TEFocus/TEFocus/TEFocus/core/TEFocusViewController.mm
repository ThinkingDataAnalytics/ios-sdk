//
//  TEFocusViewController.m
//  teviewtemplate
//
//  Created by Charles on 29.11.22.
//

#import "TEFocusViewController.h"
#import "TETempMode.h"
#import "TEViewNode.h"
#import "TENodeAttr.h"
#import "UIView+TAYoga.h"
#import "TAYGEnums.h"
#import "UIColor+TEHexColor.h"
#import "UIImageView+TEWebImage.h"
#import "TADisplayConfig.h"
#import <objc/runtime.h>

#define TE_UI_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define TE_UI_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface TEFocusViewController ()

@property(nonatomic, strong, readwrite) TETempMode *tempNode;
@property(nonatomic, assign, readwrite) BOOL mantleCloseEnabled;
@property(nonatomic, weak) TADisplayConfig *config;

@end

@implementation TEFocusViewController

- (instancetype)initWithNode:(TETempMode *)node config:(TADisplayConfig *)config
{
    self = [super init];
    if (self) {
        self.tempNode = node;
        self.config = config;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.view.backgroundColor = [UIColor clearColor];
    
    _mantleCloseEnabled = self.tempNode.mantleCloseEnabled;
    
    UIView *mantleView = [[UIView alloc] initWithFrame:self.view.bounds];
    mantleView.backgroundColor = [UIColor te_colorWithHexString:self.tempNode.mantleColor];
    [self.view addSubview:mantleView];
    
    UIView *taContentView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:taContentView];
    [self configureViewTree:self.tempNode.node superView:taContentView isOuterView:true];
    [taContentView configureLayoutWithBlock:^(TAYGLayout * layout) {
        layout.isEnabled = YES;
        layout.flex = 1;
        layout.flexDirection = TAYGFlexDirectionRow;
        layout.justifyContent = TAYGJustifyCenter;
        layout.marginTop = TAYGPointValue([self getNavigationTopHeight:self.tempNode.node]);
        //        layout.alignItems = TAYGAlignCenter;
        // 默认水平方向是主轴，内部元素都是居中显示
    }];
    //    UIView* view = [[UIView alloc]init];
    //    view.backgroundColor = [UIColor blueColor];
    //    [view configureLayoutWithBlock:^(TAYGLayout * _Nonnull layout) {
    //        layout.isEnabled = YES;
    //        layout.width = TAYGPointValue(100);
    //        layout.height = TAYGPointValue(100);
    //    }];
    //    [taContentView addSubview:view];
    
    [taContentView.ta_yoga applyLayoutPreservingOrigin:YES];
    
    if (self.config.loadSuccess) {
        self.config.loadSuccess();
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (_mantleCloseEnabled) {
        [self closePage];
    }
}

- (void)closePage {
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.config.close) {
        self.config.close();
    }
}

- (void)updateLayout:(TAYGLayout *)layout item:(TEViewNode *)node {
    layout.isEnabled = YES;
    if(node.layoutProperties[@"flexDirection"]){
        layout.flexDirection = [self getFlexDirection:node];
    }
    layout.flexDirection = [self getFlexDirection:node];
    if ([self getHeiget:node] != 0) {
        layout.height = TAYGPointValue([self getHeiget:node]);
    }
    if ([self getWidth:node] != 0) {
        layout.width = TAYGPointValue([self getWidth:node]);
    }
    if(node.layoutProperties[@"alignSelf"]){
        layout.alignSelf = [self getAlignSelf:node];
    }
    if(node.layoutProperties[@"justifyContent"]){
        layout.justifyContent = [self getJustifyContent:node];
    }
    if(node.layoutProperties[@"alignItems"]){
        layout.alignItems = [self getAlignItems:node];
    }
    [self setLayoutPadding:layout item:node];
    [self setLayoutMargin:layout item:node];
}

static char TD_FOCUS_BUTTON_ID;
static char TD_FOCUS_IMAGE_ID;
- (void)configureViewTree:(TEViewNode *)node superView:(UIView *)superView isOuterView:(BOOL)isOuterView{
    
    if ([node.viewClassName isEqualToString:@"container"]) {
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = [self getViewBGColor:node];
        [superView addSubview:contentView];
        [contentView configureLayoutWithBlock:^(TAYGLayout * layout) {
            [self updateLayout:layout item:node];
        }];
        if(isOuterView){
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentClick:)];
            [contentView addGestureRecognizer:tapGesture];
            UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentClick:)];
            [contentView addGestureRecognizer:panGesture];
        }
        for (TEViewNode *item in node.children) {
            //[self configureViewTree:item superView:contentView];
            [self configureViewTree:item superView:contentView isOuterView:false];
        };
        [self setCorner:node view:contentView];
    } else if ([node.viewClassName isEqualToString:@"image"]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [superView addSubview:imageView];
        [imageView configureLayoutWithBlock:^(TAYGLayout * _Nonnull layout) {
            [self updateLayout:layout item:node];
        }];
        if ([self getLocalImage:node]) {
            imageView.image = [self getLocalImage:node];
        }
        if ([self getImageURl:node]) {
            [imageView te_setImageWithURL:[NSURL URLWithString:[self getImageURl:node]] options:TEWebImageOptionProgressive];
            //            [imageView sd_setImageWithURL:[NSURL URLWithString:[self getImageURl:node]]];
        }
        if([self hasClickAction:node]){
            objc_setAssociatedObject(imageView, &TD_FOCUS_IMAGE_ID, node, OBJC_ASSOCIATION_RETAIN);
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:tapGesture];
        }
        [self setCorner:node view:imageView];
    } else if ([node.viewClassName isEqualToString:@"text"]) {
        UILabel *textlable = [[UILabel alloc] init];
        textlable.numberOfLines = 2;
        
        [superView addSubview:textlable];
        [textlable configureLayoutWithBlock:^(TAYGLayout * _Nonnull layout) {
            [self updateLayout:layout item:node];
            //layout.alignSelf = TAYGAlignStretch;
        }];
        textlable.text = [self getText:node];
        textlable.font = [self getTextFont:node];
        textlable.textColor = [self getTextColor:node];
        textlable.textAlignment = [self getTextAlignment:node];
        //[self setCorner:node view:textlable];
        
    } else if ([node.viewClassName isEqualToString:@"button"]) {
        UIButton *button = [[UIButton alloc] init];
        [superView addSubview:button];
        [button configureLayoutWithBlock:^(TAYGLayout * _Nonnull layout) {
            [self updateLayout:layout item:node];
        }];
        [button setTitle:[self getText:node] forState:UIControlStateNormal];
        [button setTitleColor:[self getTextColor:node] forState:UIControlStateNormal];
        [button setBackgroundColor:[self getViewBGColor:node]];
        button.titleLabel.font =[self getTextFont:node];
        objc_setAssociatedObject(button, &TD_FOCUS_BUTTON_ID, node, OBJC_ASSOCIATION_RETAIN);
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self setCorner:node view:button];
    }
}

- (void)setLayoutPadding:(TAYGLayout *)layout item:(TEViewNode *)item {
    if(item.layoutProperties[@"paddingLeft"]){
        layout.paddingLeft = TAYGPointValue([self getSize:item.layoutProperties[@"paddingLeft"]]);
    }
    if(item.layoutProperties[@"paddingTop"]){
        layout.paddingTop = TAYGPointValue([self getSize:item.layoutProperties[@"paddingTop"]]);
    }
    if(item.layoutProperties[@"paddingRight"]){
        layout.paddingRight = TAYGPointValue([self getSize:item.layoutProperties[@"paddingRight"]]);
    }
    if(item.layoutProperties[@"paddingBottom"]){
        layout.paddingBottom = TAYGPointValue([self getSize:item.layoutProperties[@"paddingBottom"]]);
    }
}

- (void)setLayoutMargin:(TAYGLayout *)layout item:(TEViewNode *)item {
    if(item.layoutProperties[@"marginLeft"]){
        layout.marginLeft = TAYGPointValue([self getSize:item.layoutProperties[@"marginLeft"]]);
    }
    if(item.layoutProperties[@"marginTop"]){
        layout.marginTop = TAYGPointValue([self getSize:item.layoutProperties[@"marginTop"]]);
    }
    if(item.layoutProperties[@"marginRight"]){
        layout.marginRight = TAYGPointValue([self getSize:item.layoutProperties[@"marginRight"]]);
    }
    if(item.layoutProperties[@"marginBottom"]){
        layout.marginBottom = TAYGPointValue([self getSize:item.layoutProperties[@"marginBottom"]]);
    }
}


- (NSString *)getOrientation:(TEViewNode *)node {
    if(node.layoutProperties[@"flexDirection"]){
        return node.layoutProperties[@"flexDirection"];
    }
    return @"";
}

- (double)getHeiget:(TEViewNode *)node {

    NSString *value = @"";
    if(node.layoutProperties[@"height"]){
        value = [node.layoutProperties[@"height"] stringByReplacingOccurrencesOfString:@"px" withString:@""];
    }
    return value.doubleValue * [self getScale];
}

- (double)getScale{
    int f = 300;
    float w = [UIScreen mainScreen].bounds.size.width;
    float h = [UIScreen mainScreen].bounds.size.height;
    double scale = 1.0;
    if(w > h){
        //横屏
        scale = h*1.0/f;
    }else{
        //竖屏
        scale = w*1.0/f;
    }
    NSLog(@"%f",scale);
    return scale;
}

- (double)getWidth:(TEViewNode *)node {
    NSString *value = @"";
    if(node.layoutProperties[@"width"]){
        value = [node.layoutProperties[@"width"] stringByReplacingOccurrencesOfString:@"px" withString:@""];
    }
    return value.doubleValue *[self getScale];
}

//- (NSDictionary<NSString *, NSNumber *> *)getMargin:(TEViewNode *)node {
//    NSMutableDictionary<NSString *,NSNumber *> *value = [NSMutableDictionary dictionaryWithCapacity:4];
//    for (TENodeAttr *nodeAttr in [node layoutParams]) {
//        if (nodeAttr.isValid && [nodeAttr.name isEqualToString:@"margin"]) {
//            for (NSString *string in ((NSDictionary *)nodeAttr.value).allKeys) {
//                NSString *size = ((NSDictionary *)nodeAttr.value)[string];
//                size = [size stringByReplacingOccurrencesOfString:@"px" withString:@""];
//                [value setObject:[NSNumber numberWithDouble:size.doubleValue] forKey:string];
//            }
//            break;
//        }
//    }
//    return value;
//}

- (double) getSize:(NSString*)size{
    if(size){
        NSString* px = [size stringByReplacingOccurrencesOfString:@"px" withString:@""];
        return px.doubleValue;
    }else{
        return 0;
    }
}

//- (NSDictionary<NSString *, NSNumber *> *)getPadding:(TEViewNode *)node {
//    NSMutableDictionary<NSString *,NSNumber *> *value = [NSMutableDictionary dictionaryWithCapacity:4];
//    for (TENodeAttr *nodeAttr in [node layoutParams]) {
//        if (nodeAttr.isValid && [nodeAttr.name isEqualToString:@"padding"]) {
//            for (NSString *string in ((NSDictionary *)nodeAttr.value).allKeys) {
//                NSString *size = ((NSDictionary *)nodeAttr.value)[string];
//                size = [size stringByReplacingOccurrencesOfString:@"px" withString:@""];
//                [value setObject:[NSNumber numberWithDouble:size.doubleValue] forKey:string];
//            }
//            break;
//        }
//    }
//    return value;
//}


- (nullable UIImage *)getLocalImage:(TEViewNode *)node {
    return [UIImage imageNamed:node.layoutProperties[@"localImage"]];
}

- (nullable NSString *)getImageURl:(TEViewNode *)node {
    return node.layoutProperties[@"url"];
}

- (TAYGAlign)getAlignSelf:(TEViewNode *)node {
    TAYGAlign alignSelf = TAYGAlignFlexStart;
    NSString* align = node.layoutProperties[@"alignSelf"];
    if(align){
        if([align isEqualToString:@"flex-start"]){
            alignSelf = TAYGAlignFlexStart;
        }else if([align isEqualToString:@"center"]){
            alignSelf = TAYGAlignCenter;
        }else if([align isEqualToString:@"flex-end"]){
            alignSelf = TAYGAlignFlexEnd;
        }
    }
    return alignSelf;
}

- (TAYGJustify)getJustifyContent:(TEViewNode *)node {
    TAYGJustify justifyContent = TAYGJustifyFlexStart;
    NSString* justify = node.layoutProperties[@"justifyContent"];
    if(justify){
        if([justify isEqualToString:@"flex-start"]){
            justifyContent = TAYGJustifyFlexStart;
        }else if([justify isEqualToString:@"center"]){
            justifyContent = TAYGJustifyCenter;
        }else if([justify isEqualToString:@"flex-end"]){
            justifyContent = TAYGJustifyFlexEnd;
        }
    }
    return justifyContent;
}

- (TAYGAlign)getAlignItems:(TEViewNode *)node {
    TAYGAlign alignItems = TAYGAlignFlexStart;
    NSString* align = node.layoutProperties[@"alignItems"];
    if(align){
        if([align isEqualToString:@"flex-start"]){
            alignItems = TAYGAlignFlexStart;
        }else if([align isEqualToString:@"center"]){
            alignItems = TAYGAlignCenter;
        }else if([align isEqualToString:@"flex-end"]){
            alignItems = TAYGAlignFlexEnd;
        }
    }
    return alignItems;
}


- (TAYGFlexDirection)getFlexDirection:(TEViewNode *)node {
    TAYGFlexDirection flexDirection = TAYGFlexDirectionColumn;
    flexDirection = [[self getOrientation:node] isEqualToString:@"row"] ?  TAYGFlexDirectionRow : TAYGFlexDirectionColumn;;
    return flexDirection;
}

- (NSTextAlignment)getTextAlignment:(TEViewNode *)node {
    NSTextAlignment  alignment = NSTextAlignmentCenter;
    NSString* align = node.layoutProperties[@"textAlign"];
    if(align){
        if([align isEqualToString:@"left"]){
            alignment = NSTextAlignmentLeft;
        }else if([align isEqualToString:@"right"]){
            alignment = NSTextAlignmentRight;
        }else if([align isEqualToString:@"center"]){
            alignment = NSTextAlignmentCenter;
        }
    }
    return alignment;
}

- (NSString *)getText:(TEViewNode *)node {
    return node.layoutProperties[@"text"];
}

- (UIFont *)getTextFont:(TEViewNode *)node {
    UIFont * textfont = [UIFont systemFontOfSize:14];
    if(node.layoutProperties[@"fontSize"]){
        textfont = [UIFont systemFontOfSize:[self getSize:node.layoutProperties[@"fontSize"]]];
    }
    return textfont;
}

- (UIColor *)getTextColor:(TEViewNode *)node {
    UIColor * textColor = [UIColor grayColor];
    if(node.layoutProperties[@"textColor"]){
        textColor = [UIColor te_colorWithHexString:node.layoutProperties[@"textColor"]];
    }
    return textColor;
}

- (UIColor *)getViewBGColor:(TEViewNode *)node {
    UIColor * textColor = [UIColor clearColor];
    if(node.layoutProperties[@"backgroundColor"]){
        textColor = [UIColor te_colorWithHexString:node.layoutProperties[@"backgroundColor"]];
    }
    return textColor;
}

- (CGFloat )getNavigationTopHeight:(TEViewNode *)node {
    CGFloat heigt = 0;
//    for (TENodeAttr *nodeAttr in [node layoutParams]) {
//        if ([nodeAttr.name isEqualToString:@"navigationTop"]) {
//            if (@available(iOS 11.0, *)) {
//                heigt = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;//44
//                } else {
//                    heigt = 0.0;
//                }
//            break;
//        }
//    }
    if(node.layoutProperties[@"navigationTop"]){
        if (@available(iOS 11.0, *)) {
            heigt = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;//44
            } else {
                heigt = 0.0;
            }
    }
    return heigt;
}

- (void)setCorner:(TEViewNode *)node view:(UIView *)view {
    double corner = 0;
    if([node.layoutProperties[@"corner"] isKindOfClass:[NSString class]]){
        NSString *size = node.layoutProperties[@"corner"];
        corner = [self getSize:size];
    }else if([node.layoutProperties[@"corner"] isKindOfClass:[NSArray class]]){
        NSArray *sizes = node.layoutProperties[@"corner"];
        corner = [self getSize:sizes.firstObject];
    }
    view.layer.cornerRadius = corner;
    view.layer.masksToBounds = YES;
}

- (ThinkingActionModel *)getActionNodeAttr:(TEViewNode *)node {
    ThinkingActionModel *model = [[ThinkingActionModel alloc] init];
    [node.viewAttrs enumerateObjectsUsingBlock:^(TENodeAttr * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:@"type"]) {
            if ([obj.value isEqualToString:@"copy"]) {
                model.type = ThinkingActionModelTypeCopy;
            }
            if ([obj.value isEqualToString:@"openLink"]) {
                model.type = ThinkingActionModelTypeOpenLink;
            }
        }
        
        if ([obj.name isEqualToString:@"value"]) {
            model.value = obj.value;
        }
    }];
    return model;
}

- (void)buttonClick:(UIButton *)btn {
    TEViewNode *node = (TEViewNode *)objc_getAssociatedObject(btn, &TD_FOCUS_BUTTON_ID);
    if (node) {
        ThinkingActionModel *model = [self getActionNodeAttr:node];
        if (self.config.actionModel) {
            self.config.actionModel(model);
        }
    }
    [self closePage];
}

- (void)contentClick:(UIView*)view{
    
}

- (void)imageClick:(UITapGestureRecognizer*)tap{
    TEViewNode *node = (TEViewNode *)objc_getAssociatedObject([tap view], &TD_FOCUS_IMAGE_ID);
    if (node) {
        ThinkingActionModel *model = [self getActionNodeAttr:node];
        if (self.config.actionModel) {
            self.config.actionModel(model);
        }
    }
    [self closePage];
}

/**
 action中如果有type 就说明有点击行为
 */
- (BOOL) hasClickAction:(TEViewNode *)node{
    BOOL flag = NO;
    if([node.viewAttrs count]>0){
        for (TENodeAttr* attr in node.viewAttrs) {
            if([attr.name isEqualToString:@"type"]){
                flag = YES;
                return flag;
            }
        }
    }
    return flag;
}

@end
