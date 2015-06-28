//
//  SVBlurView.m
//  SVBlurView
//
//  Created by Sam Vermette on 19.10.13.
//  Copyright (c) 2013 Sam Vermette. All rights reserved.
//

#import "SVBlurView.h"
#import "UIImage+ImageEffects.h"

NSString * const SVBlurViewImageKey = @"SVBlurViewImageKey";

@interface SVBlurView ()

@property (nonatomic, strong) dispatch_source_t updateBlurTimer;

@end


@implementation SVBlurView

- (id)init {
    if(self = [super init]) {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.blurRadius = 20;
    self.saturationDelta = 1.5;
    self.tintColor = nil;
    self.viewToBlur = nil;
    self.updateBlurInterval = 0;
    self.clipsToBounds = YES;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:[UIImage imageWithCGImage:(CGImageRef)self.layer.contents] forKey:SVBlurViewImageKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    self.layer.contents = (id)[[coder decodeObjectForKey:SVBlurViewImageKey] CGImage];
}

- (UIView *)viewToBlur {
    if(_viewToBlur)
        return _viewToBlur;
    return self.superview;
}

- (void)setUpdateBlurInterval:(float)updateBlurInterval {
    self.updateBlurTimer = (_updateBlurInterval=updateBlurInterval)>0?CreateDispatchTimer(_updateBlurInterval*NSEC_PER_SEC, 1ull*NSEC_PER_SEC, dispatch_get_main_queue(), ^{ [self updateBlur]; }):nil;
}

- (void)setUpdateBlurTimer:(dispatch_source_t)updateBlurTimer {
    if(_updateBlurTimer) dispatch_source_cancel(_updateBlurTimer);
    if((_updateBlurTimer=updateBlurTimer))
        dispatch_resume(_updateBlurTimer);
}

dispatch_source_t CreateDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer) {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
    }
    return timer;
}

- (void)updateBlur {
    UIGraphicsBeginImageContextWithOptions(self.viewToBlur.bounds.size, NO, 0.0);
    [self.viewToBlur drawViewHierarchyInRect:self.viewToBlur.bounds afterScreenUpdates:NO];
    UIImage *complexViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    float scale = [UIScreen mainScreen].scale;
    CGRect translationRect = [self convertRect:self.bounds toView:self.viewToBlur];
    CGRect scaledSuperviewFrame = CGRectApplyAffineTransform(translationRect, CGAffineTransformMakeScale(scale, scale));
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(complexViewImage.CGImage, scaledSuperviewFrame);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef scale:complexViewImage.scale orientation:complexViewImage.imageOrientation];
    UIImage *blurredImage = [self applyBlurToImage:croppedImage];
    CGImageRelease(croppedImageRef);
    
    self.layer.contents = (id)blurredImage.CGImage;
}

- (UIImage *)applyBlurToImage:(UIImage *)image {
    return [image applyBlurWithRadius:self.blurRadius
                            tintColor:self.tintColor
                saturationDeltaFactor:self.saturationDelta
                            maskImage:nil];
}

- (void)didMoveToSuperview {
    if(self.superview && self.viewToBlur.superview) {
        self.backgroundColor = [UIColor clearColor];
        [self updateBlur];
    }
    else if (!self.layer.contents) {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
