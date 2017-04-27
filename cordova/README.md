# Apache Cordova

Official Jumio Mobile-SDK plugin for Apache Cordova

## Requirements
* Jumio Mobile SDK Android 2.6.0+, iOS 2.5.0+

## Setup

Add the plugin to your Cordova project.

```
cordova plugin add cordova-plugin-jumio-mobilesdk
```

## Integration

### iOS

...

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
| enableEpassport | Boolean | Read the NFC chip of an ePassport |
| sendDebugInfoToJumio | Boolean | Send debug information to Jumio. |
| dataExtractionOnMobileOnly | Boolean | Limit data extraction to be done on device only |

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
| showHelpBeforeScan | Boolean | Show/Hide the help screen before scanning |
| documentName | String | Override the document label on the help screen |
| customDocumentCode | String | Set your custom document code (set in the merchatn backend under "Settings" - "Multi Documents" - "Custom" |

As soon as the sdk is initialized, the sdk is started by the following call.

```javascript
Jumio.startDocumentVerification(successCallback, errorCallback);
```
 

## Callback

JSONObject with all the extracted data.
