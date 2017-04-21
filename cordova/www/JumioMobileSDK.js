var exec = require('cordova/exec');

exports.initNetverify = function(token, secret, datacenter, options) {
    exec(function(success) { console.log("Netverify::init Success: " + success) }, 
		 function(error) { console.log("Netverify::init Error: " + error) },
		 "JumioMobileSDK", 
		 "initNetverify", 
		 [token, secret, datacenter, options]);
};

exports.startNetverify = function(success, error) {
    exec(success, error, "JumioMobileSDK", "startNetverify", []);
};

exports.initBAM = function(token, secret, datacenter, options) {
    exec(function(success) { console.log("BAM::init Success: " + success) }, 
		 function(error) { console.log("BAM::init Error: " + error) },
		 "JumioMobileSDK", 
		 "initBAM", 
		 [token, secret, datacenter, options]);
};

exports.startBAM = function(success, error) {
    exec(success, error, "JumioMobileSDK", "startBAM", []);
};