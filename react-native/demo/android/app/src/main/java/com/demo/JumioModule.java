package com.demo;

import android.widget.Toast;
import android.app.*;
import android.content.*;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.*;
import java.util.ArrayList;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.jumio.MobileSDK;
import com.jumio.bam.*;
import com.jumio.bam.custom.*;
import com.jumio.core.enums.*;
import com.jumio.core.exceptions.*;
import com.jumio.md.MultiDocumentSDK;
import com.jumio.nv.*;

import org.json.JSONObject;

/**
 * Created by lkoblmueller on 31/03/2017.
 */

public class JumioModule extends ReactContextBaseJavaModule {
    
    private final static String TAG = "JumioMobileSDK";
    public static final int PERMISSION_REQUEST_CODE_BAM = 300;
    public static final int PERMISSION_REQUEST_CODE_NETVERIFY = 301;
    public static final int PERMISSION_REQUEST_CODE_MULTI_DOCUMENT = 303;
    
    public static NetverifySDK netverifySDK;
    public static BamSDK bamSDK;
    public static MultiDocumentSDK documentVerificationSDK;
    
    public JumioModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }
    
    @Override
    public String getName() {
        return "JumioModule";
    }
    
    // BAM CHECKOUT
    
    @ReactMethod
    public void initBAM(String apiToken, String apiSecret, String dataCenter) {
        if (BamSDK.isRooted(getReactApplicationContext())) {
            showErrorMessage("The BAM SDK can't run on a rooted device.");
            return;
        }
        
        if (!BamSDK.isSupportedPlatform()) {
            showErrorMessage("This platform is not supported.");
            return;
        }
        
        try {
            JumioDataCenter center = (dataCenter.equals("eu")) ? JumioDataCenter.EU : JumioDataCenter.US;
            bamSDK = BamSDK.create(getCurrentActivity(), apiToken, apiSecret, center);
            
            //******* optional customization *******
            bamSDK.setCvvRequired(true);
            bamSDK.setCameraPosition(JumioCameraPosition.BACK);
            // ...
            
        } catch (PlatformNotSupportedException e) {
            showErrorMessage("Error initializing the BAM SDK: " + e.getLocalizedMessage());
        }
    }
    
    @ReactMethod
    public void startBAM() {
        if (bamSDK == null) {
            showErrorMessage("The BAM SDK is not initialized yet. Call initBAM() first.");
            return;
        }
        
        try {
            checkPermissionsAndStart(bamSDK);
        } catch(IllegalArgumentException e) {
            showErrorMessage("Error starting the BAM SDK: " + e.getLocalizedMessage());
        }
    }
    
    // NETVERIFY + FASTFILL
    
    @ReactMethod
    public void initNetverify(String apiToken, String apiSecret, String dataCenter) {
        if (!NetverifySDK.isSupportedPlatform()) {
            showErrorMessage("This platform is not supported.");
            return;
        }
        
        try {
            JumioDataCenter center = (dataCenter.equals("eu")) ? JumioDataCenter.EU : JumioDataCenter.US;
            netverifySDK = NetverifySDK.create(getCurrentActivity(), apiToken, apiSecret, center);
            
            //******* optional customization *******
            netverifySDK.setRequireVerification(false);
            netverifySDK.setCameraPosition(JumioCameraPosition.BACK);
            // ...
            
        } catch (PlatformNotSupportedException e) {
            showErrorMessage("Error initializing the Netverify SDK: " + e.getLocalizedMessage());
        }
    }
    
    @ReactMethod
    public void startNetverify() {
        if (netverifySDK == null) {
            showErrorMessage("The Netverify SDK is not initialized yet. Call initNetverify() first.");
            return;
        }
        
        try {
            checkPermissionsAndStart(netverifySDK);
        } catch (Exception e) {
            showErrorMessage("Error starting the Netverify SDK: " + e.getLocalizedMessage());
        }
    }
    
    // DOCUMENT VERIFICATION
    
    @ReactMethod
    public void initDocumentVerification(String apiToken, String apiSecret, String dataCenter) {
        if (!MultiDocumentSDK.isSupportedPlatform()) {
            showErrorMessage("This platform is not supported.");
            return;
        }
        
        try {
            JumioDataCenter center = (dataCenter.equals("eu")) ? JumioDataCenter.EU : JumioDataCenter.US;
            documentVerificationSDK = MultiDocumentSDK.create(getCurrentActivity(), apiToken, apiSecret, center);
            
            //******* mandatory customization *******
            documentVerificationSDK.setType("BS");
            documentVerificationSDK.setCountry("AUT");
            documentVerificationSDK.setCustomerId("123456789");
            documentVerificationSDK.setMerchantScanReference("123456789");
            
            
            //******* optional customization *******
            documentVerificationSDK.setCameraPosition(JumioCameraPosition.BACK);
            // ...
            
        } catch (PlatformNotSupportedException e) {
            showErrorMessage("Error initializing the Document-Verification SDK: " + e.getLocalizedMessage());
        }
    }
    
    @ReactMethod
    public void startDocumentVerification() {
        if (documentVerificationSDK == null) {
            showErrorMessage("The Document-Verification SDK is not initialized yet. Call initDocumentVerification() first.");
            return;
        }
        
        try {
            checkPermissionsAndStart(documentVerificationSDK);
        } catch (Exception e) {
            showErrorMessage("Error starting the Document-Verification SDK: " + e.getLocalizedMessage());
        }
    }
    
    // PERMISSIONS
    
    private void checkPermissionsAndStart(MobileSDK sdk) {
        if (!MobileSDK.hasAllRequiredPermissions(getReactApplicationContext())) {
            //Acquire missing permissions.
            String[] mp = MobileSDK.getMissingPermissions(getReactApplicationContext());
            
            int code;
            if (sdk instanceof BamSDK)
                code = PERMISSION_REQUEST_CODE_BAM;
            else if (sdk instanceof NetverifySDK)
                code = PERMISSION_REQUEST_CODE_NETVERIFY;
            else if (sdk instanceof MultiDocumentSDK)
                code = PERMISSION_REQUEST_CODE_MULTI_DOCUMENT;
            else {
                showErrorMessage("Invalid SDK instance");
                return;
            }
            
            ActivityCompat.requestPermissions(getReactApplicationContext().getCurrentActivity(), mp, code);
            //The result is received in MainActivity::onRequestPermissionsResult.
        } else {
            startSdk(sdk);
        }
    }
    
    // HELPER METHODS
    
    private void startSdk(MobileSDK sdk) {
        try {
            sdk.start();
        } catch (MissingPermissionException e) {
            showErrorMessage(e.getLocalizedMessage());
        }
    }
    
    private void showErrorMessage(String msg) {
        Log.e("Error", msg);
        getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("EventError", msg);
    }
}
