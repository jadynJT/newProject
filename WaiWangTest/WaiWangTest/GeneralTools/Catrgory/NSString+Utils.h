//
//  NSString+Utils.h
//  86YYZX
//
//  Created by apple on 2017/8/12.
//  Copyright © 2017年 jztw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

// 截取URL中的参数
- (NSMutableDictionary *)getURLParameters;

// 判断字符串是否为网址
- (BOOL)isUrlString;

// 弹框提醒
+ (void)alert:(NSString *)title
           tip:(NSString *)tipStr
cancelBtnTitle:(NSString *)cancelBtnTitle
 otherBtnTitle:(NSString *)otherBtnTitle
  confirmBLock:(void(^)())confirmBLock
   cancelBlock:(void(^)())cancelBlock;

@end
