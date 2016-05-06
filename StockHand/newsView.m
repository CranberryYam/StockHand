//
//  newsView.m
//  StockHand
//
//  Created by yihl on 4/30/16.
//  Copyright © 2016 yihl. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import "newsView.h"
#import "newsCell.h"

@interface newsView () <UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate>{
    BOOL isStartCountingItem;
}
@property(nonatomic, strong) NSMutableDictionary *currentDictionary;
@property(nonatomic, strong) NSMutableArray *itemArr;
@property(nonatomic, strong) NSString *elementName;
@property(nonatomic, strong) NSMutableString *outstring;
@property (nonatomic, weak) UITableView* tableView;
@end
@implementation newsView

-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self setupTableview];
    }
    return self;
}

-(void)setupTableview{
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView = tableView;
    [self addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    //tableView.separatorStyle = 0;
    [self.tableView registerNib:[UINib nibWithNibName:@"newsCell" bundle:nil] forCellReuseIdentifier:@"newsCell"];
}
#pragma mark - http get feedback test
-(void)addSymbol:(NSString *)symbol{
    //NSString *symbolll=@"YHOO";
    NSString *query=[NSString stringWithFormat:@"http://news.google.com/news?q=%@&output=rss", symbol];
    NSLog(@"query in newsView is %@",query);
    NSString *string=[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"string1 is %@", string);
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *XMLParser = [[NSXMLParser alloc]initWithData:data];
    [XMLParser setShouldProcessNamespaces:YES];
    XMLParser.delegate = self;
    [XMLParser parse];
}

#pragma mark - table view method
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    NSString *ID=@"newsCell";
    newsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!_itemArr.count) {
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.textLabel.text=@"no value right now";
    }else{
        [cell getDataFromDic:self.itemArr[indexPath.row]];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [self getNewsUrlFromGuid: _itemArr[indexPath.row][@"guid"]]]];
}
#pragma mark get news url from guid
-(NSString *)getNewsUrlFromGuid:(NSString *)string{
    NSRange rang =[string rangeOfString:@"="];
    NSInteger location = rang.location;
    NSUInteger len = [string length];
    return [string substringWithRange:NSMakeRange(location+1, len-location-2)];

}
#pragma mark - NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.itemArr = [NSMutableArray array];
    //NSLog(@"parser Did star document");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.elementName = qName;
    //NSLog(@"self.elementName is %@",self.elementName);
    if([qName isEqualToString:@"item"]) {
        self.currentDictionary = [NSMutableDictionary dictionary];
        isStartCountingItem=YES;
    }
    self.outstring = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!self.elementName)
        return;
    [self.outstring appendFormat:@"%@", string];//only one char in string
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([qName isEqualToString:@"item"]) {
        [self.itemArr addObject:self.currentDictionary];
        self.currentDictionary = nil;
        isStartCountingItem=NO;
    }else if (isStartCountingItem){
        self.currentDictionary[qName] = self.outstring;
    }
    self.elementName = nil;
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    //NSLog(@"itemArr is %@",self.itemArr);
    [self.tableView reloadData];
}
#pragma mark - AFNetworking way
-(void)loadingData{
    NSString *sym=@"apple";
    NSURL *url = [NSURL URLWithString:@""];
    AFHTTPSessionManager *operation =[[AFHTTPSessionManager alloc]initWithBaseURL:url];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];
    [operation setResponseSerializer:[AFXMLParserResponseSerializer new]];
    //operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSString *adPath=[NSString stringWithFormat:@"http://news.google.com/news?q=%@&output=rss", sym];
    [operation GET:adPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, NSDictionary *responseObject){
        //NSLog(@"responseObject is %@",responseObject);
        NSXMLParser *XMLParser = (NSXMLParser *)responseObject;
        [XMLParser setShouldProcessNamespaces:YES];
        
        // These lines below were previously commented
        XMLParser.delegate = self;
        [XMLParser parse];
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        NSLog(@"error is %@",error);
    }];
    
}
@end
