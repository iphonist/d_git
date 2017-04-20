//
//  AppDelegate.m
//  DaewoongElectronicApproval
//
//  Created by Ids&Trust on 2014. 12. 3..
//  Copyright (c) 2014년 Ids&Trust. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWebViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0){
        NSLog(@"register over 10");
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else{
        
            NSLog(@"register over 8");
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:
                                                                                 (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    
    
    

    
    return YES;
}


-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    //Called to let your app know which action was selected by the user for a given notification.
    NSLog(@"didReceiveNotificationResponse");
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    
    [self application:[UIApplication sharedApplication] didReceiveRemoteNotification:response.notification.request.content.userInfo];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"ERROR: %@", error);
}


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSMutableString *deviceId = [NSMutableString string];
    const unsigned char* ptr = (const unsigned char*) [deviceToken bytes];
    
    for(int i = 0 ; i < 32 ; i++)
    {
        [deviceId appendFormat:@"%02x", ptr[i]];
    }
    
    NSLog(@"APNS Device Token: %@", deviceId);
    [[NSUserDefaults standardUserDefaults] setValue:deviceId forKey:@"deviceId"];
    
    
    
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //    NSString *string = [NSString stringWithFormat:@"%@", userInfo];
    //
    //    NSLog(@"%@",string);
    
    NSString *message = [userInfo valueForKey:@"message"];
    
NSString *title = @"";
#ifdef Daewoong
    title = NSLocalizedString(@"remote_title_daewoong", @"remote_title_daewoong");
#elif SmartRunner
    title = NSLocalizedString(@"remote_title", @"remote_title");
#endif
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    NSLog(@"didRegisterUserNotificationSettings");
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    NSLog(@"handleActionWithIdentifier userInfo %@",userInfo);
    NSLog(@"identifier %@",identifier); // com.apple.UNNotificationDefaultActionIdentifier
    [self application:application didReceiveRemoteNotification:userInfo];
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
//    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    NSLog(@"applicationDidEnterBackground");

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    NSLog(@"applicationWillEnterForeground");
   }

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    NSLog(@"applicationDidBecomeActive");

//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    NSLog(@"applicationWillTerminate");

}

@end
