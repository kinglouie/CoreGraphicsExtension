
@import Cocoa;

#import "NSProcessInfo+CGE.h"
#import "NSScreen+CGE.h"
#import "CGESpace.h"

/* XXX: Undocumented private typedefs for CGSSpace */

typedef NSUInteger CGSConnectionID;
typedef NSUInteger CGSSpaceID;

typedef enum {

    kCGSSpaceIncludesCurrent = 1 << 0,
    kCGSSpaceIncludesOthers = 1 << 1,
    kCGSSpaceIncludesUser = 1 << 2,

    kCGSAllSpacesMask = kCGSSpaceIncludesCurrent | kCGSSpaceIncludesOthers | kCGSSpaceIncludesUser

} CGSSpaceMask;

typedef enum {

    kCGSSpaceUser,
    kCGSSpaceFullScreen = 4

} CGSSpaceType;

@interface CGESpace ()

@property CGSSpaceID identifier;

@end

@implementation CGESpace

static NSString * const CGSScreenIDKey = @"Display Identifier";
static NSString * const CGSSpaceIDKey = @"ManagedSpaceID";
static NSString * const CGSSpacesKey = @"Spaces";
static NSString * const PHWindowIDKey = @"identifier";

// XXX: Undocumented private API to get the CGSConnectionID for the default connection for this process
CGSConnectionID CGSMainConnectionID(void);

// XXX: Undocumented private API to get the CGSSpaceID for the active space
CGSSpaceID CGSGetActiveSpace(CGSConnectionID connection);

// XXX: Undocumented private API to get the CGSSpaceID for the current space for a given screen (UUID)
CGSSpaceID CGSManagedDisplayGetCurrentSpace(CGSConnectionID connection, CFStringRef screenId);

// XXX: Undocumented private API to get the CGSSpaceIDs for all spaces in order
CFArrayRef CGSCopyManagedDisplaySpaces(CGSConnectionID connection);

// XXX: Undocumented private API to get the CGSSpaceIDs for the given windows (CGWindowIDs)
CFArrayRef CGSCopySpacesForWindows(CGSConnectionID connection, CGSSpaceMask mask, CFArrayRef windowIds);

// XXX: Undocumented private API to get the CGSSpaceType for a given space
CGSSpaceType CGSSpaceGetType(CGSConnectionID connection, CGSSpaceID space);

// XXX: Undocumented private API to add the given windows (CGWindowIDs) to the given spaces (CGSSpaceIDs)
void CGSAddWindowsToSpaces(CGSConnectionID connection, CFArrayRef windowIds, CFArrayRef spaceIds);

// XXX: Undocumented private API to remove the given windows (CGWindowIDs) from the given spaces (CGSSpaceIDs)
void CGSRemoveWindowsFromSpaces(CGSConnectionID connection, CFArrayRef windowIds, CFArrayRef spaceIds);

#pragma mark - Initialising

- (instancetype) initWithIdentifier:(NSUInteger)identifier {

    if (self = [super init]) {
        self.identifier = identifier;
    }

    return self;
}

#pragma mark - Spaces

+ (instancetype) active {

    // Only supported from 10.11 upwards
    if (![NSProcessInfo isOperatingSystemAtLeastElCapitan]) {
        return nil;
    }

    return [(CGESpace *) [self alloc] initWithIdentifier:CGSGetActiveSpace(CGSMainConnectionID())];
}

+ (NSArray<CGESpace *> *) all {

    // Only supported from 10.11 upwards
    if (![NSProcessInfo isOperatingSystemAtLeastElCapitan]) {
        return @[];
    }

    NSMutableArray *spaces = [NSMutableArray array];
    NSArray *displaySpacesInfo = CFBridgingRelease(CGSCopyManagedDisplaySpaces(CGSMainConnectionID()));

    for (NSDictionary<NSString *, id> *spacesInfo in displaySpacesInfo) {

        NSArray<NSNumber *> *identifiers = [spacesInfo[CGSSpacesKey] valueForKey:CGSSpaceIDKey];

        for (NSNumber *identifier in identifiers) {
            [spaces addObject:[(CGESpace *) [self alloc] initWithIdentifier:identifier.unsignedLongValue]];
        }
    }

    return spaces;
}

+ (instancetype) currentSpaceForScreen:(NSScreen *)screen {

    // Only supported from 10.11 upwards
    if (![NSProcessInfo isOperatingSystemAtLeastElCapitan]) {
        return nil;
    }

    NSUInteger identifier = CGSManagedDisplayGetCurrentSpace(CGSMainConnectionID(),
                                                             (__bridge CFStringRef) [screen identifier]);

    return [(CGESpace *) [self alloc] initWithIdentifier:identifier];
}

+ (NSArray<CGESpace *> *) spacesForWindow:(NSWindow *)window {

    // Only supported from 10.11 upwards
    if (![NSProcessInfo isOperatingSystemAtLeastElCapitan]) {
        return @[];
    }

    NSMutableArray *spaces = [NSMutableArray array];
    NSArray<NSNumber *> *identifiers = CFBridgingRelease(CGSCopySpacesForWindows(CGSMainConnectionID(),
                                                                                 kCGSAllSpacesMask,
                                                                                 (__bridge CFArrayRef) @[ @([window windowNumber]) ]));
    for (CGESpace *space in [self all]) {

        NSNumber *identifier = @([space hash]);

        if ([identifiers containsObject:identifier]) {
            [spaces addObject:[(CGESpace *) [self alloc] initWithIdentifier:identifier.unsignedLongValue]];
        }
    }

    return spaces;
}

#pragma mark - Identifying

- (NSUInteger) hash {

    return self.identifier;
}

- (NSUInteger) number {
    NSUInteger number = 0;
    for (NSScreen *scr in [NSScreen screens]) {
        if([scr.spaces containsObject:self]) {
            number += ([scr.spaces indexOfObject:self] + 1);
            break;
        }
        else {
            number += [scr.spaces count];
        }
    }
    return number;
}

- (BOOL) isEqual:(id)object {

    return [object isKindOfClass:[CGESpace class]] && [self hash] == [object hash];
}

#pragma mark - Properties

- (BOOL) isNormal {

    return CGSSpaceGetType(CGSMainConnectionID(), self.identifier) == kCGSSpaceUser;
}

- (BOOL) isFullScreen {

    return CGSSpaceGetType(CGSMainConnectionID(), self.identifier) == kCGSSpaceFullScreen;
}

- (NSArray<NSScreen *> *) screens {

    if (![NSScreen screensHaveSeparateSpaces]) {
        return [NSScreen screens];
    }

    NSArray *displaySpacesInfo = CFBridgingRelease(CGSCopyManagedDisplaySpaces(CGSMainConnectionID()));

    for (NSDictionary<NSString *, id> *spacesInfo in displaySpacesInfo) {

        NSString *screenIdentifier = spacesInfo[CGSScreenIDKey];
        NSArray<NSNumber *> *identifiers = [spacesInfo[CGSSpacesKey] valueForKey:CGSSpaceIDKey];

        if ([identifiers containsObject:@(self.identifier)]) {
            return @[ [NSScreen screenForIdentifier:screenIdentifier] ];
        }
    }

    return @[];
}

@end
