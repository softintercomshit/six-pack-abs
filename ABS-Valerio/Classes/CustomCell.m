#import "CustomCell.h"
#import "GuideAppDelegate.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)
@implementation CustomCell


-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if(self.selectionStyle == UITableViewCellSelectionStyleNone){
        _filterImageView.backgroundColor = highlighted ? [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:0.3] : [UIColor clearColor];
    }
}


-(void)awakeFromNib{
    [super awakeFromNib];
    if(self.selectionStyle == UITableViewCellSelectionStyleDefault){
        UIView * selectedBackgroundView = [[UIView alloc] init];
        //(252,252,252)
        [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:0.3]];
        [self setSelectedBackgroundView:selectedBackgroundView];
    }
    
    _cellSeparator.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    _cellSeparator.frame = CGRectMake(_cellSeparator.frame.origin.x, _cellSeparator.frame.origin.y, _cellSeparator.frame.size.width, 1.0 / [UIScreen mainScreen].scale);

    [_titleLabel setBebasFontWithType:Bold size:isIpad? 27 : 23];
    [_detailedLabel setBebasFontWithType:Regular size:isIpad? 17 : 14];
    [_titleLabel setTextColor:RGBA(65, 62, 62, 1)];
    [_detailedLabel setTextColor:RGBA(151, 151, 151, 1)];
    [self setAccessoryType:UITableViewCellAccessoryNone];
//    if(isIpad){
//        _titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:23];
//        _detailedLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
//    }
}


@end
