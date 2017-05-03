//
//  JumioMobileSDK.m
//
//
//  Created by Lukas Koblmüller on 10/04/2017.
//  Jumio Software Development GmbH
//

#import "JumioMobileSDK.h"

@implementation JumioMobileSDK

#pragma mark - BAM

- (void)initBAM:(CDVInvokedUrlCommand*)command
{
    NSUInteger argc = [command.arguments count];
    if (argc < 3) {
        [self showSDKError: @"Missing required parameters apiToken, apiSecret or dataCenter."];
        return;
    }
    
    NSString *apiToken = [command.arguments objectAtIndex: 0];
    NSString *apiSecret = [command.arguments objectAtIndex: 1];
    NSString *dataCenterString = [command.arguments objectAtIndex: 2];
    NSString *dataCenterLowercase = [dataCenterString lowercaseString];
    JumioDataCenter dataCenter = ([dataCenterLowercase isEqualToString: @"us"]) ? JumioDataCenterUS : JumioDataCenterEU;
    
    // Initialize the SDK
    _bamConfiguration = [NetswipeConfiguration new];
    _bamConfiguration.delegate = self;
    _bamConfiguration.merchantApiToken = apiToken;
    _bamConfiguration.merchantApiSecret = apiSecret;
    _bamConfiguration.dataCenter = dataCenter;
    
    // Set custom configurations
    NSDictionary *options = [command.arguments objectAtIndex: 3];
    if (![options isEqual: [NSNull null]]) {
        for (NSString *key in options) {
            if ([key isEqualToString: @"cardHolderNameRequired"]) {
                _bamConfiguration.cardHolderNameRequired = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"sortCodeAndAccountNumberRequired"]) {
                _bamConfiguration.sortCodeAndAccountNumberRequired = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"expiryRequired"]) {
                _bamConfiguration.expiryRequired = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"cvvRequired"]) {
                _bamConfiguration.cvvRequired = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"expiryEditable"]) {
                _bamConfiguration.expiryEditable = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"cardHolderNameEditable"]) {
                _bamConfiguration.cardHolderNameEditable = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"merchantReportingCriteria"]) {
                _bamConfiguration.merchantReportingCriteria = [options objectForKey: key];
            } else if ([key isEqualToString: @"vibrationEffectEnabled"]) {
                _bamConfiguration.vibrationEffectEnabled = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"enableFlashOnScanStart"]) {
                _bamConfiguration.enableFlashOnScanStart = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"cardNumberMaskingEnabled"]) {
                _bamConfiguration.cardNumberMaskingEnabled = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"adyenPublicKey"]) {
                _bamConfiguration.adyenPublicKey = [options objectForKey: key];
            } else if ([key isEqualToString: @"offlineToken"]) {
                _bamConfiguration.offlineToken = [options objectForKey: key];
            } else if ([key isEqualToString: @"cameraPosition"]) {
                NSString *cameraString = [[options objectForKey: key] lowercaseString];
                JumioCameraPosition cameraPosition = ([cameraString isEqualToString: @"front"]) ? JumioCameraPositionFront : JumioCameraPositionBack;
                _bamConfiguration.cameraPosition = cameraPosition;
            } else if ([key isEqualToString: @"cardTypes"]) {
                NSMutableArray *jsonTypes = [options objectForKey: key];
                NetswipeCreditCardTypes cardTypes;
                
                int i;
                for (i = 0; i < [jsonTypes count]; i++) {
                    id type = [jsonTypes objectAtIndex: i];
                    
                    if ([[type lowercaseString] isEqualToString: @"visa"]) {
                        cardTypes = cardTypes | NetswipeCreditCardTypeVisa;
                    } else if ([[type lowercaseString] isEqualToString: @"master_card"]) {
                        cardTypes = cardTypes | NetswipeCreditCardTypeMasterCard;
                    } else if ([[type lowercaseString] isEqualToString: @"american_express"]) {
                        cardTypes = cardTypes | NetswipeCreditCardTypeAmericanExpress;
                    } else if ([[type lowercaseString] isEqualToString: @"china_unionpay"]) {
                        cardTypes = cardTypes | NetswipeCreditCardTypeChinaUnionPay;
                    } else if ([[type lowercaseString] isEqualToString: @"diners_club"]) {
                        cardTypes = cardTypes | NetswipeCreditCardTypeDiners;
                    } else if ([[type lowercaseString] isEqualToString: @"discover"]) {
                        cardTypes = cardTypes | NetswipeCreditCardTypeDiscover;
                    } else if ([[type lowercaseString] isEqualToString: @"jcb"]) {
                        cardTypes = cardTypes | NetswipeCreditCardTypeJCB;
                    } else if ([[type lowercaseString] isEqualToString: @"starbucks"]) {
                        cardTypes = cardTypes | NetswipeCreditCardTypeStarbucks;
                    }
                }
                
                _bamConfiguration.supportedCreditCardTypes = cardTypes;
            }
        }
    }
    
    _bamViewController = [[NetswipeViewController alloc] initWithConfiguration: _bamConfiguration];
}

- (void)startBAM:(CDVInvokedUrlCommand*)command
{
    if (_bamViewController == nil) {
        [self showSDKError: @"The BAM SDK is not initialized yet. Call initBAM() first."];
        return;
    }
    
    _callbackId = command.callbackId;
    [self.viewController presentViewController: _bamViewController animated: YES completion: nil];
}

#pragma mark - Netverify

- (void)initNetverify:(CDVInvokedUrlCommand*)command
{
    NSUInteger argc = [command.arguments count];
    if (argc < 3) {
        [self showSDKError: @"Missing required parameters apiToken, apiSecret or dataCenter."];
        return;
    }
    
    NSString *apiToken = [command.arguments objectAtIndex: 0];
    NSString *apiSecret = [command.arguments objectAtIndex: 1];
    NSString *dataCenterString = [command.arguments objectAtIndex: 2];
    NSString *dataCenterLowercase = [dataCenterString lowercaseString];
    JumioDataCenter dataCenter = ([dataCenterLowercase isEqualToString: @"us"]) ? JumioDataCenterUS : JumioDataCenterEU;
    
    // Initialize the SDK
    _netverifyConfiguration = [NetverifyConfiguration new];
    _netverifyConfiguration.delegate = self;
    _netverifyConfiguration.merchantApiToken = apiToken;
    _netverifyConfiguration.merchantApiSecret = apiSecret;
    _netverifyConfiguration.dataCenter = dataCenter;
    
    // Set custom configurations
    NSDictionary *options = [command.arguments objectAtIndex: 3];
    if (![options isEqual:[NSNull null]]) {
        for (NSString *key in options) {
            if ([key isEqualToString: @"requireVerification"]) {
                _netverifyConfiguration.requireVerification = [options objectForKey: key];
            } else if ([key isEqualToString: @"callbackUrl"]) {
                _netverifyConfiguration.callbackUrl = [options objectForKey: key];
            } else if ([key isEqualToString: @"requireFaceMatch"]) {
                _netverifyConfiguration.requireFaceMatch = [options objectForKey: key];
            } else if ([key isEqualToString: @"preselectedCountry"]) {
                _netverifyConfiguration.preselectedCountry = [options objectForKey: key];
            } else if ([key isEqualToString: @"merchantScanReference"]) {
                _netverifyConfiguration.merchantScanReference = [options objectForKey: key];
            } else if ([key isEqualToString: @"merchantReportingCriteria"]) {
                _netverifyConfiguration.merchantReportingCriteria = [options objectForKey: key];
            } else if ([key isEqualToString: @"customerId"]) {
                _netverifyConfiguration.customerId = [options objectForKey: key];
            } else if ([key isEqualToString: @"additionalInformation"]) {
                _netverifyConfiguration.additionalInformation = [options objectForKey: key];
            } else if ([key isEqualToString: @"sendDebugInfoToJumio"]) {
                _netverifyConfiguration.sendDebugInfoToJumio = [options objectForKey: key];
            } else if ([key isEqualToString: @"dataExtractionOnMobileOnly"]) {
                _netverifyConfiguration.dataExtractionOnMobileOnly = [options objectForKey: key];
            } else if ([key isEqualToString: @"cameraPosition"]) {
                NSString *cameraString = [[options objectForKey: key] lowercaseString];
                JumioCameraPosition cameraPosition = ([cameraString isEqualToString: @"front"]) ? JumioCameraPositionFront : JumioCameraPositionBack;
                _netverifyConfiguration.cameraPosition = cameraPosition;
            } else if ([key isEqualToString: @"preselectedDocumentVariant"]) {
                NSString *variantString = [[options objectForKey: key] lowercaseString];
                NetverifyDocumentVariant variant = ([variantString isEqualToString: @"paper"]) ? NetverifyDocumentVariantPaper : NetverifyDocumentVariantPlastic;
                _netverifyConfiguration.preselectedDocumentVariant = variant;
            } else if ([key isEqualToString: @"documentTypes"]) {
                NSMutableArray *jsonTypes = [options objectForKey: key];
                NetverifyDocumentType documentTypes;
                
                int i;
                for (i = 0; i < [jsonTypes count]; i++) {
                    id type = [jsonTypes objectAtIndex: i];
                    
                    if ([[type lowercaseString] isEqualToString: @"passport"]) {
                        documentTypes = documentTypes | NetverifyDocumentTypePassport;
                    } else if ([[type lowercaseString] isEqualToString: @"driver_license"]) {
                        documentTypes = documentTypes | NetverifyDocumentTypeDriverLicense;
                    } else if ([[type lowercaseString] isEqualToString: @"identity_card"]) {
                        documentTypes = documentTypes | NetverifyDocumentTypeIdentityCard;
                    } else if ([[type lowercaseString] isEqualToString: @"visa"]) {
                        documentTypes = documentTypes | NetverifyDocumentTypeVisa;
                    }
                }
                
                _netverifyConfiguration.preselectedDocumentTypes = documentTypes;
            }
        }
    }
    
    _netverifyViewController = [[NetverifyViewController alloc] initWithConfiguration: _netverifyConfiguration];
}

- (void)startNetverify:(CDVInvokedUrlCommand*)command
{
    if (_netverifyViewController == nil) {
        [self showSDKError: @"The Netverify SDK is not initialized yet. Call initNetverify() first."];
        return;
    }
    
    _callbackId = command.callbackId;
    [self.viewController presentViewController: _netverifyViewController animated: YES completion: nil];
}

#pragma mark - Document Verification

- (void)initDocumentVerification:(CDVInvokedUrlCommand*)command
{
    NSUInteger argc = [command.arguments count];
    if (argc < 3) {
        [self showSDKError: @"Missing required parameters apiToken, apiSecret or dataCenter."];
        return;
    }
    
    NSString *apiToken = [command.arguments objectAtIndex: 0];
    NSString *apiSecret = [command.arguments objectAtIndex: 1];
    NSString *dataCenterString = [command.arguments objectAtIndex: 2];
    NSString *dataCenterLowercase = [dataCenterString lowercaseString];
    JumioDataCenter dataCenter = ([dataCenterLowercase isEqualToString: @"us"]) ? JumioDataCenterUS : JumioDataCenterEU;
    
    // Initialize the SDK
    _documentVerifcationConfiguration = [MultiDocumentConfiguration new];
    _documentVerifcationConfiguration.delegate = self;
    _documentVerifcationConfiguration.merchantApiToken = apiToken;
    _documentVerifcationConfiguration.merchantApiSecret = apiSecret;
    _documentVerifcationConfiguration.dataCenter = dataCenter;
    
    // Set custom configurations
    NSDictionary *options = [command.arguments objectAtIndex: 3];
    if (![options isEqual:[NSNull null]]) {
        for (NSString *key in options) {
            if ([key isEqualToString: @"type"]) {
                _documentVerifcationConfiguration.type = [options objectForKey: key];
            } else if ([key isEqualToString: @"customDocumentCode"]) {
                _documentVerifcationConfiguration.customDocumentCode = [options objectForKey: key];
            } else if ([key isEqualToString: @"country"]) {
                _documentVerifcationConfiguration.country = [options objectForKey: key];
            } else if ([key isEqualToString: @"merchantReportingCriteria"]) {
                _documentVerifcationConfiguration.merchantReportingCriteria = [options objectForKey: key];
            } else if ([key isEqualToString: @"callbackUrl"]) {
                _documentVerifcationConfiguration.callbackUrl = [options objectForKey: key];
            } else if ([key isEqualToString: @"additionalInformation"]) {
                _documentVerifcationConfiguration.additionalInformation = [options objectForKey: key];
            } else if ([key isEqualToString: @"merchantScanReference"]) {
                _documentVerifcationConfiguration.merchantScanReference = [options objectForKey: key];
            } else if ([key isEqualToString: @"customerId"]) {
                _documentVerifcationConfiguration.customerId = [options objectForKey: key];
            } else if ([key isEqualToString: @"documentName"]) {
                _documentVerifcationConfiguration.documentName = [options objectForKey: key];
            } else if ([key isEqualToString: @"cameraPosition"]) {
                NSString *cameraString = [[options objectForKey: key] lowercaseString];
                JumioCameraPosition cameraPosition = ([cameraString isEqualToString: @"front"]) ? JumioCameraPositionFront : JumioCameraPositionBack;
                _documentVerifcationConfiguration.cameraPosition = cameraPosition;
            }
        }
    }
    
    _documentVerificationViewController = [[MultiDocumentViewController alloc] initWithConfiguration: _documentVerifcationConfiguration];
}

- (void)startDocumentVerification:(CDVInvokedUrlCommand*)command
{
    if (_documentVerificationViewController == nil) {
        [self showSDKError: @"The Document-Verification SDK is not initialized yet. Call initDocumentVerification() first."];
        return;
    }
    
    _callbackId = command.callbackId;
    [self.viewController presentViewController: _documentVerificationViewController animated: YES completion: nil];
}


#pragma mark - BAM Delegates

- (void) netswipeViewController:(NetswipeViewController *)controller didFinishScanWithCardInformation:(NetswipeCardInformation *)cardInformation scanReference:(NSString *)scanReference {
    // Build Result Object
    NSDictionary *result = [[NSMutableDictionary alloc] init];
    
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
    
    [result setValue: cardInformation.cardNumber forKey: @"cardNumber"];
    [result setValue: cardInformation.cardNumberGrouped forKey: @"cardNumberGrouped"];
    [result setValue: cardInformation.cardNumberMasked forKey: @"cardNumberMasked"];
    [result setValue: cardInformation.cardExpiryMonth forKey: @"cardExpiryMonth"];
    [result setValue: cardInformation.cardExpiryYear forKey: @"cardExpiryYear"];
    [result setValue: cardInformation.cardExpiryDate forKey: @"cardExpiryDate"];
    [result setValue: cardInformation.cardCVV forKey: @"cardCVV"];
    [result setValue: cardInformation.cardHolderName forKey: @"cardHolderName"];
    [result setValue: cardInformation.cardSortCode forKey: @"cardSortCode"];
    [result setValue: cardInformation.cardAccountNumber forKey: @"cardAccountNumber"];
    [result setValue: [NSNumber numberWithBool: cardInformation.cardSortCodeValid] forKey: @"cardSortCodeValid"];
    [result setValue: [NSNumber numberWithBool: cardInformation.cardAccountNumberValid] forKey: @"cardAccountNumberValid"];
    [result setValue: cardInformation.encryptedAdyenString forKey: @"encryptedAdyenString"];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (void) netswipeViewController:(NetswipeViewController *)controller didCancelWithError:(NSError *)error scanReference:(NSString *)scanReference {
    NSString *msg = [NSString stringWithFormat: @"Cancelled with error code %ld: %@", (long)error.code, error.localizedDescription];
    [self showSDKError: msg];
}

#pragma mark - Netverify Delegates

- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishWithDocumentData:(NetverifyDocumentData *)documentData scanReference:(NSString *)scanReference {
    // Build Result Object
    NSDictionary *result = [[NSMutableDictionary alloc] init];
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
        NSDictionary *mrzData = [[NSMutableDictionary alloc] init];
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
    
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishInitializingWithError:(NSError *)error {
    if (error != nil) {
        NSString *msg = [NSString stringWithFormat: @"Cancelled with error code %ld: %@", (long)error.code, error.localizedDescription];
        [self showSDKError: msg];
    }
}

- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didCancelWithError:(NSError *)error scanReference:(NSString *)scanReference {
    NSString *msg = [NSString stringWithFormat: @"Cancelled with error code %ld: %@", (long)error.code, error.localizedDescription];
    [self showSDKError: msg];
}

#pragma mark - Document Verification Delegates

- (void) multiDocumentViewController:(MultiDocumentViewController *)multiDocumentViewController didFinishWithScanReference:(NSString *)scanReference {
    NSString *msg = @"Document-Verification finished successfully.";
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: msg];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (void) multiDocumentViewController:(MultiDocumentViewController *)multiDocumentViewController didFinishWithError:(NSError *)error {
    NSString *msg = [NSString stringWithFormat: @"Cancelled with error code %ld: %@", (long)error.code, error.localizedDescription];
    [self showSDKError: msg];
}


#pragma mark - Helper methods

- (void)showSDKError:(NSString *)msg {
    NSLog(@"%@", msg);
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: msg];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (BOOL) getBoolValue:(NSObject *)value {
    if (value && [value isKindOfClass: [NSNumber class]]) {
        return [((NSNumber *)value) boolValue];
    }
    return value;
}

@end
