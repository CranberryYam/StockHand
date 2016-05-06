//
//  yButton.m
//  StockHand
//
//  Created by yihl on 4/23/16.
//  Copyright © 2016 yihl. All rights reserved.
//

#import "yButton.h"

@implementation yButton

-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        //NSLog(@"enter initWithFrame");
        [self setupUI];
    }
    return self;
}
-(void)setupUI{
    [self setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blueColor] setFill];
    CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    UIImage*     image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:image forState:UIControlStateDisabled];
    self.layer.cornerRadius=6;
    self.clipsToBounds=YES;
}
@end
