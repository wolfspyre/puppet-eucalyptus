class eucalyptus::walrus::config inherits eucalyptus::walrus {
  $cloud_name = $eucalyptus::cloud_name
  Exec <<|tag == "${cloud_name}_euca.p12"|>> ->
  File <<|tag == "${cloud_name}_euca.p12"|>>
}
