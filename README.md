Eucalyptus
==========

[![Build Status](https://travis-ci.org/wolfspyre/puppet-eucalyptus.svg)](https://travis-ci.org/wolfspyre/puppet-eucalyptus)

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
-	**Files:**`templatized files are displayed like this` *exported files are displayed lile this*
	-	`/etc/eucalyptus/drbd.conf` created by the **eucalyptus::drbd_resource** defined type and **eucalyptus::drbd_config** class.
	-	*/var/lib/eucalyptus/keys/node-cert.pem* exported by the **eucalyptus::cluster** defined type
	-	*/var/lib/eucalyptus/keys/node-pk.pem* exported by the **eucalyptus::cluster** defined type
	-	*/var/lib/eucalyptus/keys/cluster-cert.pem* exported by the **eucalyptus::cluster** defined type
	-	*/var/lib/eucalyptus/keys/cluster-pk.pem* exported by the **eucalyptus::cluster** defined type
	-	*/var/lib/eucalyptus/keys/vtunpass*
	-	`/home/eucalyptus/config.py`
-	**Cron Jobs**
-	**Logs being rotated**
-	**Packages:**
	-	eucalyptus-cc
	-	drbd83-utils **drbd_config**
	-	kmod-drbd83 **drbd_config**
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

The **eucalyptus::cluster** defined type is responsible for informing the CLC about clusters. it consumes the parameters *cloud_name* and *cluster_name* and subsequently exports the following files:

-	*/var/lib/eucalyptus/keys/node-cert.pem*
-	*/var/lib/eucalyptus/keys/node-pk.pem*
-	*/var/lib/eucalyptus/keys/cluster-cert.pem*
-	*/var/lib/eucalyptus/keys/cluster-pk.pem*

	These files are used by the`eucakeys` custom facts to make the keys available to other manifests.

The **eucalyptus::conf** class is the databinding entrypoint into the `eucalyptus_config` resource. It consumes a collection of parameters and in turn creates a virtual `eucalyptus_config` resource that is consumed by **populate_this**

The **eucalyptus::drbd_config** class is used to install the required packages to configure drbd for walrus. It ensures the *drbd83-utils* and *kmod-drbd83* packages are installed. It also utilizes the **file_line** resource to add a line to `/etc/drbd.conf` file which includes */etc/eucalyptus/drbd.conf*. It also utilizes the **eucalyptus::kern_module** defined type to enable the kernel module.**It should be noted that the inclusion of this class alone is NOT sufficient to enable drbd properly**. In addition to inclusiuon of this class, you must also have the **eucalyptus::conf** class's *cloud_opts* param have at least the following value: `'-Dwalrus.storage.manager=DRBDStorageManager'`

The **eucalyptus::drbd_resource** defined type is used in conjunction with Eucalyptus Walrus HA. It should only be declared on walrus hosts. It is responsible for initialization and enablement of the drbd synchronized block device for the primary/secondary walrus hosts. It should not be added to any other nodes. Note that using this resource solely is not sufficient to enable drbd properly for use with Eucalyptus. In addition to enabling the **eucalyptus::drbd_config** class on the walrus hosts, more stuff here. when these resources are associated with either walrus host a file resource is created for `/etc/eucalyptus/drbd.conf`, and two exec resources manage the creation and enablement of the desired drbd resource.

The **eucalyptus::repo** class controls the eucalyptus repos. It can be tuned to not manage any yum repos if your setup is managing them elsewhere.

###Hiera Example

```
## eucalyptus::cc ##############################################################
eucalyptus::cc::cloud_name:   'cloud1'
eucalyptus::cc::cluster_name: 'cluster1'
## eucalyptus::clc #############################################################
eucalyptus::clc::cloud_name: 'cloud1'
## eucalyptus::clc2 ############################################################
eucalyptus::clc2::cloud_name: 'cloud1'
## eucalyptus::conf ############################################################
eucalyptus::conf::cc_arbitrators:         'none'
eucalyptus::conf::cc_port:                '8774'
eucalyptus::conf::cloud_opts:             ''
eucalyptus::conf::disable_dns:            'Y'
eucalyptus::conf::disable_iscsi:          'N'
eucalyptus::conf::enable_ws_security:     'Y'
eucalyptus::conf::eucalyptus_dir:         '/'
eucalyptus::conf::eucalyptus_loglevel:    'DEBUG'
eucalyptus::conf::eucalyptus_user:        'eucalyptus'
eucalyptus::conf::hypervisor:             'kvm'
eucalyptus::conf::instance_path:          '/var/lib/eucalyptus/instances'
eucalyptus::conf::nc_port:                '8775'
eucalyptus::conf::nc_service:             'axis2/services/EucalyptusNC'
eucalyptus::conf::power_idlethresh:       '0'
eucalyptus::conf::power_wakethresh:       '0'
eucalyptus::conf::schedpolicy:            'ROUNDROBIN'
eucalyptus::conf::use_virtio_disk:        '1'
eucalyptus::conf::use_virtio_net:         '0'
eucalyptus::conf::use_virtio_root:        '1'
eucalyptus::conf::vnet_addrspernet:       '32'
eucalyptus::conf::vnet_bridge:            'br0'
eucalyptus::conf::vnet_dhcpdaemon:        '/usr/sbin/dhcpd41'
eucalyptus::conf::vnet_disable_tunneling: 'y'
eucalyptus::conf::vnet_dns:               '8.8.8.8'
eucalyptus::conf::vnet_mode:              'SYSTEM'
eucalyptus::conf::vnet_netmask:           '255.255.255.0'
eucalyptus::conf::vnet_privinterface:     'eth1'
eucalyptus::conf::vnet_pubinterface:      'eth0'
eucalyptus::conf::vnet_publicips:         '192.168.0.50-192.168.0.250'
eucalyptus::conf::vnet_subnet:            '127.0.0.1'
## eucalyptus::repo ############################################################
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

-	**eucalyptus::cluster** Defined type

-	**cloud_name** *string* `The name of the cloud.`

-	**cluster_name** *string* `The name of the cluster.`

**eucalyptus::drbd_resource** Defined Type

-	**host1** *string* `the fqdn of the primary walrus host`
-	**host2** *string* `the fqdn of the secondary walrus host`
-	**ip1** *string* `the ipaddress of the primary walrus host`
-	**ip2** *string* `the ipaddress of the secondary walrus host`
-	**disk_host1** *absolute path* `the block device to use for walrus on host1`
-	**disk_host2** *absolute path* `the block device to use for walrus on host2`
-	**port** *string* Default: *7789* `the port drbd uses?`
-	**rate** *string* Default: *40M* `The rate at which to copy?`
-	**manage** *boolean* Default: *true* `whether or not to manage ____`**device** *string* Default: */dev/drbd1* `The block device drbd will use`

-	**eucalyptus::repo** Class

	-	**epel_repo_enable** *boolean* Default: *true* `Whether or not to enable the epel repo via the eucalyptus module.`
	-	**euca2ools_repo_enable** *boolean* Default: *true* `Whether or not to add the euca2ools repo`
	-	**euca_repo_enable** *boolean* Default: *true* `Whether or not to add the eucalyptus repo`
	-	**manage_repos** *boolean* Default: *true* `Whether or not to manage yumrepos at all with the eucalyptus module`

##Reference

###Using the eucalyptus drbd resources Define the resource in your node definition for your walrus server:

```
eucalyptus::drbd_resource { 'r0':
  host1      => 'walrus1.example.com',
  host2      => 'walrus2.example.com',
  ip1        => '192.168.0.1',
  ip2        => '192.168.0.2',
  disk_host1 => '/dev/sda4',
  disk_host2 => '/dev/sda4',
}
```

Update properties in CLC node definition:

```
eucalyptus::cloud_properties { 'walrus blockdevice':
  property_name  => 'walrus.blockdevice',
  property_value => '/dev/drbd1',
}
eucalyptus::cloud_properties { 'walrus resource':
  property_name  => 'walrus.resource',
  property_value => 'r0'
}
```

== Notes You must still run the following manually:* Synchronize DRBD volumes* Increase sync speed whilst doing initial sync* Format the device

Use commands similar to these on the primary walrus to accomplish that:

```
    drbdsetup /dev/drbd1 syncer -r 110M
    drbdadm -- --overwrite-data-of-peer primary r0 mkfs.ext4 /dev/$device
```

You can avoid doing a full sync in dev/test by running:

```
    drbdadm -- --clear-bitmap new-current-uuid r0
    drbdadm primary r0
    mkfs.ext4 /dev/$device ##Limitations
```

OS compatibility, version compatibility, etc.

##Development

Guidelines and instructions for contributing to your module.

##Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here. You may also add any additional sections you feel are necessary or important to include here. Please use the `##` header.
