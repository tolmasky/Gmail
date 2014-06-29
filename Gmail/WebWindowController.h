//
//  WebWindowController.h
//  Gmail
//
//  Created by Francisco Tolmasky on 6/28/14.
//
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface WebWindowController : NSWindowController

@property (assign) IBOutlet WebView * webView;

- (id)initWithRequest:(NSURLRequest *)aRequest disposeWhenClosed:(BOOL)isMainWindow;

@end
