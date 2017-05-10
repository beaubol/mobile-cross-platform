/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
        this.receivedEvent('deviceready');
		
		Jumio.initBAM('5fb5e560-4a5e-4555-b28a-4513ac3f8e15', 'mGf5EWittbtSOFbcNeCD0yoWizz3wGKC', 'us', {
			cvvRequired: false,
			cameraPosition: "back"
		});
		Jumio.initNetverify('69e2685a-6669-4db9-a3d2-586674392d6c', 'HpFUf2YUQQfKQLT7LF2sIAFtP203bo9D', 'us', {
			requireVerification: false,
			preselectedCountry: "AUT",
			documentTypes: ["passPort", "DRIVER_LICENSE"]
		});
		Jumio.initDocumentVerification('69e2685a-6669-4db9-a3d2-586674392d6c', 'HpFUf2YUQQfKQLT7LF2sIAFtP203bo9D', 'us', {
			country: "USA",
			type: "BS",
			customerId: "123",
			merchantScanReference: "456"
		});
		
    	Jumio.startNetverify(function(msg) {
    		alert(JSON.stringify(msg));
    	}, function(error) {
    		alert(error);
    	});
    },

    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

app.initialize();