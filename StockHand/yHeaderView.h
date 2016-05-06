//
//  yHeaderView.h
//  StockHand
//
//  Created by yihl on 4/27/16.
//  Copyright © 2016 yihl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface yHeaderView : UIView
+ (instancetype)headerView;
@property (nonatomic,copy) void(^shareButtonClick)();
@property (nonatomic,copy) void(^favlistButtonClick)();
@end
