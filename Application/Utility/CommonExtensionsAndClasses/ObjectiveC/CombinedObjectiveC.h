//
//  CombinedObjectiveC.h
//
//  Created by Alok Singh on 09/10/15.
//  Copyright © 2015 Alok Singh. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - UIViewController (Logging)

@interface UIViewController (Logging)

+ (void)load;

@end


#pragma mark - NSManagedObject (Serialization)

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (Serialization)
- (NSDictionary*) toDictionary;
- (void) populateFromDictionary:(NSDictionary*)dict;
+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                             inContext:(NSManagedObjectContext*)context;
@end


#pragma mark - NSObject

@interface NSObject (NSLog)

+ (void)logMessage:(NSString*)message;

@end


#pragma mark - MKMapView

#import <MapKit/MapKit.h>

@interface MKMapView (AnnotationsRegion)

-(void)updateRegionForCurrentAnnotationsAnimated:(BOOL)animated;
-(void)updateRegionForCurrentAnnotationsAnimated:(BOOL)animated edgePadding:(UIEdgeInsets)edgePadding;
-(void)updateRegionForAnnotations:(NSArray *)annotations animated:(BOOL)animated;
-(void)updateRegionForAnnotations:(NSArray *)annotations animated:(BOOL)animated edgePadding:(UIEdgeInsets)edgePadding;


@end


#pragma mark - APParallaxView

@class APParallaxView;
@class APParallaxShadowView;

@interface UIScrollView (APParallaxHeader)

- (void)addParallaxWithImage:(UIImage *)image andHeight:(CGFloat)height andShadow:(BOOL)shadow;
- (void)addParallaxWithImage:(UIImage *)image size:(CGSize)size andShadow:(BOOL)shadow;
- (void)addParallaxWithImage:(UIImage *)image andHeight:(CGFloat)height;
- (void)addParallaxWithView:(UIView*)view andHeight:(CGFloat)height;

@property (nonatomic, strong, readonly) APParallaxView *parallaxView;
@property (nonatomic, assign) BOOL showsParallax;

@end

@protocol APParallaxViewDelegate;

typedef NS_ENUM(NSUInteger, APParallaxTrackingState) {
    APParallaxTrackingActive = 0,
    APParallaxTrackingInactive
};

@interface APParallaxView : UIView

@property (weak) id<APParallaxViewDelegate> delegate;

@property (nonatomic, readonly) APParallaxTrackingState state;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *currentSubView;
@property (nonatomic, strong) APParallaxShadowView *shadowView;

- (id)initWithFrame:(CGRect)frame andShadow:(BOOL)shadow;

@end

@protocol APParallaxViewDelegate <NSObject>
@optional
- (void)parallaxView:(APParallaxView *)view willChangeFrame:(CGRect)frame;
- (void)parallaxView:(APParallaxView *)view didChangeFrame:(CGRect)frame;
@end
@interface APParallaxShadowView : UIView

@end


#pragma mark - Reachability

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef enum : NSInteger {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

extern NSString *kReachabilityChangedNotification;

@interface AksReachability : NSObject

+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

+ (instancetype)reachabilityForInternetConnection;

- (BOOL)startNotifier;

- (void)stopNotifier;

- (NetworkStatus)currentReachabilityStatus;

- (BOOL)connectionRequired;

@end


#pragma mark - SVPulsingAnnotationView

#import <MapKit/MapKit.h>

@interface SVPulsingAnnotationView : MKAnnotationView

@property (nonatomic, strong) UIColor *annotationColor; // default is same as MKUserLocationView
@property (nonatomic, readwrite) NSTimeInterval pulseAnimationDuration; // default is 1s
@property (nonatomic, readwrite) NSTimeInterval outerPulseAnimationDuration; // default is 3s
@property (nonatomic, readwrite) NSTimeInterval delayBetweenPulseCycles; // default is 1s
@property (nonatomic, strong) id userInfo;

@end


#pragma mark - SwiftTryCatch

#import <Foundation/Foundation.h>

@import UIKit;

@interface SwiftTryCatch : NSObject

+ (void)tryThis:(void(^)())try catchThis:(void(^)(NSException*exception))catch finally:(void(^)())finally;
+ (void)throwString:(NSString*)s;
+ (void)throwException:(NSException*)e;

@end



#pragma mark - MarqueeLabel

typedef NS_ENUM(NSUInteger, MarqueeType) {
    MLLeftRight = 0,
    MLRightLeft,
    MLContinuous,
    MLContinuousReverse
};

@interface MarqueeLabel : UILabel
- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame rate:(CGFloat)pixelsPerSec andFadeLength:(CGFloat)fadeLength;
- (id)initWithFrame:(CGRect)frame duration:(NSTimeInterval)scrollDuration andFadeLength:(CGFloat)fadeLength;
- (void)minimizeLabelFrameWithMaximumSize:(CGSize)maxSize adjustHeight:(BOOL)adjustHeight;

@property (nonatomic, assign) UIViewAnimationOptions animationCurve;
@property (nonatomic, assign) BOOL labelize;
@property (nonatomic, assign) BOOL holdScrolling;
@property (nonatomic, assign) MarqueeType marqueeType;
@property (nonatomic, assign) NSTimeInterval lengthOfScroll;
@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, assign) CGFloat continuousMarqueeExtraBuffer;
@property (nonatomic, assign) CGFloat fadeLength;
@property (nonatomic, assign) CGFloat animationDelay;
@property (nonatomic, assign) BOOL tapToScroll;
- (void)restartLabel;
- (void)resetLabel;
- (void)pauseLabel;
- (void)unpauseLabel;
- (void)labelWillBeginScroll;
- (void)labelReturnedToHome:(BOOL)finished;
@property (nonatomic, assign, readonly) BOOL isPaused;
@property (nonatomic, assign, readonly) BOOL awayFromHome;
+ (void)restartLabelsOfController:(UIViewController *)controller;
+ (void)controllerViewDidAppear:(UIViewController *)controller;
+ (void)controllerViewWillAppear:(UIViewController *)controller;
+ (void)controllerViewAppearing:(UIViewController *)controller __attribute((deprecated("Use restartLabelsOfController: method")));
+ (void)controllerLabelsShouldLabelize:(UIViewController *)controller;
+ (void)controllerLabelsShouldAnimate:(UIViewController *)controller;
@end


#pragma mark - ACETelPrompt

@interface ACETelPrompt : NSObject

typedef void (^ACETelCallBlock)(NSTimeInterval duration);
typedef void (^ACETelCancelBlock)(void);

+ (BOOL)callPhoneNumber:(NSString *)phoneNumber
                   call:(ACETelCallBlock)callBlock
                 cancel:(ACETelCancelBlock)cancelBlock;

@end


#pragma mark - UITableView (LongPressReorder)

@protocol LPRTableViewDelegate

@optional
- (UIView *)tableView:(UITableView *)tableView draggingViewForCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView showDraggingView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView hideDraggingView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath;
@end


@interface UITableView (LongPressReorder)

@property (nonatomic, assign, getter = isLongPressReorderEnabled) BOOL longPressReorderEnabled;
@property (nonatomic, assign) id <LPRTableViewDelegate> lprDelegate;

@end

#pragma mark - UIActionSheet (Blocks)

typedef enum {
    kBadgePlacementUpperLeft,
    kBadgePlacementUpperRight,
    kBadgePlacementUpperBest,
    kBadgePlacementBottomRight
} MLTBadgePlacement;


@interface MLTBadgeView : UIView {
    
}
@property MLTBadgePlacement placement;
@property NSInteger badgeValue;
@property(nonatomic, retain) UIFont *font;
@property(nonatomic, retain) UIColor *badgeColor;
@property(nonatomic, retain) UIColor *textColor;
@property(nonatomic, retain) UIColor *outlineColor;
@property float outlineWidth;
@property float minimumDiameter;
@property BOOL displayWhenZero;
@end

@interface UIView(Badged)
@property(nonatomic, readonly) MLTBadgeView *badge;
@end

#import <UIKit/UIKit.h>

#if TARGET_OS_IOS
typedef void (^UIAlertControllerPopoverPresentationControllerBlock) (UIPopoverPresentationController * __nonnull popover);
#endif
typedef void (^UIAlertControllerCompletionBlock) (UIAlertController * __nonnull controller, UIAlertAction * __nonnull action, NSInteger buttonIndex);

@interface UIAlertController (Blocks)

+ (nonnull instancetype)showInViewController:(nonnull UIViewController *)viewController
                                   withTitle:(nullable NSString *)title
                                     message:(nullable NSString *)message
                              preferredStyle:(UIAlertControllerStyle)preferredStyle
                           cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                      destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle
                           otherButtonTitles:(nullable NSArray *)otherButtonTitles
#if TARGET_OS_IOS
          popoverPresentationControllerBlock:(nullable UIAlertControllerPopoverPresentationControllerBlock)popoverPresentationControllerBlock
#endif
                                    tapBlock:(nullable UIAlertControllerCompletionBlock)tapBlock;

+ (nonnull instancetype)showAlertInViewController:(nonnull UIViewController *)viewController
                                        withTitle:(nullable NSString *)title
                                          message:(nullable NSString *)message
                                cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                           destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle
                                otherButtonTitles:(nullable NSArray *)otherButtonTitles
                                         tapBlock:(nullable UIAlertControllerCompletionBlock)tapBlock;


+ (nonnull instancetype)showActionSheetInViewController:(nonnull UIViewController *)viewController
                                              withTitle:(nullable NSString *)title
                                                message:(nullable NSString *)message
                                      cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                 destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle
                                      otherButtonTitles:(nullable NSArray *)otherButtonTitles
#if TARGET_OS_IOS
                     popoverPresentationControllerBlock:(nullable UIAlertControllerPopoverPresentationControllerBlock)popoverPresentationControllerBlock
#endif
                                               tapBlock:(nullable UIAlertControllerCompletionBlock)tapBlock;


@property (readonly, nonatomic) BOOL visible;
@property (readonly, nonatomic) NSInteger cancelButtonIndex;
@property (readonly, nonatomic) NSInteger firstOtherButtonIndex;
@property (readonly, nonatomic) NSInteger destructiveButtonIndex;

@end

#pragma mark - UIImage Categories

@interface UIImage (Alpha)
- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size;
- (UIImage *)tranlucentWithAlpha:(CGFloat)alpha;

@end

@interface UIImage (Resize)
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)circlularCroppedImageWithDiameter:(NSInteger)diameter
                                atTopLeftPoint:(CGPoint)cropPoint
                             transparentBorder:(NSUInteger)borderSize;
- (UIImage *)croppedImageViaPercentages:(CGRect)rect;
- (UIImage *)croppedImageRespectingImageOrientation:(CGRect)rect;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithMaxEdge:(float)maxEdge;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;
@end


@interface UIImage (RoundedCorner)
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;
@end

#pragma mark - UIView AnimationExtensions

typedef NS_ENUM(NSUInteger, UIViewAnimationFlipDirection)
{
    UIViewAnimationFlipDirectionFromTop,
    UIViewAnimationFlipDirectionFromLeft,
    UIViewAnimationFlipDirectionFromRight,
    UIViewAnimationFlipDirectionFromBottom,
};
typedef NS_ENUM(NSUInteger, UIViewAnimationRotationDirection)
{
    UIViewAnimationRotationDirectionRight,
    UIViewAnimationRotationDirectionLeft
};


@interface UIView (AnimationExtensions)

- (void)shakeHorizontally;
- (void)shakeVertically;
- (void)applyMotionEffects;
- (void)pulseToSize:(CGFloat)scale
           duration:(NSTimeInterval)duration
             repeat:(BOOL)repeat;
- (void)flipWithDuration:(NSTimeInterval)duration
               direction:(UIViewAnimationFlipDirection)direction
             repeatCount:(NSUInteger)repeatCount
             autoreverse:(BOOL)shouldAutoreverse;
- (void)rotateToAngle:(CGFloat)angle
             duration:(NSTimeInterval)duration
            direction:(UIViewAnimationRotationDirection)direction
          repeatCount:(NSUInteger)repeatCount
          autoreverse:(BOOL)shouldAutoreverse;
- (void)stopAnimation;
- (BOOL)isBeingAnimated;

@end

#pragma mark - WSCoachMarksView

#ifndef WS_WEAK
#if __has_feature(objc_arc_weak)
#define WS_WEAK weak
#elif __has_feature(objc_arc)
#define WS_WEAK unsafe_unretained
#else
#define WS_WEAK assign
#endif
#endif

@protocol WSCoachMarksViewDelegate;

@interface WSCoachMarksView : UIView

@property (nonatomic, WS_WEAK) id<WSCoachMarksViewDelegate> delegate;
@property (nonatomic, retain) NSArray *coachMarks;
@property (nonatomic, retain) UILabel *lblCaption;
@property (nonatomic, retain) UIColor *maskColor;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) CGFloat cutoutRadius;
@property (nonatomic) CGFloat maxLblWidth;
@property (nonatomic) CGFloat lblSpacing;
@property (nonatomic) BOOL enableContinueLabel;

- (id)initWithFrame:(CGRect)frame coachMarks:(NSArray *)marks;
- (void)start;

@end

@protocol WSCoachMarksViewDelegate <NSObject>

@optional
- (void)coachMarksView:(WSCoachMarksView*)coachMarksView willNavigateToIndex:(NSInteger)index;
- (void)coachMarksView:(WSCoachMarksView*)coachMarksView didNavigateToIndex:(NSInteger)index;
- (void)coachMarksViewWillCleanup:(WSCoachMarksView*)coachMarksView;
- (void)coachMarksViewDidCleanup:(WSCoachMarksView*)coachMarksView;

@end

#pragma mark - ZKPulseView

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>

@interface UIView (ZKPulseView)
-(void) stopPulseEffect;
-(void) startPulse;
-(void) startPulseWithColor:(UIColor *)color;
-(void) startPulseWithColor:(UIColor *)color offset:(CGSize) offset frequency:(CGFloat) freq;
@end

#pragma mark - KTCenterFlowLayout

@interface KTCenterFlowLayout : UICollectionViewFlowLayout
@end

#pragma mark - CJAAssociatedObject

#import <objc/runtime.h>

@interface NSObject (CJAAssociatedObject)

/**
 Returns the associated value for a given key
 
 @param key The given key
 @return the associated value; otherwise nil
 */
- (id)associatedValueForKey:(void *)key;

/**
 Set's the given value for the key
 
 Notice: The value is setted with the OBJC_ASSOCIATION_RETAIN_NONATOMIC policy
 @param key The key for the associated object
 @param value The value that should be saved
 */
- (void)setAssociatedValue:(id)value forKey:(void *)key;

/**
 Set's the given value for the key, with the given policy
 
 Notice: The value is setted with the OBJC_ASSOCIATION_RETAIN_NONATOMIC policy
 @param key The key for the associated object
 @param value The value that should be saved
 @param policy The association policy
 */
- (void)setAssociatedValue:(id)value forKey:(void *)key policy:(objc_AssociationPolicy)policy;

/**
 Removes all values from the object
 */
- (void)removeAllAssociatedValues;

/**
 Returns the associated BOOL value for a given key
 
 @param key The given key
 @return the associated BOOL value; otherwise NO
 */
- (BOOL)associatedBoolValueForKey:(void *)key;

/**
 Set's the given BOOL value for the key
 
 Notice: The value is setted with the OBJC_ASSOCIATION_RETAIN_NONATOMIC policy
 @param key The key for the associated object
 @param value The BOOL value that should be saved
 */
- (void)setAssociatedBoolValue:(BOOL)value forKey:(void *)key;

/**
 Returns the associated NSInteger value for a given key
 
 @param key The given key
 @return the associated NSInteger value; otherwise 0
 */
- (NSInteger)associatedIntegerValueForKey:(void *)key;

/**
 Set's the given NSInteger value for the key
 
 Notice: The value is setted with the OBJC_ASSOCIATION_RETAIN_NONATOMIC policy
 @param key The key for the associated NSInteger
 @param value The NSInteger value that should be saved
 */
- (void)setAssociatedIntegerValue:(NSInteger)value forKey:(void *)key;

/**
 Returns the associated float value for a given key
 
 @param key The given key
 @return the associated float value; otherwise 0.0f
 */
- (float)associatedFloatValueForKey:(void *)key;

/**
 Set's the given float value for the key
 
 Notice: The value is setted with the OBJC_ASSOCIATION_RETAIN_NONATOMIC policy
 @param key The key for the associated float
 @param value The float value that should be saved
 */
- (void)setAssociatedFloatValue:(float)value forKey:(void *)key;

/**
 Returns the associated double value for a given key
 
 @param key The given key
 @return the associated double value; otherwise .0
 */
- (double)associatedDoubleValueForKey:(void *)key;

/**
 Set's the given double value for the key
 
 Notice: The value is setted with the OBJC_ASSOCIATION_RETAIN_NONATOMIC policy
 @param key The key for the associated double
 @param value The double value that should be saved
 */
- (void)setAssociatedDoubleValue:(double)value forKey:(void *)key;

@end

#pragma mark - HCSStarRatingView

typedef BOOL(^HCSStarRatingViewShouldBeginGestureRecognizerBlock)(UIGestureRecognizer *gestureRecognizer);

IB_DESIGNABLE
@interface HCSStarRatingView : UIControl
@property (nonatomic) IBInspectable NSUInteger maximumValue;
@property (nonatomic) IBInspectable CGFloat minimumValue;
@property (nonatomic) IBInspectable CGFloat value;
@property (nonatomic) IBInspectable CGFloat spacing;
@property (nonatomic) IBInspectable BOOL allowsHalfStars;
@property (nonatomic) IBInspectable BOOL accurateHalfStars;
@property (nonatomic) IBInspectable BOOL continuous;

@property (nonatomic) BOOL shouldBecomeFirstResponder;

// Optional: if `nil` method will return `NO`.
@property (nonatomic, copy) HCSStarRatingViewShouldBeginGestureRecognizerBlock shouldBeginGestureRecognizerBlock;

@property (nonatomic, strong) IBInspectable UIImage *emptyStarImage;
@property (nonatomic, strong) IBInspectable UIImage *halfStarImage;
@property (nonatomic, strong) IBInspectable UIImage *filledStarImage;
@end


/**
 This class simplifies playing sound effects as well as implementing basic caching behavior. It retains an
 `AVAudioPlayer` object with it's sound effect pre-cached and ready to play instantly. It is designed to provide user
 interface audio feedback, making it optimal for playing short sound clips.
 
 There can be some loading time between when a sound effect is initialized and when it is ready for playback. For this
 reason it is recommended to preload the sound in advance of when it is needed (for low latency playback). When you
 should preload is left up to your implementation, however a convenience method (`preloadSoundEffectNamed:`) is
 provided.
 */
@interface SAMSoundEffect : NSObject

/**
 Returns a sound effect with the provided name.
 
 @param name The name of the audio file. Can be in Core Audio Format without a file extension, otherwise an extension is
 required.
 
 @param bundleOrNil The bundle to search for the audio file (sending nil will use the main bundle).
 */
+ (instancetype)soundEffectNamed:(NSString *)name inBundle:(NSBundle *)bundleOrNil;
+ (instancetype)soundEffectNamed:(NSString *)name;


/**
 Plays a sound effect with the provided name.
 
 @param name The name of the audio file. Can be in Core Audio Format without a file extension, otherwise an extension is
 required.
 
 @param bundleOrNil The bundle to search for the audio file (sending nil will use the main bundle).
 */
+ (instancetype)playSoundEffectNamed:(NSString *)name inBundle:(NSBundle *)bundleOrNil;
+ (instancetype)playSoundEffectNamed:(NSString *)name;

/**
 Initializes a sound effect with the file at the provided path.
 
 @param path A full path to the desired audio file.
 
 The file can be in any format that AVAudioPlayer supports.
 
 @note It is recommended to use the `soundEffectNamed` class methods instead of this, as these methods cache the
 resulting sound effect object. This provides performance benefits and simpler syntax as well as assuring the sound
 effect is retained throughout its playback.
 */
- (instancetype)initWithContentsOfFile:(NSString *)path;

/**
 Plays the sound effect.
 */
- (void)play;


/**
 Stops the sound effect if its playing.
 */
- (void)stop;

/**
 Returns a boolean indicating if the sound effect is playing.
 
 @return A boolean indicating if the receiver is playing.
 */
- (BOOL)isPlaying;

@end

#pragma mark - HMSegmentedControl

@class HMSegmentedControl;

typedef void (^IndexChangeBlock)(NSInteger index);
typedef NSAttributedString *(^HMTitleFormatterBlock)(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected);

typedef NS_ENUM(NSInteger, HMSegmentedControlSelectionStyle) {
    HMSegmentedControlSelectionStyleTextWidthStripe, // Indicator width will only be as big as the text width
    HMSegmentedControlSelectionStyleFullWidthStripe, // Indicator width will fill the whole segment
    HMSegmentedControlSelectionStyleBox, // A rectangle that covers the whole segment
    HMSegmentedControlSelectionStyleArrow // An arrow in the middle of the segment pointing up or down depending on `HMSegmentedControlSelectionIndicatorLocation`
};

typedef NS_ENUM(NSInteger, HMSegmentedControlSelectionIndicatorLocation) {
    HMSegmentedControlSelectionIndicatorLocationUp,
    HMSegmentedControlSelectionIndicatorLocationDown,
    HMSegmentedControlSelectionIndicatorLocationNone // No selection indicator
};

typedef NS_ENUM(NSInteger, HMSegmentedControlSegmentWidthStyle) {
    HMSegmentedControlSegmentWidthStyleFixed, // Segment width is fixed
    HMSegmentedControlSegmentWidthStyleDynamic, // Segment width will only be as big as the text width (including inset)
};

typedef NS_OPTIONS(NSInteger, HMSegmentedControlBorderType) {
    HMSegmentedControlBorderTypeNone = 0,
    HMSegmentedControlBorderTypeTop = (1 << 0),
    HMSegmentedControlBorderTypeLeft = (1 << 1),
    HMSegmentedControlBorderTypeBottom = (1 << 2),
    HMSegmentedControlBorderTypeRight = (1 << 3)
};

enum {
    HMSegmentedControlNoSegment = -1   // Segment index for no selected segment
};

typedef NS_ENUM(NSInteger, HMSegmentedControlType) {
    HMSegmentedControlTypeText,
    HMSegmentedControlTypeImages,
    HMSegmentedControlTypeTextImages
};

@interface HMSegmentedControl : UIControl

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *sectionImages;
@property (nonatomic, strong) NSArray *sectionSelectedImages;

/**
 Provide a block to be executed when selected index is changed.
 
 Alternativly, you could use `addTarget:action:forControlEvents:`
 */
@property (nonatomic, copy) IndexChangeBlock indexChangeBlock;

/**
 Used to apply custom text styling to titles when set.
 
 When this block is set, no additional styling is applied to the `NSAttributedString` object returned from this block.
 */
@property (nonatomic, copy) HMTitleFormatterBlock titleFormatter;

/**
 Text attributes to apply to item title text.
 */
@property (nonatomic, strong) NSDictionary *titleTextAttributes UI_APPEARANCE_SELECTOR;

/*
 Text attributes to apply to selected item title text.
 
 Attributes not set in this dictionary are inherited from `titleTextAttributes`.
 */
@property (nonatomic, strong) NSDictionary *selectedTitleTextAttributes UI_APPEARANCE_SELECTOR;

/**
 Segmented control background color.
 
 Default is `[UIColor whiteColor]`
 */
@property (nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

/**
 Color for the selection indicator stripe/box
 
 Default is `R:52, G:181, B:229`
 */
@property (nonatomic, strong) UIColor *selectionIndicatorColor UI_APPEARANCE_SELECTOR;

/**
 Color for the vertical divider between segments.
 
 Default is `[UIColor blackColor]`
 */
@property (nonatomic, strong) UIColor *verticalDividerColor UI_APPEARANCE_SELECTOR;

/**
 Opacity for the seletion indicator box.
 
 Default is `0.2f`
 */
@property (nonatomic) CGFloat selectionIndicatorBoxOpacity;

/**
 Width the vertical divider between segments that is added when `verticalDividerEnabled` is set to YES.
 
 Default is `1.0f`
 */
@property (nonatomic, assign) CGFloat verticalDividerWidth;

/**
 Specifies the style of the control
 
 Default is `HMSegmentedControlTypeText`
 */
@property (nonatomic, assign) HMSegmentedControlType type;

/**
 Specifies the style of the selection indicator.
 
 Default is `HMSegmentedControlSelectionStyleTextWidthStripe`
 */
@property (nonatomic, assign) HMSegmentedControlSelectionStyle selectionStyle;

/**
 Specifies the style of the segment's width.
 
 Default is `HMSegmentedControlSegmentWidthStyleFixed`
 */
@property (nonatomic, assign) HMSegmentedControlSegmentWidthStyle segmentWidthStyle;

/**
 Specifies the location of the selection indicator.
 
 Default is `HMSegmentedControlSelectionIndicatorLocationUp`
 */
@property (nonatomic, assign) HMSegmentedControlSelectionIndicatorLocation selectionIndicatorLocation;

/*
 Specifies the border type.
 
 Default is `HMSegmentedControlBorderTypeNone`
 */
@property (nonatomic, assign) HMSegmentedControlBorderType borderType;

/**
 Specifies the border color.
 
 Default is `[UIColor blackColor]`
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 Specifies the border width.
 
 Default is `1.0f`
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 Default is YES. Set to NO to deny scrolling by dragging the scrollView by the user.
 */
@property(nonatomic, getter = isUserDraggable) BOOL userDraggable;

/**
 Default is YES. Set to NO to deny any touch events by the user.
 */
@property(nonatomic, getter = isTouchEnabled) BOOL touchEnabled;

/**
 Default is NO. Set to YES to show a vertical divider between the segments.
 */
@property(nonatomic, getter = isVerticalDividerEnabled) BOOL verticalDividerEnabled;

/**
 Index of the currently selected segment.
 */
@property (nonatomic, assign) NSInteger selectedSegmentIndex;

/**
 Height of the selection indicator. Only effective when `HMSegmentedControlSelectionStyle` is either `HMSegmentedControlSelectionStyleTextWidthStripe` or `HMSegmentedControlSelectionStyleFullWidthStripe`.
 
 Default is 5.0
 */
@property (nonatomic, readwrite) CGFloat selectionIndicatorHeight;

/**
 Edge insets for the selection indicator.
 NOTE: This does not affect the bounding box of HMSegmentedControlSelectionStyleBox
 
 When HMSegmentedControlSelectionIndicatorLocationUp is selected, bottom edge insets are not used
 
 When HMSegmentedControlSelectionIndicatorLocationDown is selected, top edge insets are not used
 
 Defaults are top: 0.0f
 left: 0.0f
 bottom: 0.0f
 right: 0.0f
 */
@property (nonatomic, readwrite) UIEdgeInsets selectionIndicatorEdgeInsets;

/**
 Inset left and right edges of segments.
 
 Default is UIEdgeInsetsMake(0, 5, 0, 5)
 */
@property (nonatomic, readwrite) UIEdgeInsets segmentEdgeInset;

@property (nonatomic, readwrite) UIEdgeInsets enlargeEdgeInset;

/**
 Default is YES. Set to NO to disable animation during user selection.
 */
@property (nonatomic) BOOL shouldAnimateUserSelection;

- (id)initWithSectionTitles:(NSArray *)sectiontitles;
- (id)initWithSectionImages:(NSArray *)sectionImages sectionSelectedImages:(NSArray *)sectionSelectedImages;
- (instancetype)initWithSectionImages:(NSArray *)sectionImages sectionSelectedImages:(NSArray *)sectionSelectedImages titlesForSections:(NSArray *)sectiontitles;
- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)setIndexChangeBlock:(IndexChangeBlock)indexChangeBlock;
- (void)setTitleFormatter:(HMTitleFormatterBlock)titleFormatter;

@end

