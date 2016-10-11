//
//  LYURLRouter.h
//  LYURLRouterDemo
//
//  Created by chairman on 16/10/11.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - TYPEDEF

/**
 *  配合 ｀openURL:｀ 系列函数使用
 */
typedef void(^LYRouterHandler)(NSDictionary *routerParameters);

/**
 *  需要返回一个 object，配合 `objectForURL:` 系列函数使用，block里面包含了通过router传过来的参数（直接添加在router里的或者通过userInfo传的参数）
 */
typedef id(^LYRouterObjectHandler)(NSDictionary *routerParameters);

/**
 *  完成操作回调
 */
typedef void(^LYRouterCompletiion)();

/**
 *  操作错误回调
 */
typedef void(^LYRouterFailure)(NSError *error);


@interface LYURLRouter : NSObject

#pragma mark - Register Methods

/**
 注册 URLPattern 对应的 Handler，在 handler 中可以初始化 VC，然后对 VC 做各种操作
 
 @param URLPattern 带上 scheme
 @param handler    该 block 会传一个字典，包含了注册的 URL 中对应的变量以及传过来的参数。
 */
+ (void)registerURLPattern:(NSString *)URLPattern toHandler:(LYRouterHandler)handler;
/**
 注册 URLPattern 对应的 ObjectHandler，需要返回一个 object 给调用方，以获取 object 做其它操作
 
 @param URLPattern 带上 scheme
 @param handler    该 block 会传一个字典，包含注册的 URL 中对应的变量以及传过来的参数。
 */
+ (void)registerURLPattern:(NSString *)URLPattern toObjectHandler:(LYRouterObjectHandler)handler;

#pragma mark - OpenURL Methods

/**
 打开这个URL，如果这个URL已经注册，则匹配这个URL，并执行handler
 
 @param URL 注册的URL
 */
+ (void)openURL:(NSString *)URL;

/**
 打开这个URL，如果这个URL已经注册，则匹配这个URL，并执行handler
 
 @param URL        注册的URL
 @param completion 完成操作回调
 @param failure    错误操作回调
 */
+ (void)openURL:(NSString *)URL completion:(LYRouterCompletiion)completion failure:(LYRouterFailure)failure;

/**
 打开这个URL，如果这个URL已经注册，则匹配这个URL，并执行handler
 
 @param URL        注册的URL
 @param userInfo   传值参数
 @param completion 完成操作回调
 @param failure    错误操作回调
 */
+ (void)openURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo completion:(LYRouterCompletiion)completion failure:(LYRouterFailure)failure;

#pragma mark - GetObjectURL Methods

/**
 通过注册的URL，返回一个通过｀toObjectHandler｀方法注册返回的对象
 
 @param URL 注册的URL
 
 @return 通过｀toObjectHandler｀方法注册返回的对象
 */
+ (id)objectForURL:(NSString *)URL;

/**
 通过注册的URL，返回一个 通过｀toObjectHandler｀方法注册返回的对象
 
 @param URL      注册的URL
 @param userInfo 传值参数
 
 @return  通过｀toObjectHandler｀方法注册返回的对象
 */
+ (id)objectForURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo;

#pragma mark - Other Methods

/**
 *  判断是否能否打开某个URL
 */
+ (BOOL)canOpenURL:(NSString *)URL;

/**
 *  取消某个 URLPattern
 */
+ (void)deregisterURLPattern:(NSString *)URLPattern;

@end

#pragma mark - Category


@interface NSDictionary (LYURLRouter)

- (NSString *)routerURL;

- (NSDictionary *)routerUserInfo;

@end


@interface NSString (LYURLRouter)

- (NSString *)appendingParams:(NSDictionary *)params;

@end


#import <UIKit/UIKit.h>
@interface UIViewController (LYURLRouter)

+ (UIViewController *)currentViewController;

+ (UINavigationController *)currentNavigationViewController;

@end
