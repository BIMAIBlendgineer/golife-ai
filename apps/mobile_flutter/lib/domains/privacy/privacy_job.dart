class PrivacyJob {
  const PrivacyJob({
    required this.jobId,
    required this.kind,
    required this.status,
    required this.auditRef,
  });

  final String jobId;
  final String kind;
  final String status;
  final String auditRef;

  Map<String, Object?> toJson() {
    return {
      'job_id': jobId,
      'kind': kind,
      'status': status,
      'audit_ref': auditRef,
    };
  }

  factory PrivacyJob.fromJson(Map<String, dynamic> json) {
    return PrivacyJob(
      jobId: (json['job_id'] ?? json['jobId'] ?? '').toString(),
      kind: (json['kind'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      auditRef: (json['audit_ref'] ?? json['auditRef'] ?? '').toString(),
    );
  }
}
