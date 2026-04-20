//
//  YBWebViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SWWebViewController.h"
//#import "fenXiangView.h"

@interface SWWebViewController ()<WKNavigationDelegate>
@property (nonatomic, copy) NSString *codeString;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) CALayer *progressLayer;
@end

@implementation SWWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, _window_height - 64 - statusbarHeight)];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];

    self.progressLayer = [[CALayer alloc] init];
    self.progressLayer.frame = CGRectMake(0, 0, _window_width * 0.1, 2);
    self.progressLayer.backgroundColor = JJAPPTHEMECOLOR.CGColor;
    [self.webView.layer addSublayer:self.progressLayer];

    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    if (self.isLocal) {
        NSString *readAccessToURL = [self.urls stringByDeletingLastPathComponent];
        [self.webView loadFileURL:[NSURL fileURLWithPath:self.urls] allowingReadAccessToURL:[NSURL fileURLWithPath:readAccessToURL]];
    } else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urls]]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressLayer.opacity = 1;
        float progress = [[change objectForKey:@"new"] floatValue];
        self.progressLayer.frame = CGRectMake(0, 0, _window_width * progress, 2);
        if (progress == 1) {
            __weak __typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.progressLayer.opacity = 0;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.progressLayer.frame = CGRectMake(0, 0, 0, 3);
            });
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            if (self.isLocal) {
                self.titleL.text = self.localTitleStr;
            } else {
                self.titleL.text = self.webView.title;
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    NSLog(@"WKWebView dealloc------------");
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

- (void)doReturn {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *url = navigationAction.request.URL.absoluteString;
    if (navigationAction.targetFrame.isMainFrame) {
        NSLog(@"target is main ... %@", url);
        if (navigationAction.sourceFrame.mainFrame) {
            NSLog(@"source is main...%@", url);
            if ([self.urls isEqualToString:url]) {
                decisionHandler(WKNavigationActionPolicyAllow);
                NSLog(@"放行bbbbbbbbbbbbbbbbb...%@", url);
                return;
            }
            if ([url hasPrefix:@"copy://"]) {
                self.codeString = [url substringFromIndex:7];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = self.codeString;
                    [MBProgressHUD showError:@"复制成功"];
                });
                decisionHandler(WKNavigationActionPolicyAllow);
                return;
            }
            if ([url hasPrefix:@"shareagent://"]) {
                self.codeString = [url substringFromIndex:13];
                [self doShare];
                decisionHandler(WKNavigationActionPolicyAllow);
                return;
            }
        } else {
            NSLog(@"source is not main...%@", url);
        }
    } else {
        NSLog(@"target is not main ... %@", url);
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    NSLog(@"在发送请求之前：%@", navigationAction.request.URL.absoluteString);
}

- (void)doShare {
//    if (!shareView) {
//        shareView = [[fenXiangView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
//        [shareView GetDIc:@{@"id":@"yaoqingzhuanqian",@"url":[NSString stringWithFormat:@"%@/appapi/agent/share?code=%@",h5url,self.codeString]}];
//        [self.view addSubview:shareView];
//    }else{
//        [shareView show];
//    }
}

@end
