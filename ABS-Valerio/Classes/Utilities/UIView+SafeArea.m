#import "UIView+SafeArea.h"


@implementation UIView (SafeArea)

-(void) addToSafeArea {
    if (@available(iOS 11, *)) {
        self.translatesAutoresizingMaskIntoConstraints = false;
        UILayoutGuide *margins = self.superview.layoutMarginsGuide;
        
        [NSLayoutConstraint activateConstraints: @[[self.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor],
                                                   [self.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor]]];
        
        UILayoutGuide *guide = self.superview.safeAreaLayoutGuide;
        [NSLayoutConstraint activateConstraints: @[[self.topAnchor constraintEqualToSystemSpacingBelowAnchor:guide.topAnchor multiplier:1.0],
                                                   [guide.bottomAnchor constraintEqualToSystemSpacingBelowAnchor:self.bottomAnchor multiplier:1.0]]];
    }
}

@end
