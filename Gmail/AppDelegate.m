//
//  AppDelegate.m
//  Gmail
//
//  Created by Francisco Tolmasky on 6/28/14.
//
//

#import "AppDelegate.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainWebWindowController = [[WebWindowController alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://gmail.com"]] disposeWhenClosed:NO];
    
    [self.mainWebWindowController.window makeKeyAndOrderFront:self];
    
    self.unreadEmailCountTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateUnreadEmailCount) userInfo:nil repeats:YES];

    [self addObserver:self forKeyPath:@"unreadEmailCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

+ (NSString *)unreadEmailCountScript
{
    static NSString * unreadEmailCountScript = nil;

    if (unreadEmailCountScript == nil)
    {
        NSURL * unreadEmailCountScriptURL = [NSBundle.mainBundle URLForResource:@"unreadEmailCount" withExtension:@"js"];

        unreadEmailCountScript = [NSString stringWithContentsOfURL:unreadEmailCountScriptURL encoding:NSUTF8StringEncoding error:NULL];
    }

    return unreadEmailCountScript;
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext
{
    if ([aKeyPath isEqualToString:@"unreadEmailCount"])
    {
        int previous = ((NSNumber *)[aChange objectForKey:NSKeyValueChangeOldKey]).intValue;

        if (previous == self.unreadEmailCount)
            return;

        [[NSApp dockTile] setBadgeLabel:self.unreadEmailCount == 0 ? @"" : [NSString stringWithFormat:@"%d", self.unreadEmailCount]];

        if (previous < self.unreadEmailCount)
            [[NSSound soundNamed:@"New Mail"] play];
    }

    if ([[self superclass] methodSignatureForSelector:_cmd] != [NSObject methodSignatureForSelector:_cmd])
        [super observeValueForKeyPath:aKeyPath ofObject:anObject change:aChange context:aContext];
}

- (void)updateUnreadEmailCount
{
    NSString * inboxString = [self.mainWebWindowController.webView stringByEvaluatingJavaScriptFromString:[[self class] unreadEmailCountScript]];
    NSScanner * scanner = [NSScanner scannerWithString:inboxString];

    [scanner setCharactersToBeSkipped:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];

    int unreadEmailCount = 0;

    [scanner scanInt:&unreadEmailCount];

    self.unreadEmailCount = unreadEmailCount;
}

@end
