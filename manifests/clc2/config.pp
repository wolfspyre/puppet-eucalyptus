class eucalyptus::clc2::config inherits eucalyptus::clc2 {
  File <<|tag == "${cloud_name}_cloud_cert"|>>
  File <<|tag == "${cloud_name}_cloud_pk"|>>

  Exec <<|tag == "${cloud_name}_euca.p12"|>> ->
  File <<|tag == "${cloud_name}_euca.p12"|>>
}
