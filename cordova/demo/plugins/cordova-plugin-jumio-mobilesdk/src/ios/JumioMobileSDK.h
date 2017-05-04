//
//  JumioMobileSDK.h
//
//
//  Created by Lukas Koblmüller on 10/04/2017.
//  Jumio Software Development GmbH
//

#import "Cordova/CDVPlugin.h"
@import Netverify;
@import Netswipe;

@interface JumioMobileSDK : CDVPlugin <NetverifyViewControllerDelegate, NetswipeViewControllerDelegate, MultiDocumentViewControllerDelegate>

@property (strong) NetverifyViewController* netverifyViewController;
@property (strong) NetverifyConfiguration* netverifyConfiguration;
@property (strong) NetswipeViewController* bamViewController;
@property (strong) NetswipeConfiguration* bamConfiguration;
@property (strong) MultiDocumentConfiguration* documentVerifcationConfiguration;
@property (strong) MultiDocumentViewController* documentVerificationViewController;
@property (strong) NSString* callbackId;

@end
