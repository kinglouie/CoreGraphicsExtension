
@import Cocoa;

@class CGESpace;

@interface NSScreen (CGE)

#pragma mark - Screens

+ (instancetype) screenForIdentifier:(NSString *)identifier;
+ (instancetype) main;
+ (NSArray<NSScreen *> *) all;

#pragma mark - Properties

- (NSString *) identifier;

#pragma mark - Spaces

- (CGESpace *) currentSpace;
- (NSArray<CGESpace *> *) spaces;

@end
