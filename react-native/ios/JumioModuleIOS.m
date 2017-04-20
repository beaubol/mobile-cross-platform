//
//  JumioManager.m
//  JumioMobileSDK
//
//  Created by Lukas Koblmüller on 29/03/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "JumioModuleIOS.h"
#import "AppDelegate.h"
@import Netverify;
@import Netswipe;

@interface JumioModuleIOS() <NetverifyViewControllerDelegate, NetswipeViewControllerDelegate>
@property (nonatomic, strong) NetverifyViewController *netverifyViewController;
@property (nonatomic, strong) NetswipeViewController *bamViewController;

@property (nonatomic, strong) NSString *apiTokenNV;
@property (nonatomic, strong) NSString *apiSecretNV;
@property (nonatomic) JumioDataCenter dataCenterNV;
@property (nonatomic, strong) NSString *apiTokenBAM;
@property (nonatomic, strong) NSString *apiSecretBAM;
@property (nonatomic) JumioDataCenter dataCenterBAM;
@end

@implementation JumioModuleIOS

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"EventDocumentData", @"EventCardInfo"];
}

#pragma mark - Netverify

RCT_EXPORT_METHOD(initNetverify:(NSString *)apiToken apiSecret:(NSString *)apiSecret dataCenter:(NSString *)dataCenter) {
    _apiTokenNV = apiToken;
    _apiSecretNV = apiSecret;
    NSString *dataCenterLowercase = [dataCenter lowercaseString];
    _dataCenterNV = ([dataCenterLowercase isEqualToString: @"eu"]) ? JumioDataCenterEU : JumioDataCenterUS;
    
    [self initNetverifySDK];
}

RCT_EXPORT_METHOD(startNetverify) {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController presentViewController: _netverifyViewController animated:YES completion: nil];
}

#pragma mark - BAM Checkout

RCT_EXPORT_METHOD(initBAM:(NSString *)apiToken apiSecret:(NSString *)apiSecret dataCenter:(NSString *)dataCenter) {
    _apiTokenBAM = apiToken;
    _apiSecretBAM = apiSecret;
    NSString *dataCenterLowercase = [dataCenter lowercaseString];
    _dataCenterBAM = ([dataCenterLowercase isEqualToString: @"eu"]) ? JumioDataCenterEU : JumioDataCenterUS;
    
    [self initBAMSDK];
}

RCT_EXPORT_METHOD(startBAM) {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController presentViewController: _bamViewController animated: YES completion: nil];
}

#pragma mark - JumioInit

- (void)initNetverifySDK {
    NetverifyConfiguration *configuration = [NetverifyConfiguration new];
    configuration.delegate = self;
    configuration.merchantApiToken = _apiTokenNV;
    configuration.merchantApiSecret = _apiSecretNV;
    configuration.dataCenter = _dataCenterNV;
    
    //******* optional customization *******
    configuration.preselectedDocumentTypes = NetverifyDocumentTypeAll;
    configuration.requireVerification = NO;
    
    _netverifyViewController = [[NetverifyViewController alloc] initWithConfiguration: configuration];
}

- (void)initBAMSDK {
    NetswipeConfiguration *configuration = [NetswipeConfiguration new];
    configuration.delegate = self;
    configuration.merchantApiToken = _apiTokenBAM;
    configuration.merchantApiSecret = _apiSecretBAM;
    configuration.dataCenter = _dataCenterBAM;
    
    //******* optional customization *******
    configuration.expiryRequired = YES;
    configuration.cvvRequired = YES;
    configuration.cardHolderNameRequired = YES;
    configuration.cardHolderNameEditable = NO;
    configuration.sortCodeAndAccountNumberRequired = NO;
    configuration.cardNumberMaskingEnabled = NO;
    configuration.vibrationEffectEnabled = NO;
    
    _bamViewController = [[NetswipeViewController alloc]initWithConfiguration: configuration];
}

#pragma mark - NetverifySDKDelegate

- (void) netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishWithDocumentData:(NetverifyDocumentData *)documentData scanReference:(NSString *)scanReference {
    NSLog(@"NetverifySDK finished successfully with scan reference: %@", scanReference);
    
    // dismiss and send document data back to react native
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController dismissViewControllerAnimated: YES completion: ^{
        [self sendEventWithName: @"EventDocumentData" body: @{
                                                              @"firstName": documentData.firstName,
                                                              @"lastName": documentData.lastName
                                                              // ...
                                                              }];
    }];
}

- (void) netverifyViewController:(NetverifyViewController *)netverifyViewController didCancelWithError:(NSError *)error scanReference:(NSString *)scanReference {
    NSLog(@"NetverifySDK cancelled with error: %@, scanReference: %@", error.localizedDescription, scanReference);
    
    // send error event
    [self sendError: error];
    
    // dismiss
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishInitializingWithError:(NSError *)error {
    if (error != nil) {
        NSLog(@"NetverifySDK initialized with error: %@", error.localizedDescription);
        
        // send error event
        [self sendError: error];
    }
}

#pragma mark - BAMSDKDelegate

- (void) netswipeViewController:(NetswipeViewController *)controller didFinishScanWithCardInformation:(NetswipeCardInformation *)cardInformation scanReference:(NSString *)scanReference {
    NSLog(@"BAMSDK finished successfully with scan reference: %@", scanReference);
    
    // send data back to react native
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController dismissViewControllerAnimated:YES completion: ^(void) {
        [self sendEventWithName:@"EventCardInfo" body:@{
                                                        @"cardNumberGrouped": cardInformation.cardNumberGrouped,
                                                        @"cardHolderName": cardInformation.cardHolderName
                                                        // ...
                                                        }];
    }];
}

- (void)netswipeViewController:(NetswipeViewController *)controller didCancelWithError:(NSError *)error{
    NSInteger code = error.code;
    NSString *message = error.localizedDescription;
    NSLog(@"Canceled with error code: %ld, message: %@", (long)code, message);
    
    // send error event
    [self sendError: error];
    
    // dismiss
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController dismissViewControllerAnimated: YES completion: nil];
}

- (void)netswipeViewController:(NetswipeViewController *)controller didStartScanAttemptWithRequestReference:(NSString *)requestReference{
    NSLog(@"NetswipeViewController did start scan attempt with request reference: %@", requestReference);
}

- (void)netswipeViewController:(NetswipeViewController *)controller didCancelWithError:(NSError *)error scanReference:(NSString *)scanReference {
    NSLog(@"BAMSDK cancelled with error: %@, scanReference: %@", error.localizedDescription, scanReference);
    
    // send error event
    [self sendError: error];
    
    // dismiss
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Helper Methods

- (void) sendError:(NSError *)error {
    // TODO:...
}

@end
