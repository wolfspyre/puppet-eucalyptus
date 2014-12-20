#
class eucalyptus::clc::reg inherits eucalyptus::clc {
  Class[eucalyptus::clc::config] -> Class[eucalyptus::clc::reg]
  if defined(Class[eucalyptus::walrus]) {
    Class['eucalyptus::walrus_reg'] -> Exec <<| tag == $cloud_name |>>
  } else {
    Exec <<| tag == $cloud_name |>>
  }
}
