//
//  WebWindowController.m
//  Gmail
//
//  Created by Francisco Tolmasky on 6/28/14.
//
//

#import "WebWindowController.h"



@implementation WebWindowController

+ (NSMutableArray *)webWindowControllers
{
    static NSMutableArray * webWindowControllers =  nil;

    if (webWindowControllers == nil)
        webWindowControllers = [NSMutableArray new];

    return webWindowControllers;
}

- (id)initWithRequest:(NSURLRequest *)aRequest disposeWhenClosed:(BOOL)shouldDisposeWhenClosed
{
    self = [self initWithWindowNibName:@"WebWindowController"];

    if (self)
    {
        NSLog(@"%@", self.window);

        [self.webView.mainFrame loadRequest:aRequest];
        [self.webView setShouldCloseWithWindow:shouldDisposeWhenClosed];
        [self.webView setApplicationNameForUserAgent:@"Safari"];
        [self.webView setPreferences:[WebPreferences standardPreferences]];

        [self.class.webWindowControllers addObject:self];
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [self.webView addObserver:self
                   forKeyPath:@"mainFrameTitle"
                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                      context:NULL];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    if (self.webView.shouldCloseWithWindow)
        [self.class.webWindowControllers performSelector:@selector(removeObject:) withObject:self afterDelay:0.0f];
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext
{
    if ([aKeyPath isEqualToString:@"mainFrameTitle"])
        self.window.title = self.webView.mainFrameTitle;
    
    if ([[self superclass] methodSignatureForSelector:_cmd] != [NSObject methodSignatureForSelector:_cmd])
        [super observeValueForKeyPath:aKeyPath ofObject:anObject change:aChange context:aContext];
}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"mainFrameTitle"];

    NSLog(@"good bye...");
}

@end

@implementation WebWindowController (WebUIDelegate)

- (WebView *)webView:(WebView *)aWebView createWebViewWithRequest:(NSURLRequest *)aRequest
{
    return [[WebWindowController alloc] initWithRequest:aRequest disposeWhenClosed:YES].webView;
}

- (void)webViewClose:(WebView *)aWebView
{
    [self.window close];
}

- (void)webViewShow:(WebView *)aWebView
{
    if (self.webView.mainFrame.dataSource.request.URL != nil)
        [self.window makeKeyAndOrderFront:self];
}

@end

@implementation WebWindowController (WebPolicyDelegate)

- (void)webView:(WebView *)aWebView decidePolicyForNavigationAction:(NSDictionary *)anActionInformation request:(NSURLRequest *)aRequest frame:(WebFrame *)aWebFrame decisionListener:(id <WebPolicyDecisionListener>)aListener
{
    if ([aRequest.URL.absoluteString isEqual:@"about:blank"] ||
        [aRequest.URL.host isEqual:@"gmail.com"] ||
        [aRequest.URL.host isEqual:@"google.com"] ||
        [aRequest.URL.host hasSuffix:@".gmail.com"] ||
        [aRequest.URL.host hasSuffix:@".google.com"])
    {
        [aListener use];

        if (!self.window.isVisible)
            [self.window makeKeyAndOrderFront:self];
    }

    else if (aRequest.URL != nil)
    {
        if (!self.window.isVisible)
            [self.window close];

        [aListener ignore];

        [[NSWorkspace sharedWorkspace] openURL:aRequest.URL];
    }
}


- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSLog(@"hello...");
}

@end
