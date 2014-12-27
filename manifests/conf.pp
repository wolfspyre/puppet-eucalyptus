# Default values for parameters not overriden in node definitions,
# try to stick to eucalyptus.conf defaults
class eucalyptus::conf(
    $cc_arbitrators         = 'none',
    $cc_port                = '8774',
    $cloud_opts             = '',
    $disable_dns            = 'Y',
    $disable_iscsi          = 'N',
    $enable_ws_security     = 'Y',
    $eucalyptus_dir         = '/',
    $eucalyptus_loglevel    = 'DEBUG',
    $eucalyptus_user        = 'eucalyptus',
    $hypervisor             = 'kvm',
    $instance_path          = '/var/lib/eucalyptus/instances',
    $nc_port                = '8775',
    $nc_service             = 'axis2/services/EucalyptusNC',
    $power_idlethresh       = '0',
    $power_wakethresh       = '0',
    $schedpolicy            = 'ROUNDROBIN',
    $use_virtio_disk        = '1',
    $use_virtio_net         = '0',
    $use_virtio_root        = '1',
    $vnet_addrspernet       = '32',
    $vnet_bridge            = 'br0',
    $vnet_dhcpdaemon        = '/usr/sbin/dhcpd41',
    $vnet_disable_tunneling = 'y',
    $vnet_dns               = '8.8.8.8',
    $vnet_mode              = 'SYSTEM',
    $vnet_netmask           = '255.255.255.0',
    $vnet_privinterface     = 'eth1',
    $vnet_pubinterface      = 'eth0',
    $vnet_publicips         = '192.168.0.50-192.168.0.250',
    $vnet_subnet            = '127.0.0.1',
){
  validate_string(
    $cc_arbitrators,
    $cc_port,
    $cloud_opts,
    $disable_dns,
    $disable_iscsi,
    $enable_ws_security,
    $eucalyptus_dir,
    $eucalyptus_loglevel,
    $eucalyptus_user,
    $hypervisor,
    $instance_path,
    $nc_port,
    $nc_service,
    $power_idlethresh,
    $power_wakethresh,
    $schedpolicy,
    $use_virtio_disk,
    $use_virtio_net,
    $use_virtio_root,
    $vnet_addrspernet,
    $vnet_bridge,
    $vnet_dhcpdaemon,
    $vnet_disable_tunneling,
    $vnet_dns,
    $vnet_mode,
    $vnet_netmask,
    $vnet_privinterface,
    $vnet_pubinterface,
    $vnet_publicips,
    $vnet_subnet,
  )
  @eucalyptus_config {
    'CC_ARBITRATORS':     value => $cc_arbitrators;
    'CC_PORT':            value => $cc_port;
    'CLOUD_OPTS':         value => $cloud_opts;
    'DISABLE_DNS':        value => $disable_dns;
    'DISABLE_ISCSI':      value => $disable_iscsi;
    'DISABLE_TUNNELING':  value => $vnet_disable_tunneling;
    'ENABLE_WS_SECURITY': value => $enable_ws_security;
    'EUCA_USER':          value => $eucalyptus_user;
    'EUCALYPTUS':         value => $eucalyptus_dir;
    'HYPERVISOR':         value => $hypervisor;
    'INSTANCE_PATH':      value => $instance_path;
    'LOGLEVEL':           value => $eucalyptus_loglevel;
    'NC_PORT':            value => $nc_port;
    'NC_SERVICE':         value => $nc_service;
    'POWER_IDLETHRESH':   value => $power_idlethresh;
    'POWER_WAKETHRESH':   value => $power_wakethresh;
    'SCHEDPOLICY':        value => $schedpolicy;
    'USE_VIRTIO_DISK':    value => $use_virtio_disk;
    'USE_VIRTIO_NET':     value => $use_virtio_net;
    'USE_VIRTIO_ROOT':    value => $use_virtio_root;
    'VNET_ADDRSPERNET':   value => $vnet_addrspernet;
    'VNET_BRIDGE':        value => $vnet_bridge;
    'VNET_DHCPDAEMON':    value => $vnet_dhcpdaemon;
    'VNET_DNS':           value => $vnet_dns;
    'VNET_MODE':          value => $vnet_mode;
    'VNET_NETMASK':       value => $vnet_netmask;
    'VNET_PRIVINTERFACE': value => $vnet_privinterface;
    'VNET_PUBINTERFACE':  value => $vnet_pubinterface;
    'VNET_PUBLICIPS':     value => $vnet_publicips;
    'VNET_SUBNET':        value => $vnet_subnet;
  }
}
