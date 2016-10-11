//
//  DetailViewController.m
//  LYURLRouterDemo
//
//  Created by chairman on 16/10/11.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//

#import "DetailViewController.h"
#import "LYURLRouter.h"

/** 屏幕的SIZE */
#define SCREEN_SIZE [[UIScreen mainScreen] bounds].size

@interface DetailViewController ()
@property (nonatomic, copy) NSString *stringValue;
@end

@implementation DetailViewController

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [LYURLRouter registerURLPattern:@"http://LaiYoung_/DetailViewController" toHandler:^(NSDictionary *routerParameters) {
            DetailViewController *detailVC = [self new];
            if (routerParameters.routerUserInfo[@"value"]) {
                detailVC.stringValue = routerParameters.routerUserInfo[@"value"];
            }
            if (routerParameters[@"value"]) {
                detailVC.stringValue = routerParameters[@"value"];
            }
            [[UIViewController currentNavigationViewController] pushViewController:detailVC animated:YES];
        }];
        
//        [LYURLRouter registerURLPattern:@"http://LaiYoung_/DetailViewController" toHandler:nil];
        
        [LYURLRouter registerURLPattern:@"http://LaiYoung_/DetailViewController_" toObjectHandler:^id(NSDictionary *routerParameters) {
            NSLog(@"toObjectHandler = %@",routerParameters);
            DetailViewController *detailVC = [self new];
            return @{@"className":[detailVC class],@"userName":@"LaiYoung_"};
        }];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"%@",_stringValue);
    UILabel *label = ({
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(10, 100, SCREEN_SIZE.width - 20, SCREEN_SIZE.height - 200);
        label.font = [UIFont systemFontOfSize:80];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [self.view addSubview:label];
    label.text = @"查看标题";
    self.title = self.stringValue;
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

@end
