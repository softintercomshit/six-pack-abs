#import "UIButton+Font.h"

@implementation UIButton (Font)

-(void)setBebasFontWithType:(FontType)type size:(CGFloat)size{
    switch (type) {
        case Bold:
            [self setFontForName:@"BebasNeueBold" size:size];
            break;
        case Book:
            [self setFontForName:@"BebasNeueBook" size:size];
            break;
        case Light:
            [self setFontForName:@"BebasNeueLight" size:size];
            break;
        case Regular:
            [self setFontForName:@"BebasNeueRegular" size:size];
            break;
        case Thin:
            [self setFontForName:@"BebasNeueThin" size:size];
            break;
        default:
            [self setFontForName:@"BebasNeueRegular" size:size];
            break;
    }
}

-(void)setFontForName:(NSString *)fontName size:(CGFloat)size{
    [self.titleLabel setFont:[UIFont fontWithName:fontName size:size]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(-3, 0, 0, 0)];
    
    if (@available(iOS 11, *)) {
        [self setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
    }
}

@end
