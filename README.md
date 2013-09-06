Eucalyptus-Puppet Integration
=============================

This module is designed to configure Eucalyptus components on physical nodes. It contains classes for the 5 main software components as well as certain OS dependencies. So far, it has been tested with CentOS and Puppet 3.2.x

[Eucalyptus](http://www.eucalyptus.com)

## Assumptions

- DNS works, period
- At least 4 nodes are available:
    * puppet master (cannot cohabitate with eucalyptus due to postgres-related issues), or `master`
    * CLC & Walrus (cloud controller and persistent storage layer), or `clc_walrus`
    * SC & CC (storage controller and cluster controller), or `sc_cc`
    * NC (node controller), or `nc`
- access to WAN/Internet
- all `iptables` rules are flushed (`iptables -F`)
- user is logged in as `root` or at least has `sudo` privileges
- for the purposes of a research environment, we will enable autosigning certificates on the puppet master
- git is present and functional
    * `yum install -y git`, e.g.
- the current version of this module relies on eventual consistency; future versions may have better cross-node state management
- the module currently does not attempt to configure a load balancer
  instance or service, this results in a lot of error messages in
`euca-describe-services -E`
- Eucalyptus requires that all nodes have active ntp services

## Process

- Install and configure Puppet Enterprise 3.0.1 master/console/puppetdb role on `master` node
    * test to make sure that `puppet agent -t` works on `master`
    * create `/etc/puppetlabs/puppet/autosign.conf` with content => "*"
        * this will automatically sign incoming CSRs, and should be considered insecure for user-facing production
        * See [docs.puppetlabs.com](http://docs.puppetlabs.com/guides/configuring.html#autosignconf) for more details
- install required modules (cwd: `/etc/puppetlabs/puppet/modules`):
    * `git clone https://github.com/dhgwilliam/puppetlabs-eucalyptus.git eucalyptus`
    * `stdlib` is also required, but ships with PE so is already present
- install puppet agent on the remaining nodes
    * see DNS and `iptables` assumptions above
    * test `puppet agent -t` on these nodes as well
- using `/etc/puppetlabs/puppet/manifests/site.pp` (PE's default manifest), classify the nodes as follows:
    * note the fake node for sharing eucalyptus_config via inheritance
    * the node names used here are for documentation and should be changed to reflect the full FQDN of the node in question
    * note, also, the use of the eucalyptus::cluster resource declaration. here we assume the default cloud and cluster names are used (cloud1 and cluster1)
    * this is NOT a complete `site.pp` and should probably be appended to whatever already exists in `site.pp`

~~~
node 'eucalyptus_config' {
  class { 'eucalyptus::conf':
    vnet_mode => 'MANAGED',
    vnet_subnet => '172.20.0.0',
    vnet_netmask => '255.255.0.0',
    vnet_dns => '10.2.0.5',
    vnet_addrspernet => '256',
    vnet_publicips => '10.2.3.100-10.2.3.250',
    vnet_privinterface => 'eth1',
    vnet_pubinterface => 'eth0',
    vnet_bridge => 'br0',
    hypervisor => 'kvm',
    use_virtio_disk => '1',
    use_virtio_root => '1',
    use_virtio_net => '1',
    instance_path => '/var/lib/eucalyptus/instances',
    vnet_dhcpdaemon => '/usr/sbin/dhcpd41',
    schedpolicy => 'ROUNDROBIN',
    eucalyptus_loglevel => 'DEBUG',
    cloud_opts => 'none',
  }
}

# clc and walrus
node 'clc_walrus' inherits 'eucalyptus_config' {
  include eucalyptus::clc
  include eucalyptus::walrus
  Exec['init-clc'] -> Exec["reg_walrus_${::hostname}"]
  eucalyptus::cluster { 'cloud1_cluster1':
    cloud_name   => 'cloud1',
    cluster_name => 'cluster1',
  }
}

# sc and cc
node 'sc_cc' inherits 'eucalyptus_config' {
  include eucalyptus::sc
  include eucalyptus::cc
}

# nc
node 'nc' inherits 'eucalyptus_config' {
  include eucalyptus::nc
}
~~~

- run `puppet agent -t` on `clc_walrus`
    * the first time you will likely notice one or more failed `exec` resources due to eucalyptus' services startup time
    * you can confirm which eucalyptus services are online by taking the following steps (on `clc_walrus`):
        * `cd`
        * `euca_conf --get-credentials admin.zip`
        * `unzip admin.zip`
        * `source eucarc`
            * you may see an error about Walrus, it's safe to ignore
        * `euca-describe-services -E`
            * once you have retrieved the credentials, you should not need to repeat the `euca_conf` and `unzip` steps, but you will need to run `source ~/eucarc` every time you start a new bash session
            * the goal state is ENABLED or DISABLED for all listed services (services may show NOTREADY until they have completed startup)
            * the loadbalancing service may show NOTREADY in eucalyptus
              3.3
        * the output of `facter -p | grep euca` should resemble the
          following:

~~~
eucakeys_cloud_cert => LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJB
eucakeys_cloud_pk => LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NB
eucakeys_euca_p12 => MIACAQMwgAYJKoZIhvcNAQcBoIAkgASCA+gwgDCABgkqhkiG9w0BBwGggCSA
~~~

- run `puppet agent -t` on `sc_cc`
    * this should install the SC and CC packages & start the services
    * this will also export the registration commands for consumption on
      `clc_walrus`, which will generate the certs for cluster1
- run `puppet agent -t` until:
    * `curl -G -H  "Accept: application/json" 'http://localhost:8080/v2/resources/File/cloud1_cluster1_cluster_cert' --data-urlencode 'query=["=","exported", true]' 2> /dev/null | grep content` run on the `master` resembles:

~~~
"content" : "-----BEGIN CERTIFICATE-----
MIIDITCCAgmgAwIBAgIGFKrBPFRHMA0GCSqGSIb3DQEBDQUAMEcxCzAJBgNVBAYT
AlVTMQ4wDAYDVQQKEwVDbG91ZDETMBEGA1UECxMKRXVjYWx5cHR1czETMBEGA1UE
AwwKY2Mtc2Nfc2NjYzAeFw0xMzA5MDYwMDUwMzFaFw0xODA5MDYwMDUwMzFaMEcx
CzAJBgNVBAYTAlVTMQ4wDAYDVQQKEwVDbG91ZDETMBEGA1UECxMKRXVjYWx5cHR1
czETMBEGA1UEAwwKY2Mtc2Nfc2NjYzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBAIlLMm54teOlwEmzKBuJTUrWR9vjkmM358IWhgQoWY8+ChOrErIvCfMt
vosJYPjbbop2pUnsU2c8OWwyRTr4t6AyEYe7qqVzSqbrzS5/Mq4QsSk96+dir5Jg
anDtMjmqkf41sfuhss1HF7/gf7oC9/klA5/tfug9EDu6HoBSZ+ulYU0n3kZvP8WW
IyLdiJX8XlMU7QZrrO8sZpHX2j6kTPZ9ntfWtWRckL4zi9Qz7c7I1/hVgoqK1qss
DWZKrDHUOKFKB1rvQ6kJDVZoYzJ8LXQl1VMg6WaJKgdIsr5//spritHwsxwGSYe1
WXoHZRSeF8hx1e6Q6LGEHhaO3LG9rA8CAwEAAaMTMBEwDwYDVR0TAQH/BAUwAwEB
/zANBgkqhkiG9w0BAQ0FAAOCAQEAJehd5R0Gl/K5KM1IjJcpZRG5G89FYgrhfQY6
gnzHqev8fPRKFdyGTxGIIfYtay2J+KV8Jzgfr/I84GHOof9rGIOsZ2l+jbiLhwoW
LTuxEDZSg6EvZxy6GtouDjol7dPrcFW0gAxLklKE2Yqn5lBUo6WVZqTxmKlV5hD5
zZj2TmfkmSVLX3kON3DTQ9HYHJONYLRZmEuIFR7PYPhnFl6E8j9zlNBbjpA4uSDC
Xg2weg0+WQLcHBxVXqICxsoctlnblU7+rAB3hsiaH0hGS1WyPJUFkSfpStmhMAKO
QF6xdIzV/lvnuJ4154aA2ipKiJtLcPvjDPXvv6oiTQytzC3HEg==
-----END CERTIFICATE-----",
~~~

- run `puppet agent -t` on `sc_cc`
    * this should drop the cluster1 certs into
      `/var/lib/eucalyptus/keys`
    * check the state of the certs on `sc_cc` with
        * `ls -alrt /var/lib/eucalyptus/keys`
        * There should be **NO** 0 byte files in this directory
- now run `puppet agent -t` on `clc_walrus` to register the SC & CC services

## Provisioning a new Node Controller instance

- the first Node Controller instance has already been classified in your
  default manifest and the `puppet agent` role should be installed
- run `puppet agent -t` on the `nc` node 
    * this should install the eucalyptus reops, packages and the NC
      service, as well as exporting the registration command for
      consumption on the clc
- run `puppet agent -t` on the `sccc` node, 
    * look for:
        + `Notice: /Stage[main]/Eucalyptus::Cc::Eucalyptus::Cc_reg/Exec[cluster1_reg_nc_node-controller]/returns: executed successfully`
    * and confirm by checking `euca-describe-nodes` on `clc_walrus`

## Deactivating a node

- OOTB, PuppetDB does not purge your database of exported resources or old nodes *ever*
- In order to avoid complications from decommissioned nodes, take the following steps:
    * deactive the node in puppetdb by running this command on the `master`:
        * `puppet node deactivate <certname>`
    * deregister the euca service with the `euca_conf` command on the `clc`, e.g. to deregister the CC service that we set up:
        * `euca_conf --deregister-cluster cluster1 cc_sccc`
