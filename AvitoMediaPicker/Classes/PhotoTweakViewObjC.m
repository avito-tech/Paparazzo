//
//  PhotoView.m
//  PhotoTweaks
//
//  Created by Tu You on 14/12/2.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "PhotoTweakViewObjC.h"


@interface PhotoScrollViewObjC : UIScrollView

@property (nonatomic, strong) UIImageView *photoContentView;

@end

@implementation PhotoScrollViewObjC

- (void)setContentOffsetY:(CGFloat)offsetY
{
    CGPoint contentOffset = self.contentOffset;
    contentOffset.y = offsetY;
    self.contentOffset = contentOffset;
}

- (void)setContentOffsetX:(CGFloat)offsetX
{
    CGPoint contentOffset = self.contentOffset;
    contentOffset.x = offsetX;
    self.contentOffset = contentOffset;
}

- (CGFloat)zoomScaleToBound
{
    CGFloat scaleW = self.bounds.size.width / self.photoContentView.bounds.size.width;
    CGFloat scaleH = self.bounds.size.height / self.photoContentView.bounds.size.height;
    CGFloat max = MAX(scaleW, scaleH);
    
    return max;
}

@end

@interface PhotoTweakViewObjC () <UIScrollViewDelegate>

@property (nonatomic, strong, readonly) UIImageView *photoContentView;

@property (nonatomic, strong) PhotoScrollViewObjC *scrollView;
@property (nonatomic, strong) UIView *cropView;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, assign) CGFloat angle;

@property (nonatomic, assign) BOOL manualZoomed;

// masks
@property (nonatomic, strong) UIView *topMask;
@property (nonatomic, strong) UIView *leftMask;
@property (nonatomic, strong) UIView *bottomMask;
@property (nonatomic, strong) UIView *rightMask;

@end

@implementation PhotoTweakViewObjC {
    CGSize _maximumCanvasSize;
    CGFloat _centerY;
    CGPoint _originalPoint;
    CGFloat _maxRotationAngle;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _maxRotationAngle = 0.5;    // TODO

        _scrollView = [PhotoScrollViewObjC new];
        _scrollView.bounces = YES;
        _scrollView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 10;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.clipsToBounds = NO;
        [self addSubview:_scrollView];

        _photoContentView = [[UIImageView alloc] initWithImage:nil];
        _photoContentView.backgroundColor = [UIColor clearColor];
        _photoContentView.userInteractionEnabled = YES;
        _scrollView.photoContentView = self.photoContentView;
        [self.scrollView addSubview:_photoContentView];

        _cropView = [UIView new];
        [self addSubview:_cropView];
        
        UIColor *maskColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];

        _topMask = [UIView new];
        _topMask.backgroundColor = maskColor;
        [self addSubview:_topMask];

        _bottomMask = [UIView new];
        _bottomMask.backgroundColor = maskColor;
        [self addSubview:_bottomMask];

        [self updateMasks:NO];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self _calculateFrames];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _photoContentView.image = image;
    
    [self _calculateFrames];
}

// layoutSubviews will be called each time scrollView rotates, but we don't want it
- (void)_calculateFrames
{
    if (self.frame.size.width == 0 || self.frame.size.height == 0 || _image == nil) {
        return;
    }
    
    const CGFloat aspectRatio = 4.0f / 3.0f;
    
    // scale the image
    _maximumCanvasSize = CGSizeMake(
                                    self.frame.size.width,
                                    self.frame.size.width / aspectRatio
                                    );
    
    CGFloat scaleX = _image.size.width / _maximumCanvasSize.width;
    CGFloat scaleY = _image.size.height / _maximumCanvasSize.height;
    CGFloat scale = fmaxf(scaleX, scaleY);
    CGRect bounds = CGRectMake(0, 0, _image.size.width / scale, _image.size.height / scale);
    
    _originalSize = bounds.size;
    _centerY = _maximumCanvasSize.height / 2;
    
    _scrollView.bounds = bounds;
    _scrollView.center = self.center;
    _scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    
    _photoContentView.frame = self.scrollView.bounds;
    
    _cropView.bounds = self.scrollView.frame;
    _cropView.center = self.scrollView.center;
    
    _originalPoint = [self convertPoint:self.scrollView.center toView:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    static int layoutCount = 0;
    
    NSLog(@"layout #%d (bounds = %@)", layoutCount++, NSStringFromCGRect(self.bounds));
    
    _slider.bounds = CGRectMake(0, 0, 260, 20);
    _slider.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) - 135);
    
    _resetBtn.bounds = CGRectMake(0, 0, 60, 20);
    _resetBtn.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) - 95);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.slider.frame, point)) {
        return self.slider;
    } else if (CGRectContainsPoint(self.resetBtn.frame, point)) {
        return self.resetBtn;
    }
    
    return self.scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoContentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.manualZoomed = YES;
}

- (void)updateMasks:(BOOL)animate
{
    void (^animationBlock)(void) = ^(void) {
        self.topMask.frame = CGRectMake(0, 0, self.cropView.frame.origin.x + self.cropView.frame.size.width, self.cropView.frame.origin.y);
        self.leftMask.frame = CGRectMake(0, self.cropView.frame.origin.y, self.cropView.frame.origin.x, self.frame.size.height - self.cropView.frame.origin.y);
        self.bottomMask.frame = CGRectMake(self.cropView.frame.origin.x, self.cropView.frame.origin.y + self.cropView.frame.size.height, self.frame.size.width - self.cropView.frame.origin.x, self.frame.size.height - (self.cropView.frame.origin.y + self.cropView.frame.size.height));
        self.rightMask.frame = CGRectMake(self.cropView.frame.origin.x + self.cropView.frame.size.width, 0, self.frame.size.width - (self.cropView.frame.origin.x + self.cropView.frame.size.width), self.cropView.frame.origin.y + self.cropView.frame.size.height);
    };
    
    if (animate) {
        [UIView animateWithDuration:0.25 animations:animationBlock];
    } else {
        animationBlock();
    }
}

- (void)checkScrollViewContentOffset
{
    self.scrollView.contentOffsetX = MAX(self.scrollView.contentOffset.x, 0);
    self.scrollView.contentOffsetY = MAX(self.scrollView.contentOffset.y, 0);
    
    if (self.scrollView.contentSize.height - self.scrollView.contentOffset.y <= self.scrollView.bounds.size.height) {
        self.scrollView.contentOffsetY = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    }
    
    if (self.scrollView.contentSize.width - self.scrollView.contentOffset.x <= self.scrollView.bounds.size.width) {
        self.scrollView.contentOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    }
}

- (void)setImageRotation:(CGFloat)angle
{
    // update masks
    [self updateMasks:NO];
    
    // rotate scroll view
    self.angle = angle;
    self.scrollView.transform = CGAffineTransformMakeRotation(self.angle);
    
    // position scroll view
    CGFloat width = fabs(cos(self.angle)) * self.cropView.frame.size.width + fabs(sin(self.angle)) * self.cropView.frame.size.height;
    CGFloat height = fabs(sin(self.angle)) * self.cropView.frame.size.width + fabs(cos(self.angle)) * self.cropView.frame.size.height;
    CGPoint center = self.scrollView.center;
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGPoint contentOffsetCenter = CGPointMake(contentOffset.x + self.scrollView.bounds.size.width / 2, contentOffset.y + self.scrollView.bounds.size.height / 2);
    self.scrollView.bounds = CGRectMake(0, 0, width, height);
    CGPoint newContentOffset = CGPointMake(contentOffsetCenter.x - self.scrollView.bounds.size.width / 2, contentOffsetCenter.y - self.scrollView.bounds.size.height / 2);
    self.scrollView.contentOffset = newContentOffset;
    self.scrollView.center = center;
    
    // scale scroll view
    BOOL shouldScale = self.scrollView.contentSize.width / self.scrollView.bounds.size.width <= 1.0 || self.scrollView.contentSize.height / self.scrollView.bounds.size.height <= 1.0;
    if (!self.manualZoomed || shouldScale) {
        [self.scrollView setZoomScale:[self.scrollView zoomScaleToBound] animated:NO];
        self.scrollView.minimumZoomScale = [self.scrollView zoomScaleToBound];

        self.manualZoomed = NO;
    }
    
    [self checkScrollViewContentOffset];
}

- (void)resetBtnTapped:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        self.angle = 0;
        
        self.scrollView.transform = CGAffineTransformIdentity;
        self.scrollView.center = self.center;
        self.scrollView.bounds = CGRectMake(0, 0, self.originalSize.width, self.originalSize.height);
        self.scrollView.minimumZoomScale = 1;
        [self.scrollView setZoomScale:1 animated:NO];
        
        self.cropView.frame = self.scrollView.frame;
        self.cropView.center = self.scrollView.center;
        [self updateMasks:NO];
        
        [self.slider setValue:0.5 animated:YES];
    }];
}

- (CGPoint)photoTranslation
{
    CGRect rect = [self.photoContentView convertRect:self.photoContentView.bounds toView:self];
    CGPoint point = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
    CGPoint zeroPoint = CGPointMake(CGRectGetWidth(self.frame) / 2, _centerY);
    return CGPointMake(point.x - zeroPoint.x, point.y - zeroPoint.y);
}

@end
