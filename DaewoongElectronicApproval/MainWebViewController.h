//
//  MainWebViewController.h
//  DaewoongElectronicApproval
//
//  Created by Ids&Trust on 2014. 12. 4..
//  Copyright (c) 2014년 Ids&Trust. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "Base64.h"

@interface MainWebViewController : UIViewController<UIWebViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;



@property (strong, nonatomic) NSString *token;

@end
