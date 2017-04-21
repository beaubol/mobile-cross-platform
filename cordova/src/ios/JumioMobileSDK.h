//
//  JumioMobileSDK.h
//
//
//  Created by Lukas Koblmüller on 10/04/2017.
//  Jumio Software Development GmbH
//

#import "Cordova/CDVPlugin.h"
#import <objc/runtime.h>
@import Netverify;
@import Netswipe;

@interface JumioMobileSDK : CDVPlugin <NetverifyViewControllerDelegate, NetswipeViewControllerDelegate>

@property (strong) NetverifyViewController* netverifyViewController;
@property (strong) NetverifyConfiguration* netverifyConfiguration;
@property (strong) NetswipeViewController* bamViewController;
@property (strong) NetswipeConfiguration* bamConfiguration;
@property (strong) NSString* callbackId;
@property (nonatomic, strong) NSString *apiTokenNV;
@property (nonatomic, strong) NSString *apiSecretNV;
@property (nonatomic) JumioDataCenter dataCenterNV;
@property (nonatomic, strong) NSString *apiTokenBAM;
@property (nonatomic, strong) NSString *apiSecretBAM;
@property (nonatomic) JumioDataCenter dataCenterBAM;

@end
