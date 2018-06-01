#import "UINavigationBar+BebasFont.h"

@implementation UINavigationBar (BebasFont)

-(void)setBebasFont{
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                   NSFontAttributeName: [UIFont fontWithName:@"BebasNeueBold" size:29]}];
    
    [self setTitleVerticalPositionAdjustment:2 forBarMetrics:UIBarMetricsDefault];
}

-(void)setBebasFontWithSize:(CGFloat)size{
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                   NSFontAttributeName: [UIFont fontWithName:@"BebasNeueBold" size:size]}];
    
    [self setTitleVerticalPositionAdjustment:10 forBarMetrics:UIBarMetricsDefault];
}

-(void)setBebasFontWithSize:(CGFloat)size positionAdjustment:(CGFloat)positionAdjustment{
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                   NSFontAttributeName: [UIFont fontWithName:@"BebasNeueBold" size:size]}];
    [self setTitleVerticalPositionAdjustment:positionAdjustment forBarMetrics:UIBarMetricsDefault];
    
    [self setTitleVerticalPositionAdjustment:2 forBarMetrics:UIBarMetricsDefault];
}

@end
