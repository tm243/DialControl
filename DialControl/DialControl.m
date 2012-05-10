/**
 *  (c) 2012 Thomas Moenicke
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <QuartzCore/QuartzCore.h>
#import "DialControl.h"

@implementation DialControl

@synthesize minimumValue, 
            maximumValue, 
            value;

- (void) setUp
{
    minimumValue = 0.0f;
    maximumValue = 1.0f;
    
    value = 0.0;    
    [self calculateAngleFromValue];
    
    _center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    NSString* imageFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"knob_foreground.png"];
    CGDataProviderRef rKnob = CGDataProviderCreateWithFilename([imageFileName UTF8String]);
    _knobImageRef = CGImageCreateWithPNGDataProvider(rKnob, NULL, NO, kCGRenderingIntentDefault);  

    NSString* knobBackgroundFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"knob_background.png"];
    CGDataProviderRef rBackground = CGDataProviderCreateWithFilename([knobBackgroundFileName UTF8String]);
    _knobBackgroundImageRef = CGImageCreateWithPNGDataProvider(rBackground, NULL, NO, kCGRenderingIntentDefault);  
        
    [self setNeedsDisplay];
}

- (id) initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self setUp];
	}
	return self;
}

- (id) initWithCoder:(NSCoder*)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self setUp];
	}
	return self;
}

- (void) setValue:(float)newValue
{
    value = newValue;
    [self calculateAngleFromValue];    
    [self setNeedsDisplay];
}

/*
 * map angle - value
 * value = (angle - startangle) / (endangle - startangle)
 * range from -PI to +PI
 */

const float startAngle = -2.0f;
const float endAngle   = +2.0f;

- (void) calculateValueFromAngle
{
    float p = (_angle - startAngle) / (endAngle - startAngle);
    value = (maximumValue - minimumValue) * p;
}

- (void) calculateAngleFromValue
{
    const float angleRange = endAngle - startAngle;
    const float valueRange = maximumValue - minimumValue;
    _angle = startAngle + angleRange * ((value - minimumValue) / valueRange);
}

- (void) angleTouchPointToCenter
{
    const CGFloat x = _touchPoint.x - _center.x;
    const CGFloat y = _center.y - _touchPoint.y;
    _angle = atan2(x,y);
    
    if (_angle < startAngle)
        _angle = startAngle;
    else if (_angle > endAngle)
        _angle = endAngle;
}

- (BOOL) beginTrackingWithTouch:(UITouch*) touch withEvent:(UIEvent*) event
{
    _touchPoint = [touch locationInView:self];

    return YES;
}

- (BOOL) continueTrackingWithTouch:(UITouch*) touch withEvent:(UIEvent*) event
{
    _touchPoint = [touch locationInView:self];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self angleTouchPointToCenter];
    [self calculateValueFromAngle];
    [self setNeedsDisplay];
    
    return YES;    
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();

    if (!_center.x) {
        _center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }

    const CGRect imageRect = self.bounds;

    CGContextDrawImage(contextRef, imageRect, _knobBackgroundImageRef);    
    
    // rotation around center point
    CGContextSaveGState(contextRef);

    CGContextTranslateCTM(contextRef, _center.x, _center.y);
    CGContextRotateCTM(contextRef, _angle);
    CGContextTranslateCTM(contextRef, -_center.x, -_center.y);
    
    CGContextDrawImage(contextRef, imageRect, _knobImageRef);

    CGContextRestoreGState(contextRef);
    
    // debug
    /*
    CGContextBeginPath(contextRef);
    CGFloat zStrokeColour1[4]    = {0.0,1.0,1.0,1.0};
    CGContextSetStrokeColor(contextRef, zStrokeColour1);
    CGContextMoveToPoint(contextRef, _touchPoint.x, _touchPoint.y);
    CGContextAddLineToPoint(contextRef, _center.x, _center.y);
    CGContextDrawPath(contextRef, kCGPathStroke);
     */
}

@end
