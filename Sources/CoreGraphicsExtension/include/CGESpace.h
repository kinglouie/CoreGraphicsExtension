
@import Foundation;

@class NSScreen;
@class CGESpace;

@interface CGESpace : NSObject

#pragma mark - Spaces

+ (instancetype) active;
+ (NSArray<CGESpace *> *) all;
+ (instancetype) currentSpaceForScreen:(NSScreen *)screen;
+ (NSArray<CGESpace *> *) spacesForWindow:(NSWindow *)window;

#pragma mark - Identifying

- (NSUInteger) number;

#pragma mark - Properties

- (BOOL) isNormal;
- (BOOL) isFullScreen;
- (NSArray<NSScreen *> *) screens;

#pragma mark - Initialising

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

- (instancetype) initWithIdentifier:(NSUInteger)identifier NS_DESIGNATED_INITIALIZER;

@end
