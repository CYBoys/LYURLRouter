//
//  LYURLRouter.m
//  LYURLRouterDemo
//
//  Created by chairman on 16/10/11.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//

#import "LYURLRouter.h"

NSString *const LYRouterParameterURL = @"LYRouterParameterURL";

NSString *const LYRouterPatameterUserInfo = @"LYRouterParameterUserInfo";

@interface LYURLRouter()
/**  数据结构如下
{
    qingtui =     {
        "~" =         {
            pushPasswordRetrieveVC =             {
                "_" = "<__NSGlobalBlock__: 0x10030c810>";
            };
            pushRegisterFinishVC =             {
                "_" = "<__NSGlobalBlock__: 0x10030c910>";
            };
        };
    };
    qtui =     {
        "~" =         {
            chat =             {
                "_" = "<__NSGlobalBlock__: 0x10030c620>";
            };
            contact =             {
                "_" = "<__NSGlobalBlock__: 0x10030c6a0>";
            };
        };
    };
}
*/
@property (nonatomic, strong) NSMutableDictionary *routes;
@end

@implementation LYURLRouter

+ (instancetype)shareInstance {
    static LYURLRouter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Register Methods

+ (void)registerURLPattern:(NSString *)URLPattern toHandler:(LYRouterHandler)handler {
    [[self shareInstance] addURLPattern:URLPattern andHandler:handler];
}

+ (void)registerURLPattern:(NSString *)URLPattern toObjectHandler:(LYRouterObjectHandler)handler {
    [[self shareInstance] addURLPattern:URLPattern andObjectHandler:handler];
}

- (void)addURLPattern:(NSString *)URLPattern andHandler:(LYRouterHandler)handler {
    NSMutableDictionary *subRoutes = [self addURLPattern:URLPattern];
    if (handler && subRoutes) {
        subRoutes[@"_"] = [handler copy];
    }
}

- (void)addURLPattern:(NSString *)URLPattern andObjectHandler:(LYRouterObjectHandler)handler {
    NSMutableDictionary *subRoutes = [self addURLPattern:URLPattern];
    if (handler && subRoutes) {
        subRoutes[@"_"] = [handler copy];
    }
}

- (NSMutableDictionary *)addURLPattern:(NSString *)URLPattern {
    NSArray *pathComponents = [self pathComponentsFromURL:URLPattern];
    NSMutableDictionary *subRoutes = self.routes;
    NSUInteger index = 0;
    /** 类似于递归一层一层的往最里面添加 */
    /**
     第一次循环,subRoutes最开始为所有的routes,如果subRoutes的key包含pathComponent，那么subRoutes就为包含pathComponent的value。如果subRoutes不包含pathComponent，就创建一个的key为pathComponent，value为@{}的字典，然后subRoutes为value为pathComponent的字典。
     第二次循环,subRoutes为第一次循环结束的字典(要么为空，要么为包含pathComponent的value的字典)。然后同第一次循环一样，判断，创建一个字典
     第三次循环,subRoutes为第二次循环结束的字典(要么为空，要么为包含pathComponent的value的字典)，同上一样。
     ...
     ...
     直到遍历完pathComponents也就是subRoutes最后返回为nil的时候。
     最后创建一个key为@"_",value为handle的字典(因为subRoutes是可变的，再加上这是一层一层往内递归的，所以这是添加到最内层的)
     >>>>数据结构，在最上面。
     */
    while (index < pathComponents.count) {
        NSString *pathComponent = pathComponents[index];
        if (!subRoutes[pathComponent]) {
            subRoutes[pathComponent] = [NSMutableDictionary dictionary];
        }
        subRoutes = subRoutes[pathComponent];
        index++;
    }
    return subRoutes;
}

#pragma mark - OpenURL Methods

+ (void)openURL:(NSString *)URL {
    [self openURL:URL completion:nil failure:nil];
}

+ (void)openURL:(NSString *)URL completion:(LYRouterCompletiion)completion failure:(LYRouterFailure)failure {
    [self openURL:URL withUserInfo:nil completion:completion failure:failure];
}

+ (void)openURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo completion:(LYRouterCompletiion)completion failure:(LYRouterFailure)failure {
    //* 将中文转成UTF8 */
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [[self shareInstance] extractParametersFromURL:URL];
    if (!parameters) {
        !failure?:failure([NSError errorWithDomain:@"无法处理该业务" code:-999 userInfo:userInfo]);
        return;
    }
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            parameters[key] = [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }];
    if (parameters) {
        LYRouterHandler handler = parameters[@"block"];
        if (userInfo) {
            parameters[LYRouterPatameterUserInfo] = userInfo;
        }
        if (handler) {
            [parameters removeObjectForKey:@"block"];
            handler(parameters);
        } else {
            !failure?:failure([NSError errorWithDomain:@"无法处理该业务" code:-999 userInfo:userInfo]);
            return;
        }
        if (completion) {
            completion();
        }
    }

}

#pragma mark - Utils

/**
 从URL中提取参数
 
 @param URL 带有参数的url（如果有参数的话）
 
 @return 将参数从url中提取出来存放到一个字典，如果没有实现block则直接返回nil
 */
- (NSMutableDictionary *)extractParametersFromURL:(NSString *)URL {
    NSMutableDictionary *parameters = @{}.mutableCopy;
    parameters[LYRouterParameterURL] = URL;
    
    NSMutableDictionary *subRoutes = self.routes;
    NSArray *pathComponents = [self pathComponentsFromURL:URL];
    
    for (NSString *pathComponent in pathComponents) {
        BOOL found = NO;
        //* 对 key 进行排序，这样可以把 @"~" 放到最后 */
        //* 类似递归查询所有的key */
        NSArray *subRoutesKeys = [subRoutes.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        for (NSString *key in subRoutesKeys) {
            if ([pathComponent isEqualToString:key] || [key isEqualToString:@"~"]) {
                found = YES;
                subRoutes = subRoutes[key];
                break;
            }
        }
        if (!found && !subRoutes[@"_"]) {
            return nil;
        }
    }
    //* 如果有@"?"就代表有参数 */
    NSArray *pathInfo = [URL componentsSeparatedByString:@"?"];
    if (pathInfo.count > 1) {//>1才代表有参数
        NSString *parametersString = pathInfo[1];//0是URL，1是参数
        //* 如果有@"&"就代表有多个参数 */
        NSArray *paramStringArr = [parametersString componentsSeparatedByString:@"&"];
        for (NSString *parameString in paramStringArr) {
            //* 将key，value分开 */
            NSArray *paramArr = [parameString componentsSeparatedByString:@"="];
            if (paramArr.count > 1) {//有可能value为nil
                NSString *key = paramArr[0];
                NSString *value = paramArr[1];
                parameters[key] = value;
            }
        }
    }
    if (subRoutes[@"_"]) {
        parameters[@"block"] = [subRoutes[@"_"] copy];//将block复制一份到parameters
    }
    return parameters;
}

- (NSArray *)pathComponentsFromURL:(NSString *)URL {
    NSMutableArray *pathComponents = @[].mutableCopy;
    if ([URL rangeOfString:@"://"].location != NSNotFound) {
        NSArray *pathSegmens = [URL componentsSeparatedByString:@"://"];
        [pathComponents addObject:pathSegmens[0]];
        
        //* 如果只有协议，就放一个占位符 */
        if ((pathSegmens.count == 2 && ((NSString *)pathSegmens[1]).length) || pathSegmens.count < 2 ) {
            [pathComponents addObject:@"~"];
        }
        
        //* 取协议的后半部分 */
        URL = [URL substringFromIndex:[URL rangeOfString:@"://"].location + 3];
    }
    //* pathComponents 遇到@"/"就会分割出来 */
    for (NSString *pathComponent in [[NSURL URLWithString:URL] pathComponents]) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        if ([[pathComponent substringToIndex:1] isEqualToString:@"?"])  break;
        [pathComponents addObject:pathComponent];
    }
    return [pathComponents copy];
}

#pragma mark - GetObjectURL Methods

- (NSMutableDictionary *)routes {
    if (!_routes) {
        _routes = [NSMutableDictionary dictionary];
    }
    return _routes;
}

+ (id)objectForURL:(NSString *)URL {
    return [self objectForURL:URL withUserInfo:nil];
}

+ (id)objectForURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo {
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [[self shareInstance] extractParametersFromURL:URL];
    LYRouterObjectHandler handler = parameters[@"block"];
    if (handler) {
        if (userInfo) {
            parameters[LYRouterPatameterUserInfo] = userInfo;
        }
        [parameters removeObjectForKey:@"block"];
        return handler(parameters);
    }
    return nil;
}

#pragma mark - Other Methods

+ (BOOL)canOpenURL:(NSString *)URL {
    return [[self shareInstance] extractParametersFromURL:URL] ? YES : NO;
}

+ (void)deregisterURLPattern:(NSString *)URLPattern {
    [[self shareInstance] removeURLPattern:URLPattern];
}

- (void)removeURLPattern:(NSString *)URL {
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:[self pathComponentsFromURL:URL]];
    //* 只删除 pattern 的最后一级 */
    if (pathComponents.count >= 1) {
        //* 假如 URLPattern 为a/b/c ，component 就是 @"a.b.c" 正好可以作为 KVC 的key */
        /**
         *  假如 url 是 www.github.com 这种，就不行，因为 url 中本身就含有@"."，所以在匹配 url 的时候也会当成一个节点来处理，也就会出现匹配不到的情况
         */
        NSString *component = [pathComponents componentsJoinedByString:@"."];
        //* 字典中的keyPath是使用@"."来连接的，例如下面的示例中keyPath就是@"qintui.~.loginVC"，得到的value就是 （"_" = "<__NSMallocBlock__: 0x608000240900>"） */
        /**
         {
            qintui =     {
                "~" =         {
                    loginVC =             {
                        "_" = "<__NSMallocBlock__: 0x608000240900>";
                    };
                };
            };
        }
        */
         
        NSMutableDictionary *subRoutes = [self.routes valueForKeyPath:component];
        
        if (subRoutes.count >= 1) {
            NSString *lastComponent = pathComponents.lastObject;
            [pathComponents removeLastObject];
            
            subRoutes = self.routes;
            if (pathComponents.count) {
                NSString *componentWithOutLast = [pathComponents componentsJoinedByString:@"."];
                subRoutes = [self.routes valueForKeyPath:componentWithOutLast];
            }
            [subRoutes removeObjectForKey:lastComponent];
        }
    }
}


@end

#pragma mark - Category

@implementation NSDictionary (LYURLRouter)

- (NSString *)routerURL {
    return self[LYRouterParameterURL];
}

- (NSDictionary *)routerUserInfo {
    return self[LYRouterPatameterUserInfo];
}

@end


@implementation NSString (LYURLRouter)

- (NSString *)appendingParams:(NSDictionary *)params {
    if (!params || params.count<=0) {
        return self;
    }
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in params.keyEnumerator) {
        NSString* value = [params objectForKey:key];
        NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, /* allocator */
                                                                                                        (CFStringRef)value,
                                                                                                        NULL, /* charactersToLeaveUnescaped */
                                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
    }
    NSString *query = [pairs componentsJoinedByString:@"&"];
    return [NSString stringWithFormat:@"%@?%@", self, query];
}

@end


@implementation UIViewController (LYURLRouter)

+ (UIViewController *)currentViewController {
    UIViewController *rootViewController = self.applicationDelegate.window.rootViewController;
    return [self currentViewControllerFrom:rootViewController];
}

+(UINavigationController *)currentNavigationViewController {
    UIViewController *currentViewController = [self currentViewController];
    return currentViewController.navigationController;
}
+ (id<UIApplicationDelegate>)applicationDelegate {
    return [UIApplication sharedApplication].delegate;
}

/** 递归拿到当控制器 */
+ (UIViewController *)currentViewControllerFrom:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [self currentViewControllerFrom:navigationController.viewControllers.lastObject];
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tableBarController = (UITabBarController *)viewController;
        return [self currentViewControllerFrom:tableBarController.selectedViewController];
    } else if (viewController.presentedViewController != nil) {
        return [self currentViewControllerFrom:viewController.presentedViewController];
    } else {
        return viewController;
    }
}

@end
