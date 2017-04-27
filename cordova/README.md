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

```
Jumio.initBAM(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {options});
```

DATACENTER can either be **us** or **eu**.


Configure the SDK with the *options*-Object.

| Option | Datatype |
| ------ | -------- |
| cardHolderNameRequired | Boolean |
| sortCodeAndAccountNumberRequired | Boolean |
| expiryRequired | Boolean |
| cvvRequired | Boolean |
| expiryEditable | Boolean |
| cardHolderNameEditable | Boolean |
| merchantReportingCriteria | String |
| vibrationEffectEnabled | Boolean |
| enableFlashOnScanStart | Boolean |
| cardNumberMaskingEnabled | Boolean |
| adyenPublicKey | String |

As soon as the sdk is initialized, the sdk is started by the following call.

```
Jumio.startBAM(successCallback, errorCallback);
```
