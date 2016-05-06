//
//  SearcheView.m
//  StockHand
//
//  Created by yihl on 4/17/16.
//  Copyright © 2016 yihl. All rights reserved.
//
#import "YQL.h"
#import "SearcheView.h"

@interface SearcheView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
    int keyboardHeight;
}
@property (nonatomic, strong) NSMutableArray* arrDict;
@property (nonatomic, weak) UITableView* tableView;
@property (strong, nonatomic) YQL *yql;
@property (strong, nonatomic) NSArray *result;
- (IBAction)BackAction:(id)sender;
- (IBAction)ClearAction:(id)sender;
- (IBAction)GetQuoteAction:(id)sender;
@end

@implementation SearcheView

+ (instancetype)searchView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"View" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib{
    [self setupTextfield];
    _yql = [[YQL alloc] init];
}

-(void)setupTableview{
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(8, 120 + 8, [UIScreen mainScreen].bounds.size.width - 16, [UIScreen mainScreen].bounds.size.height-120-8-keyboardHeight-8) style:UITableViewStylePlain];
    self.tableView = tableView;
    [self addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.separatorStyle = 0;
}

-(void)setupTextfield{
    [self.textFieldV becomeFirstResponder];
    self.textFieldV.delegate = self;
    self.textFieldV.clearButtonMode=UITextFieldViewModeWhileEditing;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myNotificationMethod:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)textFieldDidChange:(NSNotification*)aNotification
{
    if(self.textFieldV.text.length == 0) return;
    NSString *query=[NSString stringWithFormat:@"http://d.yimg.com/aq/autoc?query=%@&region=US&lang=en-US&callback=YAHOO.util.ScriptNodeDataSource.callbacks", self.textFieldV.text];
    NSString *string=[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"string1 is %@", string);
    NSRange rang =[string rangeOfString:@"["];
    NSInteger start = rang.location;
    rang =[string rangeOfString:@"]"];
    NSInteger end = rang.location;
    NSString *string2 = [string substringWithRange:NSMakeRange(start, end - start+1)];
    //NSLog(@"string2 is %@",string2);
    NSData *jsonData = [string2 dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    _result = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    //NSLog(@"results is %@", _result);
    
    [self.tableView removeFromSuperview];
    [self setupTableview];
}
- (IBAction)BackAction:(id)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
        [self.textFieldV resignFirstResponder];
    }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)myNotificationMethod:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    keyboardHeight=(int) roundf(keyboardFrameBeginRect.size.height);
}

- (IBAction)ClearAction:(id)sender {
    self.textFieldV.text=@"";
}

- (IBAction)GetQuoteAction:(id)sender {
  if (!self.textFieldV.text.length){
         [[NSNotificationCenter defaultCenter] postNotificationName:@"EmptyTextField" object:self];
    }else{
        NSString *queryString=[NSString stringWithFormat:@"select Name, symbol, LastTradePriceOnly, ChangeinPercent, MarketCapitalization from yahoo.finance.quotes where symbol = '%@'", self.textFieldV.text];
        NSDictionary *result = [self.yql query:queryString];
       [[NSNotificationCenter defaultCenter] postNotificationName:@"presentStockPage" object:result];
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
            [self.textFieldV resignFirstResponder];
        }
        completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
       // [self removeFromSuperview];
        //NSLog(@"%@", [[results valueForKeyPath:@"query.results"] description]);
    }

}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.textFieldV.text=self.result[indexPath.row][@"symbol"];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.result.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    static NSString* ID = @"search";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = self.result[indexPath.row][@"name"];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ Exch:%@",self.result[indexPath.row][@"symbol"],self.result[indexPath.row][@"exch"]];
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


@end
