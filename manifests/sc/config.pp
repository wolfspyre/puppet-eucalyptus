class eucalyptus::sc::config inherits eucalyptus::sc {
  $cloud_name   = $eucalyptus::sc::cloud_name
  $cluster_name = $eucalyptus::sc::cluster_name
  Exec <<|tag == "${cloud_name}_euca.p12"|>> ->
  File <<|tag == "${cloud_name}_euca.p12"|>>
  File <<|title == "${cloud_name}_${cluster_name}_cluster_cert"|>>
  File <<|title == "${cloud_name}_${cluster_name}_cluster_pk"|>>
}
