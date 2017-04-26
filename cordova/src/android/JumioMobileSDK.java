/*
 Created by Lukas Koblmüller (2017)
 Jumio Software Development GmbH
 
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

package com.jumio.mobilesdk;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.util.Log;
import android.widget.Toast;


import com.jumio.MobileSDK;
import com.jumio.bam.*;
import com.jumio.bam.custom.*;
import com.jumio.core.enums.*;
import com.jumio.core.exceptions.*;
import com.jumio.md.MultiDocumentSDK;
import com.jumio.nv.*;

import java.util.Iterator;

public class JumioMobileSDK extends CordovaPlugin {
    
    private static String TAG = "JumioMobileSDK";
    private static final int PERMISSION_REQUEST_CODE_BAM = 300;
    private static final int PERMISSION_REQUEST_CODE_NETVERIFY = 301;
    private static final int PERMISSION_REQUEST_CODE_MULTI_DOCUMENT = 303;
    
    private static final String ACTION_BAM_INIT = "initBAM";
    private static final String ACTION_BAM_START = "startBAM";
    private static final String ACTION_NV_INIT = "initNetverify";
    private static final String ACTION_NV_START = "startNetverify";
    
    private BamSDK bamSDK;
    private NetverifySDK netverifySDK;
    private MultiDocumentSDK multiDocumentSDK;
    private CallbackContext callbackContext;
    
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        PluginResult result = null;
        this.callbackContext = callbackContext;
        
        if (action.equals(ACTION_BAM_INIT)) {
            initBAM(args);
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(false);
            return true;
        } else if (action.equals(ACTION_BAM_START)) {
            startBAM(args);
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(true);
            return true;
        } else if (action.equals(ACTION_NV_INIT)) {
            initNetverify(args);
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(false);
            return true;
        } else if (action.equals(ACTION_NV_START)) {
            startNetverify(args);
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(true);
            return true;
        } else {
            result = new PluginResult(Status.INVALID_ACTION);
            callbackContext.error("Invalid Action");
            return false;
        }
    }
    
    // BAM
    
    private void initBAM(JSONArray data) {
        if (BamSDK.isRooted()) {
            Log.e(TAG, "BAM SDK can't run on a rooted device.");
            return;
        }
        
        if (!BamSDK.isSupportedPlatform()) {
            Log.e(TAG, "Platform not supported.");
            return;
        }
        
        try {
            if (data.isNull(0) || data.isNull(1) || data.isNull(2)) {
                Log.e(TAG, "Missing required parameters apiToken, apiSecret or dataCenter.");
                return;
            }
            
            String apiToken = data.getString(0);
            String apiSecret = data.getString(1);
            JumioDataCenter dataCenter = (data.getString(2).toLowerCase().equals("us")) ? JumioDataCenter.US : JumioDataCenter.EU;
            
            bamSDK = BamSDK.create(cordova.getActivity(), apiToken, apiSecret, dataCenter);
            
            // Configuration options
            if (!data.isNull(3)) {
                JSONObject options = data.getJSONObject(3);
                Iterator<String> keys = options.keys();
                while (keys.hasNext()) {
                    String key = keys.next();
                    
                    // ...
                }
            }
        } catch (JSONException e) {
            Log.e(TAG, "Invalid parameters.");
        } catch (PlatformNotSupportedException e) {
            Log.e(TAG, "Error initializing the BAM SDK. Try again.");
        }
    }
    
    private void startBAM(JSONArray data) {
        if (bamSDK == null) {
            try {
                JSONObject res = new JSONObject();
                res.put("code", 0);
                res.put("message", "Not initialized. Call initBAM() first.");
                callbackContext.error(res);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            return;
        }
        
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                try {
                    checkPermissionsAndStart(bamSDK);
                } catch (Exception e) {
                    Log.e(TAG, "Error starting the BAM SDK. Try again.");
                }
            }
        };
        
        this.cordova.setActivityResultCallback(this);
        this.cordova.getActivity().runOnUiThread(runnable);
    }
    
    // NETVERIFY
    
    private void initNetverify(JSONArray data) {
        if (!NetverifySDK.isSupportedPlatform()) {
            Log.e(TAG, "Platform not supported.");
            return;
        }
        
        try {
            if (data.isNull(0) || data.isNull(1) || data.isNull(2)) {
                Log.e(TAG, "Missing required parameters apiToken, apiSecret or dataCenter.");
                return;
            }
            
            String apiToken = data.getString(0);
            String apiSecret = data.getString(1);
            JumioDataCenter dataCenter = (data.getString(2).toLowerCase().equals("us")) ? JumioDataCenter.US : JumioDataCenter.EU;
            
            netverifySDK = NetverifySDK.create(cordova.getActivity(), apiToken, apiSecret, dataCenter);
            
            // Configuration options
            if (!data.isNull(3)) {
                JSONObject options = data.getJSONObject(3);
                Iterator<String> keys = options.keys();
                while (keys.hasNext()) {
                    String key = keys.next();
                    
                    if (key.equals("requireVerification")) {
                        Boolean value = options.getBoolean(key);
                        netverifySDK.setRequireVerification(value);
                    }
                    // ...
                }
            }
        } catch (JSONException e) {
            Log.e(TAG, "Invalid parameters.");
        } catch (PlatformNotSupportedException e) {
            Log.e(TAG, "Error initializing the Netverify SDK. Try again.");
        }
    }
    
    private void startNetverify(JSONArray data) {
        if (netverifySDK == null) {
            try {
                JSONObject res = new JSONObject();
                res.put("code", 0);
                res.put("message", "Not initialized. Call initNetverify() first.");
                callbackContext.error(res);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            return;
        }
        
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                try {
                    checkPermissionsAndStart(netverifySDK);
                } catch (Exception e) {
                    Log.e(TAG, "Error starting the Netverify SDK. Try again.");
                }
            }
        };
        
        this.cordova.setActivityResultCallback(this);
        this.cordova.getActivity().runOnUiThread(runnable);
    }
    
    // PERMISSIONS
    
    private void checkPermissionsAndStart(MobileSDK sdk) {
        if (!MobileSDK.hasAllRequiredPermissions(cordova.getActivity().getApplicationContext())) {
            //Acquire missing permissions.
            String[] mp = MobileSDK.getMissingPermissions(cordova.getActivity().getApplicationContext());
            
            int code;
            if (sdk instanceof BamSDK)
                code = PERMISSION_REQUEST_CODE_BAM;
            else if (sdk instanceof NetverifySDK)
                code = PERMISSION_REQUEST_CODE_NETVERIFY;
            else if (sdk instanceof MultiDocumentSDK)
                code = PERMISSION_REQUEST_CODE_MULTI_DOCUMENT;
            else {
                Toast.makeText(cordova.getActivity().getApplicationContext(), "Invalid SDK instance", Toast.LENGTH_LONG).show();
                return;
            }
            
            cordova.requestPermissions(this, code, mp);
        } else {
            this.startSdk(sdk);
        }
    }
    
    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        boolean allGranted = true;
        for (int grantResult : grantResults) {
            if (grantResult != PackageManager.PERMISSION_GRANTED) {
                allGranted = false;
                break;
            }
        }
        
        if (allGranted) {
            if (requestCode == JumioMobileSDK.PERMISSION_REQUEST_CODE_BAM) {
                startSdk(this.bamSDK);
            } else if (requestCode == JumioMobileSDK.PERMISSION_REQUEST_CODE_NETVERIFY) {
                startSdk(this.netverifySDK);
            } else if (requestCode == JumioMobileSDK.PERMISSION_REQUEST_CODE_MULTI_DOCUMENT) {
                startSdk(this.multiDocumentSDK);
            }
        } else {
            Toast.makeText(this.cordova.getActivity().getApplicationContext(), "You need to grant all required permissions to start the Jumio SDK", Toast.LENGTH_LONG).show();
            super.onRequestPermissionResult(requestCode, permissions, grantResults);
        }
    }
    
    // SDK RESULT
    
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (requestCode == BamSDK.REQUEST_CODE) {
            // BAM Results
            if (resultCode == Activity.RESULT_OK) {
                BamCardInformation cardInformation = intent.getParcelableExtra(BamSDK.EXTRA_CARD_INFORMATION);
                
                JSONObject result = new JSONObject();
                try {
                    result.put("cardType", cardInformation.getCardType());
                    result.put("cardNumber", String.valueOf(cardInformation.getCardNumber()));
                    result.put("cardNumberGrouped", String.valueOf(cardInformation.getCardNumberGrouped()));
                    result.put("cardNumberMasked", String.valueOf(cardInformation.getCardNumberMasked()));
                    result.put("cardExpiryMonth", String.valueOf(cardInformation.getCardExpiryDateMonth()));
                    result.put("cardExpiryYear", String.valueOf(cardInformation.getCardExpiryDateYear()));
                    result.put("cardExpiryDate", String.valueOf(cardInformation.getCardExpiryDateYear()));
                    result.put("cardCVV", String.valueOf(cardInformation.getCardCvvCode()));
                    result.put("cardHolderName", String.valueOf(cardInformation.getCardHolderName()));
                    result.put("cardSortCode", String.valueOf(cardInformation.getCardSortCode()));
                    result.put("cardAccountNumber", String.valueOf(cardInformation.getCardAccountNumber()));
                    result.put("cardSortCodeValid", cardInformation.isCardSortCodeValid());
                    result.put("cardAccountNumberValid", cardInformation.isCardAccountNumberValid());
                    result.put("encryptedAdyenString", cardInformation.getEncryptedAdyenString());
                    
                    callbackContext.success(result);
                    cardInformation.clear();
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        } else if (requestCode == NetverifySDK.REQUEST_CODE) {
            // NETVERIFY Results
            if (resultCode == Activity.RESULT_OK) {
                NetverifyDocumentData documentData = intent.getParcelableExtra(NetverifySDK.EXTRA_SCAN_DATA);
                JSONObject result = new JSONObject();
                try {
                    result.put("selectedCountry", documentData.getSelectedCountry());
                    result.put("selectedDocumentType", documentData.getSelectedDocumentType());
                    result.put("idNumber", documentData.getIdNumber());
                    result.put("personalNumber", documentData.getPersonalNumber());
                    result.put("issuingDate", documentData.getIssuingDate());
                    result.put("expiryDate", documentData.getExpiryDate());
                    result.put("issuingCountry", documentData.getIssuingCountry());
                    result.put("lastName", documentData.getLastName());
                    result.put("firstName", documentData.getFirstName());
                    result.put("middleName", documentData.getMiddleName());
                    result.put("dob", documentData.getDob());
                    result.put("gender", documentData.getGender());
                    result.put("originatingCountry", documentData.getOriginatingCountry());
                    result.put("addressLine", documentData.getAddressLine());
                    result.put("city", documentData.getCity());
                    result.put("subdivision", documentData.getSubdivision());
                    result.put("postCode", documentData.getPostCode());
                    result.put("optionalData1", documentData.getOptionalData1());
                    result.put("optionalData2", documentData.getOptionalData2());
                    result.put("placeOfBirth", documentData.getPlaceOfBirth());
                    result.put("extractionMethod", documentData.getExtractionMethod());
                    
                    // MRZ data if available
                    if (documentData.getMrzData() != null) {
                        JSONObject mrzData = new JSONObject();
                        mrzData.put("format", documentData.getMrzData().getFormat());
                        mrzData.put("line1", documentData.getMrzData().getMrzLine1());
                        mrzData.put("line2", documentData.getMrzData().getMrzLine2());
                        mrzData.put("line3", documentData.getMrzData().getMrzLine3());
                        mrzData.put("idNumberValid", documentData.getMrzData().idNumberValid());
                        mrzData.put("dobValid", documentData.getMrzData().dobValid());
                        mrzData.put("expiryDateValid", documentData.getMrzData().expiryDateValid());
                        mrzData.put("personalNumberValid", documentData.getMrzData().personalNumberValid());
                        mrzData.put("compositeValid", documentData.getMrzData().compositeValid());
                        result.put("mrzData", mrzData);
                    }
                    
                    callbackContext.success(result);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    // HELPER METHODS
    
    private void startSdk(MobileSDK sdk) {
        try {
            sdk.start();
        } catch (MissingPermissionException e) {
            Toast.makeText(cordova.getActivity(), e.getMessage(), Toast.LENGTH_LONG).show();
        }
    }
}
