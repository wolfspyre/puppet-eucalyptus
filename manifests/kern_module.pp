# Load or Unload a kernel module
# Inspired by: http://projects.puppetlabs.com/projects/1/wiki/Kernel_Modules_Patterns
#
# == Parameters
# [*name*] - name of kernel module to load
#
# == Examples
#
# kern_module { "drbd": ensure => present }
#
# == Authors
#
# Tom Ellis <tom.ellis@eucalyptus.com\>
# Original author: http://projects.puppetlabs.com/projects/1/wiki/Kernel_Modules_Patterns

define eucalyptus::kern_module (
  $ensure
) {
  validate_re($ensure,['^present', '^absent' ])
  case $ensure {
    present: {
      exec { "insert_module_${name}":
        command => "/sbin/modprobe ${name}",
        unless  => "/bin/grep -q '^${name} ' '/proc/modules'",
      }
    }
    absent: {
      exec { "remove_module_${name}":
        command => "/sbin/modprobe -r ${name}",
        onlyif  => "/bin/grep -q '^${name} ' '/proc/modules'",
      }
    }
    default: { #handled by validate_re
    }
  }
}
