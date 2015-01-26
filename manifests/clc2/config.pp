class eucalyptus::clc2::config inherits eucalyptus::clc2 {
  $host       = $eucalyptus::clc2::host
  $cloud_name = $eucalyptus::clc2::cloud_name
  File <<|tag == "${cloud_name}_cloud_cert"|>>
  File <<|tag == "${cloud_name}_cloud_pk"|>>

  Exec <<|tag == "${cloud_name}_euca.p12"|>> ->
  File <<|tag == "${cloud_name}_euca.p12"|>>
}
