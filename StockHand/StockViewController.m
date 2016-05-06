//
//  StockViewController.m
//  StockHand
//
//  Created by yihl on 4/23/16.
//  Copyright © 2016 yihl. All rights reserved.
//
#import "newsView.h"
#import "yHeaderView.h"
#import "YQL.h"
#import "StockCell.h"
#import "yButton.h"
#import "StockViewController.h"

@interface StockViewController ()<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>{
    NSDictionary *stockDetailResult;
    NSMutableArray *DicKeyArr;
    NSMutableArray *TableTittleArr;
}
@property (strong, nonatomic) UIScrollView *scrollView;
@property(nonatomic,strong) yButton *lastButton;
@property (strong, nonatomic) YQL *yql;
@property (nonatomic, strong) NSMutableArray* arrDict;
@end

@implementation StockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self setupThreeButton];
    [self setupSrcollView];
    [self loadStockDetail];
    [self setupTableview];
    [self addWebviewChart];
    [self setupNewsview];
}
- (NSMutableArray*)arrDict
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"favorateList.plist"];
    
    _arrDict = [NSMutableArray arrayWithContentsOfFile:path];
    if (!_arrDict) {
        _arrDict = [NSMutableArray array];
    }
    
    return _arrDict;
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    yButton *button=(yButton *)[self.view viewWithTag:1];
    _lastButton=button;

}
#pragma mark - Three Button
-(void)setupThreeButton{
    for (int i=0; i<3; i++) {
        //UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(41*(i+1)+i*70, 75, 70, 40)];
    }
    yButton *button1=[[yButton alloc]initWithFrame:CGRectMake(41-15, 75, 70, 40)];
    button1.tag=1;
    [button1 setTitle:@"Current" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(changeScrollView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    yButton *button2=[[yButton alloc]initWithFrame:CGRectMake(41*2+70, 75, 80, 40)];
    button2.tag=2;
    [button2 setTitle:@"Historical" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(changeScrollView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    yButton *button3=[[yButton alloc]initWithFrame:CGRectMake(41*3+70*2+15, 75, 70, 40)];
     [button3 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button3.tag=3;
    [button3 setTitle:@"News" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(changeScrollView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    button1.enabled=NO;
    _lastButton=button1;
}
-(void)changeScrollView:(yButton *)sender{
    if (sender.tag==1) {
          [self.scrollView setContentOffset:CGPointMake(0*self.scrollView.frame.size.width, 0) animated:YES];
    }else if (sender.tag==2){
          [self.scrollView setContentOffset:CGPointMake(1*self.scrollView.frame.size.width, 0) animated:YES];
    }else{
          [self.scrollView setContentOffset:CGPointMake(2*self.scrollView.frame.size.width, 0) animated:YES];
    }
    _lastButton.enabled=YES;
    _lastButton=sender;
    sender.enabled=NO;
}
#pragma mark - scrollView
-(void)setupSrcollView{
    //UIScrollView *scrollV=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 80, 375, 400)];
    //[self.view addSubview:scrollV];
    //self.scrollView=scrollV;
    self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 120, 375, [UIScreen mainScreen].bounds.size.height-120)];
    [self.view addSubview:self.scrollView];
    CGFloat contentSizeWidth=3*[UIScreen mainScreen].bounds.size.width;
    self.scrollView.contentSize=CGSizeMake(contentSizeWidth, 0);
    self.scrollView.pagingEnabled=YES;
    self.scrollView.showsHorizontalScrollIndicator=NO;
    self.scrollView.delegate=self;
    UIView *view1=[[UIView alloc]init];
    view1.tag=11;
    view1.backgroundColor=[UIColor blueColor];
    view1.frame=CGRectMake(0*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.scrollView addSubview:view1];
    UIView *view2=[[UIView alloc]init];
    view2.tag=12;
    view2.backgroundColor=[UIColor redColor];
    view2.frame=CGRectMake(1*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.scrollView addSubview:view2];
    UIView *view3=[[UIView alloc]init];
    view3.tag=13;
    view3.backgroundColor=[UIColor yellowColor];
    view3.frame=CGRectMake(2*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.scrollView addSubview:view3];
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index=(self.scrollView.contentOffset.x/self.scrollView.frame.size.width);
    yButton *button=(yButton *)[self.view viewWithTag:index+1];
    _lastButton.enabled=YES;
    _lastButton=button;
    button.enabled=NO;

}
#pragma mark - newsView
-(void)setupNewsview{
UIView *oneView=[self.view viewWithTag:13];
    newsView *newsview=[[newsView alloc]initWithFrame:oneView.bounds];
    [newsview addSymbol:self.stockSymbol];
    NSLog(@"self.stockSymbol is %@",self.stockSymbol);
    
    [oneView addSubview:newsview];
    newsview.backgroundColor = [UIColor whiteColor];
}

#pragma mark - chartView
-(void)addWebviewChart{
    
    NSMutableString *htmlstring=[NSMutableString string];
    NSString *htmlFile1 = [[NSBundle mainBundle] pathForResource:@"part1" ofType:@"txt"];
    NSString* htmlString1 = [NSString stringWithContentsOfFile:htmlFile1 encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"string1 is %@", htmlString1);
    NSString *symbolLine=[NSString stringWithFormat:@"var symbol = \"%@\";",self.stockSymbol];
    NSString *htmlFile2 = [[NSBundle mainBundle] pathForResource:@"part2" ofType:@"txt"];
    NSString* htmlString2 = [NSString stringWithContentsOfFile:htmlFile2 encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"string2 is %@", htmlString2);
    [htmlstring appendString:htmlString1];
    [htmlstring appendString:symbolLine];
    [htmlstring appendString:htmlString2];
    //NSLog(@"htmlstring is %@",htmlstring);
    
     
    UIView *oneView=[self.view viewWithTag:12];
    UIWebView *webChart=[[UIWebView alloc]initWithFrame:oneView.bounds];
    webChart.backgroundColor=[UIColor whiteColor];
    [oneView addSubview:webChart];
    
    

    [webChart loadHTMLString:htmlstring baseURL:nil];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Facebook share
-(void)facebookShare{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://finance.yahoo.com/q?s=%@",self.stockSymbol]];
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[url]
     applicationActivities:nil];
    controller.excludedActivityTypes = @[
                                         UIActivityTypeMessage,
                                         UIActivityTypeMail,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypeAirDrop,
                                         UIActivityTypeMail,
                                         UIActivityTypeOpenInIBooks,
                                         UIActivityTypePostToWeibo,
                                         UIActivityTypePostToTencentWeibo,
                                         ];
    [self presentViewController:controller animated:YES completion:nil];

}
#pragma mark - addToFavorList
-(void)addToFavorList{
    
    if (![self.arrDict containsObject:[self.stockSymbol uppercaseString]]) {
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"favorateList.plist"];
        NSMutableArray *temArrDict=self.arrDict;
        [temArrDict addObject:self.stockSymbol];
        [temArrDict writeToFile:path atomically:YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Have added to Favorite List" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Already in Favorite List" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
#pragma mark - stock detail tableView
-(void)setupTableview{
    UIView *oneView=[self.view viewWithTag:11];
    UITableView* tableView = [[UITableView alloc] initWithFrame:oneView.bounds];
    [oneView addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    //tableView.rowHeight = 65;
    //tableView.separatorStyle = 0;
    //tableView.layer.cornerRadius=4;
    //tableView.clipsToBounds=YES;
    yHeaderView *headerview=[yHeaderView headerView];
    headerview.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60);
    tableView.tableHeaderView=headerview;
    headerview.shareButtonClick=^(){
        [self facebookShare];
    };
    headerview.favlistButtonClick=^(){
        [self addToFavorList];
    };
    [tableView registerNib:[UINib nibWithNibName:@"StockCell" bundle:nil] forCellReuseIdentifier:@"StockCell"];
}

-(void)loadStockDetail{
    /* NSString *symbol=@"yhoo";
     NSString *queryString=[NSString stringWithFormat:@"select Name, symbol, LastTradePriceOnly, ChangeinPercent, MarketCapitalization from yahoo.finance.quotes where symbol = '%@'", symbol];
     NSDictionary *result = [self.yql query:queryString];
     NSLog(@"yqlTest result is %@", result); */
    
    NSString *query=[NSString stringWithFormat:@"http://dev.markitondemand.com/Api/v2/Quote/json?symbol=%@", self.stockSymbol];
    NSString *string=[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"string1 is %@", string);
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    stockDetailResult = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    NSLog(@"Last Price is %@",stockDetailResult[@"LastPrice"]);
    //NSLog(@"results is %@", stockDetailResult);
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 11;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{   NSString *ID=@"StockCell";
    StockCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.tittleLabel.text=@"haha";
    cell.valueLabel.text=@"hehe";
    if (indexPath.row==0) {
        cell.tittleLabel.text=@"Name";
        cell.valueLabel.text=stockDetailResult[@"Name"];
    }else if (indexPath.row==1){
        cell.tittleLabel.text=@"Symbol";
        cell.valueLabel.text=stockDetailResult[@"Symbol"];
    }else if (indexPath.row==2){
        cell.tittleLabel.text=@"Last Price";
        cell.valueLabel.text=[NSString stringWithFormat:@"$ %@", [stockDetailResult[@"LastPrice"] stringValue]];
    }else if (indexPath.row==3){
        cell.tittleLabel.text=@"Change";
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        NSString *changeFormatted = [formatter stringFromNumber:stockDetailResult[@"Change"]];
        NSString *changePercentFormatted = [formatter stringFromNumber:stockDetailResult[@"ChangePercent"]];
        cell.valueLabel.text=[NSString stringWithFormat:@"%@(%@%%)", changeFormatted, changePercentFormatted];
        if ([stockDetailResult[@"Change"] floatValue]>0) {
            [cell.extraImage setBackgroundImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
        }else{
            [cell.extraImage setBackgroundImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        }
    }else if(indexPath.row==4){
        cell.tittleLabel.text=@"Time and Date";
        cell.valueLabel.text=[self changeTimestampFormat];
    }else if(indexPath.row==5){
        cell.tittleLabel.text=@"Market Cap";
        float value=[stockDetailResult[@"MarketCap"] floatValue]/1000000000;
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        NSNumber *valueNumber=[NSNumber numberWithFloat:value];
        NSString *changeFormatted = [formatter stringFromNumber:valueNumber];
        cell.valueLabel.text=[NSString stringWithFormat:@"%@ Billion",changeFormatted];
    }else if (indexPath.row==6){
        cell.tittleLabel.text=@"Volume";
        cell.valueLabel.text=[stockDetailResult[@"Volume"] stringValue];
    }else if (indexPath.row==7){
        cell.tittleLabel.text=@"Change YTD";
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        NSString *changeFormatted = [formatter stringFromNumber:stockDetailResult[@"ChangeYTD"]];
        NSString *changePercentFormatted = [formatter
                                            stringFromNumber:stockDetailResult[@"ChangePercentYTD"]];
        cell.valueLabel.text=[NSString stringWithFormat:@"%@(%@%%)", changeFormatted, changePercentFormatted];
        if ([stockDetailResult[@"ChangePercentYTD"]floatValue]>0) {
            [cell.extraImage setBackgroundImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
        }else{
            [cell.extraImage setBackgroundImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        }

    }else if (indexPath.row==8){
        cell.tittleLabel.text=@"High Price";
        cell.valueLabel.text=[NSString stringWithFormat:@"$ %@", [stockDetailResult[@"High"] stringValue]];
    }else if (indexPath.row==9){
        cell.tittleLabel.text=@"Low Price";
        cell.valueLabel.text=[NSString stringWithFormat:@"$ %@", [stockDetailResult[@"Low"] stringValue]];
    }else if (indexPath.row==10){
        cell.tittleLabel.text=@"Opening Price";
        cell.valueLabel.text=[NSString stringWithFormat:@"$ %@", [stockDetailResult[@"Open"] stringValue]];
    }
      return cell;
}

-(NSString *)changeTimestampFormat{
NSMutableArray *locationArr=[[NSMutableArray alloc]init];
NSString *someString = stockDetailResult[@"Timestamp"];
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
NSString *Date = [someString substringWithRange:NSMakeRange([locationArr[0] intValue]+1,6)];
NSString *Year = [someString substringWithRange:NSMakeRange([locationArr[4] intValue],5)];
NSString *Time = [someString substringWithRange:NSMakeRange([locationArr[2] intValue], 6)];
NSString *timeFormarted=[NSString stringWithFormat:@"%@%@%@",Date,Year,Time];
    return timeFormarted;
}

 -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 //return [StockValueCell getHeightfrom:indexPath.row];
 return 44;
 }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



@end
