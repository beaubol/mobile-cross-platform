//
//  JumioMobileSDK.m
//
//
//  Created by Lukas Koblmüller on 10/04/2017.
//  Jumio Software Development GmbH
//

#import "JumioMobileSDK.h"

@implementation JumioMobileSDK

#pragma mark - Netverify

- (void)initNetverify:(CDVInvokedUrlCommand*)command
{
    if (_netverifyViewController != nil) {
        NSLog(@"Jumio Netverify was already initialized.");
        return;
    }
    
    NSUInteger argc = [command.arguments count];
    if (argc < 3) {
        NSLog(@"Missing required parameters apiToken, apiSecret and dataCenter.");
        return;
    }
    
    _apiTokenNV = [command.arguments objectAtIndex: 0];
    _apiSecretNV = [command.arguments objectAtIndex: 1];
    NSString *dataCenter = [command.arguments objectAtIndex: 2];
    NSString *dataCenterLowercase = [dataCenter lowercaseString];
    _dataCenterNV = ([dataCenterLowercase isEqualToString:@"us"]) ? JumioDataCenterUS : JumioDataCenterEU;
    
    // Initialize the SDK
    _netverifyConfiguration = [NetverifyConfiguration new];
    _netverifyConfiguration.delegate = self;
    _netverifyConfiguration.merchantApiToken = _apiTokenNV;
    _netverifyConfiguration.merchantApiSecret = _apiSecretNV;
    _netverifyConfiguration.dataCenter = _dataCenterNV;
    
    // Set custom configurations
    NSDictionary *options = [command.arguments objectAtIndex: 3];
    if (![options isEqual:[NSNull null]]) {
        [self setOptions: options];
    }
    
    _netverifyViewController = [[NetverifyViewController alloc] initWithConfiguration: _netverifyConfiguration];
}

- (void)startNetverify:(CDVInvokedUrlCommand*)command
{
    if (_netverifyViewController == nil) {
        NSString *error = @"Jumio Netverify is not initialized yet. Call initNetverify() first.";
        NSLog(@"%@", error);
        return;
    }
    
    _callbackId = command.callbackId;
    [self.viewController presentViewController: _netverifyViewController animated: YES completion: nil];
}

#pragma mark - BAM

- (void)initBAM:(CDVInvokedUrlCommand*)command
{
    if (_bamViewController != nil) {
        NSLog(@"Jumio BAM was already initialized.");
        return;
    }
    
    NSUInteger argc = [command.arguments count];
    if (argc < 3) {
        NSLog(@"Missing required parameters apiToken, apiSecret and dataCenter.");
        return;
    }
    
    _apiTokenBAM = [command.arguments objectAtIndex: 0];
    _apiSecretBAM = [command.arguments objectAtIndex: 1];
    NSString *dataCenter = [command.arguments objectAtIndex: 2];
    NSString *dataCenterLowercase = [dataCenter lowercaseString];
    _dataCenterBAM = ([dataCenterLowercase isEqualToString:@"us"]) ? JumioDataCenterUS : JumioDataCenterEU;
    
    // Initialize the SDK
    _bamConfiguration = [NetswipeConfiguration new];
    _bamConfiguration.delegate = self;
    _bamConfiguration.merchantApiToken = _apiTokenBAM;
    _bamConfiguration.merchantApiSecret = _apiSecretBAM;
    _bamConfiguration.dataCenter = _dataCenterBAM;
    
    // Set custom configurations
    NSDictionary *options = [command.arguments objectAtIndex: 3];
    if (![options isEqual: [NSNull null]]) {
        [self setOptions: options];
    }
    
    _bamViewController = [[NetswipeViewController alloc] initWithConfiguration: _bamConfiguration];
}

- (void)startBAM:(CDVInvokedUrlCommand*)command
{
    if (_bamViewController == nil) {
        NSString *error = @"Jumio BAM is not initialized yet. Call initBAM() first.";
        NSLog(@"%@", error);
        return;
    }
    
    _callbackId = command.callbackId;
    [self.viewController presentViewController: _bamViewController animated: YES completion: nil];
}

#pragma mark - Netverify Delegates

- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishWithDocumentData:(NetverifyDocumentData *)documentData scanReference:(NSString *)scanReference {
    NSLog(@"Successfully finished Netverify scan with DocumentData");
    
    // Build Result Object
    NSMutableDictionary *result = [self dictionaryWithPropertiesOfObject: documentData];
    
    // Include all special netverify objects
    [result setObject: [NSString stringWithFormat: @"%u", documentData.gender] forKey: @"gender"];
    [result setObject: [NSString stringWithFormat: @"%u", documentData.selectedDocumentType] forKey: @"selectedDocumentType"];
    
    // Send back result to javascript
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishInitializingWithError:(NSError *)error {
    if (error != nil) {
        [self showSDKError: error];
    }
}

- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didCancelWithError:(NSError *)error scanReference:(NSString *)scanReference {
    [self showSDKError: error];
}


#pragma mark - BAM Delegates

- (void) netswipeViewController:(NetswipeViewController *)controller didFinishScanWithCardInformation:(NetswipeCardInformation *)cardInformation scanReference:(NSString *)scanReference {
    NSLog(@"Successfully finished BAM scan with CardInformation");
    
    // Build Result Object
    NSMutableDictionary *result = [self dictionaryWithPropertiesOfObject: cardInformation];
    
    // Include all special bam objects
    // ...
    
    // Send back result to javascript
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (void) netswipeViewController:(NetswipeViewController *)controller didCancelWithError:(NSError *)error scanReference:(NSString *)scanReference {
    [self showSDKError: error];
}


#pragma mark - Helper Methods

- (void)showSDKError:(NSError *)error {
    // Build error message
    NSInteger code = error.code;
    NSString *message = error.localizedDescription;
    NSString *errorMessage = [NSString stringWithFormat: @"Cancelled with error code %lu, message: %@", (long)code, message];
    NSLog(@"%@", errorMessage);
    
    // Send error message back to javascript
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: errorMessage];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (void)setOptions:(NSDictionary *)options {
    for (NSString *key in options) {
        NSObject *value = [options objectForKey: key];
        
        // Configure option values
        // ...
    }
}

- (NSMutableDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        NSObject *value = [obj valueForKey: key];
        
        if (value) {
            if ([value isKindOfClass: [NSString class]]) {
                // Strings
                [dict setObject: value forKey: key];
            } else if ([value isKindOfClass: [NSDate class]]) {
                // Dates
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
                [dict setObject: [dateFormat stringFromDate: value] forKey: key];
            }
        }
    }
    free(properties);
    return [NSMutableDictionary dictionaryWithDictionary: dict];
}

@end
