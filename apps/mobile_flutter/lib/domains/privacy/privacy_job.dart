class PrivacyJob {
  const PrivacyJob({
    required this.jobId,
    required this.kind,
    required this.status,
    required this.auditRef,
    required this.trace,
  });

  final String jobId;
  final String kind;
  final String status;
  final String auditRef;
  final Map<String, Object?> trace;

  Map<String, Object?> toJson() {
    return {
      'job_id': jobId,
      'kind': kind,
      'status': status,
      'audit_ref': auditRef,
      'trace': trace,
    };
  }

  factory PrivacyJob.fromJson(Map<String, dynamic> json) {
    return PrivacyJob(
      jobId: (json['job_id'] ?? json['jobId'] ?? '').toString(),
      kind: (json['kind'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      auditRef: (json['audit_ref'] ?? json['auditRef'] ?? '').toString(),
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ??
            const <String, Object?>{},
      ),
    );
  }
}
