//
//  FAHorizontalMeterView.m
//  CarDash
//
//  Created by Jeff McFadden on 6/26/15.
//  Copyright (c) 2015 ForgeApps. All rights reserved.
//

#import "FAHorizontalMeterView.h"

@import CoreText;

@implementation FAHorizontalMeterView

- (void)setCurrentValue:(CGFloat)currentValue
{
    _currentValue = currentValue;
    
    [self setNeedsDisplay];
}

- (CGFloat)currentValue
{
    return _currentValue;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat barHeight = self.bounds.size.height - 12;
    
    CGRect neutralBackgroundRect = self.bounds;
    neutralBackgroundRect.size.height = barHeight;
    
    //Fill self with neutral to start
    CGContextSetFillColorWithColor(context, self.neutralColor.CGColor);
    CGContextFillRect(context, neutralBackgroundRect);
    
    if ((unsigned)(self.currentValue-self.normalMinValue) <= (self.normalMaxValue-self.normalMinValue)) {
        CGContextSetFillColorWithColor(context, self.normalColor.CGColor);
    }else if ((unsigned)(self.currentValue-self.warningMinValue) <= (self.warningMaxValue-self.warningMinValue)) {
        CGContextSetFillColorWithColor(context, self.warningColor.CGColor);
    }else if ((unsigned)(self.currentValue-self.dangerMinValue) <= (self.dangerMaxValue-self.dangerMinValue)) {
        CGContextSetFillColorWithColor(context, self.dangerColor.CGColor);
    }else{
        CGContextSetFillColorWithColor(context, self.neutralColor.CGColor);
    }
    
    CGFloat progress;
    if (( self.maxValue - self.minValue ) != 0) {
        progress = ( self.currentValue - self.minValue ) / ( self.maxValue - self.minValue );
    }else{
        progress = 0;
    }

    CGRect r = self.bounds;
    
    r.size.width  = r.size.width * progress;
    r.size.height = barHeight;
    
    CGContextFillRect(context, r);
    
    CGContextTranslateCTM(context, 0.0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(context, 1.0, -1.0);

    [self drawValueNameText:context];
    [self drawValueText:context];
}

- (void)drawValueNameText:(CGContextRef)context
{
    UIFont *aFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:(self.bounds.size.height * 0.3)];
    
    CFDictionaryRef attr = (__bridge CFDictionaryRef)@{NSFontAttributeName:aFont,NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    CFStringRef stringRef= (__bridge CFStringRef)[NSString stringWithFormat:@"%@", self.valueName];
    
    CFAttributedStringRef text = CFAttributedStringCreate( nil, stringRef, attr );
    
    CTLineRef line = CTLineCreateWithAttributedString(text);
    
    CGRect bounds = CTLineGetBoundsWithOptions(line, kCTLineBoundsUseOpticalBounds);
    
    // set the line width to stroke the text with
    CGContextSetLineWidth(context, 1.0);
    // set the drawing mode to stroke
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    // Set text position and draw the line into the graphics context, text length and height is adjusted for
    CGFloat xn = 0;// + (self.bounds.size.height - bounds.size.height) / 2.0;
    CGFloat yn = 0 - bounds.origin.y;//self.bounds.size.height * 0.1;//p.element.y - bounds.midY
    
    CGContextSetTextPosition(context, xn, yn);
    // the line of text is drawn - see https://developer.apple.com/library/ios/DOCUMENTATION/StringsTextFonts/Conceptual/CoreText_Programming/LayoutOperations/LayoutOperations.html
    // draw the line of text
    CTLineDraw(line, context);
}

- (void)drawValueText:(CGContextRef)context
{
    UIFont *aFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:(self.bounds.size.height * 0.7)];
    
    CFDictionaryRef attr = (__bridge CFDictionaryRef)@{NSFontAttributeName:aFont,NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    CFStringRef stringRef= (__bridge CFStringRef)[NSString stringWithFormat:@"%0.0f", self.currentValue];
    
    CFAttributedStringRef text = CFAttributedStringCreate( nil, stringRef, attr );
    
    CTLineRef line = CTLineCreateWithAttributedString(text);
    
    CGRect bounds = CTLineGetBoundsWithOptions(line, kCTLineBoundsUseOpticalBounds);
    
    // set the line width to stroke the text with
    CGContextSetLineWidth(context, 1.0);
    // set the drawing mode to stroke
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    // Set text position and draw the line into the graphics context, text length and height is adjusted for
    CGFloat xn = 0 + (self.bounds.size.height - bounds.size.height) / 2.0;
    CGFloat yn = 13;//self.bounds.size.height * 0.1;//p.element.y - bounds.midY
    
    CGContextSetTextPosition(context, xn, yn);
    // the line of text is drawn - see https://developer.apple.com/library/ios/DOCUMENTATION/StringsTextFonts/Conceptual/CoreText_Programming/LayoutOperations/LayoutOperations.html
    // draw the line of text
    CTLineDraw(line, context);
}

@end
