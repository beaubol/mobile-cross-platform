
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;
import android.widget.Toast;

import com.facebook.react.ReactActivity;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.jumio.MobileSDK;
import com.jumio.bam.BamCardInformation;
import com.jumio.bam.BamSDK;
import com.jumio.core.exceptions.MissingPermissionException;
import com.jumio.nv.NetverifyDocumentData;
import com.jumio.nv.NetverifyMrzData;
import com.jumio.nv.NetverifySDK;

// add JumioModule
// import com.<YOURPACKAGE>.JumioModule;

import java.util.ArrayList;

public class MainActivity extends ReactActivity {

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {

        boolean allGranted = true;
        for (int grantResult : grantResults) {
            if (grantResult != PackageManager.PERMISSION_GRANTED) {
                allGranted = false;
                break;
            }
        }

        if (allGranted) {
            if (requestCode == JumioModule.PERMISSION_REQUEST_CODE_BAM) {
                startSdk(JumioModule.bamSDK);
            } else if (requestCode == JumioModule.PERMISSION_REQUEST_CODE_NETVERIFY) {
                startSdk(JumioModule.netverifySDK);
            } else if (requestCode == JumioModule.PERMISSION_REQUEST_CODE_MULTI_DOCUMENT) {
                startSdk(JumioModule.multiDocumentSDK);
            }
        } else {
            Toast.makeText(this, "You need to grant all required permissions to start the Jumio SDK", Toast.LENGTH_LONG).show();
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

    public void startSdk(MobileSDK sdk) {
        try {
            sdk.start();
        } catch (MissingPermissionException e) {
            Toast.makeText(this, e.getMessage(), Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == NetverifySDK.REQUEST_CODE) {
            if (data == null)
                return;
            if (resultCode == Activity.RESULT_OK) {
                String scanReference = data.getStringExtra(NetverifySDK.EXTRA_SCAN_REFERENCE);
                NetverifyDocumentData documentData = (NetverifyDocumentData) data.getParcelableExtra(NetverifySDK.EXTRA_SCAN_DATA);
                NetverifyMrzData mrzData = documentData != null ? documentData.getMrzData() : null;

                // Return document data to Javascript
                WritableMap params = Arguments.createMap();
                params.putString("firstName", documentData.getFirstName());
                // ...
                sendEvent(this.getReactInstanceManager().getCurrentReactContext(), "EventDocumentData", params);
            } else if (resultCode == Activity.RESULT_CANCELED) {
                String errorMessage = data.getStringExtra(NetverifySDK.EXTRA_ERROR_MESSAGE);
                int errorCode = data.getIntExtra(NetverifySDK.EXTRA_ERROR_CODE, 0);
            }

            //At this point, the SDK is not needed anymore. It is highly advisable to call destroy(), so that
            //internal resources can be freed.
            if (JumioModule.netverifySDK != null) {
                JumioModule.netverifySDK.destroy();
                JumioModule.netverifySDK = null;
            }

        } else if (requestCode == BamSDK.REQUEST_CODE) {
            if (data == null)
                return;
            ArrayList<String> scanAttempts = data.getStringArrayListExtra(BamSDK.EXTRA_SCAN_ATTEMPTS);

            if (resultCode == Activity.RESULT_OK) {
                BamCardInformation cardInformation = data.getParcelableExtra(BamSDK.EXTRA_CARD_INFORMATION);

                // Return card info to Javascript
                WritableMap params = Arguments.createMap();
                params.putString("cardHolderName", String.valueOf(cardInformation.getCardHolderName()));
                // ...
                sendEvent(this.getReactInstanceManager().getCurrentReactContext(), "EventCardInfo", params);
                cardInformation.clear();
            } else if (resultCode == Activity.RESULT_CANCELED) {
                String errorMessage = data.getStringExtra(BamSDK.EXTRA_ERROR_MESSAGE);
                int errorCode = data.getIntExtra(BamSDK.EXTRA_ERROR_CODE, 0);
            }

            //At this point, the SDK is not needed anymore. It is highly advisable to call destroy(), so that
            //internal resources can be freed.
            if (JumioModule.bamSDK != null) {
                JumioModule.bamSDK.destroy();
                JumioModule.bamSDK = null;
            }
        }
    }

    private void sendEvent(ReactContext reactContext, String eventName, @Nullable WritableMap params) {
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }
}
