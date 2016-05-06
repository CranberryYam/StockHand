//
//  ViewController.m
//  StockHand
//
//  Created by yihl on 4/17/16.
//  Copyright © 2016 yihl. All rights reserved.
//
#import "StockViewController.h"
#import "AutoComplete.h"
#import "YQL.h"
#import "MJRefresh.h"
#import "favorCell.h"
#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
    NSArray *lookupResult;
    NSTimer *refreshTimer;
}
@property (nonatomic, strong) AutoComplete *autocom;
@property (nonatomic, strong) NSMutableArray* arrDict;
@property (nonatomic, strong) NSMutableArray *favorateListDetail;
@property (nonatomic, weak) UITableView* tableView;
@property (strong, nonatomic) YQL *yql;
@property (weak, nonatomic) IBOutlet UITextField *textFieldV;

- (IBAction)getQuoteAction:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *freshSwitch;
- (IBAction)freshAction:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _yql = [[YQL alloc] init];
   // [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self addNotification];
    [self setupTableview];
    [self setupTextfield];
    //[self loadtest];
    //[self yqlTest];
    [self setSwitchActionandInitialState];
    [self getySwitchState];
}

-(void)viewWillAppear:(BOOL)animated{
    //NSLog(@"viewwillappear");
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.textFieldV.text=@"";
    [self loadStockButNoUseRefresher];
}

-(void)viewDidDisappear:(BOOL)animated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.freshSwitch.on forKey:@"yswitchState"];
}

- (NSMutableArray*)arrDict
{
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"favorateList.plist"];
        _arrDict = [NSMutableArray arrayWithContentsOfFile:path];
    NSLog(@"in arrDict method _arrDict is %@", _arrDict);
        if (!_arrDict) {
            _arrDict = [NSMutableArray array];
            NSLog(@"in arrDict method new array");
        }

    return _arrDict;
}
#pragma mark -freshSwtich and auto refresh
-(void)getySwitchState{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.freshSwitch.on = [userDefaults boolForKey:@"yswitchState"];
    [self switchControlChangeValue];
}
- (IBAction)freshAction:(id)sender {
    [self.tableView.mj_header beginRefreshing];
}
-(void)setSwitchActionandInitialState{
    [_freshSwitch addTarget:self action:@selector(switchControlChangeValue) forControlEvents:UIControlEventValueChanged];
 /*   NSTimer *timer=[NSTimer scheduledTimerWithTimeInterval:10
                                                    target:self selector:@selector(refreshTable)
                                                  userInfo:nil repeats:YES];
    refreshTimer=timer;*/
    [self switchControlChangeValue];
}
-(void)switchControlChangeValue{
    if (self.freshSwitch.isOn) {
        if (!refreshTimer) {
            NSTimer *timer=[NSTimer scheduledTimerWithTimeInterval:10
                                                            target:self selector:@selector(refreshTable)
                                                          userInfo:nil repeats:YES];
            refreshTimer=timer;
        }
    }else{
        if (refreshTimer) {
            [refreshTimer invalidate];
            refreshTimer=nil;
        }

    }
}
-(void)refreshTable{
    NSLog(@"timer is on");
    //[self loadStock];
    [self.tableView.mj_header beginRefreshing];
}
#pragma mark - textField
-(void)setupTextfield{
    //[self.textFieldV becomeFirstResponder];
    self.textFieldV.delegate = self;
    self.textFieldV.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.textFieldV.returnKeyType=UIReturnKeyDone;
    self.textFieldV.autocorrectionType=UITextAutocorrectionTypeNo;
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self.autocom removeFromSuperview];
    textField.text=@"";
    return YES;
}
-(void)textFieldDidChange:(NSNotification*)aNotificaion{
    if (self.textFieldV.text.length==0) {
        [self.autocom removeFromSuperview];
    }
    if (self.textFieldV.text.length>2) {
        
            [self loopUpwithSymbol:self.textFieldV.text];
            //[lookupResult isKindOfClass:[NSNull class]
            if ([lookupResult count]) {
                NSLog(@"lookupResult > o");
                AutoComplete *autoCom=[[AutoComplete alloc]initWithFrame:CGRectMake(_textFieldV.frame.origin.x, _textFieldV.frame.origin.y+_textFieldV.frame.size.height, _textFieldV.frame.size.width, 300)];
                [autoCom loopUpwithArray:lookupResult];
                [self.view addSubview:autoCom];
                self.autocom=autoCom;
            }else{
                [self.autocom removeFromSuperview];
            }
    }
}
-(void)loopUpwithSymbol:(NSString *)symbol{
    NSString *query=[NSString stringWithFormat:@"http://dev.markitondemand.com/Api/v2/Lookup/json?input=%@", symbol];
    NSString *string=[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    lookupResult = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    NSLog(@"lookupResult is %@", lookupResult);
  //  [self setupTableview];
}
#pragma mark - http get feedback test
-(void)loadtest{
    NSString *symbolll=@"apple";
    NSString *query=[NSString stringWithFormat:@"http://finance.yahoo.com/rss/headline?s=%@", symbolll];
    NSString *string=[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"string1 is %@", string);
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *resultt = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    NSLog(@"results is %@", resultt);
}
-(void)yqlTest{
    NSString *symbol=@"YHOO";
    NSString *queryString=[NSString stringWithFormat:@"select Name, symbol, LastTradePriceOnly, ChangeinPercent, MarketCapitalization from yahoo.finance.quotes where symbol = '%@'", symbol];
    NSDictionary *result = [self.yql query:queryString];
    NSLog(@"yqlTest result is %@", result);
}
#pragma mark - Add Notification
-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picksFromAuto:) name:@"picksFromAutoCom" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldResignFirstResponder) name:@"textFieldResignFirstResponder" object:nil];
}
-(void)textFieldResignFirstResponder{
    //[self.textFieldV resignFirstResponder];
   // [self.view endEditing:YES];
}
-(void)picksFromAuto:(NSNotification *)note{
    NSString *symbol=note.object;
    self.textFieldV.text=symbol;
}
#pragma mark - Table view basic method
-(void)setupTableview{
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(8, 250 + 8, [UIScreen mainScreen].bounds.size.width - 16, [UIScreen mainScreen].bounds.size.height-140-16) style:UITableViewStylePlain];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.rowHeight = 65;
    //tableView.separatorStyle = 0;
    tableView.layer.cornerRadius=4;
    tableView.clipsToBounds=YES;
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadStock)];
    header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    tableView.mj_header = header;
    [tableView registerNib:[UINib nibWithNibName:@"favorCell" bundle:nil] forCellReuseIdentifier:@"favorCell"];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"arrDict.count is %lu",(unsigned long)self.arrDict.count);
    return self.arrDict.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    favorCell *cell=[tableView dequeueReusableCellWithIdentifier:@"favorCell"];
    cell.backgroundColor=[UIColor clearColor];
    cell.symbol.text=self.favorateListDetail[indexPath.row][@"symbol"];
    cell.price.text=self.favorateListDetail[indexPath.row][@"LastTradePriceOnly"];
    cell.percent.text=self.favorateListDetail[indexPath.row][@"ChangeinPercent"];
    cell.name.text=self.favorateListDetail[indexPath.row][@"Name"];
    if(![self.favorateListDetail[indexPath.row][@"MarketCapitalization"] isKindOfClass:[NSNull class]]){
        cell.cap.text=self.favorateListDetail[indexPath.row][@"MarketCapitalization"];
    }else{
        cell.cap.text=@"no value";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    /* NSString *queryString=[NSString stringWithFormat:@"select Name, symbol, LastTradePriceOnly, ChangeinPercent, MarketCapitalization from yahoo.finance.quotes where symbol = '%@'", self.arrDict[indexPath.row]];
    NSDictionary *result = [self.yql query:queryString];  */
    StockViewController *svc=[[StockViewController alloc] init];
    NSArray *temDic=self.arrDict;
    NSLog(@"temDic in didSelect is %@",temDic);
    NSLog(@"indexPath.row is %ld",(long)indexPath.row);
    svc.stockSymbol=temDic[indexPath.row];
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.navigationController pushViewController:svc animated:YES];
   // [self presentViewController:svc animated:YES completion:nil];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delete";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"favorateList.plist"];
    NSMutableArray *temArrDict=self.arrDict;
    [temArrDict removeObjectAtIndex:indexPath.row];
   // [self.arrDict removeObjectAtIndex:indexPath.row]; /*****/
    [temArrDict writeToFile:path atomically:YES];
    //NSLog(@"arrDict after deleting is %@", self.arrDict);
   [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
#pragma mark Table view extra method
-(void)loadStock{
    NSMutableString *mutiSymbol=[[NSMutableString alloc]init];
    if (self.arrDict.count>0) {
        mutiSymbol= [self DicIntoString];
    }
    //NSLog(@"mutiSymbol is %@",mutiSymbol);
    NSString *queryString=[NSString stringWithFormat:@"select Name, symbol, LastTradePriceOnly, ChangeinPercent, MarketCapitalization from yahoo.finance.quotes where symbol %@",mutiSymbol];
    NSDictionary *result = [self.yql query:queryString];
    //NSLog(@"resulf is %@",result);
    if (self.arrDict.count==1) {
        NSMutableArray *arr=[[NSMutableArray alloc]init];
        [arr addObject:result[@"query"][@"results"][@"quote"]];
        self.favorateListDetail=arr;
    }else{
        self.favorateListDetail=result[@"query"][@"results"][@"quote"];
    }
   // NSLog(@"ListDetail is %@", self.favorateListDetail);
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
}

-(void)loadStockButNoUseRefresher{
    NSMutableString *mutiSymbol=[[NSMutableString alloc]init];
    if (self.arrDict.count>0) {
        mutiSymbol= [self DicIntoString];
    }
    //NSLog(@"mutiSymbol is %@",mutiSymbol);
    NSString *queryString=[NSString stringWithFormat:@"select Name, symbol, LastTradePriceOnly, ChangeinPercent, MarketCapitalization from yahoo.finance.quotes where symbol %@",mutiSymbol];
    NSDictionary *result = [self.yql query:queryString];
    //NSLog(@"resulf is %@",result);
    if (self.arrDict.count==1) {
        NSMutableArray *arr=[[NSMutableArray alloc]init];
        [arr addObject:result[@"query"][@"results"][@"quote"]];
        self.favorateListDetail=arr;
    }else{
        self.favorateListDetail=result[@"query"][@"results"][@"quote"];
    }
    // NSLog(@"ListDetail is %@", self.favorateListDetail);
   // [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
}

-(NSMutableString *)DicIntoString{
    NSMutableString *mutiSymbol = [NSMutableString string];
 if (self.arrDict.count>1) {
    [mutiSymbol appendFormat:@"in (\"%@\"", self.arrDict[0]];
        for(NSString *symboll in self.arrDict){
            [mutiSymbol appendFormat:@",\"%@\"", symboll];
        }
    [mutiSymbol appendFormat:@")"];
 }else if (self.arrDict.count==1){
     [mutiSymbol appendFormat:@"= \"%@\"", self.arrDict[0]];
 }
    return mutiSymbol;
}
#pragma mark - GetQuote button and its alert action

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getQuoteAction:(id)sender {
    if (!self.textFieldV.text.length) {
        [self EmptyTextfieldAlert];
    }else if (![lookupResult count]){
        [self InvalidSymbolTextfieldAlert];
        
    }else{
        //NSString *queryString=[NSString stringWithFormat:@"select Name, symbol, LastTradePriceOnly, ChangeinPercent, MarketCapitalization from yahoo.finance.quotes where symbol = '%@'", self.textFieldV.text];
        //NSDictionary *result = [self.yql query:queryString];
        StockViewController *svc=[[StockViewController alloc] init];
        svc.stockSymbol=self.textFieldV.text;
        [self.navigationController pushViewController:svc animated:YES];
       // [self presentViewController:svc animated:YES completion:nil];
    }
}
-(void)EmptyTextfieldAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Please Enter a Stock Name or Symbol" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)InvalidSymbolTextfieldAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Invalid Symbol" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
