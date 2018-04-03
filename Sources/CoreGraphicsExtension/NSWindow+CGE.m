
#import "NSWindow+CGE.h"
#import "CGESpace.h"

/* XXX: Undocumented private typedefs for CGSSpace */
typedef NSUInteger CGSConnectionID;
typedef NSUInteger CGSSpaceID;

@implementation NSWindow (CGE)

// Get the CGSConnectionID for the default connection for this process
extern CGSConnectionID CGSMainConnectionID(void);
// Move the given windows (CGWindowIDs) to the given space (CGSSpaceID)
extern void CGSMoveWindowsToManagedSpace(CGSConnectionID connection, CFArrayRef windowIds, CGSSpaceID SpaceId);

- (void) moveToSpace:(CGESpace*)space
{
    CGSMoveWindowsToManagedSpace(CGSMainConnectionID(),
        (__bridge CFArrayRef) @[ @([self windowNumber]) ],
        space.hash
    );
}

@end
