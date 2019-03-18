//
//  TopView.m
//  DongLongYiKangShangCheng
//
//  Created by apple on 2018/7/23.
//  Copyright © 2018年 TW. All rights reserved.
//

#import "TopView.h"

@interface TopView ()

@end

@implementation TopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 添加按钮
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, (self.frame.size.height-35)/2, 35, 35)];
        [btn setTitle:@"返回" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(returnSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        // 添加底部分隔线
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, Screen_width, 0.5)];
        view.backgroundColor = [UIColor colorWithRed:197/255.0 green:197/255.0 blue:197/255.0 alpha:1];
        [self addSubview:view];
    }
    return self;
}

- (void)returnSelect:(id)sender {
    self.returnBlock ? self.returnBlock() : nil;
}

@end
