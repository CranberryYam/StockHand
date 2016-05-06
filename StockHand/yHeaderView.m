//
//  yHeaderView.m
//  StockHand
//
//  Created by yihl on 4/27/16.
//  Copyright © 2016 yihl. All rights reserved.
//

#import "yHeaderView.h"
@interface yHeaderView()
- (IBAction)shareAction:(id)sender;
- (IBAction)addToFavorList:(id)sender;
@end
@implementation yHeaderView
+ (instancetype)headerView{
    return [[[NSBundle mainBundle] loadNibNamed:@"yHeaderView" owner:nil options:nil] lastObject];
}

- (IBAction)shareAction:(id)sender {
    if (self.shareButtonClick) {
        self.shareButtonClick();
    }
}

- (IBAction)addToFavorList:(id)sender {
    if (self.favlistButtonClick) {
        self.favlistButtonClick();
    }
}
@end
