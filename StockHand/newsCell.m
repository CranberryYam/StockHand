//
//  newsCell.m
//  StockHand
//
//  Created by yihl on 4/30/16.
//  Copyright © 2016 yihl. All rights reserved.
//

#import "newsCell.h"
@interface newsCell()
@property (weak, nonatomic) IBOutlet UILabel *tittle;
@property (weak, nonatomic) IBOutlet UILabel *describtion;
@property (weak, nonatomic) IBOutlet UILabel *origin;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
@implementation newsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)getDataFromDic:(NSDictionary *)NewsDic{
    _tittle.text=[self changeTitleFormart:NewsDic[@"title"]];
    _describtion.text=[self convertHTML:NewsDic[@"description"]];
    _origin.text=[self changeOringeFormart:NewsDic[@"title"]];
    //_origin.text=@"title";
    _date.text=[self changeTimestampFormat:NewsDic];
}
#pragma mark html text converts into plain text
-(NSString *)convertHTML:(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&#39;"] withString:@""];
    return html;
}
#pragma mark - title Formart change
-(NSString *)changeTitleFormart:(NSString *)string{
    NSRange rang =[string rangeOfString:@"-"];
    NSInteger location = rang.location;
    return [string substringWithRange:NSMakeRange(0, location-1)];
}
-(NSString *)changeOringeFormart:(NSString *)string{
    NSRange rang =[string rangeOfString:@"-"];
    NSInteger location = rang.location;
    NSUInteger len = [string length];
    return [string substringWithRange:NSMakeRange(location+2, len-location-2)];
}
#pragma mark - TimeFormart change
-(NSString *)changeTimestampFormat:(NSDictionary *)NewsDic{
    NSMutableArray *locationArr=[[NSMutableArray alloc]init];
    NSString *someString = NewsDic[@"pubDate"];
    NSUInteger len = [someString length];
    unichar buffer[len+1];
    [someString getCharacters:buffer range:NSMakeRange(0, len)];
    
    for(int i = 0; i < len; ++i) {
        char current = buffer[i];
        // NSString* currentString = [NSString stringWithFormat:@"%c" , current];
        if (current == ' ') {
            NSNumber *number=[NSNumber numberWithInt:i];
            [locationArr addObject:number];
        }
    }
    NSString *Date = [someString substringWithRange:NSMakeRange([locationArr[0] intValue]+1,2)];
    NSString *Year = [someString substringWithRange:NSMakeRange([locationArr[2] intValue]+1,4)];
        NSString *Month = [someString substringWithRange:NSMakeRange([locationArr[1] intValue]+1,3)];
    NSString *Time = [someString substringWithRange:NSMakeRange([locationArr[3] intValue]+1, 5)];

    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM"];
    NSDate *aDate = [formatter dateFromString:Month];
    NSInteger month = [[NSCalendar currentCalendar] component:NSCalendarUnitMonth fromDate:aDate];
    Month = [NSString stringWithFormat: @"%ld", (long)month];
    
        NSString *timeFormarted=[NSString stringWithFormat:@"%@-%@-%@ %@",Year,Month,Date,Time];
    NSLog(@"timeFormarted is %@",timeFormarted);
    return timeFormarted;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
 
    // Configure the view for the selected state
}

@end
