//
//  NSString+Utils.m
//  86YYZX
//
//  Created by apple on 2017/8/12.
//  Copyright © 2017年 jztw. All rights reserved.
//

#import "NSString+Utils.h"
#import <objc/runtime.h>

@interface NSString()<UIAlertViewDelegate>

@property (nonatomic, copy) void(^confirmBLock)();
@property (nonatomic, copy) void(^cancelBLock)();

@end

@implementation NSString (Utils)

static char confirmKey;
static char cancelKey;

- (void)setConfirmBLock:(void (^)())confirmBLock {
    objc_setAssociatedObject(self, &confirmKey, confirmBLock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)())confirmBLock {
    return  objc_getAssociatedObject(self, &confirmKey);
}

- (void)setCancelBLock:(void (^)())cancelBLock {
    objc_setAssociatedObject(self, &cancelKey, cancelBLock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)())cancelBLock {
    return  objc_getAssociatedObject(self, &cancelKey);
}

/**
 *  截取URL中的参数
 *
 *  @return NSMutableDictionary parameters
 */
- (NSMutableDictionary *)getURLParameters {
    
    // 查找参数
    NSRange range = [self rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [self substringFromIndex:range.location + 1];
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params;
}

/**
 *  判断字符串是否为网址
 *
 *  @return NSMutableDictionary parameters
 */
- (BOOL)isUrlString
{
    NSString *emailRegex = @"[a-zA-z]+://.*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

/**
 *  弹框提醒
 *
 *  @return tipStr 提醒内容
 */
+ (void)alert:(NSString *)title tip:(NSString *)tipStr cancelBtnTitle:(NSString *)cancelBtnTitle otherBtnTitle:(NSString *)otherBtnTitle confirmBLock:(void (^)())confirmBLock cancelBlock:(void(^)())cancelBlock
{
    NSString *str = [NSString string];
    
    str.confirmBLock = confirmBLock;
    str.cancelBLock = cancelBlock;
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:tipStr delegate:str cancelButtonTitle:cancelBtnTitle otherButtonTitles:otherBtnTitle, nil];
    [alert show];
}

#pragma mark ----UIAlertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            //            NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
            //            if ([btnTitle isEqualToString:@"确定"]) {
            //                self.confirmBLock ? self.confirmBLock() : nil;
            //            }else {
            self.cancelBLock ? self.cancelBLock() : nil;
            //            }
        }
            break;
        case 1:
        {
            self.confirmBLock ? self.confirmBLock() : nil;
        }
            break;
        default:
            break;
    }
}

@end
