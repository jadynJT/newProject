//
//  LinkSkipViewController.h
//  DongLongYiKangShangCheng
//
//  Created by apple on 2018/7/21.
//  Copyright © 2018年 TW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinkSkipViewController : UIViewController

@property (nonatomic, copy) NSString *result;
@property (nonatomic, copy) void(^disappearBlock)();

@end
