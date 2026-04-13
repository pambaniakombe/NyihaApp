import 'dart:typed_data';

class NyihaUser {
  NyihaUser({
    required this.name,
    required this.phone,
    required this.location,
    required this.children,
    required this.status,
    required this.ticksPaid,
    required this.balance,
    required this.username,
  });

  String name;
  String phone;
  String location;
  int children;
  String status;
  int ticksPaid;
  int balance;
  String username;
}

enum ChatMediaKind { text, image, voice }

class ChatMsg {
  ChatMsg({
    required this.from,
    required this.text,
    required this.time,
    required this.me,
    this.emoji,
    ChatMediaKind? kind,
    this.imageBytes,
    this.voiceFilePath,
    this.voiceDurationSec,
  }) : _kindCode = kind == null ? 0 : kind.index;

  final String from;
  final String text;
  final String time;
  final bool me;
  final String? emoji;
  /// 0=text, 1=image, 2=voice — stored as int; nullable backing field so stale instances
  /// after hot reload (old layout) do not throw when read.
  final int? _kindCode;
  int get kindCode => _kindCode ?? 0;
  final Uint8List? imageBytes;
  final String? voiceFilePath;
  final int? voiceDurationSec;

  ChatMediaKind get mediaKind {
    final i = kindCode.clamp(0, ChatMediaKind.values.length - 1);
    return ChatMediaKind.values[i];
  }
}

class MockMember {
  const MockMember({
    required this.name,
    required this.loc,
    required this.ticks,
    required this.emoji,
  });

  final String name;
  final String loc;
  final int ticks;
  final String emoji;
}

class MockEvent {
  const MockEvent({
    required this.title,
    required this.desc,
    required this.date,
    required this.tag,
  });

  final String title;
  final String desc;
  final String date;
  final String tag;
}

/// Admin-issued community notice (home feed) — msiba, mkutano, sherehe, n.k.
/// Prefer at least one entry in [imageUrls]; the UI falls back to a default if empty.
class AdminCommunityPost {
  const AdminCommunityPost({
    required this.id,
    required this.authorLabel,
    required this.headline,
    required this.body,
    required this.dateLabel,
    required this.tag,
    this.imageUrls = const [],
  });

  final String id;
  final String authorLabel;
  final String headline;
  final String body;
  final String dateLabel;
  final String tag;
  /// Network image URLs (carousel if more than one).
  final List<String> imageUrls;
}

/// Telegram-style quick reactions on admin posts (keys stable for [AppState]).
class CommunityReactionKind {
  const CommunityReactionKind({required this.key, required this.emoji});

  final String key;
  final String emoji;
}

const List<CommunityReactionKind> kCommunityReactionKinds = [
  CommunityReactionKind(key: 'fire', emoji: '🔥'),
  CommunityReactionKind(key: 'like', emoji: '👍'),
  CommunityReactionKind(key: 'love', emoji: '❤️'),
  CommunityReactionKind(key: 'cry', emoji: '😢'),
  CommunityReactionKind(key: 'hungry', emoji: '🍽️'),
];

class MockProduct {
  const MockProduct({
    required this.name,
    required this.priceLabel,
    required this.emoji,
    required this.color,
    required this.imageUrl,
  });

  final String name;
  final String priceLabel;
  final String emoji;
  final int color;
  /// Network image for carousel and duka (replace with your CDN or assets later).
  final String imageUrl;
}

/// Placed duka order (awaiting payment; seller confirms later).
class PlacedShopOrder {
  PlacedShopOrder({
    required this.id,
    required this.productName,
    required this.priceLabel,
    required this.size,
    required this.rangi,
    required this.idadi,
    required this.placedAt,
    required this.buyerName,
    this.status = 'inasubiri malipo',
  });

  final String id;
  final String productName;
  final String priceLabel;
  final String size;
  final String rangi;
  final int idadi;
  final DateTime placedAt;
  final String buyerName;
  String status;
}

/// Annual Mkeka / tiki payment flow: user pays → money received → admin approves → [NyihaUser.ticksPaid] increases.
enum TickPaymentPhase {
  waitingMoney,
  waitingAdminApproval,
}

class PendingTickPayment {
  PendingTickPayment({
    required this.id,
    required this.tickCount,
    required this.submittedAt,
    this.phase = TickPaymentPhase.waitingMoney,
  });

  final String id;
  final int tickCount;
  final DateTime submittedAt;
  TickPaymentPhase phase;
}

class PollOption {
  PollOption({required this.t, required this.v});

  String t;
  int v;
}

class MockPoll {
  MockPoll({required this.q, required this.options});

  final String q;
  final List<PollOption> options;
  bool voted = false;
  int? votedIdx;
}
