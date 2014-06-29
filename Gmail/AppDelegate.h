//
//  AppDelegate.h
//  Gmail
//
//  Created by Francisco Tolmasky on 6/28/14.
//
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "WebWindowController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) WebWindowController  * mainWebWindowController;
@property (assign) int                  unreadEmailCount;
@property (strong) NSTimer              * unreadEmailCountTimer;


@end
