//
//  ViewController.m
//  SVBlurView
//
//  Created by Sam Vermette on 19.10.13.
//  Copyright (c) 2013 Sam Vermette. All rights reserved.
//

#import "ViewController.h"
#import "SVBlurView.h"


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    backgroundView.frame = self.view.bounds;
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundView];
    
    UILabel *helloLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 60, 200, 20)];
    helloLabel.text = @"SVBlurView";
    helloLabel.textColor = [UIColor redColor];
    helloLabel.textAlignment = NSTextAlignmentCenter;
    helloLabel.font = [UIFont boldSystemFontOfSize:20.f];
    [backgroundView addSubview:helloLabel];
    
    [UIView animateWithDuration:5 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        helloLabel.frame = CGRectMake(60, 320, 200, 20);
    } completion:nil];
    
    SVBlurView *blurView = [[SVBlurView alloc] initWithFrame:CGRectMake(60, 100, 200, 200)];
    blurView.blurRadius = 5.f;
    blurView.updateBlurInterval = 1.f/60; //60 fps
    blurView.viewToBlur = backgroundView;
    [self.view addSubview:blurView];
}

@end
