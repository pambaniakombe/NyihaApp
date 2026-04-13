/// Administrator roles — max 3 accounts: one [AdminRole.main] and up to two [AdminRole.helper].
enum AdminRole {
  main,
  helper,
}

class AdminAccount {
  AdminAccount({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.pin,
    /// Optional: member-app phone for this kituo account — may post in Jamii chat when chat is admin-only.
    this.linkedMemberPhone,
  });

  final String id;
  final String displayName;
  /// Login id (demo — replace with secure auth).
  final String email;
  final AdminRole role;
  /// Demo PIN only — never ship plain PINs to production.
  final String pin;
  final String? linkedMemberPhone;
}

enum MemberStatus {
  pending,
  approved,
  suspended,
}

/// Row shown in admin console (mirrors jamii members + status).
class ManagedMember {
  ManagedMember({
    this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.ticks,
    required this.emoji,
    this.status = MemberStatus.approved,
    this.adminProfileNote = '',
    this.adminWarning = '',
    this.balanceTzs = 0,
  });

  String? id;
  String name;
  String phone;
  String location;
  int ticks;
  String emoji;
  MemberStatus status;
  String adminProfileNote;
  String adminWarning;
  /// Deni halisi (TZS) — linasasishwa na wasimamizi.
  int balanceTzs;
}

/// New member signup waiting for admin after registration + fee (demo: in-memory).
class PendingSignupRequest {
  PendingSignupRequest({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.location,
    required this.username,
    required this.children,
    required this.submittedAt,
    this.registrationFeePaid = false,
    this.detailLines = '',
  });

  final String id;
  final String fullName;
  final String phone;
  final String location;
  final String username;
  final int children;
  final DateTime submittedAt;
  /// Admin should verify fee received before approving.
  final bool registrationFeePaid;
  final String detailLines;
}
