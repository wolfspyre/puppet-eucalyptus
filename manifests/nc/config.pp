class eucalyptus::nc::config inherits eucalyptus::nc {
  $cloud_name   = $eucalyptus::nc::cloud_name
  $cluster_name = $eucalyptus::nc::cluster_name
  File <<|title == "${cloud_name}_${cluster_name}_cluster_cert"|>>
  File <<|title == "${cloud_name}_${cluster_name}_node_cert"|>>
  File <<|title == "${cloud_name}_${cluster_name}_node_pk"|>>
  File <<|title == "${cloud_name}_cloud_cert"|>>
}
