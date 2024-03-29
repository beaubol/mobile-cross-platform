# React-Native

Official Jumio Mobile-SDK plugin for react-native.

## Requirements
* Jumio Mobile SDK Android 2.6.0+, iOS 2.5.0+

## Setup iOS

1. Add the Jumio Mobile SDK to your iOS-project of your react-native project. If you don't want to add the sdk manually, you can use CocoaPods. If you use CocoaPods, download the Podfile and change the target name to the target of your project. Call **pod init** afterwards.
2. Download the module (JumioModule.h, JumioModule.m)
3. Open the workspace of the iOS-application and add the downloaded JumioModule-files to the project.
4. Add the "NSCameraUsageDescription"-key to your Info.plist file.
5. If needed: Customise your configuration.

## Setup Android

1. Download the android module (JumioModule.java, JumioReactPackage.java, MainActivity.java)
2. Open the android project of your react-native project and add **JumioModule.java** and **JumioReactPackage.java** to your package.
3. Merge the downloaded **MainActivity.java** with the MainActivity of your project.
4. Add the import of your JumioModule to your MainActivity.
```java
import <YOUR_PACKAGE>.JumioModule;
```

5. Add **JumioReactPackage** to the getPackages()-method of your MainApplication.
```java
@Override
protected List<ReactPackage> getPackages() {
    return Arrays.<ReactPackage>asList(
        new MainReactPackage(),
        new JumioReactPackage()
    );
}
```

6. Update the AndroidManifest file.
* Set **android:allowBackup** to false
```xml
<application
    ...
    android:allowBackup="false"
    ...
</application>
```

* Add the needed sdk activities (Add only the ones you need)
```xml
<activity
    android:name="com.jumio.nv.NetverifyActivity"
    android:windowSoftInputMode="adjustResize"
    android:configChanges="orientation|screenSize|screenLayout|keyboardHidden"
    android:hardwareAccelerated="true"
    android:theme="@style/Theme.Netverify"/>
<activity
    android:name="com.jumio.bam.BamActivity"
    android:configChanges="orientation|screenSize|screenLayout|keyboardHidden"
    android:hardwareAccelerated="true"
    android:theme="@style/Theme.Bam"/>
<activity
    android:name="com.jumio.md.MultiDocumentActivity"
    android:windowSoftInputMode="adjustResize"
    android:configChanges="orientation|screenSize|screenLayout|keyboardHidden"
    android:hardwareAccelerated="true"
    android:theme="@style/Theme.MultiDocument"/>
```

7. Configure the gradle script (Module: app)
* Make sure your compileSDKVersion is high enough. Minimum: 25.
```gradle
android {
    compileSdkVersion 25
    ...
}
```

* Enable MultiDex
```gradle
android {
    ...
    defaultConfig {
        ...
        multiDexEnabled true
    }
}
```

* Set BuildToolsVersion to a minimum of 23.0.3.
```gradle
android {
    ...
    buildToolsVersion "23.0.3"
    ...
}
```

* Add the jumio mobile sdk repository.
```gradle
repositories {  
    maven { url 'http://mobile-sdk.jumio.com' }
}
```

* Add the needed dependencies.
```gradle
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

    ...
}
```

Anstelle der SDK_VERSION kann ein globaler Paramter definiert werden.
```gradle
ext {
    SDK_VERSION = "2.6.0"
}
```

8. If needed: Customise your configuration.

## Integration in react-native

1. Add "**NativeModules**" to the import of 'react-native'.
```javascript
import {
    ...
    NativeModules
} from 'react-native';
```

2. Create a variable of your iOS module:
```javascript
const { JumioModule } = NativeModules;
```

3. Initialize the SDK with the following call.
```javascript
JumioModule.initBAM(<API_TOKEN>, <API_SECRET>, <DATACENTER>);
JumioModule.initNetverify(<API_TOKEN>, <API_SECRET>, <DATACENTER>);
JumioModule.initDocumentVerification(<API_TOKEN>, <API_SECRET>, <DATACENTER>);
```

Datacenter can either be **us** or **eu**.

**If BAM Credit Card + ID is ued, init BAM and Netverify**

4. Afterwards start the SDK with the following command.
```javascript
JumioModule.startBAM();
JumioModule.startNetverify();
JumioModule.startDocumentVerification();
```

5. Now you can listen to events to retrieve the scanned data:
* **EventDocumentData** for Netverify results.
* **EventCardInfo** for BAM results.
* **EventDocumentVerification** for Document Verification results.
* **EventError** for every error.

6. First add **NativeEventEmitter** for iOS and **DeviceEventEmitter** for android to the Import from 'react-native'.

**iOS**
```javascript 
import {
    ...
    NativeEventEmitter
} from 'react-native';
```

**android**
```javascript 
import {
    ...
    DeviceEventEmitter
} from 'react-native';
```

7. Now listen to your events with the event emitter.

**iOS**
The event receives a json object with all the data.

```javascript
const emitter = new NativeEventEmitter(JumioModule);
emitter.addListener(
    'EventDocumentData|EventCardInfo|EventDocumentVerification|EventError',
    (reminder) => alert(JSON.stringify(reminder))
);
```

**android**
The event receives a json string with all the data.

```javascript
DeviceEventEmitter.addListener('EventDocumentData|EventCardInfo|EventDocumentVerification|EventError', 
    function(e: Event) {
    alert(e)
)};
```
