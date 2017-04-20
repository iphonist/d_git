//
//  AppDelegate.h
//  DaewoongElectronicApproval
//
//  Created by Ids&Trust on 2014. 12. 3..
//  Copyright (c) 2014년 Ids&Trust. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MainWebViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>
{
    LoginViewController *loginViewController;
    MainWebViewController *mainWebViewController;
}

@property (strong, nonatomic) UIWindow *window;


@end

