#
#
class eucalyptus::cc::config inherits eucalyptus::cc {
  $cluster_name = $eucalyptus::cc::cluster_name
  $host         = $eucalyptus::cc::host
  $cloud_name   = $eucalyptus::cc::cloud_name
  File <<|title == "${cloud_name}_cloud_cert"|>>
  File <<|title == "${cloud_name}_cloud_pk"|>>
  File <<|title == "${cloud_name}_${cluster_name}_cluster_cert"|>>
  File <<|title == "${cloud_name}_${cluster_name}_cluster_pk"|>>
  File <<|title == "${cloud_name}_${cluster_name}_node_cert"|>>
  File <<|title == "${cloud_name}_${cluster_name}_node_pk"|>>
  File <<|title == "${cloud_name}_${cluster_name}_vtunpass"|>>
}
