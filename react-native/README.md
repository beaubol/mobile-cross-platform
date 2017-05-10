# React-Native

Official Jumio Mobile-SDK plugin for react-native.

## Requirements
* Jumio Mobile SDK Android 2.6.0+, iOS 2.5.0+

## Setup

### Setup iOS

1. Add the Jumio Mobile SDK to your iOS-project of your react-native project. If you don't want to add the sdk manually, you can use CocoaPods.
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

3. Initialize the SDK when you need them.
```javascript
JumioModuleIOS.initBAM(<API_TOKEN>, <API_SECRET>, <DATACENTER>);
JumioModuleIOS.initNetverify(<API_TOKEN>, <API_SECRET>, <DATACENTER>);
```

**If BAM Credit Card + ID is ued, init both SDKs (BAM and Netverify)**

4. Afterwards start the SDK with the following command..
```javascript
JumioModuleIOS.startBAM();
JumioModuleIOS.startNetverify();
```

5. Now you can listen to events to retrieve the scanned data:
    * **EventDocumentData** for Netverify results.
    * **EventCardInfo** for BAM results.

