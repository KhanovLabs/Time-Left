//
//  SKEventDetailsViewController.m
//  Time Left
//
//  Created by Salavat Khanov on 1/20/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "SKEventDetailsViewController.h"
#import "SKAppDelegate.h"
#import "GAIDictionaryBuilder.h"

static NSString *kEventDetailsScreenName = @"Event Details";

@interface SKEventDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet SKProgressIndicator *progressView;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger tapCounter;

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender;


@end

@implementation SKEventDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:kEventDetailsScreenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - Setup View

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLabels];
    [self setupColors];
    [self setupProgressLabels];
    [self setupNavigationButtons];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
    self.tapCounter = 0;
}

- (void)setupColors
{
    SKAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSDictionary *colors = [delegate currentTheme];
    self.view.backgroundColor = [colors objectForKey:@"background"];
    // Transparent nav bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.nameLabel.textColor = [colors objectForKey:@"colorText"];
    self.descriptionLabel.textColor = [colors objectForKey:@"colorText"];
}

- (void)setupLabels
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.nameLabel.text = self.event.name;
    [UIView animateWithDuration:0.5 animations:^{
        self.nameLabel.alpha = 1.0;
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.progressView.alpha = 1.0;
    }];
    
    [UIView animateWithDuration:0.6 animations:^{
        self.descriptionLabel.alpha = 0.0;
    }];
    
    if ([self.event progress] < 0) {
        /*
         * Event not yet started
         * Cases:
         * 1) Starts Date
         * 2) Description (if available)
         * 3) Ends Date
         */
        switch (self.tapCounter % 3) {
            case 0:
                self.descriptionLabel.text = [NSString stringWithFormat:@"Starts on %@", [dateFormatter stringFromDate:self.event.startDate]];
                break;
            case 1:
                if (self.event.details.length) {
                    self.descriptionLabel.text = self.event.details;
                    break;
                } else {
                    self.tapCounter++;
                }
            default:
                self.descriptionLabel.text = [NSString stringWithFormat:@"Ends on %@", [dateFormatter stringFromDate:self.event.endDate]];
                break;
        }
        
    } else if ([self.event progress] >= 0 && [self.event progress] <= 1.0) {
        /*
         * Event in-progress
         * Cases:
         * 1) Description (if available)
         * 2) Ends Date
         */
        switch (self.tapCounter % 2) {
            case 0:
                if (self.event.details.length) {
                    self.descriptionLabel.text = self.event.details;
                    break;
                } else {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Ends on %@", [dateFormatter stringFromDate:self.event.endDate]];
                    break;
                }
            default:
                if (self.event.details.length) {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Ends on %@", [dateFormatter stringFromDate:self.event.endDate]];
                    break;
                } else {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Started on %@", [dateFormatter stringFromDate:self.event.startDate]];
                    break;
                }
        }
        
    } else if ([self.event progress] > 1.0) {
        /*
         * Event done
         * Cases:
         * 1) Description (if available)
         * 2) Ended Date
         */
        switch (self.tapCounter % 2) {
            case 0:
                if (self.event.details.length) {
                    self.descriptionLabel.text = self.event.details;
                    break;
                } else {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Ended on %@", [dateFormatter stringFromDate:self.event.endDate]];
                    break;
                }
            default:
                if (self.event.details.length) {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Ended on %@", [dateFormatter stringFromDate:self.event.endDate]];
                    break;
                } else {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Started on %@", [dateFormatter stringFromDate:self.event.startDate]];
                    break;
                }
        }
    }
    
    // Animate fade-in
    [UIView animateWithDuration:0.6 animations:^{
        self.descriptionLabel.alpha =  0.65;
    }];
}

- (void)setupNavigationButtons
{
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareBurronPressed)];
    [self.navigationItem setRightBarButtonItem:shareButton];
    // Back button
    UIFont *backButtonFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName : backButtonFont} forState:UIControlStateNormal];
}

- (void)setupProgressLabels
{
    // Set percent for progress indicator
    self.progressView.percentInnerCircle = [self.event progress] * 100;
    
    // Set the best number and word to display
    NSDictionary *options = [self.event bestNumberAndText];
    self.progressView.progressLabel.text = [options valueForKey:@"number"];
    self.progressView.metaLabel.text = [options valueForKey:@"text"];
}

- (void)updateProgressView
{
    // Redraw
    [self setupProgressLabels];
    [self.progressView setNeedsDisplay];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender
{
    self.tapCounter++;
    [self setupLabels];
}


#pragma mark - Sharing

- (void)shareBurronPressed
{
    // prepare string
    NSString *shareString;
    if (self.event.details.length == 0) {
        shareString = [NSString stringWithFormat: @"%@ (%@)", self.nameLabel.text, self.descriptionLabel.text];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        shareString = [NSString stringWithFormat: @"%@ (%@): %@", self.nameLabel.text, [dateFormatter stringFromDate:self.event.endDate], self.descriptionLabel.text];
    }
    
    // prepare image
    CGFloat verticalOffset = 130.0;
    UIImage *finalImage = [self cropImage:[self screenshot] byOffset:verticalOffset];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[shareString, finalImage] applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop];
	[self presentViewController:avc animated:YES completion:NULL];
    
    // GA
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:kEventDetailsScreenName];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"Share"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

#pragma mark — Screenshot

- (UIImage *)screenshot
{
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)cropImage:(UIImage *)image byOffset:(CGFloat) verticalOffset
{
    CGRect cropRect = CGRectMake(0, verticalOffset, image.size.width * 2.0, image.size.height * 2.0 - verticalOffset);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedImage;
}


@end
