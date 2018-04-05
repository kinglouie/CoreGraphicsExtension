
#import "NSScreen+CGE.h"
#import "CGESpace.h"

@implementation NSScreen (CGE)

static NSString * const NSScreenNumberKey = @"NSScreenNumber";

#pragma mark - Screens

+ (instancetype) screenForIdentifier:(NSString *)identifier {

    for (NSScreen *screen in [self screens]) {

        if ([[screen identifier] isEqualToString:identifier]) {
            return screen;
        }
    }

    return nil;
}

+ (instancetype) main {

    return [self mainScreen];
}

+ (NSArray<NSScreen *> *) all {

    return [self screens];
}

#pragma mark - Properties

- (NSString *) identifier {

    id uuid = CFBridgingRelease(CGDisplayCreateUUIDFromDisplayID([self.deviceDescription[NSScreenNumberKey] unsignedIntValue]));
    if (uuid) {
      return CFBridgingRelease(CFUUIDCreateString(NULL, (__bridge CFUUIDRef) uuid));
    }
    else {
      return @"";
    }

}

#pragma mark - Spaces

- (CGESpace *) currentSpace {

    return [CGESpace currentSpaceForScreen:self];
}

- (NSArray<CGESpace *> *) spaces {

    NSPredicate *spaceIsOnThisScreen = [NSPredicate predicateWithBlock:
                                        ^BOOL (CGESpace *space, __unused NSDictionary<NSString *, id> *bindings) {

        return [[space screens] containsObject:self];
    }];

    return [[CGESpace all] filteredArrayUsingPredicate:spaceIsOnThisScreen];
}

@end
