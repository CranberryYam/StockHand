//
//  favorCell.h
//  StockHand
//
//  Created by yihl on 4/18/16.
//  Copyright © 2016 yihl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface favorCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *symbol;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *percent;
@property (strong, nonatomic) IBOutlet UILabel *cap;
@end
