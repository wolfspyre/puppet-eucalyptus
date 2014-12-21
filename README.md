Eucalyptus
==========

####Table of Contents

1.	[Overview](#overview)
2.	[Module Description - What the module does and why it is useful](#module-description)
3.	[Setup - The basics of getting started with eucalyptus](#setup)
	-	[What eucalyptus affects](#what-eucalyptus-affects)
	-	[Setup requirements](#setup-requirements)
	-	[Beginning with eucalyptus](#beginning-with-eucalyptus)
4.	[Usage - Configuration options and additional functionality](#usage)
5.	[Reference - An under-the-hood peek at what the module is doing and how](#reference)
6.	[Limitations - OS compatibility, etc.](#limitations)
7.	[Development - Guide for contributing to the module](#development)

##Overview

A one-maybe-two sentence summary of what the module does/what problem it solves. This is your 30 second elevator pitch for your module. Consider including OS/Puppet version it works with.

##Module Description

Things to change from 3.x for 4.0

-	registering UFS
-	installing imaging worker
-	dealing with edge mode

##Setup

###What eucalyptus affects

-	**Directories:**
	-	/var/lib/eucalyptus
-	**Files:** `templatized files are displayed like this`
	-	/home/eucalyptus/setup.sh
	-	`/home/eucalyptus/config.py`
-	**Cron Jobs**
-	**Logs being rotated**
-	**Packages:**
	-	eucalyptus-cc
-	**Services**
	-	eucalyptus-cc

###Setup Requirements

-	**Required Classes**

	-	stdlib

-	notes here

###Beginning with eucalyptus

-	`include eucalyptus`

##Usage

Classes, types, and resources for customizing, configuring, and doing the fancy stuff with your module.

The **eucalyptus** class does ...

The **eucalyptus::arbitrator** defined type creates an exec which uses `euca-register-arbitrator` to register an arbitrator host which the eucalyptus host pings to evaluate whether or not it can talk to "the outside world". It additionally generates an `eucalyptus::cloud_properties` resource for the `arbitrator_gateway_${partition_name}` **It looks like this should change to use euca_conf** See [this link](https://www.eucalyptus.com/docs/eucalyptus/4.0.2/install-guide/registering_arbitrator.html)

The **eucalyptus::cc** class is responsible for the installation, configuration, and enablement of the CC packages and services. It generates the `$registerif` variable via a regex of the `$eucalyptus::conf::vnet_pubinterface` variable, and sets the `$host` variable from the `ipaddress_${registerif}` variable.

The **eucalyptus::cc::config** class is responsible for exporting the certificate files amongst services

The **eucalyptus::cc::install** class is responsible for installing the `eucalyptus-cc` package, and enabling the `eucalyptus-cc` service.

The **eucalyptus::cc::reg** class is responsible for exporting a resource by which nodes can register the cc component

The **eucalyptus::clc** class is responsible for the installation, configuration, and enablement of the CLC packages and services.

The **eucalyptus::clc2** class is responsible for the installation, configuration, and enablement of the CLC packages and services. This is to allow for an HA CLC configuration. It generates the `$registerif` variable via a regex of the `$eucalyptus::conf::vnet_pubinterface` variable, and sets the `$host` variable from the `ipaddress_${registerif}` variable.

The **eucalyptus::clc::config** class is responsible for initializing euca_conf, and exporting the file resources for `/var/lib/eucalyptus/keys/cloud-cert.pem`, `/var/lib/eucalyptus/keys/cloud-pk.pem`, and `/var/lib/eucalyptus/keys/euca.p12` as well as exporting an exec which generates the specific cloud's .p12 file. This seems to be to circumvent [this bug](http://projects.puppetlabs.com/issues/17216), which was fixed some time ago.

The **eucalyptus::clc2::config** class is responsible for collecting the `/var/lib/eucalyptus/keys/cloud-cert.pem`, `/var/lib/eucalyptus/keys/cloud-pk.pem`, and `/var/lib/eucalyptus/keys/euca.p12` file resources, as well as the exec which generates the specific cloud's .p12 file. This seems to be to circumvent [this bug](http://projects.puppetlabs.com/issues/17216), which was fixed some time ago.

The **eucalyptus::clc::install** class is responsible for the installation and enablement of the `eucalyptus-cloud` package and service

The **eucalyptus::clc::reg** class is responsible for collecting any exported exec's tagged with the `$cloud_name`. If the `eucalyptus::walrus::reg` class is included on this node, it must land before these resources.

The **eucalyptus::clc2::reg** class is responsible for exporting the `reg_clc_${::hostname}` exec tagged with the `$cloud_name`.

The **eucalyptus::cloud_properties** defined type is responsible for calling `euca-modify-property` to generate properties with specific values, unless `euca-describe-properties` lists the properties with the specific values. It is intended to configure the CLC without restarting services.

The **eucalyptus::repo** class controls the eucalyptus repos. It can be tuned to not manage any yum repos if your setup is managing them elsewhere.

###Hiera Example

```
eucalyptus::cc::cloud_name:   'cloud1'
eucalyptus::cc::cluster_name: 'cluster1'
eucalyptus::clc::cloud_name:  'cloud1'
eucalyptus::clc2::cloud_name:  'cloud1'
eucalyptus::repo::epel_repo_enable:      true
eucalyptus::repo::euca2ools_repo_enable: true
eucalyptus::repo::euca_repo_enable:      true
eucalyptus::repo::manage_repos:          true
```

###Parameters

-	**eucalyptus** Class
	-	**param1** *string*

This param controls.. what? * **param2** *boolean*

This param is a boolean

-	**eucalyptus::arbitrator** Defined Type

	-	**gateway_host** *string* `Host to ping to check for connectivity, could be the gateway`
	-	**partition_name** *string* `Unique name for the arbitrator in the cloud`
	-	**service_host** *string* `Host this arbitrator/ping will run from`

-	**eucalyptus::cc** Class

	-	**cloud_name** *string* Default: *cloud1* `The name of the cloud.`
	-	**cluster_name** *string* Default: *cluster1* `The name of the cluster.`

-	**eucalyptus::clc** Class

	-	**cloud_name** *string* Default: *cloud1* `The name of the cloud.`

-	**eucalyptus::clc2** Class

-	**cloud_name** *string* Default: *cloud1* `The name of the cloud.`

-	**eucalyptus::cloud_properties** Defined Type

-	**property_name** *string* `The name of the property to set`

-	**property_value** *string* `The value the property should have`

-	**tries** *string* Default: *3* `This is passed to the exec resource`

-	**try_sleep** *string* Default: *2* `This is passed to the exec resource`

-	**eucalyptus::repo** Class

	-	**epel_repo_enable** *boolean* Default: *true* `Whether or not to enable the epel repo via the eucalyptus module.`
	-	**euca2ools_repo_enable** *boolean* Default: *true* `Whether or not to add the euca2ools repo`
	-	**euca_repo_enable** *boolean* Default: *true* `Whether or not to add the eucalyptus repo`
	-	**manage_repos** *boolean* Default: *true* `Whether or not to manage yumrepos at all with the eucalyptus module`

##Reference

##Limitations

OS compatibility, version compatibility, etc.

##Development

Guidelines and instructions for contributing to your module.

##Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here. You may also add any additional sections you feel are necessary or important to include here. Please use the `##` header.
