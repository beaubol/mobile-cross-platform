# React-Native

Official Jumio Mobile-SDK plugin for react-native.

## Requirements
* Jumio Mobile SDK Android 2.6.0+, iOS 2.5.0+

## Setup iOS

1. Add the Jumio Mobile SDK to your iOS-project of your react-native project. If you don't want to add the sdk manually, you can use CocoaPods. If you use CocoaPods, download the Podfile and change the target name to the target of your project. Call **pod init** afterwards.
2. Download the module (JumioModuleIOS.h, JumioModuleIOS.m)
3. Open the workspace of the iOS-application and add the downloaded JumioModuleIOS-files to the project.
4. Add the "NSCameraUsageDescription"-key to your Info.plist file.
5. If needed: Customise your configuration.

Now the native part is done and we head over to the react native code.

1. Add "**NativeModules**" to the import of 'react-native'.
```javascript
import {
    ...
    NativeModules
} from 'react-native';
```

2. Create a variable of your iOS module:
```javascript
const { JumioModuleIOS } = NativeModules;
```

3. Initialize the SDK with the following call.
```javascript
JumioModuleIOS.initBAM(<API_TOKEN>, <API_SECRET>, <DATACENTER>);
JumioModuleIOS.initNetverify(<API_TOKEN>, <API_SECRET>, <DATACENTER>);
JumioModuleIOS.initDocumentVerification(<API_TOKEN>, <API_SECRET>, <DATACENTER>);
```

<DATACENTER> can either be **us** or **eu**.

**If BAM Credit Card + ID is ued, init BAM and Netverify**

4. Afterwards start the SDK with the following command.
```javascript
JumioModuleIOS.startBAM();
JumioModuleIOS.startNetverify();
JumioModuleIOS.startDocumentVerification();
```

5. Now you can listen to events to retrieve the scanned data:
    * **EventDocumentData** for Netverify results.
    * **EventCardInfo** for BAM results.
    * **EventDocumentVerification** for Document Verification results.
    * **EventError** for every error.

6. First add **NativeEventEmitter** to the Import from 'react-native'.
```javascript 
import {
    ...
    NativeEventEmitter
} from 'react-native';
```

7. Now listen to your events with the event emitter
```javascript
const emitter = new NativeEventEmitter(JumioModuleIOS);
emitter.addListener(
    'EventDocumentData|EventCardInfo|EventDocumentVerification|EventError',
    (reminder) => alert(JSON.stringify(reminder))
);
```

## Setup Android
