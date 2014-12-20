class eucalyptus::clc (
  $cloud_name = 'cloud1'
) {
  validate_string($cloud_name)
  include eucalyptus
  include eucalyptus::conf
  Class[eucalyptus] -> Class[eucalyptus::clc]

  include eucalyptus::clc::install
  include eucalyptus::clc::config
  include eucalyptus::clc::reg
}
