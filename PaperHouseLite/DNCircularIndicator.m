//
//  DNCircularIndicator.m
//  CircularIndicator
//
//  Created by Xu Jun on 5/8/13.
//  Copyright (c) 2013 Xu Jun. All rights reserved.
//

#import "DNCircularIndicator.h"

@implementation DNCircularIndicator
{
    NSTimer *updateTimer;
    CGFloat deltaAngle;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _minValue = 0;
        _maxValue = 100;
        _doubleValue = 0;
        [self setIndeterminate:NO];
    }
    
    return self;
}

- (void)setupUpdateTimer
{
    if(!updateTimer) {
        updateTimer = [NSTimer timerWithTimeInterval:1/30.0f
                                              target:self
                                            selector:@selector(updateIndeterminate)
                                            userInfo:nil
                                             repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:updateTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)setIndeterminate:(BOOL)indeterminate
{
    if(indeterminate) {
        _minValue = 0;
        _maxValue = 100;
        _doubleValue = 25;
        [self setupUpdateTimer];
    }
    else {
        [updateTimer invalidate];
        updateTimer = nil;
        _minValue = 0;
        _maxValue = 100;
        deltaAngle = 0;
    }
    _indeterminate = indeterminate;
    [self setNeedsDisplay:YES];
}

- (void)setDoubleValue:(double)doubleValue
{
    NSLog(@"Value: %f", doubleValue);
    _doubleValue = doubleValue;
    [self setNeedsDisplay:YES];
}

- (void)setMinValue:(double)minValue
{
    _minValue = minValue;
    [self setNeedsDisplay:YES];
}

- (void)setMaxValue:(double)maxValue
{
    _maxValue = maxValue;
    [self setNeedsDisplay:YES];
}

- (void)startAnimation:(id)sender
{
    [self setupUpdateTimer];
    [updateTimer fire];
}

- (void)stopAnimation:(id)sender
{
    [updateTimer invalidate];
    updateTimer = nil;
}


- (void)updateIndeterminate
{
    const float stepper= 0.04;
    deltaAngle += stepper;
    if(deltaAngle > 1) {
        deltaAngle = 0;
    }
    [self setNeedsDisplay:YES];
}

- (NSBezierPath*)clipPartOfCircular:(NSRect)circular percentBegin:(CGFloat)begin percentage:(CGFloat)p
{
    
    CGFloat angleBegin =360*begin;
    CGFloat angleEnd = 360*p + angleBegin;
    CGFloat radius = NSWidth(circular)/2.0;
    
    NSPoint center = NSMakePoint(NSWidth(circular)/2 + NSMinX(circular),
                                 NSHeight(circular)/2 + NSMinY(circular));
    
    NSBezierPath *bezipath = [NSBezierPath bezierPath];
            
    [bezipath moveToPoint:center];
    [bezipath appendBezierPathWithArcWithCenter:center radius:radius startAngle:90-angleBegin endAngle:90-angleEnd clockwise:YES];
    [bezipath lineToPoint:center];
    [bezipath closePath];
    
    return bezipath;
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect canvasRect = dirtyRect;
    CGFloat side = (NSWidth(canvasRect) > NSHeight(canvasRect)) ? NSHeight(canvasRect) : NSWidth(canvasRect);
    CGFloat thickness = side*0.15;
    CGFloat lineWidth = 1;
    
    NSRect outCircleRect;
    NSRect inCircleRect;
    NSBezierPath *circlePath;
    NSBezierPath *inCircle;
    
#if 1
    //draw outline
    [NSGraphicsContext saveGraphicsState];
    outCircleRect = NSMakeRect(0, 0, side, side);
    outCircleRect.origin.x = (NSWidth(canvasRect) - side) / 2.0;
    outCircleRect.origin.y = (NSHeight(canvasRect) - side) / 2.0;
    
    inCircleRect = NSInsetRect(outCircleRect, thickness, thickness);
    
    circlePath = [NSBezierPath bezierPathWithOvalInRect:outCircleRect];
    inCircle = [NSBezierPath bezierPathWithOvalInRect:inCircleRect];
    [circlePath appendBezierPath:inCircle];
    
    [circlePath setWindingRule:NSEvenOddWindingRule];
    [[NSColor colorWithDeviceRed:0.5 green:0.5 blue:0.5 alpha:0.0] setStroke];
    [circlePath stroke];
    [NSGraphicsContext restoreGraphicsState];
#endif
    //draw indicator color
    [NSGraphicsContext saveGraphicsState];
    CGFloat sideNoLine = side - lineWidth;
    outCircleRect = NSMakeRect(0, 0, sideNoLine, sideNoLine);
    outCircleRect.origin.x = (NSWidth(canvasRect) - sideNoLine) / 2.0;
    outCircleRect.origin.y = (NSHeight(canvasRect) - sideNoLine) / 2.0;
    
    inCircleRect = NSInsetRect(outCircleRect, thickness - lineWidth, thickness - lineWidth);
    
    circlePath = [NSBezierPath bezierPathWithOvalInRect:outCircleRect];
    inCircle = [NSBezierPath bezierPathWithOvalInRect:inCircleRect];
    [circlePath appendBezierPath:inCircle];
    [circlePath setWindingRule:NSEvenOddWindingRule];
    
    CGFloat p = (self.doubleValue - self.minValue)/(self.maxValue - self.minValue);

    if(!self.indeterminate) {
        NSBezierPath *clipPath = [self clipPartOfCircular:outCircleRect percentBegin:0 percentage:p];
        [clipPath addClip];
        [[NSColor colorWithDeviceRed:100/255.0 green:200/255.0 blue:247/255.0 alpha:0.9] setFill];
        [circlePath fill];
    }
    else {
        NSBezierPath *clipPath = [self clipPartOfCircular:outCircleRect percentBegin:deltaAngle percentage:p];
        [clipPath addClip];
        NSGradient *gradient = [[[NSGradient alloc]initWithStartingColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.3]
                                                             endingColor:[NSColor colorWithDeviceRed:0.1 green:0.1 blue:0.1 alpha:0.5]] autorelease];
        [gradient drawInBezierPath:circlePath angle:270-360*deltaAngle];
    }
    [NSGraphicsContext restoreGraphicsState];
}

- (void)dealloc
{
    [updateTimer invalidate];
    updateTimer = nil;
    [super dealloc];
}

@end
