
#import "NSProcessInfo+CGE.h"

@implementation NSProcessInfo (CGE)

#pragma mark - Operating System

+ (BOOL) isOperatingSystemAtLeastElCapitan {

    NSOperatingSystemVersion elCapitan = { .majorVersion = 10, .minorVersion = 11, .patchVersion = 0 };
    return [[self processInfo] isOperatingSystemAtLeastVersion:elCapitan];
}

@end
