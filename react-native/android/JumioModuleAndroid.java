package <YOUR_PACKAGE_NAME>;

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

import com.jumio.MobileSDK;
import com.jumio.bam.*;
import com.jumio.bam.custom.*;
import com.jumio.core.enums.*;
import com.jumio.core.exceptions.*;
import com.jumio.md.MultiDocumentSDK;
import com.jumio.nv.*;

/**
 * Created by lkoblmueller on 31/03/2017.
 */

public class JumioModuleAndroid extends ReactContextBaseJavaModule implements BamCustomScanInterface {

    private final static String TAG = "JumioMobileSDK";
    public static final int PERMISSION_REQUEST_CODE_BAM = 300;
    public static final int PERMISSION_REQUEST_CODE_NETVERIFY = 301;
    public static final int PERMISSION_REQUEST_CODE_MULTI_DOCUMENT = 303;

    private static String NETVERIFY_API_TOKEN;
    private static String NETVERIFY_API_SECRET;
    private static JumioDataCenter NETVERIFY_DATACENTER;
    private static String BAM_API_TOKEN;
    private static String BAM_API_SECRET;
    private static JumioDataCenter BAM_DATACENTER;

    public static NetverifySDK netverifySDK;
    public static BamSDK bamSDK;
    public static MultiDocumentSDK multiDocumentSDK;

    public JumioModuleAndroid(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "JumioModuleAndroid";
    }

    @ReactMethod
    public void startNetverify(String apiToken, String apiSecret, String dataCenter) {
        NETVERIFY_API_TOKEN = apiToken;
        NETVERIFY_API_SECRET = apiSecret;
        NETVERIFY_DATACENTER = (dataCenter.toLowerCase().equals("us")) ? JumioDataCenter.US : JumioDataCenter.EU;

        initializeNetverifySDK();
        checkPermissionsAndStart(netverifySDK);
    }

    @ReactMethod
    public void startBAM(String apiToken, String apiSecret, String dataCenter) {
        BAM_API_TOKEN = apiToken;
        BAM_API_SECRET = apiSecret;
        BAM_DATACENTER = (dataCenter.toLowerCase().equals("us")) ? JumioDataCenter.US : JumioDataCenter.EU;

        initializeBamSDK();
        try {
            if(bamSDK != null)
                checkPermissionsAndStart(bamSDK);
        } catch(IllegalArgumentException e) {
            Toast.makeText(getCurrentActivity(), e.getMessage(), Toast.LENGTH_LONG).show();
        }
    }

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
                Toast.makeText(getReactApplicationContext(), "Invalid SDK instance", Toast.LENGTH_LONG).show();
                return;
            }

            ActivityCompat.requestPermissions(getReactApplicationContext().getCurrentActivity(), mp, code);
            //The result is received in MainActivity::onRequestPermissionsResult.
        } else {
            startSdk(sdk);
        }
    }

    private void startSdk(MobileSDK sdk) {
        try {
            sdk.start();
        } catch (MissingPermissionException e) {
            Toast.makeText(getReactApplicationContext().getCurrentActivity(), e.getMessage(), Toast.LENGTH_LONG).show();
        }
    }

    private void initializeNetverifySDK() {
        try {
            // You can get the current SDK version using the method below.
            // NetverifySDK.getSDKVersion();

            // Call the method isSupportedPlatform to check if the device is supported.
            //NetverifySDK.isSupportedPlatform();

            // To create an instance of the SDK, perform the following call as soon as your activity is initialized.
            // Make sure that your merchant API token and API secret are correct and specify an instance
            // of your activity. If your merchant account is created in the EU data center, use
            // JumioDataCenter.EU instead.
            netverifySDK = NetverifySDK.create(getReactApplicationContext().getCurrentActivity(), NETVERIFY_API_TOKEN, NETVERIFY_API_SECRET, NETVERIFY_DATACENTER);

            // Enable ID verification to receive a verification status and verified data positions (see Callback chapter).
            // Note: Not possible for accounts configured as Fastfill only.
            netverifySDK.setRequireVerification(true);

            // You can specify issuing country (ISO 3166-1 alpha-3 country code) and/or ID types and/or document variant to skip
            // their selection during the scanning process.
            // Use the following method to convert ISO 3166-1 alpha-2 into alpha-3 country code.
            // String alpha3 = IsoCountryConverter.convertToAlpha3("AT");
            // netverifySDK.setPreselectedCountry("AUT");
            // ArrayList<NVDocumentType> documentTypes = new ArrayList<>();
            // documentTypes.add(NVDocumentType.PASSPORT);
            // netverifySDK.setPreselectedDocumentTypes(documentTypes);
            // netverifySDK.setPreselectedDocumentVariant(NVDocumentVariant.PLASTIC);

            // The merchant scan reference allows you to identify the scan (max. 100 characters).
            // Note: Must not contain sensitive data like PII (Personally Identifiable Information) or account login.
            // netverifySDK.setMerchantScanReference("YOURSCANREFERENCE");

            // Use the following property to identify the scan in your reports (max. 100 characters).
            // netverifySDK.setMerchantReportingCriteria("YOURREPORTINGCRITERIA");

            // You can also set a customer identifier (max. 100 characters).
            // Note: The customer ID should not contain sensitive data like PII (Personally Identifiable Information) or account login.
            // netverifySDK.setCustomerId("CUSTOMERID");

            // Callback URL for the confirmation after the verification is completed. This setting overrides your Jumio merchant settings.
            // netverifySDK.setCallbackUrl("YOURCALLBACKURL");

            // You can enable face match during the ID verification for a specific transaction.
            // netverifySDK.setRequireFaceMatch(true);

            // Use the following method to disable ePassport scanning.
            // netverifySDK.setEnableEpassport(false);

            // Use the following method to set the default camera position.
            // netverifySDK.setCameraPosition(JumioCameraPosition.FRONT);

            // Use the following method to only support IDs where data can be extracted on mobile only.
            // netverifySDK.setDataExtractionOnMobileOnly(true);

            // Use the following method to disable showing help before scanning.
            // netverifySDK.setShowHelpBeforeScan(false);

            // Additional information for this scan should not contain sensitive data like PII (Personally Identifiable Information) or account login
            // netverifySDK.setAdditionalInformation("YOURADDITIONALINFORMATION");

            // Use the following method to explicitly send debug-info to Jumio. (default: false)
            // Only set this property to true if you are asked by our Jumio support personnel.
            // netverifySDK.sendDebugInfoToJumio(true);

            // Use the following method to override the SDK theme that is defined in the Manifest with a custom Theme at runtime
            // netverifySDK.setCustomTheme(R.style.YOURCUSTOMTHEMEID);

            // Use the following method to initialize the SDK before displaying it
            // netverifySDK.initiate(new NetverifyInitiateCallback() {
            //     @Override
            //     public void onNetverifyInitiateSuccess() {
            //     }
            //     @Override
            //     public void onNetverifyInitiateError(int errorCode, int errorDetail, String errorMessage, boolean retryPossible) {
            //     }
            // });

        } catch (PlatformNotSupportedException e) {
            e.printStackTrace();
            Toast.makeText(getReactApplicationContext(), "This platform is not supported", Toast.LENGTH_LONG).show();
        }
    }

    private void initializeBamSDK() {
        try {
            // You can get the current SDK version using the method below.
            // BamSDK.getSDKVersion();

            // Call the method isSupportedPlatform to check if the device is supported
            // BamSDK.isSupportedPlatform();

            // Applications implementing the SDK shall not run on rooted devices. Use either the below
            // method or a self-devised check to prevent usage of SDK scanning functionality on rooted
            // devices.
            if (BamSDK.isRooted())
                Log.w(TAG, "Device is rooted");

            // To create an instance of the SDK, perform the following call as soon as your activity is initialized.
            // Make sure that your merchant API token and API secret are correct and specify an instance
            // of your activity. If your merchant account is created in the EU data center, use
            // JumioDataCenter.EU instead.
            bamSDK = BamSDK.create(getReactApplicationContext().getCurrentActivity(), BAM_API_TOKEN, BAM_API_SECRET, BAM_DATACENTER);

            // Use the following method to enable offline credit card scanning.
            // try {
            //     bamSDK = BamSDK.create(SampleActivity.this, "YOUROFFLINETOKEN");
            // } catch (SDKExpiredException e) {
            //    e.printStackTrace();
            //    Toast.makeText(getApplicationContext(), "The offline SDK is expired", Toast.LENGTH_LONG).show();
            // }

            // Overwrite your specified reporting criteria to identify each scan attempt in your reports (max. 100 characters).
            // bamSDK.setMerchantReportingCriteria("YOURREPORTINGCRITERIA");

            // To restrict supported card types, pass an ArrayList of CreditCardTypes to the setSupportedCreditCardTypes method.
            // ArrayList<CreditCardType> creditCardTypes = new ArrayList<CreditCardType>();
            // creditCardTypes.add(CreditCardType.VISA);
            // creditCardTypes.add(CreditCardType.MASTER_CARD);
            // creditCardTypes.add(CreditCardType.AMERICAN_EXPRESS);
            // creditCardTypes.add(CreditCardType.DINERS_CLUB);
            // creditCardTypes.add(CreditCardType.DISCOVER);
            // creditCardTypes.add(CreditCardType.CHINA_UNIONPAY);
            // creditCardTypes.add(CreditCardType.JCB);
            // bamSDK.setSupportedCreditCardTypes(creditCardTypes);

            // Expiry recognition, card holder name and CVV entry are enabled by default and can be disabled.
            // You can enable the recognition of sort code and account number.
            // bamSDK.setExpiryRequired(false);
            // bamSDK.setCardHolderNameRequired(false);
            // bamSDK.setCvvRequired(false);
            // bamSDK.setSortCodeAndAccountNumberRequired(true);

            // You can show the unmasked credit card number to the user during the workflow if setCardNumberMaskingEnabled is disabled.
            // bamSDK.setCardNumberMaskingEnabled(false);

            // The user can edit the recognized expiry date if setExpiryEditable is enabled.
            // bamSDK.setExpiryEditable(true);

            // The user can edit the recognized card holder name if setCardHolderNameEditable is enabled.
            // bamSDK.setCardHolderNameEditable(true);

            // You can set a short vibration and sound effect to notify the user that the card has been detected.
            // bamSDK.setVibrationEffectEnabled(true);
            // bamSDK.setSoundEffect(R.raw.shutter_sound);

            // Use the following method to set the default camera position.
            // bamSDK.setCameraPosition(JumioCameraPosition.FRONT);

            // Automatically enable flash when scan is started.
            // bamSDK.setEnableFlashOnScanStart(true);

            // Use the following method to provide the Adyen Public Key. This activates the generation
            // of an encrypted Adyen payment data object.
            // bamSDK.setAdyenPublicKey("YOUR ADYEN PUBLIC KEY");

            // You can add custom fields to the confirmation page (keyboard entry or predefined values).
            // bamSDK.addCustomField("zipCodeId", getString(R.string.zip_code), InputType.TYPE_CLASS_NUMBER, "[0-9]{5,}");
            // ArrayList<String> states = new ArrayList<String>(Arrays.asList(getResources().getStringArray(R.array.state_selection_values)));
            // bamSDK.addCustomField("stateId", getString(R.string.state), states, false, getString(R.string.state_reset_value));

            // Use the following method to override the SDK theme that is defined in the Manifest with a custom Theme at runtime
            //bamSDK.setCustomTheme(R.style.YOURCUSTOMTHEMEID);

        } catch (PlatformNotSupportedException e) {
            e.printStackTrace();
            Toast.makeText(getReactApplicationContext(), "This platform is not supported", Toast.LENGTH_LONG).show();
        }
    }

    private void initializeMultiDocumentSDK() {
        try {
            // You can get the current SDK version using the method below.
            MultiDocumentSDK.getSDKVersion();

            // Call the method isSupportedPlatform to check if the device is supported.
            MultiDocumentSDK.isSupportedPlatform();

            // To create an instance of the SDK, perform the following call as soon as your activity is initialized.
            // Make sure that your merchant API token and API secret are correct and specify an instance
            // of your activity. If your merchant account is created in the EU data center, use
            // JumioDataCenter.EU instead.
            multiDocumentSDK = MultiDocumentSDK.create(getReactApplicationContext().getCurrentActivity(), NETVERIFY_API_TOKEN, NETVERIFY_API_SECRET, BAM_DATACENTER);

            // One of the configured DocumentTypeCodes: BC, BS, CAAP, CB, CCS, CRC, HCC, IC, LAG, LOAP,
            // MEDC, MOAP, PB, SEL, SENC, SS, STUC, TAC, TR, UB, SSC, USSS, VC, VT, WWCC, CUSTOM
            //multiDocumentSDK.setType("BC");

            // ISO 3166-1 alpha-3 country code
            //multiDocumentSDK.setCountry("USA");

            // The merchant scan reference allows you to identify the scan (max. 100 characters).
            // Note: Must not contain sensitive data like PII (Personally Identifiable Information) or account login.
            //multiDocumentSDK.setMerchantScanReference("YOURSCANREFERENCE");

            // You can also set a customer identifier (max. 100 characters).
            // Note: The customer ID should not contain sensitive data like PII (Personally Identifiable Information) or account login.
            //multiDocumentSDK.setCustomerId("CUSTOMERID");

            // One of the Custom Document Type Codes as configurable by Merchant in Merchant UI.
            // multiDocumentSDK.setCustomDocumentCode("YOURCUSTOMDOCUMENTCODE");

            // Overrides the label for the document name (on Help Screen below document icon)
            // multiDocumentSDK.setDocumentName("DOCUMENTNAME");

            // Use the following property to identify the scan in your reports (max. 255 characters).
            // multiDocumentSDK.setMerchantReportingCriteria("YOURREPORTINGCRITERIA");

            // Callback URL for the confirmation after the verification is completed. This setting overrides your Jumio merchant settings.
            // multiDocumentSDK.setCallbackUrl("YOURCALLBACKURL");

            // Use the following method to set the default camera position.
            // multiDocumentSDK.setCameraPosition(JumioCameraPosition.FRONT);

            // Use the following method to disable showing help before scanning.
            // multiDocumentSDK.setShowHelpBeforeScan(false);

            // Additional information for this scan should not contain sensitive data like PII (Personally Identifiable Information) or account login
            // multiDocumentSDK.setAdditionalInformation("YOURADDITIONALINFORMATION");

            // Use the following method to override the SDK theme that is defined in the Manifest with a custom Theme at runtime
            //multiDocumentSDK.setCustomTheme(R.style.YOURCUSTOMTHEMEID);

        } catch (PlatformNotSupportedException e) {
            e.printStackTrace();
            Toast.makeText(getReactApplicationContext(), "This platform is not supported", Toast.LENGTH_LONG).show();
        }
    }

    //Called as soon as the camera is available for the custom scan. It is safe to check for flash and additional cameras here.
    @Override
    public void onBamCameraAvailable() {
        Log.d("BamCustomScan", "camera available");
    }

    @Override
    public void onBamError(int errorCode, int detailedErrorCode, String errorMessage, boolean retryPossible, ArrayList<String> scanAttempts) {
        Log.d("BamCustomScan", "error occured");
    }

    //When extraction is started, the preview screen will be paused. A loading indicator can be displayed within this callback.
    @Override
    public void onBamExtractionStarted() {
        Log.d("BamCustomScan", "extraction started");
    }

    @Override
    public void onBamExtractionFinished(BamCardInformation bamCardInformation, ArrayList<String> scanAttempts) {
        Log.d("BamCustomScan", "extraction finished");
        bamCardInformation.clear();
    }
}
