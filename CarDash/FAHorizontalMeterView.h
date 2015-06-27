//
//  FAHorizontalMeterView.h
//  CarDash
//
//  Created by Jeff McFadden on 6/26/15.
//  Copyright (c) 2015 ForgeApps. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface FAHorizontalMeterView : UIView {
    CGFloat _currentValue;
}

@property (nonatomic, strong) IBInspectable NSString *valueName;

@property (nonatomic, assign) IBInspectable CGFloat currentValue;

@property (nonatomic, assign) IBInspectable CGFloat minValue;
@property (nonatomic, assign) IBInspectable CGFloat maxValue;

@property (nonatomic, assign) IBInspectable CGFloat dangerMinValue;
@property (nonatomic, assign) IBInspectable CGFloat dangerMaxValue;

@property (nonatomic, assign) IBInspectable CGFloat warningMinValue;
@property (nonatomic, assign) IBInspectable CGFloat warningMaxValue;

@property (nonatomic, assign) IBInspectable CGFloat normalMinValue;
@property (nonatomic, assign) IBInspectable CGFloat normalMaxValue;

@property (nonatomic, strong) IBInspectable UIColor *dangerColor;
@property (nonatomic, strong) IBInspectable UIColor *warningColor;
@property (nonatomic, strong) IBInspectable UIColor *normalColor;
@property (nonatomic, strong) IBInspectable UIColor *neutralColor;

@end
