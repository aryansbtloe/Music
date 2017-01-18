//
//  CombinedObjectiveC.m
//
//  Created by Alok Singh on 09/10/15.
//  Copyright © 2015 Alok Singh. All rights reserved.
//


#import "CombinedObjectiveC.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define FULL_LOGGING 0
#define CHECK_DEALLOCATION 0
#define LOG_NAMES 0

@implementation UIViewController (Logging)
    
+ (void)load {
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
#if FULL_LOGGING
        {
            Method originalMethod = class_getInstanceMethod(self, @selector(viewDidLoad));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledViewDidLoad));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
        
        {
            Method originalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledViewWillAppear:));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
        {
            Method originalMethod = class_getInstanceMethod(self, @selector(viewDidAppear:));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledViewDidAppear:));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
        {
            Method originalMethod = class_getInstanceMethod(self, @selector(viewWillDisappear:));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledViewWillDisappear));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
        {
            Method originalMethod = class_getInstanceMethod(self, @selector(viewDidDisappear:));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledViewDidDisappear:));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
#endif
        {
            Method originalMethod = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledDealloc));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
        
    });
}
    
- (void) loggedEnabledViewDidLoad {
#if LOG_NAMES
    NSLog(@"viewDidLoad : %@", [self class]);
#endif
    [self loggedEnabledViewDidLoad];
    [[NSUserDefaults standardUserDefaults]setObject:@"exist" forKey:[[self class]description]];
}
    
- (void) loggedEnabledViewWillAppear:(BOOL)animated {
#if LOG_NAMES
    NSLog(@"ViewWillAppear : %@", [self class]);
#endif
    [self loggedEnabledViewWillAppear:animated];
}
    
- (void) loggedEnabledViewDidAppear:(BOOL)animated {
#if LOG_NAMES
    NSLog(@"viewDidAppear : %@", [self class]);
#endif
    [self loggedEnabledViewDidAppear:animated];
}
    
- (void) loggedEnabledViewWillDisappear {
#if LOG_NAMES
    NSLog(@"ViewWillDisappear : %@", [self class]);
#endif
    [self loggedEnabledViewWillDisappear];
#if CHECK_DEALLOCATION
    [self checkIfViewControllerDeallocatedWhenPopped];
#endif
}
    
- (void) loggedEnabledViewDidDisappear:(BOOL)animated {
#if LOG_NAMES
    NSLog(@"ViewDidDisappear : %@", [self class]);
#endif
    [self loggedEnabledViewDidDisappear:animated];
}
    
- (void) loggedEnabledDealloc {
#if CHECK_DEALLOCATION
    [self viewControllerDeallocatedWhenPopped];
#endif
#if LOG_NAMES
    NSLog(@"Dealloc : %@", [self class]);
#endif
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self loggedEnabledDealloc];
}
    
- (void)viewControllerDeallocatedWhenPopped{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:[[self class]description]];
}
    
#if CHECK_DEALLOCATION
- (void)checkIfViewControllerDeallocatedWhenPopped{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([viewControllers indexOfObject:self] == NSNotFound){
        __block __weak typeof(self) bself = self;
        NSLog(@"%@ just popped out and next within few seconds it should print its deallocation message", [[bself class]description]);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ((bself!=nil)&&[((NSString*)[[NSUserDefaults standardUserDefaults]objectForKey:[[bself class]description]])  isEqualToString:@"exist"]) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@ doesn't deallocated even it is popped out from navigation stack.. check for possibility of error", [[bself class]description]]);
            }
        });
    }
}
#endif
    
    @end


@implementation NSManagedObject (Serialization)
    
#define DATE_ATTR_PREFIX @"dAtEaTtr:"
    
- (NSDictionary*) toDictionaryWithTraversalHistory:(NSMutableArray*)traversalHistory {
    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    NSArray* relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:
                                 [attributes count] + [relationships count] + 1];
    
    NSMutableArray *localTraversalHistory = nil;
    
    if (traversalHistory == nil) {
        localTraversalHistory = [NSMutableArray arrayWithCapacity:[attributes count] + [relationships count] + 1];
    } else {
        localTraversalHistory = traversalHistory;
    }
    
    [localTraversalHistory addObject:self];
    
    [dict setObject:[[self class] description] forKey:@"class"];
    
    for (NSString* attr in attributes) {
        NSObject* value = [self valueForKey:attr];
        
        if (value != nil) {
            if ([value isKindOfClass:[NSDate class]]) {
                NSTimeInterval date = [(NSDate*)value timeIntervalSinceReferenceDate];
                NSString *dateAttr = [NSString stringWithFormat:@"%@%@", DATE_ATTR_PREFIX, attr];
                [dict setObject:[NSNumber numberWithDouble:date] forKey:dateAttr];
            } else {
                [dict setObject:value forKey:attr];
            }
        }
    }
    
    for (NSString* relationship in relationships) {
        NSObject* value = [self valueForKey:relationship];
        
        if ([value isKindOfClass:[NSSet class]]) {
            // To-many relationship
            
            // The core data set holds a collection of managed objects
            NSSet* relatedObjects = (NSSet*) value;
            
            // Our set holds a collection of dictionaries
            NSMutableArray* dictSet = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
            
            for (NSManagedObject* relatedObject in relatedObjects) {
                if ([localTraversalHistory containsObject:relatedObject] == NO) {
                    [dictSet addObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory]];
                }
            }
            
            [dict setObject:[NSArray arrayWithArray:dictSet] forKey:relationship];
        }
        else if ([value isKindOfClass:[NSManagedObject class]]) {
            // To-one relationship
            
            NSManagedObject* relatedObject = (NSManagedObject*) value;
            
            if ([localTraversalHistory containsObject:relatedObject] == NO) {
                // Call toDictionary on the referenced object and put the result back into our dictionary.
                [dict setObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory] forKey:relationship];
            }
        }
    }
    if (traversalHistory == nil) {
        [localTraversalHistory removeAllObjects];
    }
    return dict;
}
    
- (NSDictionary*) toDictionary {
    return [self toDictionaryWithTraversalHistory:nil];
}
    
+ (id) decodedValueFrom:(id)codedValue forKey:(NSString*)key {
    if ([key hasPrefix:DATE_ATTR_PREFIX] == YES) {
        // This is a date attribute
        NSTimeInterval dateAttr = [(NSNumber*)codedValue doubleValue];
        return [NSDate dateWithTimeIntervalSinceReferenceDate:dateAttr];
    } else {
        // This is an attribute
        return codedValue;
    }
}
    
- (void) populateFromDictionary:(NSDictionary*)dict{
    NSManagedObjectContext* context = [self managedObjectContext];
    for (NSString* key in dict) {
        if ([key isEqualToString:@"class"]) {
            continue;
        }
        NSObject* value = [dict objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            // This is a to-one relationship
            NSManagedObject* relatedObject =
            [NSManagedObject createManagedObjectFromDictionary:(NSDictionary*)value
                                                     inContext:context];
            [self setValue:relatedObject forKey:key];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            // This is a to-many relationship
            NSArray* relatedObjectDictionaries = (NSArray*) value;
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet* relatedObjects = [self mutableSetValueForKey:key];
            for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {
                NSManagedObject* relatedObject =
                [NSManagedObject createManagedObjectFromDictionary:relatedObjectDict
                                                         inContext:context];
                [relatedObjects addObject:relatedObject];
            }
        }
        else if (value != nil) {
            [self setValue:[NSManagedObject decodedValueFrom:value forKey:key] forKey:key];
        }
    }
}
    
+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                             inContext:(NSManagedObjectContext*)context{
    NSString* class = [dict objectForKey:@"class"];
    NSManagedObject* newObject =
    (NSManagedObject*)[NSEntityDescription insertNewObjectForEntityForName:class
                                                    inManagedObjectContext:context];
    [newObject populateFromDictionary:dict];
    return newObject;
}
    
    @end

@implementation NSObject (NSLog)
    
+ (void)logMessage:(NSString*)message{
    NSLog(@"%@",message);
}
    
    
    @end

@implementation MKMapView (AnnotationsRegion)
    
-(void)updateRegionForCurrentAnnotationsAnimated:(BOOL)animated{
    [self updateRegionForCurrentAnnotationsAnimated:animated edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)];
}
-(void)updateRegionForCurrentAnnotationsAnimated:(BOOL)animated edgePadding:(UIEdgeInsets)edgePadding{
    [self updateRegionForAnnotations:self.annotations animated:animated edgePadding:edgePadding];
}
    
-(void)updateRegionForAnnotations:(NSArray *)annotations animated:(BOOL)animated{
    [self updateRegionForAnnotations:annotations animated:animated edgePadding:UIEdgeInsetsMake(30, 30, 100, 30)];
}
    
-(void)updateRegionForAnnotations:(NSArray *)annotations animated:(BOOL)animated edgePadding:(UIEdgeInsets)edgePadding{
    MKMapRect zoomRect = MKMapRectNull;
    for(id<MKAnnotation> annotation in annotations){
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.3, 0.3);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [self setVisibleMapRect:zoomRect edgePadding:edgePadding animated:animated];
}
    @end



#import <QuartzCore/QuartzCore.h>

@interface APParallaxView ()
    
    @property (nonatomic, readwrite) APParallaxTrackingState state;
    
    @property (nonatomic, weak) UIScrollView *scrollView;
    @property (nonatomic, readwrite) CGFloat originalTopInset;
    @property (nonatomic) CGFloat parallaxHeight;
    
    @property(nonatomic, assign) BOOL isObserving;
    
    @end



#import <objc/runtime.h>

static char UIScrollViewParallaxView;

@implementation UIScrollView (APParallaxHeader)
    
- (void)addParallaxWithImage:(UIImage *)image andHeight:(CGFloat)height {
    [self addParallaxWithImage:image andHeight:height andShadow:YES];
}
    
- (void)addParallaxWithImage:(UIImage *)image size:(CGSize)size andShadow:(BOOL)shadow{
    if(self.parallaxView) {
        if(self.parallaxView.currentSubView) {
            [self.parallaxView.currentSubView removeFromSuperview];
        }
        [self.parallaxView.imageView setImage:image];
    }
    else
    {
        APParallaxView *view = [[APParallaxView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) andShadow:shadow];
        [view setClipsToBounds:YES];
        [view.imageView setImage:image];
        
        view.scrollView = self;
        view.parallaxHeight = size.height;
        [self addSubview:view];
        
        view.originalTopInset = self.contentInset.top;
        
        UIEdgeInsets newInset = self.contentInset;
        newInset.top = size.height;
        self.contentInset = newInset;
        
        self.parallaxView = view;
        self.showsParallax = YES;
    }
}
    
- (void)addParallaxWithImage:(UIImage *)image andHeight:(CGFloat)height andShadow:(BOOL)shadow {
    [self addParallaxWithImage:image size:CGSizeMake([UIScreen mainScreen].bounds.size.width, height) andShadow:shadow];
}
    
- (void)addParallaxWithView:(UIView*)view andHeight:(CGFloat)height {
    if(self.parallaxView) {
        [self.parallaxView.currentSubView removeFromSuperview];
        [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.parallaxView addSubview:view];
    }
    else
    {
        APParallaxView *parallaxView = [[APParallaxView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, height)];
        [parallaxView setClipsToBounds:YES];
        [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [parallaxView addSubview:view];
        
        parallaxView.scrollView = self;
        parallaxView.parallaxHeight = height;
        [self addSubview:parallaxView];
        
        parallaxView.originalTopInset = self.contentInset.top;
        
        UIEdgeInsets newInset = self.contentInset;
        newInset.top = height;
        self.contentInset = newInset;
        
        self.parallaxView = parallaxView;
        self.showsParallax = YES;
    }
}
    
- (void)setParallaxView:(APParallaxView *)parallaxView {
    objc_setAssociatedObject(self, &UIScrollViewParallaxView,
                             parallaxView,
                             OBJC_ASSOCIATION_ASSIGN);
}
    
- (APParallaxView *)parallaxView {
    return objc_getAssociatedObject(self, &UIScrollViewParallaxView);
}
    
- (void)setShowsParallax:(BOOL)showsParallax {
    self.parallaxView.hidden = !showsParallax;
    
    if(!showsParallax) {
        if (self.parallaxView.isObserving) {
            [self removeObserver:self.parallaxView forKeyPath:@"contentOffset"];
            [self removeObserver:self.parallaxView forKeyPath:@"frame"];
            self.parallaxView.isObserving = NO;
        }
    }
    else {
        if (!self.parallaxView.isObserving) {
            [self addObserver:self.parallaxView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.parallaxView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            self.parallaxView.isObserving = YES;
        }
    }
}
    
- (BOOL)showsParallax {
    return !self.parallaxView.hidden;
}
    
    @end

@implementation APParallaxShadowView
    
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:NO];
    }
    return self;
}
    
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    //// Gradient Declarations
    NSArray* gradient3Colors = [NSArray arrayWithObjects:
                                (id)[UIColor colorWithWhite:0 alpha:0.3].CGColor,
                                (id)[UIColor clearColor].CGColor, nil];
    CGFloat gradient3Locations[] = {0, 1};
    CGGradientRef gradient3 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradient3Colors, gradient3Locations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, CGRectGetWidth(rect), 8)];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawLinearGradient(context, gradient3, CGPointMake(0, CGRectGetHeight(rect)), CGPointMake(0, 0), 0);
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(gradient3);
    CGColorSpaceRelease(colorSpace);
    
}
    
    @end

@implementation APParallaxView
    
- (id)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame andShadow:YES];
    if (self) {
        
    }
    return self;
}
    
- (id)initWithFrame:(CGRect)frame andShadow:(BOOL)shadow {
    if(self = [super initWithFrame:frame]) {
        
        // default styling values
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self setState:APParallaxTrackingActive];
        [self setAutoresizesSubviews:YES];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.imageView setClipsToBounds:YES];
        [self addSubview:self.imageView];
        
        if (shadow) {
            self.shadowView = [[APParallaxShadowView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(frame)-8, CGRectGetWidth(frame), 8)];
            [self.shadowView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
            [self addSubview:self.shadowView];
        }
    }
    
    return self;
}
    
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsParallax) {
            if (self.isObserving) {
                //If enter this branch, it is the moment just before "APParallaxView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"frame"];
                self.isObserving = NO;
            }
        }
    }
}
    
- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    self.currentSubView = view;
}
    
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"])
    [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if([keyPath isEqualToString:@"frame"])
    [self layoutSubviews];
}
    
- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    // We do not want to track when the parallax view is hidden
    if (contentOffset.y > 0) {
        [self setState:APParallaxTrackingInactive];
    } else {
        [self setState:APParallaxTrackingActive];
    }
    
    if(self.state == APParallaxTrackingActive) {
        CGFloat yOffset = contentOffset.y*-1;
        if ([self.delegate respondsToSelector:@selector(parallaxView:willChangeFrame:)]) {
            [self.delegate parallaxView:self willChangeFrame:self.frame];
        }
        
        [self setFrame:CGRectMake(0, contentOffset.y, CGRectGetWidth(self.frame), yOffset)];
        
        if ([self.delegate respondsToSelector:@selector(parallaxView:didChangeFrame:)]) {
            [self.delegate parallaxView:self didChangeFrame:self.frame];
        }
    }
}
    
    @end

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <CoreFoundation/CoreFoundation.h>

@implementation AksReachability {
    SCNetworkReachabilityRef _reachabilityRef;
}
    
+ (instancetype)reachabilityWithHostName:(NSString *)hostName {
    AksReachability* returnValue = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL){
        returnValue= [[self alloc] init];
        if (returnValue != NULL){
            returnValue->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}
    
    
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    AksReachability* returnValue = NULL;
    if (reachability != NULL){
        returnValue = [[self alloc] init];
        if (returnValue != NULL){
            returnValue->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}
    
    
+ (instancetype)reachabilityForInternetConnection{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}
    
- (NetworkStatus)currentReachabilityStatus {
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    NetworkStatus returnValue = NotReachable;
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        returnValue = [self networkStatusForFlags:flags];
    }
    return returnValue;
}
    
- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0){
        return NotReachable;
    }
    NetworkStatus returnValue = NotReachable;
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0){
        returnValue = ReachableViaWiFi;
    }
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            returnValue = ReachableViaWiFi;
        }
    }
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN){
        returnValue = ReachableViaWWAN;
    }
    return returnValue;
}
    
- (void)dealloc{
    if (_reachabilityRef != NULL){
        CFRelease(_reachabilityRef);
    }
}
    
    @end


#import <QuartzCore/QuartzCore.h>

@interface SVPulsingAnnotationView ()
    
    @property (nonatomic, readwrite) BOOL shouldBeFlat;
    
    @property (nonatomic, strong) CALayer *shinyDotLayer;
    @property (nonatomic, strong) CALayer *glowingHaloLayer;
    
    @property (nonatomic, strong) CALayer *whiteDotLayer;
    @property (nonatomic, strong) CALayer *colorDotLayer;
    @property (nonatomic, strong) CALayer *colorHaloLayer;
    
    @property (nonatomic, strong) CAAnimationGroup *pulseAnimationGroup;
    
    @end

@implementation SVPulsingAnnotationView
    
    @synthesize annotation = _annotation;
    @synthesize userInfo;
    
+ (NSMutableDictionary*)cachedRingImages {
    static NSMutableDictionary *cachedRingLayers = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{ cachedRingLayers = [NSMutableDictionary new]; });
    return cachedRingLayers;
}
    
- (BOOL)shouldBeFlat {
    return ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] == NSOrderedDescending);
}
    
- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.calloutOffset = CGPointMake(0, 4);
        
        if(self.shouldBeFlat) {
            self.bounds = CGRectMake(0, 0, 22, 22);
            self.pulseAnimationDuration = 1.5;
            self.outerPulseAnimationDuration = 3;
            self.delayBetweenPulseCycles = 0;
            self.annotationColor = [UIColor colorWithRed:0.000 green:0.478 blue:1.000 alpha:1];
        }
        else {
            self.bounds = CGRectMake(0, 0, 23, 23);
            self.pulseAnimationDuration = 1;
            self.outerPulseAnimationDuration = 1;
            self.delayBetweenPulseCycles = 1;
            self.annotationColor = [UIColor colorWithRed:0.082 green:0.369 blue:0.918 alpha:1];
        }
    }
    return self;
}
    
- (void)rebuildLayers {
    if(self.shouldBeFlat) {
        [_whiteDotLayer removeFromSuperlayer];
        _whiteDotLayer = nil;
        
        [_colorDotLayer removeFromSuperlayer];
        _colorDotLayer = nil;
        
        [_colorHaloLayer removeFromSuperlayer];
        _colorHaloLayer = nil;
        
        [self.layer addSublayer:self.colorHaloLayer];
        [self.layer addSublayer:self.whiteDotLayer];
        [self.layer addSublayer:self.colorDotLayer];
    }
    else {
        [_glowingHaloLayer removeFromSuperlayer];
        _glowingHaloLayer = nil;
        
        [_shinyDotLayer removeFromSuperlayer];
        _shinyDotLayer = nil;
        
        [self.layer addSublayer:self.glowingHaloLayer];
        [self.layer addSublayer:self.shinyDotLayer];
    }
}
    
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if(newSuperview) {
        [self rebuildLayers];
        [self popIn];
    }
}
    
- (void)popIn {
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    CAMediaTimingFunction *easeInOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    bounceAnimation.values = @[@0.05, @1.25, @0.8, @1.1, @0.9, @1.0];
    bounceAnimation.duration = 0.3;
    bounceAnimation.timingFunctions = @[easeInOut, easeInOut, easeInOut, easeInOut, easeInOut, easeInOut];
    [(self.shouldBeFlat ? self.layer : self.shinyDotLayer) addAnimation:bounceAnimation forKey:@"popIn"];
}
    
- (void)setAnnotationColor:(UIColor *)annotationColor {
    if(CGColorGetNumberOfComponents(annotationColor.CGColor) == 2) {
        float white = CGColorGetComponents(annotationColor.CGColor)[0];
        float alpha = CGColorGetComponents(annotationColor.CGColor)[1];
        annotationColor = [UIColor colorWithRed:white green:white blue:white alpha:alpha];
    }
    _annotationColor = annotationColor;
    
    if(self.superview)
    [self rebuildLayers];
}
    
- (void)setDelayBetweenPulseCycles:(NSTimeInterval)delayBetweenPulseCycles {
    _delayBetweenPulseCycles = delayBetweenPulseCycles;
    
    if(self.superview)
    [self rebuildLayers];
}
    
- (void)setPulseAnimationDuration:(NSTimeInterval)pulseAnimationDuration {
    _pulseAnimationDuration = pulseAnimationDuration;
    
    if(self.superview)
    [self rebuildLayers];
}
    
- (CAAnimationGroup*)pulseAnimationGroup {
    if(!_pulseAnimationGroup) {
        CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        _pulseAnimationGroup = [CAAnimationGroup animation];
        _pulseAnimationGroup.duration = self.outerPulseAnimationDuration + self.delayBetweenPulseCycles;
        _pulseAnimationGroup.repeatCount = INFINITY;
        _pulseAnimationGroup.removedOnCompletion = NO;
        _pulseAnimationGroup.timingFunction = defaultCurve;
        
        NSMutableArray *animations = [NSMutableArray new];
        
        if(!self.shouldBeFlat) {
            CAKeyframeAnimation *imageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
            imageAnimation.duration = self.pulseAnimationDuration;
            imageAnimation.calculationMode = kCAAnimationDiscrete;
            imageAnimation.values = @[
                                      (id)[[self haloImageWithRadius:20] CGImage],
                                      (id)[[self haloImageWithRadius:35] CGImage],
                                      (id)[[self haloImageWithRadius:50] CGImage]
                                      ];
            [animations addObject:imageAnimation];
        }
        
        
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
        pulseAnimation.fromValue = @0.0;
        pulseAnimation.toValue = @1.0;
        pulseAnimation.duration = self.outerPulseAnimationDuration;
        [animations addObject:pulseAnimation];
        
        
        if(!self.shouldBeFlat) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.fromValue = @1.0;
            animation.toValue = @0.0;
            animation.duration = self.outerPulseAnimationDuration;
            animation.timingFunction = defaultCurve;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            [animations addObject:animation];
        }
        else {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
            animation.duration = self.outerPulseAnimationDuration;
            animation.values = @[@0.45, @0.45, @0];
            animation.keyTimes = @[@0, @0.2, @1];
            animation.removedOnCompletion = NO;
            [animations addObject:animation];
        }
        
        _pulseAnimationGroup.animations = animations;
    }
    return _pulseAnimationGroup;
}
    
- (CALayer*)whiteDotLayer {
    if(!_whiteDotLayer) {
        _whiteDotLayer = [CALayer layer];
        _whiteDotLayer.bounds = self.bounds;
        _whiteDotLayer.contents = (id)[self circleImageWithColor:[UIColor whiteColor] height:22].CGImage;
        _whiteDotLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _whiteDotLayer.contentsGravity = kCAGravityCenter;
        _whiteDotLayer.contentsScale = [UIScreen mainScreen].scale;
        _whiteDotLayer.shadowColor = [UIColor blackColor].CGColor;
        _whiteDotLayer.shadowOffset = CGSizeMake(0, 2);
        _whiteDotLayer.shadowRadius = 3;
        _whiteDotLayer.shadowOpacity = 0.3;
        _whiteDotLayer.shouldRasterize = YES;
        _whiteDotLayer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    return _whiteDotLayer;
}
    
- (CALayer*)colorDotLayer {
    if(!_colorDotLayer) {
        _colorDotLayer = [CALayer layer];
        _colorDotLayer.bounds = CGRectMake(0, 0, 16, 16);
        _colorDotLayer.allowsGroupOpacity = YES;
        _colorDotLayer.backgroundColor = self.annotationColor.CGColor;
        _colorDotLayer.cornerRadius = 8;
        _colorDotLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            
            if(self.delayBetweenPulseCycles != INFINITY) {
                CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
                
                CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
                animationGroup.duration = self.pulseAnimationDuration;
                animationGroup.repeatCount = INFINITY;
                animationGroup.removedOnCompletion = NO;
                animationGroup.autoreverses = YES;
                animationGroup.beginTime = 1;
                animationGroup.timingFunction = defaultCurve;
                animationGroup.speed = 1;
                animationGroup.fillMode = kCAFillModeBoth;
                
                CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
                pulseAnimation.fromValue = @0.8;
                pulseAnimation.toValue = @1;
                pulseAnimation.duration = self.pulseAnimationDuration;
                
                CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                opacityAnimation.fromValue = @0.8;
                opacityAnimation.toValue = @1;
                opacityAnimation.duration = self.pulseAnimationDuration;
                
                animationGroup.animations = @[pulseAnimation, opacityAnimation];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [_colorDotLayer addAnimation:animationGroup forKey:@"pulse"];
                });
            }
        });
        
    }
    return _colorDotLayer;
}
    
- (CALayer *)colorHaloLayer {
    if(!_colorHaloLayer) {
        _colorHaloLayer = [CALayer layer];
        _colorHaloLayer.bounds = CGRectMake(0, 0, 40, 40);
        _colorHaloLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _colorHaloLayer.contentsScale = [UIScreen mainScreen].scale;
        _colorHaloLayer.backgroundColor = self.annotationColor.CGColor;
        _colorHaloLayer.cornerRadius = 20;
        _colorHaloLayer.opacity = 0;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            if(self.delayBetweenPulseCycles != INFINITY) {
                CAAnimationGroup *animationGroup = self.pulseAnimationGroup;
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [_colorHaloLayer addAnimation:animationGroup forKey:@"pulse"];
                });
            }
        });
    }
    return _colorHaloLayer;
}
    
- (UIImage*)circleImageWithColor:(UIColor*)color height:(float)height {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(height, height), NO, 0);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    UIBezierPath* fillPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, height, height)];
    [color setFill];
    [fillPath fill];
    
    UIImage *dotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(colorSpace);
    
    return dotImage;
}
    
- (CALayer *)shinyDotLayer {
    if(!_shinyDotLayer) {
        _shinyDotLayer = [CALayer layer];
        _shinyDotLayer.bounds = self.bounds;
        _shinyDotLayer.contents = (id)[self dotAnnotationImage].CGImage;
        _shinyDotLayer.position = CGPointMake(self.bounds.size.width/2+0.5, self.bounds.size.height/2+0.5); // 0.5 is for drop shadow
        _shinyDotLayer.contentsGravity = kCAGravityCenter;
        _shinyDotLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    return _shinyDotLayer;
}
    
- (CALayer *)glowingHaloLayer {
    if(!_glowingHaloLayer) {
        _glowingHaloLayer = [CALayer layer];
        _glowingHaloLayer.bounds = CGRectMake(0, 0, 100, 100);
        _glowingHaloLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _glowingHaloLayer.contentsScale = [UIScreen mainScreen].scale;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            if(self.delayBetweenPulseCycles != INFINITY) {
                CAAnimationGroup *animationGroup = self.pulseAnimationGroup;
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [_glowingHaloLayer addAnimation:animationGroup forKey:@"pulse"];
                });
            }
        });
    }
    return _glowingHaloLayer;
}
    
- (UIImage*)haloImageWithRadius:(CGFloat)radius {
    NSString *key = [NSString stringWithFormat:@"%@-%.0f", self.annotationColor, radius];
    UIImage *ringImage = [[SVPulsingAnnotationView cachedRingImages] objectForKey:key];
    
    if(!ringImage) {
        CGFloat glowRadius = radius/6;
        CGFloat ringThickness = radius/24;
        CGPoint center = CGPointMake(glowRadius+radius, glowRadius+radius);
        CGRect imageBounds = CGRectMake(0, 0, center.x*2, center.y*2);
        CGRect ringFrame = CGRectMake(glowRadius, glowRadius, radius*2, radius*2);
        
        UIGraphicsBeginImageContextWithOptions(imageBounds.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIColor* ringColor = [UIColor whiteColor];
        [ringColor setFill];
        
        UIBezierPath *ringPath = [UIBezierPath bezierPathWithOvalInRect:ringFrame];
        [ringPath appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectInset(ringFrame, ringThickness, ringThickness)]];
        ringPath.usesEvenOddFillRule = YES;
        
        for(float i=1.3; i>0.3; i-=0.18) {
            CGFloat blurRadius = MIN(1, i)*glowRadius;
            CGContextSetShadowWithColor(context, CGSizeZero, blurRadius, self.annotationColor.CGColor);
            [ringPath fill];
        }
        
        ringImage = UIGraphicsGetImageFromCurrentImageContext();
        [[SVPulsingAnnotationView cachedRingImages] setObject:ringImage forKey:key];
        
        UIGraphicsEndImageContext();
    }
    return ringImage;
}
    
- (UIImage*)dotAnnotationImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(16, 16), NO, 0);
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint origin = CGPointMake(0, 0);
    
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    CGFloat routeColorRGBA[4];
    [self.annotationColor getRed: &routeColorRGBA[0] green: &routeColorRGBA[1] blue: &routeColorRGBA[2] alpha: &routeColorRGBA[3]];
    
    UIColor* strokeColor = [UIColor colorWithRed: (routeColorRGBA[0] * 0.9) green: (routeColorRGBA[1] * 0.9) blue: (routeColorRGBA[2] * 0.9) alpha: (routeColorRGBA[3] * 0.9 + 0.1)];
    UIColor* outerShadowColor = [self.annotationColor colorWithAlphaComponent: 0.5];
    UIColor* transparentColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0];
    
    //// Gradient Declarations
    NSArray* glossGradientColors = [NSArray arrayWithObjects:
                                    (id)fillColor.CGColor,
                                    (id)[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.5].CGColor,
                                    (id)transparentColor.CGColor, nil];
    CGFloat glossGradientLocations[] = {0, 0.49, 1};
    CGGradientRef glossGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)glossGradientColors, glossGradientLocations);
    
    //// Shadow Declarations
    UIColor* innerShadow = fillColor;
    CGSize innerShadowOffset = CGSizeMake(-1.1, -2.1);
    CGFloat innerShadowBlurRadius = 2;
    UIColor* outerShadow = outerShadowColor;
    CGSize outerShadowOffset = CGSizeMake(0.5, 0.5);
    CGFloat outerShadowBlurRadius = 1.5;
    
    //// drop shadow Drawing
    UIBezierPath* dropShadowPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, outerShadowOffset, outerShadowBlurRadius, outerShadow.CGColor);
    [strokeColor setFill];
    [dropShadowPath fill];
    CGContextRestoreGState(context);
    
    //// fill Drawing
    UIBezierPath* fillPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
    [self.annotationColor setFill];
    [fillPath fill];
    
    //// Group
    {
        CGContextSaveGState(context);
        CGContextSetAlpha(context, 0.5);
        CGContextSetBlendMode(context, kCGBlendModeOverlay);
        CGContextBeginTransparencyLayer(context, NULL);
        
        //// Clip mask 3
        UIBezierPath* mask3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
        [mask3Path addClip];
        
        
        //// bottom inner light Drawing
        UIBezierPath* bottomInnerLightPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+3, origin.y+3, 14, 14)];
        CGContextSaveGState(context);
        [bottomInnerLightPath addClip];
        CGContextDrawRadialGradient(context, glossGradient,
                                    CGPointMake(origin.x+10, origin.y+10), 0.54,
                                    CGPointMake(origin.x+10, origin.y+10), 5.93,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        CGContextRestoreGState(context);
        
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    
    
    //// bottom circle inner light
    {
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, kCGBlendModeOverlay);
        CGContextBeginTransparencyLayer(context, NULL);
        
        //// Clip mask 4
        UIBezierPath* mask4Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
        [mask4Path addClip];
        
        
        //// bottom circle inner light 2 Drawing
        UIBezierPath* bottomCircleInnerLight2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x-1.5, origin.y-0.5, 16, 16)];
        [transparentColor setFill];
        [bottomCircleInnerLight2Path fill];
        
        ////// bottom circle inner light 2 Inner Shadow
        CGRect bottomCircleInnerLight2BorderRect = CGRectInset([bottomCircleInnerLight2Path bounds], -innerShadowBlurRadius, -innerShadowBlurRadius);
        bottomCircleInnerLight2BorderRect = CGRectOffset(bottomCircleInnerLight2BorderRect, -innerShadowOffset.width, -innerShadowOffset.height);
        bottomCircleInnerLight2BorderRect = CGRectInset(CGRectUnion(bottomCircleInnerLight2BorderRect, [bottomCircleInnerLight2Path bounds]), -1, -1);
        
        UIBezierPath* bottomCircleInnerLight2NegativePath = [UIBezierPath bezierPathWithRect: bottomCircleInnerLight2BorderRect];
        [bottomCircleInnerLight2NegativePath appendPath: bottomCircleInnerLight2Path];
        bottomCircleInnerLight2NegativePath.usesEvenOddFillRule = YES;
        
        CGContextSaveGState(context);
        {
            CGFloat xOffset = innerShadowOffset.width + round(bottomCircleInnerLight2BorderRect.size.width);
            CGFloat yOffset = innerShadowOffset.height;
            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        innerShadowBlurRadius,
                                        innerShadow.CGColor);
            
            [bottomCircleInnerLight2Path addClip];
            CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(bottomCircleInnerLight2BorderRect.size.width), 0);
            [bottomCircleInnerLight2NegativePath applyTransform: transform];
            [[UIColor grayColor] setFill];
            [bottomCircleInnerLight2NegativePath fill];
        }
        CGContextRestoreGState(context);
        
        
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    
    
    //// bottom circle inner light 3
    {
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, kCGBlendModeOverlay);
        CGContextBeginTransparencyLayer(context, NULL);
        
        //// Clip mask 2
        UIBezierPath* mask2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
        [mask2Path addClip];
        
        
        //// bottom circle inner light 4 Drawing
        UIBezierPath* bottomCircleInnerLight4Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x-1.5, origin.y-0.5, 16, 16)];
        [transparentColor setFill];
        [bottomCircleInnerLight4Path fill];
        
        ////// bottom circle inner light 4 Inner Shadow
        CGRect bottomCircleInnerLight4BorderRect = CGRectInset([bottomCircleInnerLight4Path bounds], -innerShadowBlurRadius, -innerShadowBlurRadius);
        bottomCircleInnerLight4BorderRect = CGRectOffset(bottomCircleInnerLight4BorderRect, -innerShadowOffset.width, -innerShadowOffset.height);
        bottomCircleInnerLight4BorderRect = CGRectInset(CGRectUnion(bottomCircleInnerLight4BorderRect, [bottomCircleInnerLight4Path bounds]), -1, -1);
        
        UIBezierPath* bottomCircleInnerLight4NegativePath = [UIBezierPath bezierPathWithRect: bottomCircleInnerLight4BorderRect];
        [bottomCircleInnerLight4NegativePath appendPath: bottomCircleInnerLight4Path];
        bottomCircleInnerLight4NegativePath.usesEvenOddFillRule = YES;
        
        CGContextSaveGState(context);
        {
            CGFloat xOffset = innerShadowOffset.width + round(bottomCircleInnerLight4BorderRect.size.width);
            CGFloat yOffset = innerShadowOffset.height;
            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        innerShadowBlurRadius,
                                        innerShadow.CGColor);
            
            [bottomCircleInnerLight4Path addClip];
            CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(bottomCircleInnerLight4BorderRect.size.width), 0);
            [bottomCircleInnerLight4NegativePath applyTransform: transform];
            [[UIColor grayColor] setFill];
            [bottomCircleInnerLight4NegativePath fill];
        }
        CGContextRestoreGState(context);
        
        
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    
    
    //// fill 2 Drawing
    
    
    //// glosses
    {
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, kCGBlendModeOverlay);
        CGContextBeginTransparencyLayer(context, NULL);
        
        //// Clip mask
        UIBezierPath* maskPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
        [maskPath addClip];
        
        
        //// white gloss glow 2 Drawing
        UIBezierPath* whiteGlossGlow2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+1.5, origin.y+0.5, 7.5, 7.5)];
        CGContextSaveGState(context);
        [whiteGlossGlow2Path addClip];
        CGContextDrawRadialGradient(context, glossGradient,
                                    CGPointMake(origin.x+5.25, origin.y+4.25), 0.68,
                                    CGPointMake(origin.x+5.25, origin.y+4.25), 2.68,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        CGContextRestoreGState(context);
        
        
        //// white gloss glow 1 Drawing
        UIBezierPath* whiteGlossGlow1Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+1.5, origin.y+0.5, 7.5, 7.5)];
        CGContextSaveGState(context);
        [whiteGlossGlow1Path addClip];
        CGContextDrawRadialGradient(context, glossGradient,
                                    CGPointMake(origin.x+5.25, origin.y+4.25), 0.68,
                                    CGPointMake(origin.x+5.25, origin.y+4.25), 1.93,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        CGContextRestoreGState(context);
        
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    
    
    //// white gloss Drawing
    UIBezierPath* whiteGlossPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+2, origin.y+1, 6.5, 6.5)];
    CGContextSaveGState(context);
    [whiteGlossPath addClip];
    CGContextDrawRadialGradient(context, glossGradient,
                                CGPointMake(origin.x+5.25, origin.y+4.25), 0.5,
                                CGPointMake(origin.x+5.25, origin.y+4.25), 1.47,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    
    //// stroke Drawing
    UIBezierPath* strokePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
    [strokeColor setStroke];
    strokePath.lineWidth = 1;
    [strokePath stroke];
    
    UIImage *dotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //// Cleanup
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(colorSpace);
    
    return dotImage;
}
    
    @end



@implementation SwiftTryCatch
    
    /**
     Provides try catch functionality for swift by wrapping around Objective-C
     */
+(void)tryThis:(void (^)())try catchThis:(void (^)(NSException *))catch finally:(void (^)())finally{
    @try {
        try ? try() : nil;
    }
    
    @catch (NSException *exception) {
        NSLog(@"\n\n\n\n\n\n\
              \n\n|EXCEPTION FOUND HERE...PLEASE DO NOT IGNORE\
              \n\n|\
              \n\n|\
              \n\n|\
              \n\n|EXCEPTION REASON  %@\
              \n\n\n\n\n\n\n",exception);
        catch ? catch(exception) : nil;
    }
    @finally {
        finally ? finally() : nil;
    }
}
    
+ (void)throwString:(NSString*)s
    {
        @throw [NSException exceptionWithName:s reason:s userInfo:nil];
    }
    
+ (void)throwException:(NSException*)e
    {
        @throw e;
    }
    
    @end


#import <QuartzCore/QuartzCore.h>

NSString *const kMarqueeLabelControllerRestartNotification = @"MarqueeLabelViewControllerRestart";
NSString *const kMarqueeLabelShouldLabelizeNotification = @"MarqueeLabelShouldLabelizeNotification";
NSString *const kMarqueeLabelShouldAnimateNotification = @"MarqueeLabelShouldAnimateNotification";

typedef void (^animationCompletionBlock)(void);

// Helpers
@interface UIView (MarqueeLabelHelpers)
- (UIViewController *)firstAvailableViewController;
- (id)traverseResponderChainForFirstViewController;
    @end

@interface MarqueeLabel ()
    
    @property (nonatomic, strong) UILabel *subLabel;
    
    @property (nonatomic, assign, readwrite) BOOL awayFromHome;
    @property (nonatomic, assign) BOOL orientationWillChange;
    @property (nonatomic, strong) id orientationObserver;
    
    @property (nonatomic, assign) NSTimeInterval animationDuration;
    @property (nonatomic, assign, readonly) BOOL labelShouldScroll;
    @property (nonatomic, weak) UITapGestureRecognizer *tapRecognizer;
    @property (nonatomic, assign) CGRect homeLabelFrame;
    @property (nonatomic, assign) CGRect awayLabelFrame;
    @property (nonatomic, assign, readwrite) BOOL isPaused;
    
- (void)scrollAwayWithInterval:(NSTimeInterval)interval;
- (void)scrollHomeWithInterval:(NSTimeInterval)interval;
- (void)returnLabelToOriginImmediately;
- (void)restartLabel;
- (void)setupLabel;
- (void)observedViewControllerChange:(NSNotification *)notification;
- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength;
- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength animated:(BOOL)animated;
- (NSArray *)allSubLabels;
    
    // Support
    @property (nonatomic, strong) NSArray *gradientColors;
    
    @end


@implementation MarqueeLabel
    
+ (void)restartLabelsOfController:(UIViewController *)controller {
    [MarqueeLabel notifyController:controller
                       withMessage:kMarqueeLabelControllerRestartNotification];
}
    
+ (void)controllerViewWillAppear:(UIViewController *)controller {
    [MarqueeLabel restartLabelsOfController:controller];
}
    
+ (void)controllerViewDidAppear:(UIViewController *)controller {
    [MarqueeLabel restartLabelsOfController:controller];
}
    
+ (void)controllerViewAppearing:(UIViewController *)controller {
    [MarqueeLabel restartLabelsOfController:controller];
}
    
+ (void)controllerLabelsShouldLabelize:(UIViewController *)controller {
    [MarqueeLabel notifyController:controller
                       withMessage:kMarqueeLabelShouldLabelizeNotification];
}
    
+ (void)controllerLabelsShouldAnimate:(UIViewController *)controller {
    [MarqueeLabel notifyController:controller
                       withMessage:kMarqueeLabelShouldAnimateNotification];
}
    
+ (void)notifyController:(UIViewController *)controller withMessage:(NSString *)message {
    if (controller && message) {
        [[NSNotificationCenter defaultCenter] postNotificationName:message
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:controller
                                                                                               forKey:@"controller"]];
    }
}
    
- (void)viewControllerShouldRestart:(NSNotification *)notification {
    UIViewController *controller = [[notification userInfo] objectForKey:@"controller"];
    if (controller == [self firstAvailableViewController]) {
        [self restartLabel];
    }
}
    
- (void)labelsShouldLabelize:(NSNotification *)notification {
    UIViewController *controller = [[notification userInfo] objectForKey:@"controller"];
    if (controller == [self firstAvailableViewController]) {
        self.labelize = YES;
    }
}
    
- (void)labelsShouldAnimate:(NSNotification *)notification {
    UIViewController *controller = [[notification userInfo] objectForKey:@"controller"];
    if (controller == [self firstAvailableViewController]) {
        self.labelize = NO;
    }
}
    
- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame duration:7.0 andFadeLength:0.0];
}
    
- (id)initWithFrame:(CGRect)frame duration:(NSTimeInterval)aLengthOfScroll andFadeLength:(CGFloat)aFadeLength {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLabel];
        
        _lengthOfScroll = aLengthOfScroll;
        self.fadeLength = MIN(aFadeLength, frame.size.width / 2);
    }
    return self;
}
    
- (id)initWithFrame:(CGRect)frame rate:(CGFloat)pixelsPerSec andFadeLength:(CGFloat)aFadeLength {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLabel];
        
        _rate = pixelsPerSec;
        self.fadeLength = MIN(aFadeLength, frame.size.width / 2);
    }
    return self;
}
    
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLabel];
        
        if (self.lengthOfScroll == 0) {
            self.lengthOfScroll = 7.0;
        }
    }
    return self;
}
    
- (void)awakeFromNib {
    [super awakeFromNib];
    [self forwardPropertiesToSubLabel];
}
    
- (void)forwardPropertiesToSubLabel {
    // Since we're a UILabel, we actually do implement all of UILabel's properties.
    // We don't care about these values, we just want to forward them on to our sublabel.
    NSArray *properties = @[@"baselineAdjustment", @"enabled", @"font", @"highlighted", @"highlightedTextColor", @"minimumFontSize", @"shadowColor", @"shadowOffset", @"textAlignment", @"textColor", @"userInteractionEnabled", @"text", @"adjustsFontSizeToFitWidth", @"lineBreakMode", @"numberOfLines", @"backgroundColor"];
    for (NSString *property in properties) {
        id val = [super valueForKey:property];
        [self.subLabel setValue:val forKey:property];
    }
    [self setText:[super text]];
    
    // Clear super text, in the case of IB-created labels, to prevent double-drawing
    [super setText:nil];
    
    [self setFont:[super font]];
}
    
- (void)setupLabel {
    // Basic UILabel options override
    self.clipsToBounds = YES;
    self.numberOfLines = 1;
    
    self.subLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.subLabel.tag = 700;
    [self addSubview:self.subLabel];
    
    [super setBackgroundColor:[UIColor clearColor]];
    
    _animationCurve = UIViewAnimationOptionCurveEaseInOut;
    _awayFromHome = NO;
    _orientationWillChange = NO;
    _labelize = NO;
    _holdScrolling = NO;
    _tapToScroll = NO;
    _isPaused = NO;
    _fadeLength = 0.0f;
    _animationDelay = 1.0;
    _animationDuration = 0.0f;
    _continuousMarqueeExtraBuffer = 0.0f;
    
    // Add notification observers
    // Custom class notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerShouldRestart:) name:kMarqueeLabelControllerRestartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(labelsShouldLabelize:) name:kMarqueeLabelShouldLabelizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(labelsShouldAnimate:) name:kMarqueeLabelShouldAnimateNotification object:nil];
    
    // UINavigationController view controller change notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observedViewControllerChange:) name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
    
    // UIApplication state notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartLabel) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartLabel) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shutdownLabel) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shutdownLabel) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // Device Orientation change handling
    /* Necessary to prevent a "super-speed" scroll bug. When the frame is changed due to a flexible width autoresizing mask,
     * the setFrame call occurs during the in-flight orientation rotation animation, and the scroll to the away location
     * occurs at super speed. To work around this, the orientationWilLChange property is set to YES when the notification
     * UIApplicationWillChangeStatusBarOrientationNotification is posted, and a notification handler block listening for
     * the UIViewAnimationDidStopNotification notification is added. The handler block checks the notification userInfo to
     * see if the delegate of the ending animation is the UIWindow of the label. If so, the rotation animation has finished
     * and the label can be restarted, and the notification observer removed.
     */
    
    __weak __typeof(& *self) weakSelf = self;
    
    __block id animationObserver = nil;
    self.orientationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification
                                                                                 object:nil
                                                                                  queue:nil
                                                                             usingBlock: ^(NSNotification *notification) {
                                                                                 weakSelf.orientationWillChange = YES;
                                                                                 [weakSelf returnLabelToOriginImmediately];
                                                                                 animationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"UIViewAnimationDidStopNotification"
                                                                                                                                                       object:nil
                                                                                                                                                        queue:nil
                                                                                                                                                   usingBlock: ^(NSNotification *notification) {
                                                                                                                                                       if ([notification.userInfo objectForKey:@"delegate"] == weakSelf.window) {
                                                                                                                                                           weakSelf.orientationWillChange = NO;
                                                                                                                                                           [weakSelf restartLabel];
                                                                                                                                                           
                                                                                                                                                           // Remove notification observer
                                                                                                                                                           [[NSNotificationCenter defaultCenter] removeObserver:animationObserver];
                                                                                                                                                       }
                                                                                                                                                   }];
                                                                             }];
}
    
- (void)observedViewControllerChange:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    id fromController = [userInfo objectForKey:@"UINavigationControllerLastVisibleViewController"];
    id toController = [userInfo objectForKey:@"UINavigationControllerNextVisibleViewController"];
    
    id ownController = [self firstAvailableViewController];
    if ([fromController isEqual:ownController]) {
        [self shutdownLabel];
    }
    else if ([toController isEqual:ownController]) {
        [self restartLabel];
    }
}
    
- (void)minimizeLabelFrameWithMaximumSize:(CGSize)maxSize adjustHeight:(BOOL)adjustHeight {
    if (self.subLabel.text != nil) {
        // Calculate text size
        if (CGSizeEqualToSize(maxSize, CGSizeZero)) {
            maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        }
        CGSize minimumLabelSize = [self subLabelSize];
        
        
        // Adjust for fade length
        CGSize minimumSize = CGSizeMake(minimumLabelSize.width + (self.fadeLength * 2), minimumLabelSize.height);
        
        // Find minimum size of options
        minimumSize = CGSizeMake(MIN(minimumSize.width, maxSize.width), MIN(minimumSize.height, maxSize.height));
        
        // Apply to frame
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, minimumSize.width, (adjustHeight ? minimumSize.height : self.frame.size.height));
    }
}
    
- (void)didMoveToSuperview {
    [self updateSublabelAndLocationsAndBeginScroll:YES];
}
    
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self applyGradientMaskForFadeLength:self.fadeLength animated:!self.orientationWillChange];
    [self updateSublabelAndLocationsAndBeginScroll:!self.orientationWillChange];
}
    
- (void)updateSublabelAndLocations {
    [self updateSublabelAndLocationsAndBeginScroll:YES];
}
    
- (void)updateSublabelAndLocationsAndBeginScroll:(BOOL)beginScroll {
    if (!self.subLabel.text) {
        return;
    }
    
    // Calculate expected size
    CGSize expectedLabelSize = [self subLabelSize];
    
    // Invalidate intrinsic size
    if ([self respondsToSelector:@selector(invalidateIntrinsicContentSize)]) {
        [self invalidateIntrinsicContentSize];
    }
    
    // Move to origin
    [self returnLabelToOriginImmediately];
    
    // Check if label is labelized, or does not need to scroll
    if (self.labelize || !self.labelShouldScroll) {
        // Set text alignment and break mode to act like normal label
        [self.subLabel setTextAlignment:[super textAlignment]];
        [self.subLabel setLineBreakMode:[super lineBreakMode]];
        
        CGRect labelFrame = CGRectIntegral(CGRectMake(self.fadeLength, 0.0f, self.bounds.size.width - self.fadeLength * 2.0f, expectedLabelSize.height));
        
        self.homeLabelFrame = labelFrame;
        self.awayLabelFrame = labelFrame;
        
        // Remove any additional text layers (for MLContinuous)
        NSArray *labels = [self allSubLabels];
        for (UILabel *sl in labels) {
            if (sl != self.subLabel) {
                [sl removeFromSuperview];
            }
        }
        
        self.subLabel.frame = self.homeLabelFrame;
        
        return;
    }
    
    // Label does need to scroll
    [self.subLabel setLineBreakMode:NSLineBreakByClipping];
    
    switch (self.marqueeType) {
        case MLContinuous:
        {
            self.homeLabelFrame = CGRectIntegral(CGRectMake(self.fadeLength, 0.0f, expectedLabelSize.width, expectedLabelSize.height));
            CGFloat awayLabelOffset = -(self.homeLabelFrame.size.width + 2 * self.fadeLength + self.continuousMarqueeExtraBuffer);
            self.awayLabelFrame = CGRectIntegral(CGRectOffset(self.homeLabelFrame, awayLabelOffset, 0.0f));
            
            NSArray *labels = [self allSubLabels];
            if (labels.count < 2) {
                UILabel *secondSubLabel = [[UILabel alloc] initWithFrame:CGRectOffset(self.homeLabelFrame, self.homeLabelFrame.size.width + self.fadeLength + self.continuousMarqueeExtraBuffer, 0.0f)];
                secondSubLabel.tag = 701;
                secondSubLabel.numberOfLines = 1;
                
                [self addSubview:secondSubLabel];
                labels = [labels arrayByAddingObject:secondSubLabel];
            }
            
            [self refreshSubLabels:labels];
            
            // Recompute the animation duration
            self.animationDuration = (self.rate != 0) ? ((NSTimeInterval)fabs(self.awayLabelFrame.origin.x) / self.rate) : (self.lengthOfScroll);
            
            self.subLabel.frame = self.homeLabelFrame;
            
            break;
        }
        
        case MLContinuousReverse:
        {
            self.homeLabelFrame = CGRectIntegral(CGRectMake(self.bounds.size.width - (expectedLabelSize.width + self.fadeLength), 0.0f, expectedLabelSize.width, expectedLabelSize.height));
            CGFloat awayLabelOffset = (self.homeLabelFrame.size.width + 2 * self.fadeLength + self.continuousMarqueeExtraBuffer);
            self.awayLabelFrame = CGRectIntegral(CGRectOffset(self.homeLabelFrame, awayLabelOffset, 0.0f));
            
            NSArray *labels = [self allSubLabels];
            if (labels.count < 2) {
                UILabel *secondSubLabel = [[UILabel alloc] initWithFrame:CGRectOffset(self.homeLabelFrame, -(self.homeLabelFrame.size.width + self.fadeLength + self.continuousMarqueeExtraBuffer), 0.0f)];
                secondSubLabel.numberOfLines = 1;
                secondSubLabel.tag = 701;
                
                [self addSubview:secondSubLabel];
                labels = [labels arrayByAddingObject:secondSubLabel];
            }
            
            [self refreshSubLabels:labels];
            
            // Recompute the animation duration
            self.animationDuration = (self.rate != 0) ? ((NSTimeInterval)fabs(self.awayLabelFrame.origin.x) / self.rate) : (self.lengthOfScroll);
            
            self.subLabel.frame = self.homeLabelFrame;
            
            break;
        }
        
        case MLRightLeft:
        {
            self.homeLabelFrame = CGRectIntegral(CGRectMake(self.bounds.size.width - (expectedLabelSize.width + self.fadeLength), 0.0f, expectedLabelSize.width, expectedLabelSize.height));
            self.awayLabelFrame = CGRectIntegral(CGRectMake(self.fadeLength, 0.0f, expectedLabelSize.width, expectedLabelSize.height));
            
            // Calculate animation duration
            self.animationDuration = (self.rate != 0) ? ((NSTimeInterval)fabs(self.awayLabelFrame.origin.x - self.homeLabelFrame.origin.x) / self.rate) : (self.lengthOfScroll);
            
            // Set frame and text
            self.subLabel.frame = self.homeLabelFrame;
            
            // Enforce text alignment for this type
            self.subLabel.textAlignment = NSTextAlignmentRight;
            
            break;
        }
        
        //Fallback to LeftRight marqueeType
        default:
        {
            self.homeLabelFrame = CGRectIntegral(CGRectMake(self.fadeLength, 0.0f, expectedLabelSize.width, expectedLabelSize.height));
            self.awayLabelFrame = CGRectIntegral(CGRectOffset(self.homeLabelFrame, -expectedLabelSize.width + (self.bounds.size.width - self.fadeLength * 2), 0.0));
            
            // Calculate animation duration
            self.animationDuration = (self.rate != 0) ? ((NSTimeInterval)fabs(self.awayLabelFrame.origin.x - self.homeLabelFrame.origin.x) / self.rate) : (self.lengthOfScroll);
            
            // Set frame
            self.subLabel.frame = self.homeLabelFrame;
            
            // Enforce text alignment for this type
            self.subLabel.textAlignment = NSTextAlignmentLeft;
        }
    } //end of marqueeType switch
    
    if (!self.tapToScroll && !self.holdScrolling && beginScroll) {
        [self beginScroll];
    }
}
    
- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength {
    [self applyGradientMaskForFadeLength:fadeLength animated:YES];
}
    
- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength animated:(BOOL)animated {
    if (animated) {
        [self returnLabelToOriginImmediately];
    }
    
    CAGradientLayer *gradientMask = nil;
    if (fadeLength != 0.0f) {
        // Recreate gradient mask with new fade length
        gradientMask = [CAGradientLayer layer];
        
        gradientMask.bounds = self.layer.bounds;
        gradientMask.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        
        gradientMask.shouldRasterize = YES;
        gradientMask.rasterizationScale = [UIScreen mainScreen].scale;
        
        gradientMask.startPoint = CGPointMake(0.0, CGRectGetMidY(self.frame));
        gradientMask.endPoint = CGPointMake(1.0, CGRectGetMidY(self.frame));
        CGFloat fadePoint = (CGFloat)self.fadeLength / self.frame.size.width;
        [gradientMask setColors:self.gradientColors];
        [gradientMask setLocations:[NSArray arrayWithObjects:
                                    [NSNumber numberWithDouble:0.0],
                                    [NSNumber numberWithDouble:fadePoint],
                                    [NSNumber numberWithDouble:1 - fadePoint],
                                    [NSNumber numberWithDouble:1.0],
                                    nil]];
    }
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.layer.mask = gradientMask;
    [CATransaction commit];
    
    if (animated && self.labelShouldScroll && !self.tapToScroll) {
        [self beginScroll];
    }
}
    
- (CGSize)subLabelSize {
    // Calculate expected size
    CGSize expectedLabelSize = CGSizeZero;
    CGSize maximumLabelSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
    // Check for attributed string attributes
    if ([self.subLabel respondsToSelector:@selector(attributedText)]) {
        // Calculate based on attributed text
        expectedLabelSize = [self.subLabel.attributedText boundingRectWithSize:maximumLabelSize
                                                                       options:0
                                                                       context:nil].size;
    }
    else {
        // Calculate on base string
#if  __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        expectedLabelSize = [self.subLabel.text sizeWithFont:self.font
                                           constrainedToSize:maximumLabelSize
                                               lineBreakMode:NSLineBreakByClipping];
#endif
    }
    
    expectedLabelSize.width = ceilf(expectedLabelSize.width);
    expectedLabelSize.height = self.bounds.size.height;
    
    return expectedLabelSize;
}
    
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize fitSize = [self.subLabel sizeThatFits:size];
    fitSize.width += 2.0f * self.fadeLength;
    return fitSize;
}
    
- (BOOL)labelShouldScroll {
    BOOL stringLength = ([self.subLabel.text length] > 0);
    if (!stringLength) {
        return NO;
    }
    
    BOOL labelWidth = (self.bounds.size.width < [self subLabelSize].width + (self.marqueeType == MLContinuous ? 2 * self.fadeLength : self.fadeLength));
    return (!self.labelize && labelWidth);
}
    
- (NSTimeInterval)durationForInterval:(NSTimeInterval)interval {
    switch (self.marqueeType) {
        case MLContinuous:
        return (interval * 2.0);
        break;
        
        default:
        return interval;
        break;
    }
}
    
- (void)beginScroll {
    [self beginScrollWithDelay:YES];
}
    
- (void)beginScrollWithDelay:(BOOL)delay {
    switch (self.marqueeType) {
        case MLContinuous:
        case MLContinuousReverse:
        [self scrollContinuousWithInterval:[self durationForInterval:self.animationDuration] after:(delay ? self.animationDelay : 0.0)];
        break;
        
        default:
        [self scrollAwayWithInterval:[self durationForInterval:self.animationDuration]];
        break;
    }
}
    
- (void)scrollAwayWithInterval:(NSTimeInterval)interval {
    [self scrollAwayWithInterval:interval delay:YES];
}
    
- (void)scrollAwayWithInterval:(NSTimeInterval)interval delay:(BOOL)delay {
    [self scrollAwayWithInterval:interval delayAmount:(delay ? self.animationDelay : 0.0)];
}
    
- (void)scrollAwayWithInterval:(NSTimeInterval)interval delayAmount:(NSTimeInterval)delayAmount {
    if (![self superview]) {
        return;
    }
    
    UIViewController *viewController = [self firstAvailableViewController];
    if (!(viewController.isViewLoaded && viewController.view.window)) {
        return;
    }
    
    [self.subLabel.layer removeAllAnimations];
    [self.layer removeAllAnimations];
    
    // Call pre-animation method
    [self labelWillBeginScroll];
    
    // Animate
    [UIView animateWithDuration:interval
                          delay:delayAmount
                        options:self.animationCurve
                     animations: ^{
                         self.subLabel.frame = self.awayLabelFrame;
                     }
     
                     completion: ^(BOOL finished) {
                         if (finished) {
                             [self scrollHomeWithInterval:interval delayAmount:delayAmount];
                         }
                     }];
    
    // Move to away state
    self.awayFromHome = YES;
}
    
- (void)scrollHomeWithInterval:(NSTimeInterval)interval {
    [self scrollHomeWithInterval:interval delay:YES];
}
    
- (void)scrollHomeWithInterval:(NSTimeInterval)interval delay:(BOOL)delay {
    [self scrollHomeWithInterval:interval delayAmount:(delay ? self.animationDelay : 0.0)];
}
    
- (void)scrollHomeWithInterval:(NSTimeInterval)interval delayAmount:(NSTimeInterval)delayAmount {
    if (![self superview]) {
        return;
    }
    
    [UIView animateWithDuration:interval
                          delay:delayAmount
                        options:self.animationCurve
                     animations: ^{
                         self.subLabel.frame = self.homeLabelFrame;
                     }
     
                     completion: ^(BOOL finished) {
                         // Call completion method
                         [self labelReturnedToHome:finished];
                         
                         if (finished) {
                             // Set awayFromHome
                             self.awayFromHome = NO;
                             
                             if (!self.tapToScroll && !self.holdScrolling) {
                                 [self scrollAwayWithInterval:interval];
                             }
                         }
                     }];
}
    
- (void)scrollContinuousWithInterval:(NSTimeInterval)interval after:(NSTimeInterval)delayAmount {
    if (![self superview]) {
        return;
    }
    
    // Return labels to home frame
    [self returnLabelToOriginImmediately];
    
    UIViewController *viewController = [self firstAvailableViewController];
    if (!(viewController.isViewLoaded && viewController.view.window)) {
        return;
    }
    
    NSArray *labels = [self allSubLabels];
    __block CGFloat offset = 0.0f;
    
    self.awayFromHome = YES;
    
    // Call pre-animation method
    [self labelWillBeginScroll];
    
    // Animate
    [UIView animateWithDuration:interval
                          delay:delayAmount
                        options:self.animationCurve
                     animations: ^{
                         for (UILabel * sl in labels) {
                             sl.frame = CGRectIntegral(CGRectOffset(self.awayLabelFrame, offset, 0.0f));
                             
                             // Increment offset
                             offset += (self.marqueeType == MLContinuousReverse ? -1.0f : 1.0f) * (self.homeLabelFrame.size.width + 2 * self.fadeLength + self.continuousMarqueeExtraBuffer);
                         }
                     }
     
                     completion: ^(BOOL finished) {
                         // Call completion method
                         [self labelReturnedToHome:finished];
                         
                         if (finished && !self.tapToScroll && !self.holdScrolling) {
                             self.awayFromHome = NO;
                             [self scrollContinuousWithInterval:interval after:delayAmount];
                         }
                     }];
}
    
- (void)returnLabelToOriginImmediately {
    NSArray *labels = [self allSubLabels];
    CGFloat offset = 0.0f;
    for (UILabel *sl in labels) {
        [sl.layer removeAllAnimations];
        sl.frame = CGRectIntegral(CGRectOffset(self.homeLabelFrame, offset, 0.0f));
        offset += (self.marqueeType == MLContinuousReverse ? -1.0f : 1.0f) * (self.homeLabelFrame.size.width + self.fadeLength + self.continuousMarqueeExtraBuffer);
    }
    
    if (self.subLabel.frame.origin.x == self.homeLabelFrame.origin.x) {
        self.awayFromHome = NO;
    }
}
    
- (void)restartLabel {
    [self returnLabelToOriginImmediately];
    
    if (self.labelShouldScroll && !self.tapToScroll) {
        [self beginScroll];
    }
}
    
- (void)resetLabel {
    [self returnLabelToOriginImmediately];
    self.homeLabelFrame = CGRectNull;
    self.awayLabelFrame = CGRectNull;
}
    
- (void)shutdownLabel {
    [self returnLabelToOriginImmediately];
}
    
- (void)pauseLabel {
    if (!self.isPaused) {
        NSArray *labels = [self allSubLabels];
        for (UILabel *sl in labels) {
            CFTimeInterval pausedTime = [sl.layer convertTime:CACurrentMediaTime() fromLayer:nil];
            sl.layer.speed = 0.0;
            sl.layer.timeOffset = pausedTime;
        }
        self.isPaused = YES;
    }
}
    
- (void)unpauseLabel {
    if (self.isPaused) {
        NSArray *labels = [self allSubLabels];
        for (UILabel *sl in labels) {
            CFTimeInterval pausedTime = [sl.layer timeOffset];
            sl.layer.speed = 1.0;
            sl.layer.timeOffset = 0.0;
            sl.layer.beginTime = 0.0;
            CFTimeInterval timeSincePause = [sl.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
            sl.layer.beginTime = timeSincePause;
        }
        self.isPaused = NO;
    }
}
    
- (void)labelWasTapped:(UITapGestureRecognizer *)recognizer {
    if (self.labelShouldScroll) {
        [self beginScrollWithDelay:NO];
    }
}
    
- (void)labelWillBeginScroll {
    return;
}
    
- (void)labelReturnedToHome:(BOOL)finished {
    return;
}
    
- (NSString *)text {
    return self.subLabel.text;
}
    
- (void)setText:(NSString *)text {
    if ([text isEqualToString:self.subLabel.text]) {
        return;
    }
    self.subLabel.text = text;
    [self updateSublabelAndLocations];
}
    
- (UIFont *)font {
    return self.subLabel.font;
}
    
- (void)setFont:(UIFont *)font {
    if ([font isEqual:self.subLabel.font]) {
        return;
    }
    self.subLabel.font = font;
    [self updateSublabelAndLocations];
}
    
- (UIColor *)textColor {
    return self.subLabel.textColor;
}
    
- (void)setTextColor:(UIColor *)textColor {
    [self updateSubLabelsForKey:@"textColor" withValue:textColor];
}
    
- (UIColor *)backgroundColor {
    return self.subLabel.backgroundColor;
}
    
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self updateSubLabelsForKey:@"backgroundColor" withValue:backgroundColor];
}
    
- (UIColor *)shadowColor {
    return self.subLabel.shadowColor;
}
    
- (void)setShadowColor:(UIColor *)shadowColor {
    [self updateSubLabelsForKey:@"shadowColor" withValue:shadowColor];
}
    
- (CGSize)shadowOffset {
    return self.subLabel.shadowOffset;
}
    
- (void)setShadowOffset:(CGSize)shadowOffset {
    [self updateSubLabelsForKey:@"shadowOffset" withValue:[NSValue valueWithCGSize:shadowOffset]];
}
    
- (UIColor *)highlightedTextColor {
    return self.subLabel.highlightedTextColor;
}
    
- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor {
    [self updateSubLabelsForKey:@"highlightedTextColor" withValue:highlightedTextColor];
}
    
- (BOOL)isHighlighted {
    return self.subLabel.isHighlighted;
}
    
- (void)setHighlighted:(BOOL)highlighted {
    [self updateSubLabelsForKey:@"highlighted" withValue:@(highlighted)];
}
    
- (BOOL)isEnabled {
    return self.subLabel.isEnabled;
}
    
- (void)setEnabled:(BOOL)enabled {
    [self updateSubLabelsForKey:@"enabled" withValue:@(enabled)];
}
    
- (void)setNumberOfLines:(NSInteger)numberOfLines {
    // By the nature of MarqueeLabel, this is 1
    [super setNumberOfLines:1];
}
    
- (void)setAdjustsFontSizeToFitWidth:(BOOL)adjustsFontSizeToFitWidth {
    // By the nature of MarqueeLabel, this is NO
    [super setAdjustsFontSizeToFitWidth:NO];
}
    
- (void)setMinimumFontSize:(CGFloat)minimumFontSize {
    [super setMinimumFontSize:0.0];
}
    
- (UIBaselineAdjustment)baselineAdjustment {
    return self.subLabel.baselineAdjustment;
}
    
- (void)setBaselineAdjustment:(UIBaselineAdjustment)baselineAdjustment {
    [self updateSubLabelsForKey:@"baselineAdjustment" withValue:@(baselineAdjustment)];
}
    
- (CGSize)intrinsicContentSize {
    return self.subLabel.intrinsicContentSize;
}
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
- (NSAttributedString *)attributedText {
    return self.subLabel.attributedText;
}
    
- (void)setAttributedText:(NSAttributedString *)attributedText {
    if ([attributedText isEqualToAttributedString:self.subLabel.attributedText]) {
        return;
    }
    self.subLabel.attributedText = attributedText;
    [self updateSublabelAndLocations];
}
    
- (void)setAdjustsLetterSpacingToFitWidth:(BOOL)adjustsLetterSpacingToFitWidth {
    // By the nature of MarqueeLabel, this is NO
    [super setAdjustsLetterSpacingToFitWidth:NO];
}
    
- (void)setMinimumScaleFactor:(CGFloat)minimumScaleFactor {
    [super setMinimumScaleFactor:0.0f];
}
    
#endif
    
- (void)refreshSubLabels:(NSArray *)subLabels {
    for (UILabel *sl in subLabels) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
        sl.attributedText = self.attributedText;
#else
        sl.text = self.text;
        sl.font = self.font;
        sl.textColor = self.textColor;
#endif
        sl.backgroundColor = self.backgroundColor;
        sl.shadowColor = self.shadowColor;
        sl.shadowOffset = self.shadowOffset;
        sl.textAlignment = NSTextAlignmentLeft;
    }
}
    
- (void)updateSubLabelsForKey:(NSString *)key withValue:(id)value {
    NSArray *labels = [self allSubLabels];
    for (UILabel *sl in labels) {
        [sl setValue:value forKeyPath:key];
    }
}
    
- (void)updateSubLabelsForKeysWithValues:(NSDictionary *)dictionary {
    NSArray *labels = [self allSubLabels];
    for (UILabel *sl in labels) {
        for (NSString *key in dictionary) {
            [sl setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
}
    
- (void)setRate:(CGFloat)rate {
    if (_rate == rate) {
        return;
    }
    
    _lengthOfScroll = 0.0f;
    _rate = rate;
    [self updateSublabelAndLocations];
}
    
- (void)setLengthOfScroll:(NSTimeInterval)lengthOfScroll {
    if (_lengthOfScroll == lengthOfScroll) {
        return;
    }
    
    _rate = 0.0f;
    _lengthOfScroll = lengthOfScroll;
    [self updateSublabelAndLocations];
}
    
- (void)setAnimationCurve:(UIViewAnimationOptions)animationCurve {
    if (_animationCurve == animationCurve) {
        return;
    }
    
    NSUInteger allowableOptions = UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionCurveLinear;
    if ((allowableOptions & animationCurve) == animationCurve) {
        _animationCurve = animationCurve;
    }
}
    
- (void)setContinuousMarqueeExtraBuffer:(CGFloat)continuousMarqueeExtraBuffer {
    if (_continuousMarqueeExtraBuffer == continuousMarqueeExtraBuffer) {
        return;
    }
    
    // Do not allow negative values
    _continuousMarqueeExtraBuffer = fabsf(continuousMarqueeExtraBuffer);
    [self updateSublabelAndLocations];
}
    
- (void)setFadeLength:(CGFloat)fadeLength {
    if (_fadeLength == fadeLength) {
        return;
    }
    
    _fadeLength = fadeLength;
    [self applyGradientMaskForFadeLength:_fadeLength];
    [self updateSublabelAndLocations];
}
    
- (void)setTapToScroll:(BOOL)tapToScroll {
    if (_tapToScroll == tapToScroll) {
        return;
    }
    
    _tapToScroll = tapToScroll;
    
    if (_tapToScroll) {
        UITapGestureRecognizer *newTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelWasTapped:)];
        [self addGestureRecognizer:newTapRecognizer];
        self.tapRecognizer = newTapRecognizer;
        self.userInteractionEnabled = YES;
    }
    else {
        [self removeGestureRecognizer:self.tapRecognizer];
        self.tapRecognizer = nil;
        self.userInteractionEnabled = NO;
    }
}
    
- (void)setMarqueeType:(MarqueeType)marqueeType {
    if (marqueeType == _marqueeType) {
        return;
    }
    
    _marqueeType = marqueeType;
    
    if (_marqueeType == MLContinuous) {
    }
    else {
        // Remove any second text layers
        NSArray *labels = [self allSubLabels];
        for (UILabel *sl in labels) {
            if (sl != self.subLabel) {
                [sl removeFromSuperview];
            }
        }
    }
    
    [self updateSublabelAndLocations];
}
    
- (CGRect)awayLabelFrame {
    if (CGRectEqualToRect(_awayLabelFrame, CGRectNull)) {
        // Calculate label size
        CGSize expectedLabelSize = [self subLabelSize];
        // Create home label frame
        _awayLabelFrame = CGRectOffset(self.homeLabelFrame, -expectedLabelSize.width + (self.bounds.size.width - self.fadeLength * 2), 0.0);
    }
    
    return _awayLabelFrame;
}
    
- (CGRect)homeLabelFrame {
    if (CGRectEqualToRect(_homeLabelFrame, CGRectNull)) {
        // Calculate label size
        CGSize expectedLabelSize = [self subLabelSize];
        // Create home label frame
        _homeLabelFrame = CGRectMake(self.fadeLength, 0, (expectedLabelSize.width + self.fadeLength), self.bounds.size.height);
    }
    
    return _homeLabelFrame;
}
    
- (void)setLabelize:(BOOL)labelize {
    if (_labelize == labelize) {
        return;
    }
    
    _labelize = labelize;
    
    if (labelize && self.subLabel != nil) {
        [self returnLabelToOriginImmediately];
    }
    
    [self updateSublabelAndLocationsAndBeginScroll:YES];
}
    
- (void)setHoldScrolling:(BOOL)holdScrolling {
    if (_holdScrolling == holdScrolling) {
        return;
    }
    
    _holdScrolling = holdScrolling;
    
    if (!holdScrolling && !self.awayFromHome) {
        [self beginScroll];
    }
}
    
- (NSArray *)gradientColors {
    if (!_gradientColors) {
        NSObject *transparent = (NSObject *)[[UIColor clearColor] CGColor];
        NSObject *opaque = (NSObject *)[[UIColor blackColor] CGColor];
        _gradientColors = [NSArray arrayWithObjects:transparent, opaque, opaque, transparent, nil];
    }
    return _gradientColors;
}
    
- (NSArray *)allSubLabels {
    return [self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag >= %i", 700]];
}
    
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
    
    @end


@implementation UIView (MarqueeLabelHelpers)
    // Thanks to Phil M
    // http://stackoverflow.com/questions/1340434/get-to-uiviewcontroller-from-uiview-on-iphone
    
- (id)firstAvailableViewController {
    // convenience function for casting and to "mask" the recursive function
    return [self traverseResponderChainForFirstViewController];
}
    
- (id)traverseResponderChainForFirstViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    }
    else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForFirstViewController];
    }
    else {
        return nil;
    }
}
    
    @end


#import <UIKit/UIKit.h>

// the time required to launch the phone app and come back (will be substracted to the duration)
#define kCallSetupTime      3.0

@interface ACETelPrompt ()
    @property (nonatomic, strong) NSDate *callStartTime;
    
    @property (nonatomic, copy) ACETelCallBlock callBlock;
    @property (nonatomic, copy) ACETelCancelBlock cancelBlock;
    @end

@implementation ACETelPrompt
    
+ (instancetype)sharedInstance
    {
        static ACETelPrompt *_instance = nil;
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _instance = [[self alloc] init];
        });
        return _instance;
    }
    
+ (BOOL)callPhoneNumber:(NSString *)phoneNumber
                   call:(ACETelCallBlock)callBlock
                 cancel:(ACETelCancelBlock)cancelBlock
    {
        if ([self validPhone:phoneNumber]) {
            
            ACETelPrompt *telPrompt = [ACETelPrompt sharedInstance];
            
            // observe the app notifications
            [telPrompt setNotifications];
            
            // set the blocks
            telPrompt.callBlock = callBlock;
            telPrompt.cancelBlock = cancelBlock;
            
            // clean the phone number
            NSString *simplePhoneNumber =
            [[phoneNumber componentsSeparatedByCharactersInSet:
              [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
            
            // call the phone number using the telprompt scheme
            NSString *stringURL = [@"telprompt://" stringByAppendingString:simplePhoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
            
            return YES;
        }
        return NO;
    }
    
+ (BOOL)validPhone:(NSString*) phoneString
    {
        if (phoneString == nil) {
            return false;
        }
        
        NSTextCheckingType type = [[NSTextCheckingResult phoneNumberCheckingResultWithRange:NSMakeRange(0, phoneString.length)
                                                                                phoneNumber:phoneString] resultType];
        return type == NSTextCheckingTypePhoneNumber;
    }
    
- (void)setNotifications
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
    }
    
- (void)applicationDidEnterBackground:(NSNotification *)notification
    {
        // save the time of the call
        self.callStartTime = [NSDate date];
    }
    
- (void)applicationDidBecomeActive:(NSNotification *)notification
    {
        // now it's time to remove the observers
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        if (self.callStartTime != nil) {
            
            // I'm coming back after a call
            if (self.callBlock != nil) {
                self.callBlock(-([self.callStartTime timeIntervalSinceNow]) - kCallSetupTime);
            }
            
            // reset the start timer
            self.callStartTime = nil;
            
        } else if (self.cancelBlock != nil) {
            
            // user didn't start the call
            self.cancelBlock();
        }
    }
    
    @end


#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>


// The basic idea is simple: we add a long press gesture to the tableView, once the gesture is activeated,
// a placeholder view is created for the pressed cell, then we move the placeholder view as the touch goes on.
@interface LPRTableViewProxy : NSObject <LPRTableViewDelegate>
    
    @property (nonatomic, readonly) UITableView *tableView;
    @property (nonatomic, assign) CGFloat draggingViewOpacity;
    @property (nonatomic, assign) BOOL canReorder;
    @property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
    @property (nonatomic, strong) CADisplayLink *scrollDisplayLink;
    @property (nonatomic, assign) CGFloat scrollRate;
    @property (nonatomic, strong) NSIndexPath *currentLocationIndexPath;
    @property (nonatomic, strong) NSIndexPath *initialIndexPath;
    @property (nonatomic, strong) UIView *draggingView;
    
    @end


@implementation LPRTableViewProxy
    
- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        _tableView = tableView;
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [_tableView addGestureRecognizer:_longPress];
        
        _canReorder = YES;
        _draggingViewOpacity = 0.85;
        _longPress.enabled = _canReorder;
    }
    
    return self;
}
    
- (void)setCanReorder:(BOOL)canReorder {
    _canReorder = canReorder;
    _longPress.enabled = _canReorder;
}
    
- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    
    CGPoint location = [gesture locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:location];
    
    int sections = [_tableView numberOfSections];
    int rows = 0;
    for(int i = 0; i < sections; i++) {
        rows += [_tableView numberOfRowsInSection:i];
    }
    
    // get out of here if the long press was not on a valid row or our table is empty
    // or the dataSource tableView:canMoveRowAtIndexPath: doesn't allow moving the row
    if (rows == 0 || (gesture.state == UIGestureRecognizerStateBegan && indexPath == nil) ||
        (gesture.state == UIGestureRecognizerStateEnded && self.currentLocationIndexPath == nil) ||
        (gesture.state == UIGestureRecognizerStateBegan &&
         [_tableView.dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)] &&
         indexPath && ![_tableView.dataSource tableView:_tableView canMoveRowAtIndexPath:indexPath])) {
            [self cancelGesture];
            return;
        }
    
    // started
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO animated:NO];
        [cell setHighlighted:NO animated:NO];
        
        // create view that we will drag around the screen
        if (!_draggingView) {
            if ([(id)_tableView.lprDelegate respondsToSelector:@selector(tableView:draggingViewForCellAtIndexPath:)]) {
                _draggingView = [_tableView.lprDelegate tableView:_tableView draggingViewForCellAtIndexPath:indexPath];
            } else {
                // make an image from the pressed tableview cell
                UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0);
                [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                _draggingView = [[UIImageView alloc] initWithImage:cellImage];
            }
            
            [_tableView addSubview:_draggingView];
            CGRect rect = [_tableView rectForRowAtIndexPath:indexPath];
            _draggingView.frame = CGRectOffset(_draggingView.bounds, rect.origin.x, rect.origin.y);
            
            // add a show animation
            [UIView beginAnimations:@"show" context:nil];
            if ([(id)_tableView.lprDelegate respondsToSelector:@selector(tableView:showDraggingView:atIndexPath:)]) {
                [_tableView.lprDelegate tableView:_tableView showDraggingView:_draggingView atIndexPath:indexPath];
            } else {
                // add drop shadow to image and lower opacity
                _draggingView.layer.masksToBounds = NO;
                _draggingView.layer.shadowColor = [[UIColor blackColor] CGColor];
                _draggingView.layer.shadowOffset = CGSizeMake(0, 0);
                _draggingView.layer.shadowRadius = 2.0;
                _draggingView.layer.shadowOpacity = 0.5;
                _draggingView.layer.opacity = self.draggingViewOpacity;
                
                _draggingView.transform = CGAffineTransformMakeScale(1, 1);
                _draggingView.center = CGPointMake(_tableView.center.x, location.y);
            }
            [UIView commitAnimations];
        }
        
        cell.hidden = YES;
        
        self.currentLocationIndexPath = indexPath;
        self.initialIndexPath = indexPath;
        
        // enable scrolling for cell
        self.scrollDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollTableWithCell:)];
        [self.scrollDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    // dragging
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        // update position of the drag view
        // don't let it go past the top or the bottom too far
        if (location.y >= 0 && location.y <= _tableView.contentSize.height + 50) {
            _draggingView.center = CGPointMake(_tableView.center.x, location.y);
        }
        
        CGRect rect = _tableView.bounds;
        // adjust rect for content inset as we will use it below for calculating scroll zones
        rect.size.height -= _tableView.contentInset.top;
        CGPoint location = [gesture locationInView:_tableView];
        
        [self updateCurrentLocation:gesture];
        
        // tell us if we should scroll and which direction
        CGFloat scrollZoneHeight = rect.size.height / 6;
        CGFloat bottomScrollBeginning = _tableView.contentOffset.y + _tableView.contentInset.top + rect.size.height - scrollZoneHeight;
        CGFloat topScrollBeginning = _tableView.contentOffset.y + _tableView.contentInset.top  + scrollZoneHeight;
        // we're in the bottom zone
        if (location.y >= bottomScrollBeginning) {
            _scrollRate = (location.y - bottomScrollBeginning) / scrollZoneHeight;
        }
        // we're in the top zone
        else if (location.y <= topScrollBeginning) {
            _scrollRate = (location.y - topScrollBeginning) / scrollZoneHeight;
        }
        else {
            _scrollRate = 0;
        }
    }
    // dropped
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        NSIndexPath *indexPath = self.currentLocationIndexPath;
        
        // remove scrolling CADisplayLink
        [_scrollDisplayLink invalidate];
        _scrollDisplayLink = nil;
        _scrollRate = 0;
        
        // animate the drag view to the newly hovered cell
        [UIView animateWithDuration:0.3
                         animations:^{
                             if ([(id)_tableView.lprDelegate respondsToSelector:@selector(tableView:hideDraggingView:atIndexPath:)]) {
                                 [_tableView.lprDelegate tableView:_tableView hideDraggingView:_draggingView atIndexPath:indexPath];
                             } else {
                                 CGRect rect = [_tableView rectForRowAtIndexPath:indexPath];
                                 _draggingView.transform = CGAffineTransformIdentity;
                                 _draggingView.frame = CGRectOffset(_draggingView.bounds, rect.origin.x, rect.origin.y);
                             }
                         } completion:^(BOOL finished) {
                             [_tableView beginUpdates];
                             [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                             [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                             [_tableView endUpdates];
                             
                             [_draggingView removeFromSuperview];
                             
                             // reload the rows that were affected just to be safe
                             NSMutableArray *visibleRows = [[_tableView indexPathsForVisibleRows] mutableCopy];
                             [visibleRows removeObject:indexPath];
                             [_tableView reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];
                             
                             _currentLocationIndexPath = nil;
                             _draggingView = nil;
                         }];
    }
}
    
    
- (void)updateCurrentLocation:(UILongPressGestureRecognizer *)gesture {
    
    NSIndexPath *indexPath  = nil;
    CGPoint location = CGPointZero;
    
    // refresh index path
    location  = [gesture locationInView:_tableView];
    indexPath = [_tableView indexPathForRowAtPoint:location];
    
    if ([_tableView.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]) {
        indexPath = [_tableView.delegate tableView:_tableView targetIndexPathForMoveFromRowAtIndexPath:self.initialIndexPath toProposedIndexPath:indexPath];
    }
    
    NSInteger oldHeight = [_tableView rectForRowAtIndexPath:self.currentLocationIndexPath].size.height;
    NSInteger newHeight = [_tableView rectForRowAtIndexPath:indexPath].size.height;
    
    if (indexPath && ![indexPath isEqual:self.currentLocationIndexPath] && [gesture locationInView:[_tableView cellForRowAtIndexPath:indexPath]].y > newHeight - oldHeight) {
        [_tableView beginUpdates];
        [_tableView moveRowAtIndexPath:self.currentLocationIndexPath toIndexPath:indexPath];
        
        if ([(id)_tableView.dataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
            [_tableView.dataSource tableView:_tableView moveRowAtIndexPath:self.currentLocationIndexPath toIndexPath:indexPath];
        }
        else {
            NSLog(@"moveRowAtIndexPath:toIndexPath: is not implemented");
        }
        
        _currentLocationIndexPath = indexPath;
        [_tableView endUpdates];
    }
}
    
- (void)scrollTableWithCell:(NSTimer *)timer {
    UILongPressGestureRecognizer *gesture = _longPress;
    CGPoint location  = [gesture locationInView:_tableView];
    
    CGPoint currentOffset = _tableView.contentOffset;
    CGPoint newOffset = CGPointMake(currentOffset.x, currentOffset.y + self.scrollRate * 10);
    
    if (newOffset.y < -_tableView.contentInset.top) {
        newOffset.y = -_tableView.contentInset.top;
    } else if (_tableView.contentSize.height + _tableView.contentInset.bottom < _tableView.frame.size.height) {
        newOffset = currentOffset;
    } else if (newOffset.y > (_tableView.contentSize.height + _tableView.contentInset.bottom) - _tableView.frame.size.height) {
        newOffset.y = (_tableView.contentSize.height + _tableView.contentInset.bottom) - _tableView.frame.size.height;
    }
    
    [_tableView setContentOffset:newOffset];
    
    if (location.y >= 0 && location.y <= _tableView.contentSize.height + 50) {
        _draggingView.center = CGPointMake(_tableView.center.x, location.y);
    }
    
    [self updateCurrentLocation:gesture];
}
    
- (void)cancelGesture {
    _longPress.enabled = NO;
    _longPress.enabled = YES;
}
    
    @end


@implementation UITableView (LongPressReorder)
    
    static void *LPRDelegateKey = &LPRDelegateKey;
    
- (void)setLprDelegate:(id<LPRTableViewDelegate>)LPRDelegate {
    id delegate = objc_getAssociatedObject(self, LPRDelegateKey);
    if (delegate != LPRDelegate) {
        objc_setAssociatedObject(self, LPRDelegateKey, LPRDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
    
- (id <LPRTableViewDelegate>)lprDelegate {
    id delegate = objc_getAssociatedObject(self, LPRDelegateKey);
    return delegate;
}
    
    static void *LPRLongPressEnabledKey = &LPRLongPressEnabledKey;
    
- (void)setLongPressReorderEnabled:(BOOL)longPressReorderEnabled {
    BOOL isEnabled = [self isLongPressReorderEnabled];
    if (isEnabled != longPressReorderEnabled) {
        NSNumber *enabled = [NSNumber numberWithBool:longPressReorderEnabled];
        objc_setAssociatedObject(self, LPRLongPressEnabledKey, enabled, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self lprProxy].canReorder = longPressReorderEnabled;
    }
}
    
- (BOOL)isLongPressReorderEnabled {
    NSNumber *enabled = objc_getAssociatedObject(self, LPRLongPressEnabledKey);
    if (enabled == nil) {
        enabled = [NSNumber numberWithBool:NO];
        objc_setAssociatedObject(self, LPRLongPressEnabledKey, enabled, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [enabled boolValue];
}
    
    static void *LPRProxyKey = &LPRProxyKey;
    
- (LPRTableViewProxy *)lprProxy {
    LPRTableViewProxy *proxy = objc_getAssociatedObject(self, LPRProxyKey);
    if (proxy == nil) {
        proxy = [[LPRTableViewProxy alloc] initWithTableView:self];
        objc_setAssociatedObject(self, LPRProxyKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return proxy;
}
    
    @end

static int MLT_BADGE_TAG = 6546;

@implementation MLTBadgeView
    @synthesize placement, badgeValue, font, badgeColor, textColor, outlineColor, outlineWidth, minimumDiameter, displayWhenZero;
    
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.font = [UIFont boldSystemFontOfSize:13.0];
        self.badgeColor = [UIColor redColor];
        self.textColor = [UIColor whiteColor];
        self.outlineColor = [UIColor whiteColor];
        self.outlineWidth = 2.0;
        self.backgroundColor = [UIColor clearColor];
        self.minimumDiameter = 20.0;
        self.placement = kBadgePlacementUpperBest;
        self.opaque = YES;
    }
    return self;
}
    
- (void)setBadgeValue:(NSInteger)value {
    if (value != 0 || self.displayWhenZero) {
        CGSize numberSize = [[NSString stringWithFormat:@"%d", value] sizeWithFont:self.font];
        float diameterForNumber = numberSize.width > numberSize.height ? numberSize.width : numberSize.height;
        float diameter = diameterForNumber + 6 + (self.outlineWidth * 2);
        if (diameter < self.minimumDiameter) {
            diameter = self.minimumDiameter;
        }
        
        //We know the size of the badge circle. If no explicit placement for the badge has been set, we'll
        //see if it works on the right side first.
        CGRect superviewFrame = self.superview.frame;
        if (self.placement == kBadgePlacementUpperBest) {
            CGPoint rightMostInWindow = [self.superview convertPoint:CGPointMake(superviewFrame.origin.x + superviewFrame.size.width + (diameter / 2.0), -(diameter / 2.0)) fromView:nil];
            if (rightMostInWindow.x > [[UIScreen mainScreen] applicationFrame].size.width) {
                self.placement = kBadgePlacementUpperLeft;
            }
            else {
                self.placement = kBadgePlacementUpperRight;
            }
        }
        self.bounds = CGRectMake(0, 0, diameter, diameter);
        self.center = (self.placement == kBadgePlacementUpperLeft) ? CGPointMake(0, 0) : CGPointMake(superviewFrame.size.width, 0);
        if (self.placement == kBadgePlacementUpperLeft) {
            self.center =  CGPointMake(0, 0);
        }
        if (self.placement == kBadgePlacementUpperRight) {
            self.center =  CGPointMake(superviewFrame.size.width, 0);
        }
        if (self.placement == kBadgePlacementBottomRight) {
            self.center =  CGPointMake(superviewFrame.size.width - 10, superviewFrame.size.height - 10);
        }
    }
    else {
        self.frame = CGRectZero;
    }
    badgeValue = value;
    
    [self setNeedsDisplay];
}
    
- (void)setMinimumDiameter:(float)f {
    minimumDiameter = f;
    self.bounds = CGRectMake(0, 0, f, f);
}
    
- (void)drawRect:(CGRect)rect {
    if (self.badgeValue != 0 || self.displayWhenZero) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.outlineColor set];
        CGContextFillEllipseInRect(context, CGRectInset(rect, 1, 1));
        [self.badgeColor set];
        CGContextFillEllipseInRect(context, CGRectInset(rect, self.outlineWidth + 1, self.outlineWidth + 1));
        [self.textColor set];
        NSString * badgeText = @" ";
        if (self.badgeValue > 0) {
            badgeText = [NSString stringWithFormat:@"%ld", (long)self.badgeValue];
        }
        CGSize numberSize = [badgeText sizeWithFont:self.font];
        [badgeText drawInRect:CGRectMake(self.outlineWidth + 3, (rect.size.height / 2.0) - (numberSize.height / 2.0), rect.size.width - (self.outlineWidth * 2) - 6, numberSize.height) withFont:self.font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    }
}
    
    @end


@implementation UIView (Badged)
    
- (MLTBadgeView *)badge {
    UIView *existingView = [self viewWithTag:MLT_BADGE_TAG];
    if (existingView) {
        if (![existingView isKindOfClass:[MLTBadgeView class]]) {
            NSLog(@"Unexpected view of class %@ found with badge tag.");
            return nil;
        }
        else {
            return (MLTBadgeView *)existingView;
        }
    }
    MLTBadgeView *badgeView = [[MLTBadgeView alloc]initWithFrame:CGRectZero];
    badgeView.tag = MLT_BADGE_TAG;
    [self addSubview:badgeView];
    return badgeView;
}
    
    @end

static NSInteger const UIAlertControllerBlocksCancelButtonIndex = 0;
static NSInteger const UIAlertControllerBlocksDestructiveButtonIndex = 1;
static NSInteger const UIAlertControllerBlocksFirstOtherButtonIndex = 2;

@interface UIViewController (UACB_Topmost)
    
- (UIViewController *)uacb_topmost;
    
    @end

@implementation UIAlertController (Blocks)
    
+ (instancetype)showInViewController:(UIViewController *)viewController
                           withTitle:(NSString *)title
                             message:(NSString *)message
                      preferredStyle:(UIAlertControllerStyle)preferredStyle
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
                   otherButtonTitles:(NSArray *)otherButtonTitles
#if TARGET_OS_IOS
  popoverPresentationControllerBlock:(void(^)(UIPopoverPresentationController *popover))popoverPresentationControllerBlock
#endif
                            tapBlock:(UIAlertControllerCompletionBlock)tapBlock
    {
        UIAlertController *strongController = [self alertControllerWithTitle:title
                                                                     message:message
                                                              preferredStyle:preferredStyle];
        
        __weak UIAlertController *controller = strongController;
        
        if (cancelButtonTitle) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action){
                                                                     if (tapBlock) {
                                                                         tapBlock(controller, action, UIAlertControllerBlocksCancelButtonIndex);
                                                                     }
                                                                 }];
            [controller addAction:cancelAction];
        }
        
        if (destructiveButtonTitle) {
            UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructiveButtonTitle
                                                                        style:UIAlertActionStyleDestructive
                                                                      handler:^(UIAlertAction *action){
                                                                          if (tapBlock) {
                                                                              tapBlock(controller, action, UIAlertControllerBlocksDestructiveButtonIndex);
                                                                          }
                                                                      }];
            [controller addAction:destructiveAction];
        }
        
        for (NSUInteger i = 0; i < otherButtonTitles.count; i++) {
            NSString *otherButtonTitle = otherButtonTitles[i];
            
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action){
                                                                    if (tapBlock) {
                                                                        tapBlock(controller, action, UIAlertControllerBlocksFirstOtherButtonIndex + i);
                                                                    }
                                                                }];
            [controller addAction:otherAction];
        }
        
#if TARGET_OS_IOS
        if (popoverPresentationControllerBlock) {
            popoverPresentationControllerBlock(controller.popoverPresentationController);
        }
#endif
        
        [viewController.uacb_topmost presentViewController:controller animated:YES completion:nil];
        
        return controller;
    }
    
+ (instancetype)showAlertInViewController:(UIViewController *)viewController
                                withTitle:(NSString *)title
                                  message:(NSString *)message
                        cancelButtonTitle:(NSString *)cancelButtonTitle
                   destructiveButtonTitle:(NSString *)destructiveButtonTitle
                        otherButtonTitles:(NSArray *)otherButtonTitles
                                 tapBlock:(UIAlertControllerCompletionBlock)tapBlock
    {
        return [self showInViewController:viewController
                                withTitle:title
                                  message:message
                           preferredStyle:UIAlertControllerStyleAlert
                        cancelButtonTitle:cancelButtonTitle
                   destructiveButtonTitle:destructiveButtonTitle
                        otherButtonTitles:otherButtonTitles
#if TARGET_OS_IOS
       popoverPresentationControllerBlock:nil
#endif
                                 tapBlock:tapBlock];
    }
    
+ (instancetype)showActionSheetInViewController:(UIViewController *)viewController
                                      withTitle:(NSString *)title
                                        message:(NSString *)message
                              cancelButtonTitle:(NSString *)cancelButtonTitle
                         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                              otherButtonTitles:(NSArray *)otherButtonTitles
#if TARGET_OS_IOS
             popoverPresentationControllerBlock:(void(^)(UIPopoverPresentationController *popover))popoverPresentationControllerBlock
#endif
                                       tapBlock:(UIAlertControllerCompletionBlock)tapBlock
    {
        return [self showInViewController:viewController
                                withTitle:title
                                  message:message
                           preferredStyle:UIAlertControllerStyleActionSheet
                        cancelButtonTitle:cancelButtonTitle
                   destructiveButtonTitle:destructiveButtonTitle
                        otherButtonTitles:otherButtonTitles
#if TARGET_OS_IOS
       popoverPresentationControllerBlock:popoverPresentationControllerBlock
#endif
                                 tapBlock:tapBlock];
    }
    
#pragma mark -
    
- (BOOL)visible
    {
        return self.view.superview != nil;
    }
    
- (NSInteger)cancelButtonIndex
    {
        return UIAlertControllerBlocksCancelButtonIndex;
    }
    
- (NSInteger)firstOtherButtonIndex
    {
        return UIAlertControllerBlocksFirstOtherButtonIndex;
    }
    
- (NSInteger)destructiveButtonIndex
    {
        return UIAlertControllerBlocksDestructiveButtonIndex;
    }
    
    @end

@implementation UIViewController (UACB_Topmost)
    
- (UIViewController *)uacb_topmost
    {
        UIViewController *topmost = self;
        
        UIViewController *above;
        while ((above = topmost.presentedViewController)) {
            topmost = above;
        }
        
        return topmost;
    }
    
    @end

@implementation UIImage (Alpha)
    
    // Returns true if the image has an alpha layer
- (BOOL)hasAlpha {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}
    
    // Returns a copy of the given image, adding an alpha channel if it doesn't already have one
- (UIImage *)imageWithAlpha {
    if ([self hasAlpha]) {
        return self;
    }
    
    CGFloat scale = MAX(self.scale, 1.0f);
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef)*scale;
    size_t height = CGImageGetHeight(imageRef)*scale;
    
    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha scale:self.scale orientation:UIImageOrientationUp];
    
    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}
    
    // Returns a copy of the image with a transparent border of the given size added around its edges.
    // If the image has no alpha layer, one will be added to it.
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    CGFloat scale = MAX(self.scale, 1.0f);
    NSUInteger scaledBorderSize = borderSize * scale;
    CGRect newRect = CGRectMake(0, 0, image.size.width * scale + scaledBorderSize * 2, image.size.height * scale + scaledBorderSize * 2);
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(self.CGImage),
                                                0,
                                                CGImageGetColorSpace(self.CGImage),
                                                CGImageGetBitmapInfo(self.CGImage));
    
    // Draw the image in the center of the context, leaving a gap around the edges
    CGRect imageLocation = CGRectMake(scaledBorderSize, scaledBorderSize, image.size.width*scale, image.size.height*scale);
    CGContextDrawImage(bitmap, imageLocation, self.CGImage);
    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
    
    // Create a mask to make the border transparent, and combine it with the image
    CGImageRef maskImageRef = [self newBorderMask:scaledBorderSize size:newRect.size];
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef scale:self.scale orientation:UIImageOrientationUp];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(borderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    
    return transparentBorderImage;
}
    
    // Creates a mask that makes the outer edges transparent and everything else opaque
    // The size must include the entire mask (opaque part + transparent border)
    // The caller is responsible for releasing the returned reference by calling CGImageRelease
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Build a context that's the same dimensions as the new size
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
                                                     size.width,
                                                     size.height,
                                                     8, // 8-bit grayscale
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    
    // Start with a mask that's entirely transparent
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
    
    // Make the inner part (within the border) opaque
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));
    
    // Get an image of the context
    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);
    
    // Clean up
    CGContextRelease(maskContext);
    CGColorSpaceRelease(colorSpace);
    
    return maskImageRef;
}
    
- (UIImage *)tranlucentWithAlpha:(CGFloat)alpha{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
    
    @end


@implementation UIImage (Resize)
    
    // Returns a copy of this image that is cropped to the given bounds.
    // The bounds will be adjusted using CGRectIntegral.
    // This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    CGFloat scale = MAX(self.scale, 1.0f);
    CGRect scaledBounds = CGRectMake(bounds.origin.x * scale, bounds.origin.y * scale, bounds.size.width * scale, bounds.size.height * scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], scaledBounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    return croppedImage;
}
    
    // Returns a copy of the current image cropped into a circle using
    // a supplied diameter and top left anchorpoint for the crop.
- (UIImage *)circlularCroppedImageWithDiameter:(NSInteger)diameter
                                atTopLeftPoint:(CGPoint)cropPoint
                             transparentBorder:(NSUInteger)borderSize {
    UIImage *croppedImage = [self croppedImage:CGRectMake(cropPoint.x,
                                                          cropPoint.y,
                                                          diameter,
                                                          diameter)];
    UIImage *transparentBorderImage = borderSize ? [croppedImage transparentBorderImage:borderSize] : croppedImage;
    return [transparentBorderImage roundedCornerImage:diameter/2 borderSize:borderSize];
}
    
    // Returns a new UI Image cropped within the given rectangle.
    // The imageOrientation is accounted for by applying a transform
    // to the rect prior to renderings.
-(UIImage *)croppedImageRespectingImageOrientation:(CGRect)rect {
    
    CGAffineTransform rectTransform;
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -self.size.height);
        break;
        case UIImageOrientationRight:
        rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -self.size.width, 0);
        break;
        case UIImageOrientationDown:
        rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI), -self.size.width, -self.size.height);
        break;
        default:
        rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectApplyAffineTransform(rect, rectTransform));
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}
    
    // Similar to the standard crop method but in this case the properties of the
    // supplied CGRect are intended to be percentages rather than the absolute
    // values for the rect. A new CGRect is calculated by applying the supplied
    // rect's percentages to the image's own dimensions prior to executing the crop.
-(UIImage *)croppedImageViaPercentages:(CGRect)rect {
    CGRect cropRect = CGRectMake(self.size.width*rect.origin.x,
                                 self.size.height*rect.origin.y,
                                 self.size.width*rect.size.width,
                                 self.size.height*rect.size.height);
    return [self croppedImageRespectingImageOrientation:cropRect];
}
    
    // Returns a copy of this image that is squared to the thumbnail size.
    // If transparentBorder is non-zero, a transparent border of the given size will be added around the edges of the thumbnail. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality {
    
    UIImage *resizedImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                       bounds:CGSizeMake(thumbnailSize, thumbnailSize)
                                         interpolationQuality:quality];
    
    
    // Crop out any part of the image that's larger than the thumbnail size
    // The cropped rect must be centered on the resized image
    // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
    CGRect cropRect = CGRectMake(round((resizedImage.size.width - thumbnailSize) / 2),
                                 round((resizedImage.size.height - thumbnailSize) / 2),
                                 thumbnailSize,
                                 thumbnailSize);
    UIImage *croppedImage = [resizedImage croppedImage:cropRect];
    
    UIImage *transparentBorderImage = borderSize ? [croppedImage transparentBorderImage:borderSize] : croppedImage;
    
    return [transparentBorderImage roundedCornerImage:cornerRadius borderSize:borderSize];
}
    
-(UIImage*)resizedImageWithMaxEdge:(float)maxEdge {
    float aspectRatio = self.size.width/self.size.height;
    CGSize size;
    
    if (aspectRatio >= 1 && self.size.width > maxEdge) {
        size = CGSizeMake(maxEdge, maxEdge * (1/aspectRatio));
    } else if (aspectRatio < 1 && self.size.height > maxEdge) {
        size = CGSizeMake(maxEdge * aspectRatio, maxEdge);
    } else {
        return [self copy];
    }
    
    return [self resizedImage:size interpolationQuality:kCGInterpolationHigh];
}
    
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    switch ( self.imageOrientation )
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        drawTransposed = YES;
        break;
        default:
        drawTransposed = NO;
    }
    
    CGAffineTransform transform = [self transformForOrientation:newSize];
    
    return [self resizedImage:newSize transform:transform drawTransposed:drawTransposed interpolationQuality:quality];
}
    
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
        ratio = MAX(horizontalRatio, verticalRatio);
        break;
        
        case UIViewContentModeScaleAspectFit:
        ratio = MIN(horizontalRatio, verticalRatio);
        break;
        
        default:
        [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", (int)contentMode];
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    return [self resizedImage:newSize interpolationQuality:quality];
}
    
    // Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
    // The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
    // If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat scale = MAX(1.0f, self.scale);
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width*scale, newSize.height*scale));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Fix for a colorspace / transparency issue that affects some types of
    // images. See here: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/comment-page-2/#comment-39951
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                8, /* bits per channel */
                                                (newRect.size.width * 4), /* 4 channels per pixel * numPixels/row */
                                                colorSpace,
                                                kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast
                                                );
    CGColorSpaceRelease(colorSpace);
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:UIImageOrientationUp];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}
    
    // Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
        transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        break;
        
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        transform = CGAffineTransformTranslate(transform, newSize.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        break;
        
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
        transform = CGAffineTransformTranslate(transform, 0, newSize.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        break;
        default:
        break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
        transform = CGAffineTransformTranslate(transform, newSize.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
        
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
        transform = CGAffineTransformTranslate(transform, newSize.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
        default:
        break;
    }
    
    return transform;
}
    
    @end


@implementation UIImage (RoundedCorner)
    
    // Creates a copy of this image with rounded corners
    // If borderSize is non-zero, a transparent border of the given size will also be added
    // Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
    CGFloat scale = MAX(self.scale,1.0f);
    NSUInteger scaledBorderSize = borderSize * scale;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 image.size.width*scale,
                                                 image.size.height*scale,
                                                 CGImageGetBitsPerComponent(image.CGImage),
                                                 0,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 CGImageGetBitmapInfo(image.CGImage));
    
    // Create a clipping path with rounded corners
    
    CGContextBeginPath(context);
    [self addRoundedRectToPath:CGRectMake(scaledBorderSize, scaledBorderSize, image.size.width*scale - borderSize * 2, image.size.height*scale - borderSize * 2)
                       context:context
                     ovalWidth:cornerSize*scale
                    ovalHeight:cornerSize*scale];
    CGContextClosePath(context);
    CGContextClip(context);
    
    // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width*scale, image.size.height*scale), image.CGImage);
    
    // Create a CGImage from the context
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    // Create a UIImage from the CGImage
    UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage scale:self.scale orientation:UIImageOrientationUp];
    
    CGImageRelease(clippedImage);
    
    return roundedImage;
}
    
    // Adds a rectangular path to the given context and rounds its corners by the given extents
    // Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight {
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    CGFloat fw = CGRectGetWidth(rect) / ovalWidth;
    CGFloat fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}
    
    @end


@implementation UIView (AnimationExtensions)
    
    
- (void)shakeHorizontally
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.duration = 0.5;
        animation.values = @[@(-12), @(12), @(-8), @(8), @(-4), @(4), @(0) ];
        
        [self.layer addAnimation:animation forKey:@"shake"];
    }
    
    
- (void)shakeVertically
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.duration = 0.5;
        animation.values = @[@(-12), @(12), @(-8), @(8), @(-4), @(4), @(0) ];
        
        [self.layer addAnimation:animation forKey:@"shake"];
    }
    
    
- (void)applyMotionEffects
    {
        // Motion effects are available starting from iOS 7.
        if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending))
        {
            
            UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                            type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            horizontalEffect.minimumRelativeValue = @(-10.0f);
            horizontalEffect.maximumRelativeValue = @( 10.0f);
            UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                          type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            verticalEffect.minimumRelativeValue = @(-10.0f);
            verticalEffect.maximumRelativeValue = @( 10.0f);
            UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
            motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];
            
            [self addMotionEffect:motionEffectGroup];
        }
    }
    
    
- (void)pulseToSize:(CGFloat)scale
           duration:(NSTimeInterval)duration
             repeat:(BOOL)repeat
    {
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        pulseAnimation.duration = duration;
        pulseAnimation.toValue = [NSNumber numberWithFloat:scale];
        pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pulseAnimation.autoreverses = YES;
        pulseAnimation.repeatCount = repeat ? HUGE_VALF : 0;
        
        [self.layer addAnimation:pulseAnimation
                          forKey:@"pulse"];
    }
    
    
- (void)flipWithDuration:(NSTimeInterval)duration
               direction:(UIViewAnimationFlipDirection)direction
             repeatCount:(NSUInteger)repeatCount
             autoreverse:(BOOL)shouldAutoreverse
    {
        NSString *subtype = nil;
        
        switch (direction)
        {
            case UIViewAnimationFlipDirectionFromTop:
            subtype = @"fromTop";
            break;
            case UIViewAnimationFlipDirectionFromLeft:
            subtype = @"fromLeft";
            break;
            case UIViewAnimationFlipDirectionFromBottom:
            subtype = @"fromBottom";
            break;
            case UIViewAnimationFlipDirectionFromRight:
            default:
            subtype = @"fromRight";
            break;
        }
        
        CATransition *transition = [CATransition animation];
        
        transition.startProgress = 0;
        transition.endProgress = 1.0;
        transition.type = @"flip";
        transition.subtype = subtype;
        transition.duration = duration;
        transition.repeatCount = repeatCount;
        transition.autoreverses = shouldAutoreverse;
        
        [self.layer addAnimation:transition
                          forKey:@"spin"];
    }
    
    
- (void)rotateToAngle:(CGFloat)angle
             duration:(NSTimeInterval)duration
            direction:(UIViewAnimationRotationDirection)direction
          repeatCount:(NSUInteger)repeatCount
          autoreverse:(BOOL)shouldAutoreverse;
    {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        
        rotationAnimation.toValue = @(direction == UIViewAnimationRotationDirectionRight ? angle : -angle);
        rotationAnimation.duration = duration;
        rotationAnimation.autoreverses = shouldAutoreverse;
        rotationAnimation.repeatCount = repeatCount;
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.layer addAnimation:rotationAnimation
                          forKey:@"transform.rotation.z"];
    }
    
    
- (void)stopAnimation
    {
        [CATransaction begin];
        [self.layer removeAllAnimations];
        [CATransaction commit];
        
        [CATransaction flush];
    }
    
    
- (BOOL)isBeingAnimated
    {
        return [self.layer.animationKeys count];
    }
    
    
    @end

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kCutoutRadius = 2.0f;
static const CGFloat kMaxLblWidth = 230.0f;
static const CGFloat kLblSpacing = 35.0f;
static const BOOL kEnableContinueLabel = YES;

@implementation WSCoachMarksView {
    CAShapeLayer *mask;
    NSUInteger markIndex;
    UILabel *lblContinue;
}
    
    @synthesize delegate;
    @synthesize coachMarks;
    @synthesize lblCaption;
    @synthesize maskColor = _maskColor;
    @synthesize animationDuration;
    @synthesize cutoutRadius;
    @synthesize maxLblWidth;
    @synthesize lblSpacing;
    @synthesize enableContinueLabel;
    
- (id)initWithFrame:(CGRect)frame coachMarks:(NSArray *)marks {
    self = [super initWithFrame:frame];
    if (self) {
        // Save the coach marks
        self.coachMarks = marks;
        
        // Setup
        [self setup];
    }
    return self;
}
    
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}
    
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}
    
- (void)setup {
    // Default
    self.animationDuration = kAnimationDuration;
    self.cutoutRadius = kCutoutRadius;
    self.maxLblWidth = kMaxLblWidth;
    self.lblSpacing = kLblSpacing;
    self.enableContinueLabel = kEnableContinueLabel;
    
    // Shape layer mask
    mask = [CAShapeLayer layer];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.9f] CGColor]];
    [self.layer addSublayer:mask];
    
    // Capture touches
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    // Captions
    self.lblCaption = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}}];
    self.lblCaption.backgroundColor = [UIColor clearColor];
    self.lblCaption.textColor = [UIColor whiteColor];
    self.lblCaption.font = [UIFont systemFontOfSize:20.0f];
    self.lblCaption.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblCaption.numberOfLines = 0;
    self.lblCaption.textAlignment = NSTextAlignmentCenter;
    self.lblCaption.alpha = 0.0f;
    [self addSubview:self.lblCaption];
    
    // Hide until unvoked
    self.hidden = YES;
}
    
- (void)setCutoutToRect:(CGRect)rect {
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    [maskPath appendPath:cutoutPath];
    
    // Set the new path
    mask.path = maskPath.CGPath;
}
    
- (void)animateCutoutToRect:(CGRect)rect {
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    [maskPath appendPath:cutoutPath];
    
    // Animate it
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = self.animationDuration;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = (__bridge id)(mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [mask addAnimation:anim forKey:@"path"];
    mask.path = maskPath.CGPath;
}
    
- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    [mask setFillColor:[maskColor CGColor]];
}
    
- (void)userDidTap:(UITapGestureRecognizer *)recognizer {
    // Go to the next coach mark
    [self goToCoachMarkIndexed:(markIndex+1)];
}
    
- (void)start {
    // Fade in self
    self.alpha = 0.0f;
    self.hidden = NO;
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         // Go to the first coach mark
                         [self goToCoachMarkIndexed:0];
                     }];
}
    
- (void)goToCoachMarkIndexed:(NSInteger)index {
    // Out of bounds
    if (index >= self.coachMarks.count) {
        [self cleanup];
        return;
    }
    
    // Current index
    markIndex = index;
    
    // Coach mark definition
    NSDictionary *markDef = [self.coachMarks objectAtIndex:index];
    NSString *markCaption = [markDef objectForKey:@"caption"];
    CGRect markRect = [[markDef objectForKey:@"rect"] CGRectValue];
    
    // Delegate (coachMarksView:willNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndex:)]) {
        [self.delegate coachMarksView:self willNavigateToIndex:markIndex];
    }
    
    // Calculate the caption position and size
    self.lblCaption.alpha = 0.0f;
    self.lblCaption.frame = (CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}};
    self.lblCaption.text = markCaption;
    [self.lblCaption sizeToFit];
    CGFloat y = markRect.origin.y + markRect.size.height + self.lblSpacing;
    CGFloat bottomY = y + self.lblCaption.frame.size.height + self.lblSpacing;
    if (bottomY > self.bounds.size.height) {
        y = markRect.origin.y - self.lblSpacing - self.lblCaption.frame.size.height;
    }
    CGFloat x = floorf((self.bounds.size.width - self.lblCaption.frame.size.width) / 2.0f);
    
    // Animate the caption label
    self.lblCaption.frame = (CGRect){{x, y}, self.lblCaption.frame.size};
    [UIView animateWithDuration:0.3f animations:^{
        self.lblCaption.alpha = 1.0f;
    }];
    
    // If first mark, set the cutout to the center of first mark
    if (markIndex == 0) {
        CGPoint center = CGPointMake(floorf(markRect.origin.x + (markRect.size.width / 2.0f)), floorf(markRect.origin.y + (markRect.size.height / 2.0f)));
        CGRect centerZero = (CGRect){center, CGSizeZero};
        [self setCutoutToRect:centerZero];
    }
    
    // Animate the cutout
    [self animateCutoutToRect:markRect];
    
    // Show continue lbl if first mark
    if (self.enableContinueLabel) {
        if (markIndex == 0) {
            lblContinue = [[UILabel alloc] initWithFrame:(CGRect){{0, self.bounds.size.height - 30.0f}, {self.bounds.size.width, 30.0f}}];
            lblContinue.font = [UIFont boldSystemFontOfSize:13.0f];
            lblContinue.textAlignment = NSTextAlignmentCenter;
            lblContinue.text = @"Tap to continue";
            lblContinue.alpha = 0.0f;
            [self addSubview:lblContinue];
            [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
                lblContinue.alpha = 1.0f;
            } completion:nil];
        } else if (markIndex > 0 && lblContinue != nil) {
            // Otherwise, remove the lbl
            [lblContinue removeFromSuperview];
            lblContinue = nil;
        }
    }
}
    
- (void)cleanup {
    // Delegate (coachMarksViewWillCleanup:)
    if ([self.delegate respondsToSelector:@selector(coachMarksViewWillCleanup:)]) {
        [self.delegate coachMarksViewWillCleanup:self];
    }
    
    // Fade out self
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // Remove self
                         [self removeFromSuperview];
                         
                         // Delegate (coachMarksViewDidCleanup:)
                         if ([self.delegate respondsToSelector:@selector(coachMarksViewDidCleanup:)]) {
                             [self.delegate coachMarksViewDidCleanup:self];
                         }
                     }];
}
    
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // Delegate (coachMarksView:didNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:didNavigateToIndex:)]) {
        [self.delegate coachMarksView:self didNavigateToIndex:markIndex];
    }
}
    
    @end

@implementation UIView (ZKPulseView)
    
-(void)stopPulseEffect{
    [self.layer removeAnimationForKey:@"ZKPulse"];
    self.layer.shadowOpacity = 0.0;
}
    
-(void)startPulse{
    //Start to pulse use the default reversed color
    [self startPulseWithColor:[self reversedColor]];
}
    
-(void)startPulseWithColor:(UIColor *)color{
    //Shadow radius can enable to pulse part to just be the view itself, if you dont like to have dropdown effect
    //You can set value for this key.
    self.layer.shadowRadius = 14;
    [self startPulseWithColor:color offset:CGSizeMake(0.0, 0.0) frequency:2];
}
    
-(void) startPulseWithColor:(UIColor *)color offset:(CGSize)offset frequency:(CGFloat)freq{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowOpacity = 0.9;
    self.layer.masksToBounds = NO;
    
    //Animation part
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    anim.fromValue = @(0.9);
    anim.toValue = @(0.2);
    anim.duration = freq;
    anim.autoreverses = YES;
    anim.repeatCount = INT32_MAX;
    
    [self.layer addAnimation:anim forKey:@"ZKPulse"];
}
    
    /*
     * Private method to generate reversed color from this view's background color
     *
     */
-(UIColor *) reversedColor{
    const CGFloat *componentColors = CGColorGetComponents(self.backgroundColor.CGColor);
    UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                               green:(1.0 - componentColors[1])
                                                blue:(1.0 - componentColors[2])
                                               alpha:componentColors[3]];
    return newColor;
}
    
    
    @end


@interface KTCenterFlowLayout ()
    @property (nonatomic) NSMutableDictionary *attrCache;
    @end

@implementation KTCenterFlowLayout
    
- (void)prepareLayout
    {
        // Clear the attrCache
        self.attrCache = [NSMutableDictionary new];
    }
    
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
    {
        NSMutableArray *updatedAttributes = [NSMutableArray new];
        
        NSInteger sections = [self.collectionView numberOfSections];
        NSInteger s = 0;
        while (s < sections)
        {
            NSInteger rows = [self.collectionView numberOfItemsInSection:s];
            NSInteger r = 0;
            while (r < rows)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:s];
                
                UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
                
                if (attrs && CGRectIntersectsRect(attrs.frame, rect))
                {
                    [updatedAttributes addObject:attrs];
                }
                
                UICollectionViewLayoutAttributes *headerAttrs =  [super layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                       atIndexPath:indexPath];
                
                if (headerAttrs && CGRectIntersectsRect(headerAttrs.frame, rect))
                {
                    [updatedAttributes addObject:headerAttrs];
                }
                
                UICollectionViewLayoutAttributes *footerAttrs =  [super layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                                       atIndexPath:indexPath];
                
                if (footerAttrs && CGRectIntersectsRect(footerAttrs.frame, rect))
                {
                    [updatedAttributes addObject:footerAttrs];
                }
                
                r++;
            }
            s++;
        }
        
        return updatedAttributes;
    }
    
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
    {
        if (self.attrCache[indexPath])
        {
            return self.attrCache[indexPath];
        }
        
        // Find the other items in the same "row"
        NSMutableArray *rowBuddies = [NSMutableArray new];
        
        // Calculate the available width to center stuff within
        // sectionInset is NOT applicable here because a) we're centering stuff
        // and b) Flow layout has arranged the cells to respect the inset. We're
        // just hijacking the X position.
        CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds) -
        self.collectionView.contentInset.left -
        self.collectionView.contentInset.right;
        
        // To find other items in the "row", we need a rect to check intersects against.
        // Take the item attributes frame (from vanilla flow layout), and stretch it out
        CGRect rowTestFrame = [super layoutAttributesForItemAtIndexPath:indexPath].frame;
        rowTestFrame.origin.x = 0;
        rowTestFrame.size.width = collectionViewWidth;
        
        NSInteger totalRows = [self.collectionView numberOfItemsInSection:indexPath.section];
        
        // From this item, work backwards to find the first item in the row
        // Decrement the row index until a) we get to 0, b) we reach a previous row
        NSInteger rowStartIDX = indexPath.row;
        while (true)
        {
            NSInteger prevIDX = rowStartIDX - 1;
            
            if (prevIDX < 0)
            {
                break;
            }
            
            NSIndexPath *prevPath = [NSIndexPath indexPathForRow:prevIDX inSection:indexPath.section];
            CGRect prevFrame = [super layoutAttributesForItemAtIndexPath:prevPath].frame;
            
            // If the item intersects the test frame, it's in the same row
            if (CGRectIntersectsRect(prevFrame, rowTestFrame))
            rowStartIDX = prevIDX;
            else
            // Found previous row, escape!
            break;
        }
        
        // Now, work back UP to find the last item in the row
        // For each item in the row, add it's attributes to rowBuddies
        NSInteger buddyIDX = rowStartIDX;
        while (true)
        {
            if (buddyIDX > (totalRows-1))
            {
                break;
            }
            
            NSIndexPath *buddyPath = [NSIndexPath indexPathForRow:buddyIDX inSection:indexPath.section];
            
            UICollectionViewLayoutAttributes *buddyAttributes = [super layoutAttributesForItemAtIndexPath:buddyPath];
            
            if (CGRectIntersectsRect(buddyAttributes.frame, rowTestFrame))
            {
                // If the item intersects the test frame, it's in the same row
                [rowBuddies addObject:[buddyAttributes copy]];
                buddyIDX++;
            }
            else
            {
                // Encountered next row
                break;
            }
        }
        
        id <UICollectionViewDelegateFlowLayout> flowDelegate = (id<UICollectionViewDelegateFlowLayout>) [[self collectionView] delegate];
        BOOL delegateSupportsInteritemSpacing = [flowDelegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)];
        
        // x-x-x-x ... sum up the interim space
        CGFloat interitemSpacing = [self minimumInteritemSpacing];
        
        // Check for minimumInteritemSpacingForSectionAtIndex support
        if (delegateSupportsInteritemSpacing && rowBuddies.count > 0)
        {
            interitemSpacing = [flowDelegate collectionView:self.collectionView
                                                     layout:self
                   minimumInteritemSpacingForSectionAtIndex:indexPath.section];
        }
        
        CGFloat aggregateInteritemSpacing = interitemSpacing * (rowBuddies.count -1);
        
        // Sum the width of all elements in the row
        CGFloat aggregateItemWidths = 0.f;
        for (UICollectionViewLayoutAttributes *itemAttributes in rowBuddies)
        aggregateItemWidths += CGRectGetWidth(itemAttributes.frame);
        
        // Build an alignment rect
        // |  |x-x-x-x|  |
        CGFloat alignmentWidth = aggregateItemWidths + aggregateInteritemSpacing;
        CGFloat alignmentXOffset = (collectionViewWidth - alignmentWidth) / 2.f;
        
        // Adjust each item's position to be centered
        CGRect previousFrame = CGRectZero;
        for (UICollectionViewLayoutAttributes *itemAttributes in rowBuddies)
        {
            CGRect itemFrame = itemAttributes.frame;
            
            if (CGRectEqualToRect(previousFrame, CGRectZero))
            itemFrame.origin.x = alignmentXOffset;
            else
            itemFrame.origin.x = CGRectGetMaxX(previousFrame) + interitemSpacing;
            
            itemAttributes.frame = itemFrame;
            previousFrame = itemFrame;
            
            // Finally, add it to the cache
            self.attrCache[itemAttributes.indexPath] = itemAttributes;
        }
        
        return self.attrCache[indexPath];
    }
    
    @end


@implementation NSObject (CJAAssociatedObject)
    
- (id)associatedValueForKey:(void *)key {
    
    return objc_getAssociatedObject(self, key);
}
    
- (void)setAssociatedValue:(id)value forKey:(void *)key {
    
    [self setAssociatedValue:value forKey:key policy: OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}
    
- (void)setAssociatedValue:(id)value forKey:(void *)key policy:(objc_AssociationPolicy)policy {
    
    objc_setAssociatedObject(self, key, value, policy);
}
    
- (void)removeAllAssociatedValues {
    
    objc_removeAssociatedObjects(self);
}
    
- (BOOL)associatedBoolValueForKey:(void *)key {
    
    NSNumber *value = [self associatedValueForKey: key];
    
    return value.boolValue;
}
- (void)setAssociatedBoolValue:(BOOL)value forKey:(void *)key {
    
    NSNumber *valueObject = [NSNumber numberWithBool: value];
    
    [self setAssociatedValue:valueObject forKey:key];
}
    
- (NSInteger)associatedIntegerValueForKey:(void *)key {
    
    NSNumber *value = [self associatedValueForKey: key];
    
    return value.integerValue;
}
    
- (void)setAssociatedIntegerValue:(NSInteger)value forKey:(void *)key {
    
    NSNumber *valueObject = [NSNumber numberWithInteger: value];
    
    [self setAssociatedValue:valueObject forKey:key];
}
    
- (float)associatedFloatValueForKey:(void *)key {
    
    NSNumber *value = [self associatedValueForKey: key];
    
    return value.floatValue;
}
    
- (void)setAssociatedFloatValue:(float)value forKey:(void *)key {
    
    NSNumber *valueObject = [NSNumber numberWithFloat: value];
    
    [self setAssociatedValue:valueObject forKey:key];
}
    
- (double)associatedDoubleValueForKey:(void *)key {
    
    NSNumber *value = [self associatedValueForKey: key];
    
    return value.doubleValue;
}
    
- (void)setAssociatedDoubleValue:(double)value forKey:(void *)key {
    
    NSNumber *valueObject = [NSNumber numberWithDouble: value];
    
    [self setAssociatedValue:valueObject forKey:key];
}
    
    
    @end


@interface HCSStarRatingView ()
    @property (nonatomic, readonly) BOOL shouldUseImages;
    @end

@implementation HCSStarRatingView {
    CGFloat _minimumValue;
    NSUInteger _maximumValue;
    CGFloat _value;
}
    
    @dynamic minimumValue;
    @dynamic maximumValue;
    @dynamic value;
    @dynamic shouldUseImages;
    
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _customInit];
    }
    return self;
}
    
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _customInit];
    }
    return self;
}
    
- (void)_customInit {
    self.exclusiveTouch = YES;
    _minimumValue = 0;
    _maximumValue = 5;
    _value = 0;
    _spacing = 5.f;
    _continuous = YES;
    [self _updateAppearanceForState:self.enabled];
}
    
- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self setNeedsDisplay];
}
    
- (UIColor *)backgroundColor {
    if ([super backgroundColor]) {
        return [super backgroundColor];
    } else {
        return self.isOpaque ? [UIColor whiteColor] : [UIColor clearColor];
    };
}
    
- (CGFloat)minimumValue {
    return MAX(_minimumValue, 0);
}
    
- (void)setMinimumValue:(CGFloat)minimumValue {
    if (_minimumValue != minimumValue) {
        _minimumValue = minimumValue;
        [self setNeedsDisplay];
    }
}
    
- (NSUInteger)maximumValue {
    return MAX(_minimumValue, _maximumValue);
}
    
- (void)setMaximumValue:(NSUInteger)maximumValue {
    if (_maximumValue != maximumValue) {
        _maximumValue = maximumValue;
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}
    
- (CGFloat)value {
    return MIN(MAX(_value, _minimumValue), _maximumValue);
}
    
- (void)setValue:(CGFloat)value {
    [self setValue:value sendValueChangedAction:NO];
}
    
- (void)setValue:(CGFloat)value sendValueChangedAction:(BOOL)sendAction {
    [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
    if (_value != value && value >= _minimumValue && value <= _maximumValue) {
        _value = value;
        if (sendAction) [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self setNeedsDisplay];
    }
    [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
}
    
- (void)setSpacing:(CGFloat)spacing {
    _spacing = MAX(spacing, 0);
    [self setNeedsDisplay];
}
    
- (void)setAllowsHalfStars:(BOOL)allowsHalfStars {
    if (_allowsHalfStars != allowsHalfStars) {
        _allowsHalfStars = allowsHalfStars;
        [self setNeedsDisplay];
    }
}
    
- (void)setAccurateHalfStars:(BOOL)accurateHalfStars {
    if (_accurateHalfStars != accurateHalfStars) {
        _accurateHalfStars = accurateHalfStars;
        [self setNeedsDisplay];
    }
}
    
- (void)setEmptyStarImage:(UIImage *)emptyStarImage {
    if (_emptyStarImage != emptyStarImage) {
        _emptyStarImage = emptyStarImage;
        [self setNeedsDisplay];
    }
}
    
- (void)setHalfStarImage:(UIImage *)halfStarImage {
    if (_halfStarImage != halfStarImage) {
        _halfStarImage = halfStarImage;
        [self setNeedsDisplay];
    }
}
    
- (void)setFilledStarImage:(UIImage *)filledStarImage {
    if (_filledStarImage != filledStarImage) {
        _filledStarImage = filledStarImage;
        [self setNeedsDisplay];
    }
}
    
- (BOOL)shouldUseImages {
    return (self.emptyStarImage!=nil && self.filledStarImage!=nil);
}
    
- (void)setEnabled:(BOOL)enabled
    {
        [self _updateAppearanceForState:enabled];
        [super setEnabled:enabled];
    }
    
- (void)_updateAppearanceForState:(BOOL)enabled
    {
        self.alpha = enabled ? 1.f : .5f;
    }
    
- (void)_drawStarImageWithFrame:(CGRect)frame tintColor:(UIColor*)tintColor highlighted:(BOOL)highlighted {
    UIImage *image = highlighted ? self.filledStarImage : self.emptyStarImage;
    [self _drawImage:image frame:frame tintColor:tintColor];
}
    
- (void)_drawHalfStarImageWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor {
    [self _drawAccurateHalfStarImageWithFrame:frame tintColor:tintColor progress:.5f];
}
    
- (void)_drawAccurateHalfStarImageWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor progress:(CGFloat)progress {
    UIImage *image = self.halfStarImage;
    if (image == nil) {
        // first draw star outline
        [self _drawStarImageWithFrame:frame tintColor:tintColor highlighted:NO];
        
        image = self.filledStarImage;
        CGRect imageFrame = CGRectMake(0, 0, image.size.width * image.scale * progress, image.size.height * image.scale);
        frame.size.width *= progress;
        CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, imageFrame);
        UIImage *halfImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
        image = [halfImage imageWithRenderingMode:image.renderingMode];
        CGImageRelease(imageRef);
    }
    [self _drawImage:image frame:frame tintColor:tintColor];
}
    
- (void)_drawImage:(UIImage *)image frame:(CGRect)frame tintColor:(UIColor *)tintColor {
    if (image.renderingMode == UIImageRenderingModeAlwaysTemplate) {
        [tintColor setFill];
    }
    [image drawInRect:frame];
}
    
- (void)_drawStarShapeWithFrame:(CGRect)frame tintColor:(UIColor*)tintColor highlighted:(BOOL)highlighted {
    [self _drawAccurateHalfStarShapeWithFrame:frame tintColor:tintColor progress:highlighted ? 1.f : 0.f];
}
    
- (void)_drawHalfStarShapeWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor {
    [self _drawAccurateHalfStarShapeWithFrame:frame tintColor:tintColor progress:.5f];
}
    
- (void)_drawAccurateHalfStarShapeWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor progress:(CGFloat)progress {
    UIBezierPath* starShapePath = UIBezierPath.bezierPath;
    [starShapePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.62723 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37309 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02500 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.37292 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37309 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39112 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30504 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62908 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20642 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97500 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78265 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79358 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97500 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.69501 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62908 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39112 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.62723 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37309 * CGRectGetHeight(frame))];
    [starShapePath closePath];
    starShapePath.miterLimit = 4;
    
    CGFloat frameWidth = frame.size.width;
    CGRect rightRectOfStar = CGRectMake(frame.origin.x + progress * frameWidth, frame.origin.y, frameWidth - progress * frameWidth, frame.size.height);
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [clipPath appendPath:[UIBezierPath bezierPathWithRect:rightRectOfStar]];
    clipPath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(UIGraphicsGetCurrentContext()); {
        [clipPath addClip];
        [tintColor setFill];
        [starShapePath fill];
    }
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    
    [tintColor setStroke];
    starShapePath.lineWidth = 1;
    [starShapePath stroke];
}
    
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    CGFloat availableWidth = rect.size.width - (_spacing * (_maximumValue - 1)) - 2;
    CGFloat cellWidth = (availableWidth / _maximumValue);
    CGFloat starSide = (cellWidth <= rect.size.height) ? cellWidth : rect.size.height;
    for (int idx = 0; idx < _maximumValue; idx++) {
        CGPoint center = CGPointMake(cellWidth*idx + cellWidth/2 + _spacing*idx + 1, rect.size.height/2);
        CGRect frame = CGRectMake(center.x - starSide/2, center.y - starSide/2, starSide, starSide);
        BOOL highlighted = (idx+1 <= ceilf(_value));
        if (_allowsHalfStars && highlighted && (idx+1 > _value)) {
            if (_accurateHalfStars) {
                [self _drawAccurateStarWithFrame:frame tintColor:self.tintColor progress:_value - idx];
            }
            else {
                [self _drawHalfStarWithFrame:frame tintColor:self.tintColor];
            }
        } else {
            [self _drawStarWithFrame:frame tintColor:self.tintColor highlighted:highlighted];
        }
    }
}
    
- (void)_drawStarWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor highlighted:(BOOL)highlighted {
    if (self.shouldUseImages) {
        [self _drawStarImageWithFrame:frame tintColor:tintColor highlighted:highlighted];
    } else {
        [self _drawStarShapeWithFrame:frame tintColor:tintColor highlighted:highlighted];
    }
}
    
- (void)_drawHalfStarWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor {
    if (self.shouldUseImages) {
        [self _drawHalfStarImageWithFrame:frame tintColor:tintColor];
    } else {
        [self _drawHalfStarShapeWithFrame:frame tintColor:tintColor];
    }
}
- (void)_drawAccurateStarWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor progress:(CGFloat)progress {
    if (self.shouldUseImages) {
        [self _drawAccurateHalfStarImageWithFrame:frame tintColor:tintColor progress:progress];
    } else {
        [self _drawAccurateHalfStarShapeWithFrame:frame tintColor:tintColor progress:progress];
    }
}
    
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.isEnabled) {
        [super beginTrackingWithTouch:touch withEvent:event];
        if (_shouldBecomeFirstResponder && ![self isFirstResponder]) {
            [self becomeFirstResponder];
        }
        [self _handleTouch:touch];
        return YES;
    } else {
        return NO;
    }
}
    
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.isEnabled) {
        [super continueTrackingWithTouch:touch withEvent:event];
        [self _handleTouch:touch];
        return YES;
    } else {
        return NO;
    }
}
    
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    if (_shouldBecomeFirstResponder && [self isFirstResponder]) {
        [self resignFirstResponder];
    }
    [self _handleTouch:touch];
    if (!_continuous) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}
    
- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    if (_shouldBecomeFirstResponder && [self isFirstResponder]) {
        [self resignFirstResponder];
    }
}
    
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer.view isEqual:self]) {
        return !self.isUserInteractionEnabled;
    }
    return self.shouldBeginGestureRecognizerBlock ? self.shouldBeginGestureRecognizerBlock(gestureRecognizer) : NO;
}
    
- (void)_handleTouch:(UITouch *)touch {
    CGFloat cellWidth = self.bounds.size.width / _maximumValue;
    CGPoint location = [touch locationInView:self];
    CGFloat value = location.x / cellWidth;
    if (_allowsHalfStars) {
        if (_accurateHalfStars) {
            value = value;
        }
        else {
            if (value+.5f < ceilf(value)) {
                value = floor(value)+.5f;
            } else {
                value = ceilf(value);
            }
        }
    } else {
        value = ceilf(value);
    }
    [self setValue:value sendValueChangedAction:_continuous];
}
    
- (BOOL)canBecomeFirstResponder {
    return _shouldBecomeFirstResponder;
}
    
- (CGSize)intrinsicContentSize {
    CGFloat height = 44.f;
    return CGSizeMake(_maximumValue * height + (_maximumValue-1) * _spacing, height);
}
    
- (BOOL)isAccessibilityElement {
    return YES;
}
    
- (NSString *)accessibilityLabel {
    return [super accessibilityLabel] ?: NSLocalizedString(@"Rating", @"Accessibility label for star rating control.");
}
    
- (UIAccessibilityTraits)accessibilityTraits {
    return ([super accessibilityTraits] | UIAccessibilityTraitAdjustable);
}
    
- (NSString *)accessibilityValue {
    return [@(self.value) description];
}
    
- (BOOL)accessibilityActivate {
    return YES;
}
    
- (void)accessibilityIncrement {
    CGFloat value = self.value + (self.allowsHalfStars ? .5f : 1.f);
    [self setValue:value sendValueChangedAction:YES];
}
    
- (void)accessibilityDecrement {
    CGFloat value = self.value - (self.allowsHalfStars ? .5f : 1.f);
    [self setValue:value sendValueChangedAction:YES];
}
    
    @end

@import AVFoundation;

@interface SAMSoundEffect ()
    @property (nonatomic) AVAudioPlayer *player;
    @end

@implementation SAMSoundEffect
    
    @synthesize player = _player;
    
+ (void)initialize {
    if (self == [SAMSoundEffect class]) {
        [[NSNotificationCenter defaultCenter]
         addObserverForName:AVAudioSessionMediaServicesWereResetNotification
         object:nil
         queue:nil
         usingBlock:^(NSNotification *notification) {
             [[self _cache] removeAllObjects];
         }];
    }
}
    
    
+ (NSCache *)_cache {
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}
    
    
+ (instancetype)soundEffectNamed:(NSString *)name {
    return [SAMSoundEffect soundEffectNamed:name inBundle:nil];
}
    
    
+ (instancetype)soundEffectNamed:(NSString *)name inBundle:(NSBundle *)bundleOrNil {
    if (!name) {
        return nil;
    }
    
    if (!bundleOrNil) {
        bundleOrNil = [NSBundle mainBundle];
    }
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@-%@", bundleOrNil.bundleIdentifier, name];
    SAMSoundEffect *cachedSoundEffect = [[self _cache] objectForKey:cacheKey];
    if (!cachedSoundEffect) {
        NSString *fileName = [[[name pathComponents] lastObject] stringByDeletingPathExtension];
        NSString *fileExtension = [name pathExtension];
        if ([fileExtension isEqualToString:@""]) {
            fileExtension = @"caf";
        }
        
        cachedSoundEffect = [[SAMSoundEffect alloc] initWithContentsOfFile:[bundleOrNil pathForResource:fileName ofType:fileExtension]];
        if (cachedSoundEffect) {
            [[self _cache] setObject:cachedSoundEffect forKey:cacheKey];
        } else {
            NSLog(@"[SAMSoundEffect] Could not find file named: %@ in bundle: %@", name, bundleOrNil.bundleIdentifier);
        }
    }
    
    return cachedSoundEffect;
}
    
+ (instancetype)playSoundEffectNamed:(NSString *)name {
    return [self playSoundEffectNamed:name inBundle:nil];
}
    
+ (instancetype)playSoundEffectNamed:(NSString *)name inBundle:(NSBundle *)bundleOrNil {
    SAMSoundEffect *soundEffect = [SAMSoundEffect soundEffectNamed:name inBundle:bundleOrNil];
    [soundEffect play];
    return soundEffect;
}
    
- (instancetype)initWithContentsOfFile:(NSString *)path {
    if ((self = [super init])) {
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        
        if (!fileURL) {
            NSLog(@"[SAMSoundEffect] NSURL is nil for path: %@", path);
            return nil;
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
            NSLog(@"[SAMSoundEffect] File doesn't exist at path: %@", path);
            return nil;
        }
        
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        [self.player prepareToPlay];
    }
    return self;
}
    
    
- (void)play {
    if (!self.player) {
        NSLog(@"[SAMSoundEffect] Could not play sound - no effectPlayer. %@", self);
    }
    
    [self.player play];
}
    
    
- (void)stop {
    [self.player stop];
}
    
    
- (BOOL)isPlaying {
    return self.player.playing;
}
    
    @end


#import <QuartzCore/QuartzCore.h>
#import <math.h>

@interface HMScrollView : UIScrollView
    @end

@interface HMSegmentedControl ()
    
    @property (nonatomic, strong) CALayer *selectionIndicatorStripLayer;
    @property (nonatomic, strong) CALayer *selectionIndicatorBoxLayer;
    @property (nonatomic, strong) CALayer *selectionIndicatorArrowLayer;
    @property (nonatomic, readwrite) CGFloat segmentWidth;
    @property (nonatomic, readwrite) NSArray *segmentWidthsArray;
    @property (nonatomic, strong) HMScrollView *scrollView;
    
    @end

@implementation HMScrollView
    
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging) {
        [self.nextResponder touchesBegan:touches withEvent:event];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}
    
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.dragging) {
        [self.nextResponder touchesMoved:touches withEvent:event];
    } else{
        [super touchesMoved:touches withEvent:event];
    }
}
    
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging) {
        [self.nextResponder touchesEnded:touches withEvent:event];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}
    
    @end

@implementation HMSegmentedControl
    
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}
    
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}
    
- (id)initWithSectionTitles:(NSArray *)sectiontitles {
    self = [self initWithFrame:CGRectZero];
    
    if (self) {
        [self commonInit];
        self.sectionTitles = sectiontitles;
        self.type = HMSegmentedControlTypeText;
    }
    
    return self;
}
    
- (id)initWithSectionImages:(NSArray*)sectionImages sectionSelectedImages:(NSArray*)sectionSelectedImages {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self commonInit];
        self.sectionImages = sectionImages;
        self.sectionSelectedImages = sectionSelectedImages;
        self.type = HMSegmentedControlTypeImages;
    }
    
    return self;
}
    
- (instancetype)initWithSectionImages:(NSArray *)sectionImages sectionSelectedImages:(NSArray *)sectionSelectedImages titlesForSections:(NSArray *)sectiontitles {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self commonInit];
        
        if (sectionImages.count != sectiontitles.count) {
            [NSException raise:NSRangeException format:@"***%s: Images bounds (%ld) Dont match Title bounds (%ld)", sel_getName(_cmd), (unsigned long)sectionImages.count, (unsigned long)sectiontitles.count];
        }
        
        self.sectionImages = sectionImages;
        self.sectionSelectedImages = sectionSelectedImages;
        self.sectionTitles = sectiontitles;
        self.type = HMSegmentedControlTypeTextImages;
    }
    
    return self;
}
    
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.segmentWidth = 0.0f;
    [self commonInit];
}
    
- (void)commonInit {
    self.scrollView = [[HMScrollView alloc] init];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    _backgroundColor = [UIColor whiteColor];
    self.opaque = NO;
    _selectionIndicatorColor = [UIColor colorWithRed:52.0f/255.0f green:181.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
    
    self.selectedSegmentIndex = 0;
    self.segmentEdgeInset = UIEdgeInsetsMake(0, 5, 0, 5);
    self.selectionIndicatorHeight = 5.0f;
    self.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationUp;
    self.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    self.userDraggable = YES;
    self.touchEnabled = YES;
    self.verticalDividerEnabled = NO;
    self.type = HMSegmentedControlTypeText;
    self.verticalDividerWidth = 1.0f;
    _verticalDividerColor = [UIColor blackColor];
    self.borderColor = [UIColor blackColor];
    self.borderWidth = 1.0f;
    
    self.shouldAnimateUserSelection = YES;
    
    self.selectionIndicatorArrowLayer = [CALayer layer];
    self.selectionIndicatorStripLayer = [CALayer layer];
    self.selectionIndicatorBoxLayer = [CALayer layer];
    self.selectionIndicatorBoxLayer.opacity = self.selectionIndicatorBoxOpacity;
    self.selectionIndicatorBoxLayer.borderWidth = 1.0f;
    self.selectionIndicatorBoxOpacity = 0.2;
    
    self.contentMode = UIViewContentModeRedraw;
}
    
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateSegmentsRects];
}
    
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self updateSegmentsRects];
}
    
- (void)setSectionTitles:(NSArray *)sectionTitles {
    _sectionTitles = sectionTitles;
    
    [self setNeedsLayout];
}
    
- (void)setSectionImages:(NSArray *)sectionImages {
    _sectionImages = sectionImages;
    
    [self setNeedsLayout];
}
    
- (void)setSelectionIndicatorLocation:(HMSegmentedControlSelectionIndicatorLocation)selectionIndicatorLocation {
    _selectionIndicatorLocation = selectionIndicatorLocation;
    
    if (selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationNone) {
        self.selectionIndicatorHeight = 0.0f;
    }
}
    
- (void)setSelectionIndicatorBoxOpacity:(CGFloat)selectionIndicatorBoxOpacity {
    _selectionIndicatorBoxOpacity = selectionIndicatorBoxOpacity;
    
    self.selectionIndicatorBoxLayer.opacity = _selectionIndicatorBoxOpacity;
}
    
- (void)setSegmentWidthStyle:(HMSegmentedControlSegmentWidthStyle)segmentWidthStyle {
    // Force HMSegmentedControlSegmentWidthStyleFixed when type is HMSegmentedControlTypeImages.
    if (self.type == HMSegmentedControlTypeImages) {
        _segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    } else {
        _segmentWidthStyle = segmentWidthStyle;
    }
}
    
- (void)setBorderType:(HMSegmentedControlBorderType)borderType {
    _borderType = borderType;
    [self setNeedsDisplay];
}
    
- (CGSize)measureTitleAtIndex:(NSUInteger)index {
    id title = self.sectionTitles[index];
    CGSize size = CGSizeZero;
    BOOL selected = (index == self.selectedSegmentIndex) ? YES : NO;
    if ([title isKindOfClass:[NSString class]] && !self.titleFormatter) {
        NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
        size = [(NSString *)title sizeWithAttributes:titleAttrs];
    } else if ([title isKindOfClass:[NSString class]] && self.titleFormatter) {
        size = [self.titleFormatter(self, title, index, selected) size];
    } else if ([title isKindOfClass:[NSAttributedString class]]) {
        size = [(NSAttributedString *)title size];
    } else {
        NSAssert(title == nil, @"Unexpected type of segment title: %@", [title class]);
        size = CGSizeZero;
    }
    return CGRectIntegral((CGRect){CGPointZero, size}).size;
}
    
- (NSAttributedString *)attributedTitleAtIndex:(NSUInteger)index {
    id title = self.sectionTitles[index];
    BOOL selected = (index == self.selectedSegmentIndex) ? YES : NO;
    
    if ([title isKindOfClass:[NSAttributedString class]]) {
        return (NSAttributedString *)title;
    } else if (!self.titleFormatter) {
        NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
        
        // the color should be cast to CGColor in order to avoid invalid context on iOS7
        UIColor *titleColor = titleAttrs[NSForegroundColorAttributeName];
        
        if (titleColor) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:titleAttrs];
            
            dict[NSForegroundColorAttributeName] = (id)titleColor.CGColor;
            
            titleAttrs = [NSDictionary dictionaryWithDictionary:dict];
        }
        
        return [[NSAttributedString alloc] initWithString:(NSString *)title attributes:titleAttrs];
    } else {
        return self.titleFormatter(self, title, index, selected);
    }
}
    
- (void)drawRect:(CGRect)rect {
    [self.backgroundColor setFill];
    UIRectFill([self bounds]);
    
    self.selectionIndicatorArrowLayer.backgroundColor = self.selectionIndicatorColor.CGColor;
    
    self.selectionIndicatorStripLayer.backgroundColor = self.selectionIndicatorColor.CGColor;
    
    self.selectionIndicatorBoxLayer.backgroundColor = self.selectionIndicatorColor.CGColor;
    self.selectionIndicatorBoxLayer.borderColor = self.selectionIndicatorColor.CGColor;
    
    // Remove all sublayers to avoid drawing images over existing ones
    self.scrollView.layer.sublayers = nil;
    
    CGRect oldRect = rect;
    
    if (self.type == HMSegmentedControlTypeText) {
        [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
            
            CGFloat stringWidth = 0;
            CGFloat stringHeight = 0;
            CGSize size = [self measureTitleAtIndex:idx];
            stringWidth = size.width;
            stringHeight = size.height;
            CGRect rectDiv, fullRect;
            
            // Text inside the CATextLayer will appear blurry unless the rect values are rounded
            BOOL locationUp = (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationUp);
            BOOL selectionStyleNotBox = (self.selectionStyle != HMSegmentedControlSelectionStyleBox);
            
            CGFloat y = roundf((CGRectGetHeight(self.frame) - selectionStyleNotBox * self.selectionIndicatorHeight) / 2 - stringHeight / 2 + self.selectionIndicatorHeight * locationUp);
            CGRect rect;
            if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
                rect = CGRectMake((self.segmentWidth * idx) + (self.segmentWidth - stringWidth) / 2, y, stringWidth, stringHeight);
                rectDiv = CGRectMake((self.segmentWidth * idx) - (self.verticalDividerWidth / 2), self.selectionIndicatorHeight * 2, self.verticalDividerWidth, self.frame.size.height - (self.selectionIndicatorHeight * 4));
                fullRect = CGRectMake(self.segmentWidth * idx, 0, self.segmentWidth, oldRect.size.height);
            } else if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
                // When we are drawing dynamic widths, we need to loop the widths array to calculate the xOffset
                CGFloat xOffset = 0;
                NSInteger i = 0;
                for (NSNumber *width in self.segmentWidthsArray) {
                    if (idx == i)
                    break;
                    xOffset = xOffset + [width floatValue];
                    i++;
                }
                
                CGFloat widthForIndex = [[self.segmentWidthsArray objectAtIndex:idx] floatValue];
                rect = CGRectMake(xOffset, y, widthForIndex, stringHeight);
                fullRect = CGRectMake(self.segmentWidth * idx, 0, widthForIndex, oldRect.size.height);
                rectDiv = CGRectMake(xOffset - (self.verticalDividerWidth / 2), self.selectionIndicatorHeight * 2, self.verticalDividerWidth, self.frame.size.height - (self.selectionIndicatorHeight * 4));
            }
            
            // Fix rect position/size to avoid blurry labels
            rect = CGRectMake(ceilf(rect.origin.x), ceilf(rect.origin.y), ceilf(rect.size.width), ceilf(rect.size.height));
            
            CATextLayer *titleLayer = [CATextLayer layer];
            titleLayer.frame = rect;
            titleLayer.alignmentMode = kCAAlignmentCenter;
            if ([UIDevice currentDevice].systemVersion.floatValue < 10.0 ) {
                titleLayer.truncationMode = kCATruncationEnd;
            }
            titleLayer.string = [self attributedTitleAtIndex:idx];
            titleLayer.contentsScale = [[UIScreen mainScreen] scale];
            
            [self.scrollView.layer addSublayer:titleLayer];
            
            // Vertical Divider
            if (self.isVerticalDividerEnabled && idx > 0) {
                CALayer *verticalDividerLayer = [CALayer layer];
                verticalDividerLayer.frame = rectDiv;
                verticalDividerLayer.backgroundColor = self.verticalDividerColor.CGColor;
                
                [self.scrollView.layer addSublayer:verticalDividerLayer];
            }
            
            [self addBackgroundAndBorderLayerWithRect:fullRect];
        }];
    } else if (self.type == HMSegmentedControlTypeImages) {
        [self.sectionImages enumerateObjectsUsingBlock:^(id iconImage, NSUInteger idx, BOOL *stop) {
            UIImage *icon = iconImage;
            CGFloat imageWidth = icon.size.width;
            CGFloat imageHeight = icon.size.height;
            CGFloat y = roundf(CGRectGetHeight(self.frame) - self.selectionIndicatorHeight) / 2 - imageHeight / 2 + ((self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationUp) ? self.selectionIndicatorHeight : 0);
            CGFloat x = self.segmentWidth * idx + (self.segmentWidth - imageWidth)/2.0f;
            CGRect rect = CGRectMake(x, y, imageWidth, imageHeight);
            
            CALayer *imageLayer = [CALayer layer];
            imageLayer.frame = rect;
            
            if (self.selectedSegmentIndex == idx) {
                if (self.sectionSelectedImages) {
                    UIImage *highlightIcon = [self.sectionSelectedImages objectAtIndex:idx];
                    imageLayer.contents = (id)highlightIcon.CGImage;
                } else {
                    imageLayer.contents = (id)icon.CGImage;
                }
            } else {
                imageLayer.contents = (id)icon.CGImage;
            }
            
            [self.scrollView.layer addSublayer:imageLayer];
            // Vertical Divider
            if (self.isVerticalDividerEnabled && idx>0) {
                CALayer *verticalDividerLayer = [CALayer layer];
                verticalDividerLayer.frame = CGRectMake((self.segmentWidth * idx) - (self.verticalDividerWidth / 2), self.selectionIndicatorHeight * 2, self.verticalDividerWidth, self.frame.size.height-(self.selectionIndicatorHeight * 4));
                verticalDividerLayer.backgroundColor = self.verticalDividerColor.CGColor;
                
                [self.scrollView.layer addSublayer:verticalDividerLayer];
            }
            
            [self addBackgroundAndBorderLayerWithRect:rect];
        }];
    } else if (self.type == HMSegmentedControlTypeTextImages){
        [self.sectionImages enumerateObjectsUsingBlock:^(id iconImage, NSUInteger idx, BOOL *stop) {
            UIImage *icon = iconImage;
            CGFloat imageWidth = icon.size.width;
            CGFloat imageHeight = icon.size.height;
            
            CGFloat stringHeight = [self measureTitleAtIndex:idx].height;
            CGFloat yOffset = roundf(((CGRectGetHeight(self.frame) - self.selectionIndicatorHeight) / 2) - (stringHeight / 2));
            
            CGFloat imageXOffset = self.segmentEdgeInset.left; // Start with edge inset
            CGFloat textXOffset  = self.segmentEdgeInset.left;
            CGFloat textWidth = 0;
            
            if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
                imageXOffset = (self.segmentWidth * idx) + (self.segmentWidth / 2.0f) - (imageWidth / 2.0f);
                textXOffset = self.segmentWidth * idx;
                textWidth = self.segmentWidth;
            } else if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
                // When we are drawing dynamic widths, we need to loop the widths array to calculate the xOffset
                CGFloat xOffset = 0;
                NSInteger i = 0;
                
                for (NSNumber *width in self.segmentWidthsArray) {
                    if (idx == i) {
                        break;
                    }
                    
                    xOffset = xOffset + [width floatValue];
                    i++;
                }
                
                imageXOffset = xOffset + ([self.segmentWidthsArray[idx] floatValue] / 2.0f) - (imageWidth / 2.0f); //(self.segmentWidth / 2.0f) - (imageWidth / 2.0f)
                textXOffset = xOffset;
                textWidth = [self.segmentWidthsArray[idx] floatValue];
            }
            
            CGFloat imageYOffset = roundf((CGRectGetHeight(self.frame) - self.selectionIndicatorHeight) / 2.0f);
            CGRect imageRect = CGRectMake(imageXOffset, imageYOffset, imageWidth, imageHeight);
            CGRect textRect = CGRectMake(textXOffset, yOffset, textWidth, stringHeight);
            
            // Fix rect position/size to avoid blurry labels
            textRect = CGRectMake(ceilf(textRect.origin.x), ceilf(textRect.origin.y), ceilf(textRect.size.width), ceilf(textRect.size.height));
            
            CATextLayer *titleLayer = [CATextLayer layer];
            titleLayer.frame = textRect;
            titleLayer.alignmentMode = kCAAlignmentCenter;
            titleLayer.string = [self attributedTitleAtIndex:idx];
            if ([UIDevice currentDevice].systemVersion.floatValue < 10.0 ) {
                titleLayer.truncationMode = kCATruncationEnd;
            }
            CALayer *imageLayer = [CALayer layer];
            imageLayer.frame = imageRect;
            
            if (self.selectedSegmentIndex == idx) {
                if (self.sectionSelectedImages) {
                    UIImage *highlightIcon = [self.sectionSelectedImages objectAtIndex:idx];
                    imageLayer.contents = (id)highlightIcon.CGImage;
                } else {
                    imageLayer.contents = (id)icon.CGImage;
                }
            } else {
                imageLayer.contents = (id)icon.CGImage;
            }
            
            [self.scrollView.layer addSublayer:imageLayer];
            titleLayer.contentsScale = [[UIScreen mainScreen] scale];
            [self.scrollView.layer addSublayer:titleLayer];
            
            [self addBackgroundAndBorderLayerWithRect:imageRect];
        }];
    }
    
    // Add the selection indicators
    if (self.selectedSegmentIndex != HMSegmentedControlNoSegment) {
        if (self.selectionStyle == HMSegmentedControlSelectionStyleArrow) {
            if (!self.selectionIndicatorArrowLayer.superlayer) {
                [self setArrowFrame];
                [self.scrollView.layer addSublayer:self.selectionIndicatorArrowLayer];
            }
        } else {
            if (!self.selectionIndicatorStripLayer.superlayer) {
                self.selectionIndicatorStripLayer.frame = [self frameForSelectionIndicator];
                [self.scrollView.layer addSublayer:self.selectionIndicatorStripLayer];
                
                if (self.selectionStyle == HMSegmentedControlSelectionStyleBox && !self.selectionIndicatorBoxLayer.superlayer) {
                    self.selectionIndicatorBoxLayer.frame = [self frameForFillerSelectionIndicator];
                    [self.scrollView.layer insertSublayer:self.selectionIndicatorBoxLayer atIndex:0];
                }
            }
        }
    }
}
    
- (void)addBackgroundAndBorderLayerWithRect:(CGRect)fullRect {
    // Background layer
    CALayer *backgroundLayer = [CALayer layer];
    backgroundLayer.frame = fullRect;
    [self.scrollView.layer insertSublayer:backgroundLayer atIndex:0];
    
    // Border layer
    if (self.borderType & HMSegmentedControlBorderTypeTop) {
        CALayer *borderLayer = [CALayer layer];
        borderLayer.frame = CGRectMake(0, 0, fullRect.size.width, self.borderWidth);
        borderLayer.backgroundColor = self.borderColor.CGColor;
        [backgroundLayer addSublayer: borderLayer];
    }
    if (self.borderType & HMSegmentedControlBorderTypeLeft) {
        CALayer *borderLayer = [CALayer layer];
        borderLayer.frame = CGRectMake(0, 0, self.borderWidth, fullRect.size.height);
        borderLayer.backgroundColor = self.borderColor.CGColor;
        [backgroundLayer addSublayer: borderLayer];
    }
    if (self.borderType & HMSegmentedControlBorderTypeBottom) {
        CALayer *borderLayer = [CALayer layer];
        borderLayer.frame = CGRectMake(0, fullRect.size.height - self.borderWidth, fullRect.size.width, self.borderWidth);
        borderLayer.backgroundColor = self.borderColor.CGColor;
        [backgroundLayer addSublayer: borderLayer];
    }
    if (self.borderType & HMSegmentedControlBorderTypeRight) {
        CALayer *borderLayer = [CALayer layer];
        borderLayer.frame = CGRectMake(fullRect.size.width - self.borderWidth, 0, self.borderWidth, fullRect.size.height);
        borderLayer.backgroundColor = self.borderColor.CGColor;
        [backgroundLayer addSublayer: borderLayer];
    }
}
    
- (void)setArrowFrame {
    self.selectionIndicatorArrowLayer.frame = [self frameForSelectionIndicator];
    
    self.selectionIndicatorArrowLayer.mask = nil;
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    CGPoint p3 = CGPointZero;
    
    if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationDown) {
        p1 = CGPointMake(self.selectionIndicatorArrowLayer.bounds.size.width / 2, 0);
        p2 = CGPointMake(0, self.selectionIndicatorArrowLayer.bounds.size.height);
        p3 = CGPointMake(self.selectionIndicatorArrowLayer.bounds.size.width, self.selectionIndicatorArrowLayer.bounds.size.height);
    }
    
    if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationUp) {
        p1 = CGPointMake(self.selectionIndicatorArrowLayer.bounds.size.width / 2, self.selectionIndicatorArrowLayer.bounds.size.height);
        p2 = CGPointMake(self.selectionIndicatorArrowLayer.bounds.size.width, 0);
        p3 = CGPointMake(0, 0);
    }
    
    [arrowPath moveToPoint:p1];
    [arrowPath addLineToPoint:p2];
    [arrowPath addLineToPoint:p3];
    [arrowPath closePath];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.selectionIndicatorArrowLayer.bounds;
    maskLayer.path = arrowPath.CGPath;
    self.selectionIndicatorArrowLayer.mask = maskLayer;
}
    
- (CGRect)frameForSelectionIndicator {
    CGFloat indicatorYOffset = 0.0f;
    
    if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationDown) {
        indicatorYOffset = self.bounds.size.height - self.selectionIndicatorHeight + self.selectionIndicatorEdgeInsets.bottom;
    }
    
    if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationUp) {
        indicatorYOffset = self.selectionIndicatorEdgeInsets.top;
    }
    
    CGFloat sectionWidth = 0.0f;
    
    if (self.type == HMSegmentedControlTypeText) {
        CGFloat stringWidth = [self measureTitleAtIndex:self.selectedSegmentIndex].width;
        sectionWidth = stringWidth;
    } else if (self.type == HMSegmentedControlTypeImages) {
        UIImage *sectionImage = [self.sectionImages objectAtIndex:self.selectedSegmentIndex];
        CGFloat imageWidth = sectionImage.size.width;
        sectionWidth = imageWidth;
    } else if (self.type == HMSegmentedControlTypeTextImages) {
        CGFloat stringWidth = [self measureTitleAtIndex:self.selectedSegmentIndex].width;
        UIImage *sectionImage = [self.sectionImages objectAtIndex:self.selectedSegmentIndex];
        CGFloat imageWidth = sectionImage.size.width;
        sectionWidth = MAX(stringWidth, imageWidth);
    }
    
    if (self.selectionStyle == HMSegmentedControlSelectionStyleArrow) {
        CGFloat widthToEndOfSelectedSegment = (self.segmentWidth * self.selectedSegmentIndex) + self.segmentWidth;
        CGFloat widthToStartOfSelectedIndex = (self.segmentWidth * self.selectedSegmentIndex);
        
        CGFloat x = widthToStartOfSelectedIndex + ((widthToEndOfSelectedSegment - widthToStartOfSelectedIndex) / 2) - (self.selectionIndicatorHeight/2);
        return CGRectMake(x - (self.selectionIndicatorHeight / 2), indicatorYOffset, self.selectionIndicatorHeight * 2, self.selectionIndicatorHeight);
    } else {
        if (self.selectionStyle == HMSegmentedControlSelectionStyleTextWidthStripe &&
            sectionWidth <= self.segmentWidth &&
            self.segmentWidthStyle != HMSegmentedControlSegmentWidthStyleDynamic) {
            CGFloat widthToEndOfSelectedSegment = (self.segmentWidth * self.selectedSegmentIndex) + self.segmentWidth;
            CGFloat widthToStartOfSelectedIndex = (self.segmentWidth * self.selectedSegmentIndex);
            
            CGFloat x = ((widthToEndOfSelectedSegment - widthToStartOfSelectedIndex) / 2) + (widthToStartOfSelectedIndex - sectionWidth / 2);
            return CGRectMake(x + self.selectionIndicatorEdgeInsets.left, indicatorYOffset, sectionWidth - self.selectionIndicatorEdgeInsets.right, self.selectionIndicatorHeight);
        } else {
            if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
                CGFloat selectedSegmentOffset = 0.0f;
                
                NSInteger i = 0;
                for (NSNumber *width in self.segmentWidthsArray) {
                    if (self.selectedSegmentIndex == i)
                    break;
                    selectedSegmentOffset = selectedSegmentOffset + [width floatValue];
                    i++;
                }
                return CGRectMake(selectedSegmentOffset + self.selectionIndicatorEdgeInsets.left, indicatorYOffset, [[self.segmentWidthsArray objectAtIndex:self.selectedSegmentIndex] floatValue] - self.selectionIndicatorEdgeInsets.right, self.selectionIndicatorHeight + self.selectionIndicatorEdgeInsets.bottom);
            }
            
            return CGRectMake((self.segmentWidth + self.selectionIndicatorEdgeInsets.left) * self.selectedSegmentIndex, indicatorYOffset, self.segmentWidth - self.selectionIndicatorEdgeInsets.right, self.selectionIndicatorHeight);
        }
    }
}
    
- (CGRect)frameForFillerSelectionIndicator {
    if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
        CGFloat selectedSegmentOffset = 0.0f;
        
        NSInteger i = 0;
        for (NSNumber *width in self.segmentWidthsArray) {
            if (self.selectedSegmentIndex == i) {
                break;
            }
            selectedSegmentOffset = selectedSegmentOffset + [width floatValue];
            
            i++;
        }
        
        return CGRectMake(selectedSegmentOffset, 0, [[self.segmentWidthsArray objectAtIndex:self.selectedSegmentIndex] floatValue], CGRectGetHeight(self.frame));
    }
    return CGRectMake(self.segmentWidth * self.selectedSegmentIndex, 0, self.segmentWidth, CGRectGetHeight(self.frame));
}
    
- (void)updateSegmentsRects {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    if ([self sectionCount] > 0) {
        self.segmentWidth = self.frame.size.width / [self sectionCount];
    }
    
    if (self.type == HMSegmentedControlTypeText && self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
        [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
            CGFloat stringWidth = [self measureTitleAtIndex:idx].width + self.segmentEdgeInset.left + self.segmentEdgeInset.right;
            self.segmentWidth = MAX(stringWidth, self.segmentWidth);
        }];
    } else if (self.type == HMSegmentedControlTypeText && self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
        NSMutableArray *mutableSegmentWidths = [NSMutableArray array];
        
        [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
            CGFloat stringWidth = [self measureTitleAtIndex:idx].width + self.segmentEdgeInset.left + self.segmentEdgeInset.right;
            [mutableSegmentWidths addObject:[NSNumber numberWithFloat:stringWidth]];
        }];
        self.segmentWidthsArray = [mutableSegmentWidths copy];
    } else if (self.type == HMSegmentedControlTypeImages) {
        for (UIImage *sectionImage in self.sectionImages) {
            CGFloat imageWidth = sectionImage.size.width + self.segmentEdgeInset.left + self.segmentEdgeInset.right;
            self.segmentWidth = MAX(imageWidth, self.segmentWidth);
        }
    } else if (self.type == HMSegmentedControlTypeTextImages && self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed){
        //lets just use the title.. we will assume it is wider then images...
        [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
            CGFloat stringWidth = [self measureTitleAtIndex:idx].width + self.segmentEdgeInset.left + self.segmentEdgeInset.right;
            self.segmentWidth = MAX(stringWidth, self.segmentWidth);
        }];
    } else if (self.type == HMSegmentedControlTypeTextImages && HMSegmentedControlSegmentWidthStyleDynamic) {
        NSMutableArray *mutableSegmentWidths = [NSMutableArray array];
        
        int i = 0;
        [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
            CGFloat stringWidth = [self measureTitleAtIndex:idx].width + self.segmentEdgeInset.right;
            UIImage *sectionImage = [self.sectionImages objectAtIndex:i];
            CGFloat imageWidth = sectionImage.size.width + self.segmentEdgeInset.left;
            
            CGFloat combinedWidth = MAX(imageWidth, stringWidth);
            
            [mutableSegmentWidths addObject:[NSNumber numberWithFloat:combinedWidth]];
        }];
        self.segmentWidthsArray = [mutableSegmentWidths copy];
    }
    
    self.scrollView.scrollEnabled = self.isUserDraggable;
    self.scrollView.contentSize = CGSizeMake([self totalSegmentedControlWidth], self.frame.size.height);
}
    
- (NSUInteger)sectionCount {
    if (self.type == HMSegmentedControlTypeText) {
        return self.sectionTitles.count;
    } else if (self.type == HMSegmentedControlTypeImages ||
               self.type == HMSegmentedControlTypeTextImages) {
        return self.sectionImages.count;
    }
    
    return 0;
}
    
- (void)willMoveToSuperview:(UIView *)newSuperview {
    // Control is being removed
    if (newSuperview == nil)
    return;
    
    if (self.sectionTitles || self.sectionImages) {
        [self updateSegmentsRects];
    }
}
    
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    CGRect enlargeRect =   CGRectMake(self.bounds.origin.x - self.enlargeEdgeInset.left,
                                      self.bounds.origin.y - self.enlargeEdgeInset.top,
                                      self.bounds.size.width + self.enlargeEdgeInset.left + self.enlargeEdgeInset.right,
                                      self.bounds.size.height + self.enlargeEdgeInset.top + self.enlargeEdgeInset.bottom);
    
    if (CGRectContainsPoint(enlargeRect, touchLocation)) {
        NSInteger segment = 0;
        if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
            segment = (touchLocation.x + self.scrollView.contentOffset.x) / self.segmentWidth;
        } else if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
            // To know which segment the user touched, we need to loop over the widths and substract it from the x position.
            CGFloat widthLeft = (touchLocation.x + self.scrollView.contentOffset.x);
            for (NSNumber *width in self.segmentWidthsArray) {
                widthLeft = widthLeft - [width floatValue];
                
                // When we don't have any width left to substract, we have the segment index.
                if (widthLeft <= 0)
                break;
                
                segment++;
            }
        }
        
        NSUInteger sectionsCount = 0;
        
        if (self.type == HMSegmentedControlTypeImages) {
            sectionsCount = [self.sectionImages count];
        } else if (self.type == HMSegmentedControlTypeTextImages || self.type == HMSegmentedControlTypeText) {
            sectionsCount = [self.sectionTitles count];
        }
        
        if (segment != self.selectedSegmentIndex && segment < sectionsCount) {
            // Check if we have to do anything with the touch event
            if (self.isTouchEnabled)
            [self setSelectedSegmentIndex:segment animated:self.shouldAnimateUserSelection notify:YES];
        }
    }
}
    
- (CGFloat)totalSegmentedControlWidth {
    if (self.type == HMSegmentedControlTypeText && self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
        return self.sectionTitles.count * self.segmentWidth;
    } else if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
        return [[self.segmentWidthsArray valueForKeyPath:@"@sum.self"] floatValue];
    } else {
        return self.sectionImages.count * self.segmentWidth;
    }
}
    
- (void)scrollToSelectedSegmentIndex:(BOOL)animated {
    CGRect rectForSelectedIndex;
    CGFloat selectedSegmentOffset = 0;
    if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
        rectForSelectedIndex = CGRectMake(self.segmentWidth * self.selectedSegmentIndex,
                                          0,
                                          self.segmentWidth,
                                          self.frame.size.height);
        
        selectedSegmentOffset = (CGRectGetWidth(self.frame) / 2) - (self.segmentWidth / 2);
    } else if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
        NSInteger i = 0;
        CGFloat offsetter = 0;
        for (NSNumber *width in self.segmentWidthsArray) {
            if (self.selectedSegmentIndex == i)
            break;
            offsetter = offsetter + [width floatValue];
            i++;
        }
        
        rectForSelectedIndex = CGRectMake(offsetter,
                                          0,
                                          [[self.segmentWidthsArray objectAtIndex:self.selectedSegmentIndex] floatValue],
                                          self.frame.size.height);
        
        selectedSegmentOffset = (CGRectGetWidth(self.frame) / 2) - ([[self.segmentWidthsArray objectAtIndex:self.selectedSegmentIndex] floatValue] / 2);
    }
    
    
    CGRect rectToScrollTo = rectForSelectedIndex;
    rectToScrollTo.origin.x -= selectedSegmentOffset;
    rectToScrollTo.size.width += selectedSegmentOffset * 2;
    [self.scrollView scrollRectToVisible:rectToScrollTo animated:animated];
}
    
- (void)setSelectedSegmentIndex:(NSInteger)index {
    [self setSelectedSegmentIndex:index animated:NO notify:NO];
}
    
- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated {
    [self setSelectedSegmentIndex:index animated:animated notify:NO];
}
    
- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated notify:(BOOL)notify {
    _selectedSegmentIndex = index;
    [self setNeedsDisplay];
    
    if (index == HMSegmentedControlNoSegment) {
        [self.selectionIndicatorArrowLayer removeFromSuperlayer];
        [self.selectionIndicatorStripLayer removeFromSuperlayer];
        [self.selectionIndicatorBoxLayer removeFromSuperlayer];
    } else {
        [self scrollToSelectedSegmentIndex:animated];
        
        if (animated) {
            // If the selected segment layer is not added to the super layer, that means no
            // index is currently selected, so add the layer then move it to the new
            // segment index without animating.
            if(self.selectionStyle == HMSegmentedControlSelectionStyleArrow) {
                if ([self.selectionIndicatorArrowLayer superlayer] == nil) {
                    [self.scrollView.layer addSublayer:self.selectionIndicatorArrowLayer];
                    
                    [self setSelectedSegmentIndex:index animated:NO notify:YES];
                    return;
                }
            }else {
                if ([self.selectionIndicatorStripLayer superlayer] == nil) {
                    [self.scrollView.layer addSublayer:self.selectionIndicatorStripLayer];
                    
                    if (self.selectionStyle == HMSegmentedControlSelectionStyleBox && [self.selectionIndicatorBoxLayer superlayer] == nil)
                    [self.scrollView.layer insertSublayer:self.selectionIndicatorBoxLayer atIndex:0];
                    
                    [self setSelectedSegmentIndex:index animated:NO notify:YES];
                    return;
                }
            }
            
            if (notify)
            [self notifyForSegmentChangeToIndex:index];
            
            // Restore CALayer animations
            self.selectionIndicatorArrowLayer.actions = nil;
            self.selectionIndicatorStripLayer.actions = nil;
            self.selectionIndicatorBoxLayer.actions = nil;
            
            // Animate to new position
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.15f];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self setArrowFrame];
            self.selectionIndicatorBoxLayer.frame = [self frameForSelectionIndicator];
            self.selectionIndicatorStripLayer.frame = [self frameForSelectionIndicator];
            self.selectionIndicatorBoxLayer.frame = [self frameForFillerSelectionIndicator];
            [CATransaction commit];
        } else {
            // Disable CALayer animations
            NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", [NSNull null], @"bounds", nil];
            self.selectionIndicatorArrowLayer.actions = newActions;
            [self setArrowFrame];
            
            self.selectionIndicatorStripLayer.actions = newActions;
            self.selectionIndicatorStripLayer.frame = [self frameForSelectionIndicator];
            
            self.selectionIndicatorBoxLayer.actions = newActions;
            self.selectionIndicatorBoxLayer.frame = [self frameForFillerSelectionIndicator];
            
            if (notify)
            [self notifyForSegmentChangeToIndex:index];
        }
    }
}
    
- (void)notifyForSegmentChangeToIndex:(NSInteger)index {
    if (self.superview)
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if (self.indexChangeBlock)
    self.indexChangeBlock(index);
}
    
- (NSDictionary *)resultingTitleTextAttributes {
    NSDictionary *defaults = @{
                               NSFontAttributeName : [UIFont systemFontOfSize:19.0f],
                               NSForegroundColorAttributeName : [UIColor blackColor],
                               };
    
    NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:defaults];
    
    if (self.titleTextAttributes) {
        [resultingAttrs addEntriesFromDictionary:self.titleTextAttributes];
    }
    
    return [resultingAttrs copy];
}
    
- (NSDictionary *)resultingSelectedTitleTextAttributes {
    NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:[self resultingTitleTextAttributes]];
    
    if (self.selectedTitleTextAttributes) {
        [resultingAttrs addEntriesFromDictionary:self.selectedTitleTextAttributes];
    }
    
    return [resultingAttrs copy];
}
    
    @end
