//
//  AutoComplete.m
//  StockHand
//
//  Created by yihl on 4/23/16.
//  Copyright © 2016 yihl. All rights reserved.
//
#import "YQL.h"
#import "AutoComplete.h"
@interface AutoComplete () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray* arrDict;
@property (nonatomic, weak) UITableView* tableView;
@property (strong, nonatomic) YQL *yql;
@property (strong, nonatomic) NSArray *lookupResult;
@end
@implementation AutoComplete

-(id)initWithFrame:(CGRect)frame{
     if (self = [super initWithFrame:frame]){
         //NSLog(@"enter initWithFrame");
     }
        return self;
}
-(void)setupTableview{
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView = tableView;
    [self addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.separatorStyle = 0;
    //NSLog(@"enter setupTableview");
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"picksFromAutoCom" object:_lookupResult[indexPath.row][@"Symbol"]];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"textFieldResignFirstResponder" object:nil];
    [self removeFromSuperview];
}
#pragma mark - http post
-(void)loopUpwithArray:(NSArray *)array{
    _lookupResult = array;
     [self setupTableview];
}
#pragma mark - table view delegate method
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _lookupResult.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    static NSString* ID = @"autoCom";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = self.lookupResult[indexPath.row][@"Name"];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ Exch:%@",self.lookupResult[indexPath.row][@"Symbol"],self.lookupResult[indexPath.row][@"Exchange"]];
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

@end
