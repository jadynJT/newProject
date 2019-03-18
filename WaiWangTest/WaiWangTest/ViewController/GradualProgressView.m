//
//  GradualProgressView.m
//  ColorGradualProgress
//
//  Created by dhuil on 15/9/12.
//  Copyright (c) 2015年 Gavin Li. All rights reserved.
//

#import "GradualProgressView.h"


@interface GradualProgressView ()

@property (nonatomic, strong) CALayer * maskLayer;

@end


@implementation GradualProgressView

/**  init  */
- (instancetype)initWithFrame:(CGRect )frame
{
    if ([super initWithFrame:frame])
    {
        CAGradientLayer * layer = (CAGradientLayer *)[self layer];
        [layer setStartPoint:CGPointMake(0.0, 0.5)];
        [layer setEndPoint:CGPointMake(1.0, 0.5)];
        
        NSMutableArray *colors = [NSMutableArray array];
        
        for (NSInteger hue = 0; hue <= 360; hue += 5)
        {
           UIColor * color = [UIColor colorWithHue:1.0 * hue / 360
                                        saturation:0.5
                                        brightness:1.0
                                             alpha:1.0];
            [colors addObject:(id)[color CGColor]];
        }
        [layer setColors:[NSArray arrayWithArray:colors]];
        
        
        self.maskLayer = [CALayer layer];
        [self.maskLayer setFrame:CGRectMake(0.0, 0.0, 0.0, frame.size.height)];
        [self.maskLayer setBackgroundColor:[[UIColor whiteColor] CGColor]];
        [layer setMask:self.maskLayer];

        
    }
    return self;
}

+ (Class)layerClass
{
    return [CAGradientLayer class];
}


- (void)setProgress:(CGFloat)value {
    
    if (_progress != value) {
        
        // progress values go from 0.0 to 1.0
        
        _progress = MIN(1.0, fabs(value));
        [self setNeedsLayout];
    }
}

- (NSArray *)shiftColors:(NSArray *)colors {
    
    // Moves the last item in the array to the front
    // shifting all the other elements.
    
    NSMutableArray *mutable = [colors mutableCopy];
    id last = [mutable lastObject];
    [mutable removeLastObject];
    [mutable insertObject:last atIndex:0];
    return [NSArray arrayWithArray:mutable];
}


- (void)performAnimation
{
    CAGradientLayer *layer = (id)[self layer];
    NSArray *fromColors = [layer colors];
    NSArray *toColors = [self shiftColors:fromColors];
    [layer setColors:toColors];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    [animation setFromValue:fromColors];
    [animation setToValue:toColors];
    [animation setRemovedOnCompletion:YES];
    [animation setDuration:0.03];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [animation setDelegate:self];
    
    [layer addAnimation:animation forKey:@"animateGradient"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    
    if ([self isAnimating]) {
        
        [self performAnimation];
    }
}

- (void)layoutSubviews
{
    CGRect maskRect = [self.maskLayer frame];
    maskRect.size.width = CGRectGetWidth([self bounds]) * self.progress;
    [self.maskLayer setFrame:maskRect];
}


- (void)startAnimating {
    
    if (![self isAnimating]) {
        
        _animating = YES;
        
        [self performAnimation];
    }
}

- (void)stopAnimating {
    
    if ([self isAnimating]) {
        
        _animating = NO;
    }
}


@end
