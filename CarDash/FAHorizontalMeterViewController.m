//
//  FAHorizontalMeterView.m
//  CarDash
//
//  Created by Jeff McFadden on 6/26/15.
//  Copyright (c) 2015 ForgeApps. All rights reserved.
//

#import "FAHorizontalMeterViewController.h"

@interface FAHorizontalMeterViewController()

@property (nonatomic, weak) IBOutlet UILabel *currentValueLabel;

@property (nonatomic, weak) IBOutlet UIView *meterColorView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *meterColorViewWidthConstraint;

@end


@implementation FAHorizontalMeterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setCurrentValue:(CGFloat)currentValue
{
    _currentValue = currentValue;
    
    [self updateLayout];
}

- (CGFloat)currentValue
{
    return _currentValue;
}

- (void)layoutSubviews
{
    [self updateLayout];
}

- (void)updateLayout
{
    self.currentValueLabel.text = [NSString stringWithFormat:@"%.0f", self.currentValue];
    
    CGFloat progress = ( self.currentValue - self.minValue ) / ( self.maxValue - self.minValue )
    ;
    
    NSLog( @"progress: %0.2f", progress );
    
    CGFloat newWidth = progress * self.view.bounds.size.width;
    
    if (newWidth < 0) {
        newWidth = 0;
    }else if( newWidth > self.view.bounds.size.width ) {
        newWidth = self.view.bounds.size.width;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.meterColorViewWidthConstraint.constant = newWidth;
    }];
}


@end
