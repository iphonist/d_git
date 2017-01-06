//
//  LoginViewController.h
//  DaewoongElectronicApproval
//
//  Created by Ids&Trust on 2014. 12. 3..
//  Copyright (c) 2014년 Ids&Trust. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "Base64.h"


@interface LoginViewController : UIViewController{
     UIActivityIndicatorView *activityIndicator;
}
@property (weak, nonatomic) IBOutlet UITextField *id_TextField;
@property (weak, nonatomic) IBOutlet UITextField *pw_TextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;





@end
