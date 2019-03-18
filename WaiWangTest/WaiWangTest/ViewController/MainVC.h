//
//  MainVC.h
//  YueYaoWang
//
//  Created by apple on 16/1/20.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeReaderViewController.h"


@interface MainVC : UIViewController

+ (void)showWithContro:(UIViewController *)contro;

- (void)showStoreVersion:(NSString *)storeVersion openUrl:(NSString *)openUrl;

@end
