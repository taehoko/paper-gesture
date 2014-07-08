//
//  MainViewController.m
//  paper-nav
//
//  Created by Taeho Ko on 7/1/14.
//  Copyright (c) 2014 google. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIView *headlineContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *headlineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *cardContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;


@property (nonatomic, retain) NSArray *headlineImages;
@property (nonatomic) int currentImageIndex;
@property (nonatomic) int cardViewIndex;
@property (nonatomic) float snapPositionX;

@property (nonatomic, assign) BOOL isVerticalGesture;
@property (nonatomic, assign) BOOL isCardsViewUp;


@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.menuImageView.alpha = 0.5;
    
    // Hide the navigation bar
    self.navigationController.navigationBar.hidden = YES;
    
    // Hide the status bar 1/2
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    // Instantiate the pan gesture recognizer to container view
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomPan:)];
    [self.headlineContainerView addGestureRecognizer:panGestureRecognizer];
    
    // Instantiate the pan gesture recognizer to cards view
    UIPanGestureRecognizer *panCardsGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onCardsPan:)];
    [self.cardContainerView addGestureRecognizer:panCardsGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeLeftCardGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onCardsSwipe:)];
    swipeLeftCardGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.cardContainerView addGestureRecognizer:swipeLeftCardGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeRightCardGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onCardsSwipe:)];
    swipeRightCardGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.cardContainerView addGestureRecognizer:swipeRightCardGestureRecognizer];
    
    swipeLeftCardGestureRecognizer.delegate = self;
    swipeRightCardGestureRecognizer.delegate = self;
    
    // Load headline images
    self.headlineImages = [NSArray arrayWithObjects:
                           [UIImage imageNamed:@"headline_01"],
                           [UIImage imageNamed:@"headline_02"],
                           [UIImage imageNamed:@"headline_03"],
                           [UIImage imageNamed:@"headline_04"],
                           [UIImage imageNamed:@"headline_05"],
                           nil];
    self.headlineImageView.image = [self.headlineImages objectAtIndex:0];
    self.currentImageIndex = 0;
    self.cardViewIndex = 0;
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self
                                   selector:@selector(changeHeadlineImage) userInfo:nil repeats:YES];
    
    self.isCardsViewUp = NO;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Using Simultaneous Gesture Recognizers
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// Hide the stauts bar 2/2
- (BOOL)prefersStatusBarHidden {
    return YES;
}

// Implement the pan gesture handler method for headline container
- (void)onCustomPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    //CGPoint point = [panGestureRecognizer locationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        // Do nothing
        
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        // Drag the headline container view
        CGPoint newCenter = self.headlineContainerView.center;
        
        if (self.headlineContainerView.center.y < 284) {
            newCenter.y += [panGestureRecognizer translationInView:self.view].y * 0.1;
        } else {
            newCenter.y += [panGestureRecognizer translationInView:self.view].y;
        }
        
        self.headlineContainerView.center = newCenter;
        [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
        
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        // Animate to the final up or down position
        CGRect newFrame = self.menuImageView.frame;
        
        if (velocity.y > 0) {
            [UIView animateWithDuration:0.4
                             animations:^{
                                 self.headlineContainerView.center = CGPointMake(160, 805);
                                 
                                 self.menuImageView.alpha = 1;
                                 self.menuImageView.frame = CGRectMake(0, 0, 320, 568);
                             }];
        } else {
            self.menuImageView.center = CGPointMake(160, 284);
            [UIView animateWithDuration:0.4
                             animations:^{
                                 self.headlineContainerView.center = CGPointMake(160, 284);
                                 
                                 self.menuImageView.alpha = 0.5;
                                 self.menuImageView.frame = CGRectMake(newFrame.origin.x+320*0.05, newFrame.origin.y+568*0.05, 320*0.9, 568*0.9);
                             }];
        }
        
    }
}

// Implement the pan gesture handler method for headline cards
- (void)onCardsPan:(UIPanGestureRecognizer *)panCardsGestureRecognizer {
    CGPoint velocity = [panCardsGestureRecognizer velocityInView:self.view];
    
    
    if (panCardsGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        // Do Nothing
        
    } else if (panCardsGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        // Determine the direction
        self.isVerticalGesture = fabs(velocity.y) > fabs(velocity.x) * 3;
        
        if (self.isVerticalGesture) {
            
            // Scale the card view and drag vertically
            CGRect newFrame = self.cardContainerView.frame;
            newFrame.origin.y += [panCardsGestureRecognizer translationInView:self.view].y;
            newFrame.size.width -= [panCardsGestureRecognizer translationInView:self.view].y;
            newFrame.size.height -= [panCardsGestureRecognizer translationInView:self.view].y;
            self.cardContainerView.frame = newFrame;
            
        } else {
            
            // Horizontally drag the cards view
            if (self.isCardsViewUp == NO) {
                
                CGRect newFrame = self.cardContainerView.frame;
                if ((self.cardContainerView.frame.origin.x > 2) || (self.cardContainerView.frame.origin.x < -842)) {
                    newFrame.origin.x += [panCardsGestureRecognizer translationInView:self.view].x * 0.1;
                } else {
                    newFrame.origin.x += [panCardsGestureRecognizer translationInView:self.view].x * 1.5;
                }
                self.cardContainerView.frame = newFrame;
                
                float value = (self.cardContainerView.frame.origin.x * -1 + 75) / 146;
                self.cardViewIndex = (int)value;
                
            }
            
        } // end isVerticalGesture
        
        [panCardsGestureRecognizer setTranslation:CGPointZero inView:self.view];
        
    } else if (panCardsGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        // Determine the direction
        self.isVerticalGesture = fabs(velocity.y) > fabs(velocity.x) * 3;
        
        if (self.isVerticalGesture) {
            
            // Animate to the final vertical position
            
            float zoomLevel = 2588.0 / 1162.0;
            if (velocity.y > 0) {
                [UIView animateWithDuration:0.4 animations:^{
                    self.cardContainerView.frame = CGRectMake(self.cardContainerView.frame.origin.x / zoomLevel, 314, 1162, 255);
                }];
                self.isCardsViewUp = NO;
            } else {
                
                
                [self snapCardViewPosition];
                self.isCardsViewUp = YES;
                
            } // end velocity
            
        } else {
            
            // Animate to the final horizontal position
            if (self.isCardsViewUp == NO) {
                CGRect newFrame = self.cardContainerView.frame;
                
                if (self.cardContainerView.frame.origin.x > 2) {
                    [UIView animateWithDuration:0.4 animations:^{
                        self.cardContainerView.frame = CGRectMake(2, 314, newFrame.size.width, newFrame.size.height);
                    }];
                } else if (self.cardContainerView.frame.origin.x < -842) {
                    [UIView animateWithDuration:0.4 animations:^{
                        self.cardContainerView.frame = CGRectMake(-842, 314, newFrame.size.width, newFrame.size.height);
                    }];
                }
            }
            
        } //end isVerticalGesture
        
    }
}

- (void)onCardsSwipe:(UISwipeGestureRecognizer *)sender  {
    if (self.isCardsViewUp) {
        if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
            self.cardViewIndex++;
            if (self.cardViewIndex > 7) {
                self.cardViewIndex = 7;
            }
        } else if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
            self.cardViewIndex--;
            if (self.cardViewIndex < 0) {
                self.cardViewIndex = 0;
            }
        }
        
        [self snapCardViewPosition];
    }
}

- (void)snapCardViewPosition {
    self.snapPositionX = self.cardViewIndex * 324 * -1;
    [UIView animateWithDuration:0.4 animations:^{
        self.cardContainerView.frame = CGRectMake(self.snapPositionX, 0, 2588, 568);
    }];
}

// Load headline images
- (void)changeHeadlineImage {
    self.currentImageIndex++;
    if (self.currentImageIndex == 5) {
        self.currentImageIndex = 0;
    }
    
    UIImage *target = [self.headlineImages objectAtIndex:self.currentImageIndex];
    
    CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
    crossFade.duration = 0.5;
    crossFade.fromValue = self.headlineImageView.image;
    crossFade.toValue = target;
    [self.headlineImageView.layer addAnimation:crossFade forKey:@"animateContents"];
    self.headlineImageView.image = target;
}

@end

