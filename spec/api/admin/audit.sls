//// Admin audit: the anomaly event allow list of trusted IP ranges and ASNs.
module slackline/api/admin/audit

method admin.audit.anomaly.allow.getItem {
  response {
    /// Allow list of IPv4 ranges in CIDR notation.
    trusted_cidr: List(String)?
    /// Allow list of Autonomous System Numbers.
    trusted_asns: List(Int)?
  }
}

method admin.audit.anomaly.allow.updateItem {
  args {
    /// Allow list of IPv4 addresses in CIDR notation. Overwrites the previous list.
    trusted_cidr: List(String)? json
    /// Allow list of Autonomous System Numbers, as integers. Overwrites the previous list.
    trusted_asns: List(Int)? json
  }
  response Nil
}
