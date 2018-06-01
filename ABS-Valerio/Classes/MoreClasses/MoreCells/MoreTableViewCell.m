#import "MoreTableViewCell.h"



@interface MoreTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;


@property (weak, nonatomic) IBOutlet UIImageView *filterImageView;

@property (nonatomic) CGSize iconImageViewSize;
@property (nonatomic) CGPoint iconImageViewCenter;

@property (weak, nonatomic) IBOutlet UIImageView *separatorImageView;

@end


@implementation MoreTableViewCell



-(void)awakeFromNib{
    [super awakeFromNib];
    _iconImageViewSize = _iconImageView.frame.size;
    _iconImageViewCenter = _iconImageView.center;
    
    [_titleLabel setBebasFontWithType:Bold size:isIpad? 27 : 20];
    [_descriptionLabel setBebasFontWithType:Regular size:isIpad? 18 : 15];
    
//    if(isIpad){
//        _titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:22];
//        _descriptionLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
//    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    _filterImageView.backgroundColor = highlighted ? [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:0.3] : [UIColor clearColor];
}


-(void)setMoreValues:(NSDictionary*)moreValuesDictionary{
    _iconImageView.image = [UIImage imageNamed:moreValuesDictionary[@"icon"]];
    _titleLabel.text = moreValuesDictionary[@"title"];
    NSString* description = moreValuesDictionary[@"description"];
    _descriptionLabel.text = description.length ? description : @"";
    if([moreValuesDictionary[@"small"] isEqualToNumber:@1]){
        _iconImageView.frame = CGRectMake(0, 0, 40, 40);
        _iconImageView.layer.cornerRadius = 0;
    }else{
        _iconImageView.frame = CGRectMake(0, 0, _iconImageViewSize.width, _iconImageViewSize.height);
        _iconImageView.layer.cornerRadius = _iconImageViewSize.width/2;
    }
    _iconImageView.center = _iconImageViewCenter;
    _separatorImageView.frame  = CGRectMake(_iconImageViewCenter.x + _iconImageView.frame.size.width/2 + 10, _separatorImageView.frame.origin.y, self.frame.size.width - (_iconImageView.frame.size.width/2 + _iconImageViewCenter.x + 25), 1/[UIScreen mainScreen].scale);
}


#pragma mark - IBActions


- (IBAction)contantValeriuMailButtonAction:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(mailContact)]){
        [_delegate mailContact];
    }
}


- (IBAction)contantValeriuFBButtonAction:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(fbContact)]){
        [_delegate fbContact];
    }
}


- (IBAction)contantValeriuInstagramlButtonAction:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(instagramContact)]){
        [_delegate instagramContact];
    }
}

- (IBAction)openWebSiteButton:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(openOffSite)]){
        [_delegate openOffSite];
    }
}

- (IBAction)followOnTwitterButton:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(twitterFollow)]){
        [_delegate twitterFollow];
    }
}
@end
