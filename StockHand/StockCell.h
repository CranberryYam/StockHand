//
//  StockCell.h
//  StockHand
//
//  Created by yihl on 4/26/16.
//  Copyright © 2016 yihl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StockCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tittleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIButton *extraImage;
//-(void)getDataFromDic:(NSDictionary *)NewsDic andIndex:(NSIndexPath *)index;
@end
