//
//  StockCell.m
//  StockHand
//
//  Created by yihl on 4/26/16.
//  Copyright © 2016 yihl. All rights reserved.
//

#import "StockCell.h"
@interface StockCell()

@end
@implementation StockCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

/*-(void)getDataFromDic:(NSDictionary *)NewsDic andIndex:(NSIndexPath *)index{
    NSLog(@"enter getDataFromDic");
    NSMutableArray *DicKeyArr = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DicKey" ofType:@"plist"]];
    NSMutableArray *TableTittleArr = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TableTittle" ofType:@"plist"]];
    if(![NewsDic[DicKeyArr[index.row]] isKindOfClass:[NSNumber class]]){
        _tittleLabel.text=TableTittleArr[index.row];
        _valueLabel.text=NewsDic[DicKeyArr[index.row]];
    }else{
        _tittleLabel.text=TableTittleArr[index.row];
        _valueLabel.text=@"no value";
    }
}*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
