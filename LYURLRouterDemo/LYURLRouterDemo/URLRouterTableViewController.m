//
//  URLRouterTableViewController.m
//  LYURLRouterDemo
//
//  Created by chairman on 16/10/11.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//

#import "URLRouterTableViewController.h"
#import "LYURLRouter.h"


#define kDetailViewControllerURL @"http://LaiYoung_/DetailViewController"

@interface URLRouterTableViewController ()
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation URLRouterTableViewController

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [LYURLRouter registerURLPattern:@"http://LaiYoung_/TableViewController" toObjectHandler:^id(NSDictionary *routerParameters) {
            NSLog(@"routerParameter = %@",routerParameters);
            URLRouterTableViewController *tabVC = [self new];
            return tabVC;
        }];
    });
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@"openURL:",@"openURL_completion_failure",@"openURL_userInfo_completion_failure",@"objectForURL:",@"objectForURL_userInfo",@"canOpenURL",@"deregister"];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.title = @"LYURLRouterDemo";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier" forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0: {//openURL
            [LYURLRouter openURL:[kDetailViewControllerURL appendingParams:@{@"value":@"Qintui",@"userName":@"LaiYoung_"}]];
        }
            break;
        case 1: {//openURL_completiom_failure
            [LYURLRouter openURL:[kDetailViewControllerURL appendingParams:@{@"value":@"CISDI",@"userName":@"LaiYoung_"}] completion:^{
                NSLog(@"_______________openURL_completiom______________");
            } failure:^(NSError *error) {
                if (error.code == -999) {
                NSLog(@"_______________openURL_failure______________");
                }
            }];
        }
            break;
        case 2: {//openUrl_userInfo_completion_failure
            [LYURLRouter openURL:kDetailViewControllerURL withUserInfo:@{@"value":@"15923456720",@"userName":@"LaiYoung_"} completion:^{
                NSLog(@"_______________openUrl_userInfo_completion______________");
            } failure:^(NSError *error) {
                if (error.code == -999) {
                    NSLog(@"_______________openUrl_userInfo_failure______________");
                }
            }];
            
        }
            break;
        case 3: {//objectForURL
            id object = [LYURLRouter objectForURL:[[kDetailViewControllerURL stringByAppendingString:@"_"] appendingParams:@{@"hello":@"detailVC"}]];
            NSLog(@"objectForURL_object = %@",object);
        }
            break;
        case 4: {//objectForUrl_userInfo
           id object = [LYURLRouter objectForURL:[kDetailViewControllerURL stringByAppendingString:@"_"] withUserInfo:@{@"value":@"15923456720",@"userName":@"LaiYoung"}];
            NSLog(@"objectForUrl_userInfo_object = %@",object);
        }
            break;
        case 5: {//canOpenUrl
            BOOL can = [LYURLRouter canOpenURL:kDetailViewControllerURL];
            NSLog(@"%@",can?@"能打开":@"不能打开");
        }
            break;
        case 6: {//deregister
            [LYURLRouter deregisterURLPattern:kDetailViewControllerURL];
        }
            break;
        default:
            break;
    }
}


@end
