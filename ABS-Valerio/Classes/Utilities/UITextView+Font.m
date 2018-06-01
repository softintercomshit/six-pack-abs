#import "UITextView+Font.h"

@implementation UITextView (Font)

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
    [self setFont:[UIFont fontWithName:fontName size:size]];
}

@end
