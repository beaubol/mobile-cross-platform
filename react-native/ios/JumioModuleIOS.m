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

@interface JumioModuleIOS() <NetverifyViewControllerDelegate, NetswipeViewControllerDelegate, MultiDocumentViewControllerDelegate>

@property (nonatomic, strong) NetverifyViewController *netverifyViewController;
@property (nonatomic, strong) NetswipeViewController *bamViewController;
@property (nonatomic, strong) MultiDocumentViewController *documentVerificationViewController;

@end

@implementation JumioModuleIOS

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"EventError", @"EventDocumentData", @"EventCardInfo", @"EventDocumentVerification"];
}

#pragma mark - BAM Checkout

RCT_EXPORT_METHOD(initBAM:(NSString *)apiToken apiSecret:(NSString *)apiSecret dataCenter:(NSString *)dataCenter) {
    if ([apiToken length] == 0 || [apiSecret length] == 0 || [dataCenter length] == 0) {
        [self sendError: @"Missing required parameters apiToken, apiSecret or dataCenter"];
        return;
    }
    
    NetswipeConfiguration *configuration = [NetswipeConfiguration new];
    configuration.delegate = self;
    configuration.merchantApiToken = apiToken;
    configuration.merchantApiSecret = apiSecret;
    NSString *dataCenterLowercase = [dataCenter lowercaseString];
    configuration.dataCenter = ([dataCenterLowercase isEqualToString: @"eu"]) ? JumioDataCenterEU : JumioDataCenterUS;
    
    //******* optional customization *******
    configuration.expiryRequired = YES;
    configuration.cvvRequired = YES;
    // ...
    
    _bamViewController = [[NetswipeViewController alloc]initWithConfiguration: configuration];
}

RCT_EXPORT_METHOD(startBAM) {
    if (_bamViewController == nil) {
        NSLog(@"The BAM SDK is not initialized yet. Call initBAM() first.");
        return;
    }
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController presentViewController: _bamViewController animated: YES completion: nil];
}

#pragma mark - Netverify + Fastfill

RCT_EXPORT_METHOD(initNetverify:(NSString *)apiToken apiSecret:(NSString *)apiSecret dataCenter:(NSString *)dataCenter) {
    if ([apiToken length] == 0 || [apiSecret length] == 0 || [dataCenter length] == 0) {
        [self sendError: @"Missing required parameters apiToken, apiSecret or dataCenter"];
        return;
    }
    
    NetverifyConfiguration *configuration = [NetverifyConfiguration new];
    configuration.delegate = self;
    configuration.merchantApiToken = apiToken;
    configuration.merchantApiSecret = apiSecret;
    NSString *dataCenterLowercase = [dataCenter lowercaseString];
    configuration.dataCenter = ([dataCenterLowercase isEqualToString: @"eu"]) ? JumioDataCenterEU : JumioDataCenterUS;
    
    //******* optional customization *******
    configuration.preselectedDocumentTypes = NetverifyDocumentTypeAll;
    configuration.requireVerification = NO;
    // ...
    
    _netverifyViewController = [[NetverifyViewController alloc] initWithConfiguration: configuration];
}

RCT_EXPORT_METHOD(startNetverify) {
    if (_netverifyViewController == nil) {
        NSLog(@"The Netverify SDK is not initialized yet. Call initNetverify() first.");
        return;
    }
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController presentViewController: _netverifyViewController animated:YES completion: nil];
}

#pragma mark - Document Verification

RCT_EXPORT_METHOD(initDocumentVerification:(NSString *)apiToken apiSecret:(NSString *)apiSecret dataCenter:(NSString *)dataCenter) {
    if ([apiToken length] == 0 || [apiSecret length] == 0 || [dataCenter length] == 0) {
        [self sendError: @"Missing required parameters apiToken, apiSecret or dataCenter"];
        return;
    }
    
    MultiDocumentConfiguration *configuration = [MultiDocumentConfiguration new];
    configuration.delegate = self;
    configuration.merchantApiToken = apiToken;
    configuration.merchantApiSecret = apiSecret;
    NSString *dataCenterLowercase = [dataCenter lowercaseString];
    configuration.dataCenter = ([dataCenterLowercase isEqualToString: @"eu"]) ? JumioDataCenterEU : JumioDataCenterUS;
    
    //******* mandatory customization *******
    configuration.type = @"BS";
    configuration.country = @"AUT";
    configuration.customerId = @"123456789";
    configuration.merchantScanReference = @"123456789";
    
    //******* optional customization *******
    configuration.cameraPosition = JumioCameraPositionBack;
    // ...
    
    _documentVerificationViewController = [[MultiDocumentViewController alloc]initWithConfiguration: configuration];
}

RCT_EXPORT_METHOD(startDocumentVerification) {
    if (_documentVerificationViewController == nil) {
        NSLog(@"The Document-Verification SDK is not initialized yet. Call initDocumentVerification() first.");
        return;
    }
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController presentViewController: _documentVerificationViewController animated: YES completion: nil];
}

#pragma mark - BAMSDKDelegate

- (void) netswipeViewController:(NetswipeViewController *)controller didFinishScanWithCardInformation:(NetswipeCardInformation *)cardInformation scanReference:(NSString *)scanReference {
    // Build result object
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    if (cardInformation.cardType == NetswipeCreditCardTypeVisa) {
        [result setValue: @"VISA" forKey: @"cardType"];
    } else if (cardInformation.cardType == NetswipeCreditCardTypeMasterCard) {
        [result setValue: @"MASTER_CARD" forKey: @"cardType"];
    } else if (cardInformation.cardType == NetswipeCreditCardTypeAmericanExpress) {
        [result setValue: @"AMERICAN_EXPRESS" forKey: @"cardType"];
    } else if (cardInformation.cardType == NetswipeCreditCardTypeChinaUnionPay) {
        [result setValue: @"CHINA_UNIONPAY" forKey: @"cardType"];
    } else if (cardInformation.cardType == NetswipeCreditCardTypeDiners) {
        [result setValue: @"DINERS_CLUB" forKey: @"cardType"];
    } else if (cardInformation.cardType == NetswipeCreditCardTypeDiscover) {
        [result setValue: @"DISCOVER" forKey: @"cardType"];
    } else if (cardInformation.cardType == NetswipeCreditCardTypeJCB) {
        [result setValue: @"JCB" forKey: @"cardType"];
    } else if (cardInformation.cardType == NetswipeCreditCardTypeStarbucks) {
        [result setValue: @"STARBUCKS" forKey: @"cardType"];
    }
    
    [result setValue: [cardInformation.cardNumber copy] forKey: @"cardNumber"];
    [result setValue: [cardInformation.cardNumberGrouped copy] forKey: @"cardNumberGrouped"];
    [result setValue: [cardInformation.cardNumberMasked copy] forKey: @"cardNumberMasked"];
    [result setValue: [cardInformation.cardExpiryMonth copy] forKey: @"cardExpiryMonth"];
    [result setValue: [cardInformation.cardExpiryYear copy] forKey: @"cardExpiryYear"];
    [result setValue: [cardInformation.cardExpiryDate copy] forKey: @"cardExpiryDate"];
    [result setValue: [cardInformation.cardCVV copy] forKey: @"cardCVV"];
    [result setValue: [cardInformation.cardHolderName copy] forKey: @"cardHolderName"];
    [result setValue: [cardInformation.cardSortCode copy] forKey: @"cardSortCode"];
    [result setValue: [cardInformation.cardAccountNumber copy] forKey: @"cardAccountNumber"];
    [result setValue: [NSNumber numberWithBool: cardInformation.cardSortCodeValid] forKey: @"cardSortCodeValid"];
    [result setValue: [NSNumber numberWithBool: cardInformation.cardAccountNumberValid] forKey: @"cardAccountNumberValid"];
    [result setValue: cardInformation.encryptedAdyenString forKey: @"encryptedAdyenString"];
    
    // send data back to react native
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController dismissViewControllerAnimated: YES completion: ^{
        [self sendEventWithName: @"EventCardInfo" body: result];
    }];
}

- (void)netswipeViewController:(NetswipeViewController *)controller didCancelWithError:(NSError *)error{
    [self sendError: [self getErrorMessage: error]];
}

- (void)netswipeViewController:(NetswipeViewController *)controller didStartScanAttemptWithRequestReference:(NSString *)requestReference{
    NSLog(@"NetswipeViewController did start scan attempt with request reference: %@", requestReference);
}

- (void)netswipeViewController:(NetswipeViewController *)controller didCancelWithError:(NSError *)error scanReference:(NSString *)scanReference {
    [self sendError: [self getErrorMessage: error]];
}

#pragma mark - NetverifySDKDelegate

- (void) netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishWithDocumentData:(NetverifyDocumentData *)documentData scanReference:(NSString *)scanReference {
    // Build Result Object
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    
    [result setValue: documentData.selectedCountry forKey: @"selectedCountry"];
    if (documentData.selectedDocumentType == NetverifyDocumentTypePassport) {
        [result setValue: @"PASSPORT" forKey: @"selectedDocumentType"];
    } else if (documentData.selectedDocumentType == NetverifyDocumentTypeDriverLicense) {
        [result setValue: @"DRIVER_LICENSE" forKey: @"selectedDocumentType"];
    } else if (documentData.selectedDocumentType == NetverifyDocumentTypeIdentityCard) {
        [result setValue: @"IDENTITY_CARD" forKey: @"selectedDocumentType"];
    } else if (documentData.selectedDocumentType == NetverifyDocumentTypeVisa) {
        [result setValue: @"VISA" forKey: @"selectedDocumentType"];
    }
    [result setValue: documentData.idNumber forKey: @"idNumber"];
    [result setValue: documentData.personalNumber forKey: @"personalNumber"];
    [result setValue: [formatter stringFromDate: documentData.issuingDate] forKey: @"issuingDate"];
    [result setValue: [formatter stringFromDate: documentData.expiryDate] forKey: @"expiryDate"];
    [result setValue: documentData.issuingCountry forKey: @"issuingCountry"];
    [result setValue: documentData.lastName forKey: @"lastName"];
    [result setValue: documentData.firstName forKey: @"firstName"];
    [result setValue: documentData.middleName forKey: @"middleName"];
    [result setValue: [formatter stringFromDate: documentData.dob] forKey: @"dob"];
    if (documentData.gender == NetverifyGenderM) {
        [result setValue: @"m" forKey: @"gender"];
    } else if (documentData.gender == NetverifyGenderF) {
        [result setValue: @"f" forKey: @"gender"];
    }
    [result setValue: documentData.originatingCountry forKey: @"originatingCountry"];
    [result setValue: documentData.addressLine forKey: @"addressLine"];
    [result setValue: documentData.city forKey: @"city"];
    [result setValue: documentData.subdivision forKey: @"subdivision"];
    [result setValue: documentData.postCode forKey: @"postCode"];
    [result setValue: documentData.optionalData1 forKey: @"optionalData1"];
    [result setValue: documentData.optionalData2 forKey: @"optionalData2"];
    if (documentData.extractionMethod == NetverifyExtractionMethodMRZ) {
        [result setValue: @"MRZ" forKey: @"extractionMethod"];
    } else if (documentData.extractionMethod == NetverifyExtractionMethodOCR) {
        [result setValue: @"OCR" forKey: @"extractionMethod"];
    } else if (documentData.extractionMethod == NetverifyExtractionMethodBarcode) {
        [result setValue: @"BARCODE" forKey: @"extractionMethod"];
    } else if (documentData.extractionMethod == NetverifyExtractionMethodBarcodeOCR) {
        [result setValue: @"BARCODE_OCR" forKey: @"extractionMethod"];
    } else if (documentData.extractionMethod == NetverifyExtractionMethodNone) {
        [result setValue: @"NONE" forKey: @"extractionMethod"];
    }
    
    // MRZ data if available
    if (documentData.mrzData != nil) {
        NSMutableDictionary *mrzData = [[NSMutableDictionary alloc] init];
        if (documentData.mrzData.format == NetverifyMRZFormatMRP) {
            [mrzData setValue: @"MRP" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatTD1) {
            [mrzData setValue: @"TD1" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatTD2) {
            [mrzData setValue: @"TD2" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatCNIS) {
            [mrzData setValue: @"CNIS" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatMRVA) {
            [mrzData setValue: @"MRVA" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatMRVB) {
            [mrzData setValue: @"MRVB" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatUnknown) {
            [mrzData setValue: @"UNKNOWN" forKey: @"format"];
        }
        
        [mrzData setValue: documentData.mrzData.line1 forKey: @"line1"];
        [mrzData setValue: documentData.mrzData.line2 forKey: @"line2"];
        [mrzData setValue: documentData.mrzData.line3 forKey: @"line3"];
        [mrzData setValue: [NSNumber numberWithBool: documentData.mrzData.idNumberValid] forKey: @"idNumberValid"];
        [mrzData setValue: [NSNumber numberWithBool: documentData.mrzData.dobValid] forKey: @"dobValid"];
        [mrzData setValue: [NSNumber numberWithBool: documentData.mrzData.expiryDateValid] forKey: @"expiryDateValid"];
        [mrzData setValue: [NSNumber numberWithBool: documentData.mrzData.personalNumberValid] forKey: @"personalNumberValid"];
        [mrzData setValue: [NSNumber numberWithBool: documentData.mrzData.compositeValid] forKey: @"compositeValid"];
        [result setValue: mrzData forKey: @"mrzData"];
    }
    
    // dismiss and send document data back to react native
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController dismissViewControllerAnimated: YES completion: ^{
        [self sendEventWithName: @"EventDocumentData" body: result];
    }];
}

- (void) netverifyViewController:(NetverifyViewController *)netverifyViewController didCancelWithError:(NSError *)error scanReference:(NSString *)scanReference {
    [self sendError: [self getErrorMessage: error]];
}

- (void) netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishInitializingWithError:(NSError *)error {
    if (error != nil) {
        [self sendError: [self getErrorMessage: error]];
    }
}

#pragma mark - Document Verification Delegates

- (void)multiDocumentViewController:(MultiDocumentViewController *)multiDocumentViewController didFinishWithScanReference:(NSString *)scanReference {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController dismissViewControllerAnimated: YES completion: ^{
        [self sendEventWithName: @"EventDocumentVerification" body: @"Document Verification finished successfully."];
    }];
}

- (void)multiDocumentViewController:(MultiDocumentViewController *)multiDocumentViewController didFinishWithError:(NSError *)error {
    [self sendError: [self getErrorMessage: error]];
}

# pragma mark - Helper Methods

- (void) sendError:(NSString *)error {
    // send error event
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController dismissViewControllerAnimated: YES completion: ^{
        [self sendEventWithName: @"EventError" body: error];
    }];
}

- (NSString *) getErrorMessage:(NSError *)error {
    return [NSString stringWithFormat: @"Cancelled with error code: %ld, message: %@", (long)error.code, error.localizedDescription];
}

@end
