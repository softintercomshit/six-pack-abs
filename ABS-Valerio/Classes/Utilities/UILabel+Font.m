#import "UILabel+Font.h"

@implementation UILabel (Font)

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
        case Nike:
            [self setFontForName:@"NikeBebas" size:size];
        default:
//            [self setFontForName:@"BebasNeueRegular" size:size];
            break;
    }
}

-(void)setFontForName:(NSString *)fontName size:(CGFloat)size{
    [self setFont:[UIFont fontWithName:fontName size:size]];
}

@end
