//
//  SKEventDetailsViewController.m
//  Time Left
//
//  Created by Salavat Khanov on 1/20/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "SKEventDetailsViewController.h"

@interface SKEventDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet SKProgressIndicator *progressView;
@property (strong, nonatomic) NSTimer *timer;

- (IBAction)swipeGesture:(id)sender;

@end

@implementation SKEventDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLabels];
    [self setupColors];
    [self setupShareButton];
    [self updateProgressView];
}

- (void)setupColors
{
    UIColor *dayColor = [UIColor colorWithRed:255/255.0 green:149/255.0 blue:0/255.0 alpha:1.0];
    self.view.backgroundColor = dayColor;
    self.navigationController.navigationBar.backgroundColor = dayColor;
}

- (void)setupLabels
{
    self.nameLabel.text = self.event.name;
    if (self.event.details.length == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        self.descriptionLabel.text = [dateFormatter stringFromDate:self.event.endDate];
    } else {
        self.descriptionLabel.text = self.event.details;
    }
}

- (void)setupShareButton
{
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareBurronPressed)];
    [self.navigationItem setRightBarButtonItem:shareButton];
}

- (void)updateProgressView
{
    // Set percent for progress indicator
    NSInteger currentProgressPercent = lroundf([self.event progress] * 100);
    self.progressView.percentInnerCircle = currentProgressPercent;
        
    // Set the best number and word to display
    NSDictionary *options = [self.event bestNumberAndText];
    self.progressView.progressLabel.text = [options valueForKey:@"number"];
    self.progressView.metaLabel.text = [options valueForKey:@"text"];
    
    // Redraw
    [self.progressView setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
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

- (IBAction)swipeGesture:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Sharing

- (void)shareBurronPressed
{
    // prepare string
    NSString *shareString = [NSString stringWithFormat: @"%@ (%@) — ", self.nameLabel.text, self.descriptionLabel.text];
    
    // prepare image
    CGFloat verticalOffset = 130.0;
    UIImage *finalImage = [self cropImage:[self screenshot] byOffset:verticalOffset];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[shareString, finalImage] applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop];
	[self presentViewController:avc animated:YES completion:NULL];
}

#pragma mark — Screenshot

- (UIImage *) screenshot
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

- (UIImage *) cropImage: (UIImage *) image byOffset: (CGFloat) verticalOffset {

    CGRect cropRect = CGRectMake(0, verticalOffset, image.size.width * 2.0, image.size.height * 2.0 - verticalOffset);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

@end
