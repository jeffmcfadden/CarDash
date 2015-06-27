//
//  FAHorizontalMeterView.h
//  CarDash
//
//  Created by Jeff McFadden on 6/26/15.
//  Copyright (c) 2015 ForgeApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAHorizontalMeterViewController : UIViewController {
    CGFloat _currentValue;
}

@property (nonatomic, assign) IBInspectable CGFloat minValue;
@property (nonatomic, assign) IBInspectable CGFloat maxValue;

@property (nonatomic, assign) IBInspectable CGFloat currentValue;

@property (nonatomic) IBInspectable UIColor *dangerColor;
@property (nonatomic) IBInspectable UIColor *goodColor;
@property (nonatomic) IBInspectable UIColor *neutralColor;

@property (nonatomic) NSIndexSet *goodValueRanges;
@property (nonatomic) NSIndexSet *dangerValueRanges;

@end
