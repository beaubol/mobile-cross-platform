/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Button,
  NativeModules,
  NativeEventEmitter
} from 'react-native';

const { JumioModule } = NativeModules;
const startSDK = () => {
    JumioModule.initBAM(<API_TOKEN>, <API_SECRET>, <DATACENTER>);
    JumioModule.initNetverify(<API_TOKEN>, <API_SECRET>, <DATACENTER>);
    JumioModule.initDocumentVerification(<API_TOKEN>, <API_SECRET>, <DATACENTER>);
  
    JumioModule.startNetverify();
};

const emitter = new NativeEventEmitter(JumioModule);
emitter.addListener(
    'EventDocumentData',
    (reminder) => alert(JSON.stringify(reminder))
);

export default class demo extends Component {
  render() {
    return (
      <View style={styles.container}>
		<Button
			onPress={startSDK}
			title="Start SDK" />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('demo', () => demo);
