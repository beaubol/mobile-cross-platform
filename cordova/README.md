# Apache Cordova

Official Jumio Mobile-SDK plugin for Apache Cordova

## Requirements
* Jumio Mobile SDK Android 2.6.0+, iOS 2.5.0+
* CocoaPods for iOS.

## Setup

Add the plugin to your Cordova project.

```
cordova plugin add cordova-plugin-jumio-mobilesdk
```

## Integration

### iOS

Nothing to do. Cocoapods handles everything.

### Android

Open the android project of your cordova project located in /platforms/android and open the **build.gradle** file. (Module: android)

Add the Jumio repository:

```
repositories {
    maven { url 'http://mobile-sdk.jumio.com' }
}
```

Add a parameter for your SDK_VERSION into the ext-section:

```
ext {
    SDK_VERSION = "2.6.0"
}
```

Add your needed dependencies:

```
dependencies {
    compile "com.jumio.android:core:${SDK_VERSION}@aar"
    compile "com.jumio.android:bam:${SDK_VERSION}@aar"
    compile "com.jumio.android:nv:${SDK_VERSION}@aar"
    compile "com.jumio.android:nv-barcode:${SDK_VERSION}@aar"
    compile "com.jumio.android:nv-barcode-vision:${SDK_VERSION}@aar"
    compile "com.jumio.android:nv-mrz:${SDK_VERSION}@aar"
    compile "com.jumio.android:nv-nfc:${SDK_VERSION}@aar"
    compile "com.jumio.android:nv-ocr:${SDK_VERSION}@aar"
    compile "com.jumio.android:md:${SDK_VERSION}@aar"

    //for core:
    compile "com.android.support:support-v4:25.0.0"
    compile "com.android.support:appcompat-v7:25.0.0"

    //for nv:
    compile "com.android.support:design:25.0.0"

    //only for nv-nfc
    compile "com.madgag.spongycastle:prov:1.54.0.0"
    compile "net.sf.scuba:scuba-sc-android:0.0.10"

    //only for nv-barcode-vision
    compile "com.google.android.gms:play-services-vision:9.6.1"
}
```

## Usage

### BAM Checkout

To Initialize the SDK, perform the following call.

```javascript
Jumio.initBAM(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {options});
```

DATACENTER can either be **us** or **eu**.

 

Configure the SDK with the *options*-Object.

| Option | Datatype | Description |
| ------ | -------- | ----------- |
| cardHolderNameRequired | Boolean | 
| sortCodeAndAccountNumberRequired | Boolean | 
| expiryRequired | Boolean | 
| cvvRequired | Boolean |
| expiryEditable | Boolean |
| cardHolderNameEditable | Boolean |
| merchantReportingCriteria | String | Overwrite your specified reporting criteria to identify each scan attempt in your reports (max. 100 characters)
| vibrationEffectEnabled | Boolean |
| enableFlashOnScanStart | Boolean |
| cardNumberMaskingEnabled | Boolean |
| adyenPublicKey | String | Use the following option to support the Adyen client-side-encryption.
| offlineToken *(iOS only)* | String | In your Jumio merchant backend on the "Settings" page under "API credentials" you can find your Offline token. |
| cameraPosition | String | Which camera is used by default. Can be **front** or **back**. |
| cardTypes | String-Array | An array of accepted card types. Available card types: **visa**, **master_card**, **american_express**, **china_unionpay**, **diners_club**, **discover**, **jcb**, **starbucks** |

Initialization example with options.

```javascript
Jumio.initBAM("123", "456", "us", {
    cardHolderNameRequired: false,
    cvvRequired: true,
    cameraPosition: "back",
    cardTypes: ["visa", "master_card"]
});
```


As soon as the sdk is initialized, the sdk is started by the following call.

```javascript
Jumio.startBAM(successCallback, errorCallback);
```
 

### Netverify / Fastfill

To initialize the SDK, perform the following call.

```javascript
Jumio.initNetverify(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {options});
```

DATACENTER can either be **us** or **eu**.

 

Configure the SDK with the *options*-Object.

| Option | Datatype | Description |
| ------ | -------- | ----------- |
| requireVerification | Boolean | Enable ID verification |
| callbackUrl | String | Specify an URL for individual transactions |
| requireFaceMatch | Boolean | Enable face match during the ID verification for a specific transaction |
| preselectedCountry | Boolean | Specify the issuing country (ISO 3166-1 alpha-3 country code) |
| merchantScanReference | String | Allows you to identify the scan (max. 100 characters) |
| merchantReportingCriteria | String | Use this option to identify the scan in your reports (max. 100 characters) |
| customerId | String | Set a customer identifier (max. 100 characters) |
| additionalInformation | String | Add additional paramter (max. 255 characters) |
| enableEpassport *(android only)* | Boolean | Read the NFC chip of an ePassport |
| sendDebugInfoToJumio | Boolean | Send debug information to Jumio. |
| dataExtractionOnMobileOnly | Boolean | Limit data extraction to be done on device only |
| cameraPosition | String | Which camera is used by default. Can be **front** or **back**. |
| preselectedDocumentVariant | String | Which types of document variants are available. Can be **paper** or **plastic** |
| documentTypes | String-Array | An array of accepted document types: Available document types: **passport**, **driver_license**, **identity_card**, **visa** |


Initialization example with options.

```javascript
Jumio.initNetverify("123", "456", "us", {
    requireVerification: false,
    customerID: "123456789",
    preselectedCountry: "AUT",
    cameraPosition: "back",
    documentTypes: ["driver_license", "passport"]
});
```

As soon as the sdk is initialized, the sdk is started by the following call.

```javascript
Jumio.startNetverify(successCallback, errorCallback);
```


### Document Verification

To initialize the SDK, perform the following call.

```javascript
Jumio.initDocumentVerification(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {options});
```

DATACENTER can either be **us** or **eu**.

 

Configure the SDK with the *options*-Object. **(options marked with * are mandatory)**

| Option | Datatype | Description |
| ------ | -------- | ----------- |
| **type*** | String | See the list below |
| **customerId*** | String | Set a customer identifier (max. 100 characters) |
| **country*** | String | Set the country (ISO-3166-1 alpha-3 code) |
| **merchantScanReference*** | String | Allows you to identify the scan (max. 100 characters) |
| merchantReportingCriteria | String | Use this option to identify the scan in your reports (max. 100 characters) |
| callbackUrl | String | Specify an URL for individual transactions |
| additionalInformation | String | Add additional paramter (max. 255 characters) |
| showHelpBeforeScan *(android only)* | Boolean | Show/Hide the help screen before scanning |
| documentName | String | Override the document label on the help screen |
| customDocumentCode | String | Set your custom document code (set in the merchant backend under "Settings" - "Multi Documents" - "Custom" |
| cameraPosition | String | Which camera is used by default. Can be **front** or **back**. |

Possible types:

*  BS (Bank statement)
*  IC (Insurance card)
*  UB (Utility bill, front side)
*  CAAP (Cash advance application)
*  CRC (Corporate resolution certificate)
*  CCS (Credit card statement)
*  LAG (Lease agreement)
*  LOAP (Loan application)
*  MOAP (Mortgage application)
*  TR (Tax return)
*  VT (Vehicle title)
*  VC (Voided check)
*  STUC (Student card)
*  HCC (Health care card)
*  CB (Council bill)
*  SENC (Seniors card)
*  MEDC (Medicare card)
*  BC (Birth certificate)
*  WWCC (Working with children check)
*  SS (Superannuation statement)
*  TAC (Trade association card)
*  SEL (School enrolment letter)
*  PB (Phone bill)
*  USSS (US social security card)
*  SSC (Social security card)
*  CUSTOM (Custom document type)

Initialization example with options.

```javascript
Jumio.initDocumentVerification("123", "456", "us", {
    type: "BS",
    customerId: "123456789",
    country: "AUT",
    merchantScanReference: "123456789",
    cameraPosition: "front"
});
```

As soon as the sdk is initialized, the sdk is started by the following call.

```javascript
Jumio.startDocumentVerification(successCallback, errorCallback);
```
 

## Callback

JSONObject with all the extracted data.
