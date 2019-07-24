var util = require('util');
var path = require('path');
var hfc = require('fabric-client');

var file = 'network-config%s.yaml';

var env = process.env.TARGET_FAB_NETWORK;
var config = require('./project-config.json');

if (env)
	file = util.format(file, '-' + env);
else
	file = util.format(file, '');

// indicate to the application where the setup file is located so it able
// to have the hfc load it to initalize the fabric client instance
hfc.setConfigSetting('network-connection-profile-path',path.join(__dirname, config.FAB_NET_NM ,file));
hfc.setConfigSetting(config.ORG1_NAME + '-connection-profile-path',path.join(__dirname, config.FAB_NET_NM, 'org1.yaml'));
hfc.setConfigSetting(config.ORG2_NAME + '-connection-profile-path',path.join(__dirname, config.FAB_NET_NM, 'org2.yaml'));
hfc.setConfigSetting(config.ORG3_NAME + '-connection-profile-path',path.join(__dirname, config.FAB_NET_NM, 'org3.yaml'));


//hfc.setConfigSetting('Org1-connection-profile-path',path.join(__dirname, config.FAB_NET_NM, 'org1.yaml'));
//hfc.setConfigSetting('Org2-connection-profile-path',path.join(__dirname, config.FAB_NET_NM, 'org2.yaml'));
// some other settings the application might need to know
hfc.addConfigFile(path.join(__dirname, 'config.json'));
hfc.addConfigFile(path.join(__dirname, 'project-config.json'));
