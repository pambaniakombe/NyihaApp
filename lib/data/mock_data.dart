import 'package:flutter/material.dart';
import '../models/models.dart';

final List<Map<String, dynamic>> onboardSlides = [
  {
    'icon': '🏔️',
    'imageAsset': 'assets/ic_launcher-dbe283b4-1882-48a2-8b1b-9c4202a0f734.png',
    'title': 'Karibu Nyiha App',
    'sub': 'Hili ni nyukwaa kwaajili ya wanyiha, Tunayo furaha kukualika wewe mnyiha kuungana na wanyiha wote duniani ili tuweze kushirikiana katika mambo mbalimbali',
    'color': const Color(0xFFD4A017),
  },
  {
    'icon': '🤝',
    'title': 'Jamii Moja',
    'sub': 'Wasiliana na wanajamii, shiriki taarifa muhimu, na kuwa sehemu ya umoja wetu.',
    'color': const Color(0xFFC45E1A),
  },
  {
    'icon': '📊',
    'title': 'Kuhaya kwe kumwinyu',
    'sub': 'Nyiha Society ipo tayari kukushika mkono pale unapotatwa na matatizo, kuwa huru kwako ni kama kwetu',
    'color': const Color(0xFF2D8A4E),
  },
  {
    'icon': '🛍️',
    'title': 'Utambuzi',
    'sub': 'Tunatambuana kwa sare zetu , kofia na tshirt ungana nasi leo uwe miongoni mwa wana familia ya nyiha society',
    'color': const Color(0xFF1A5FA8),
  },
];

const List<MockMember> mockMembers = [
  MockMember(name: 'Agnes Mwakasege', loc: 'Mbeya', ticks: 22, emoji: '👩🏿'),
  MockMember(name: 'Petro Mwakyusa', loc: 'Dar es Salaam', ticks: 18, emoji: '👨🏿'),
  MockMember(name: 'Mama Zuhura Nkosi', loc: 'Nairobi', ticks: 31, emoji: '👩🏾'),
  MockMember(name: 'Daniel Mwamtemi', loc: 'Dodoma', ticks: 15, emoji: '👨🏾'),
  MockMember(name: 'Grace Chisenye', loc: 'Lusaka, Zambia', ticks: 27, emoji: '👩🏿'),
  MockMember(name: 'Lulez Mtemi', loc: 'Dar es Salaam', ticks: 12, emoji: '👨🏾'),
  MockMember(name: 'Pastor Yohana Mwakipesile', loc: 'Mbozi', ticks: 40, emoji: '👨🏿'),
  MockMember(name: 'Fatuma Mkandawile', loc: 'Songwe', ticks: 12, emoji: '👩🏾'),
];

/// Matukio ya jamii (machapisho kutoka kwa wakuu) — nyumbani chini ya MATUKIO YA JAMII.
final List<AdminCommunityPost> mockAdminCommunityPosts = [
  AdminCommunityPost(
    id: 'post-msiba',
    authorLabel: 'Wakuu wa Jamii',
    headline: 'Msiba wa Juma Sambewe',
    body:
        'Tunatoa pole kwa familia. Mazishi yatafanyika nyumbani kwa Sambewe — sisi ni familia moja. Tafadhali wasiliana na kamati ya msiba kwa michango na usafiri.',
    dateLabel: '12/04/2070',
    tag: 'Msiba',
    imageUrls: [
      'https://images.unsplash.com/photo-1519834785169-98be25ec3f84?w=900&q=80',
      'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=900&q=80',
    ],
  ),
  AdminCommunityPost(
    id: 'post-sherehe',
    authorLabel: 'Wakuu wa Jamii',
    headline: 'Sherehe ya kijamii — Mwaka mpya',
    body:
        'Tunakukaribisha wewe na familia. Chakula, ngoma, na utamaduni wa Nyiha utakuwepo. Sisi ni familia — tuje wote kwa amani na furaha.',
    dateLabel: '20/04/2070',
    tag: 'Sherehe',
    imageUrls: [
      'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=900&q=80',
    ],
  ),
  AdminCommunityPost(
    id: 'post-mkutano',
    authorLabel: 'Wakuu wa Jamii',
    headline: 'Mkutano wa dharura — bajeti ya Mkeka',
    body:
        'Kikao fupi kuhusu michango ya mwaka. Mwaliko kwa wawakilishi wa familia; maoni yatajumlishwa kwenye ripoti ya Jamii.',
    dateLabel: '05/05/2070',
    tag: 'Mkutano',
    imageUrls: [
      'https://images.unsplash.com/photo-1544531586-fde5298d40e0?w=900&q=80',
    ],
  ),
];

/// Fallback single image if a post ever has no URLs (should not happen for admin matangazo).
const String kDefaultAdminCommunityPostImage =
    'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=900&q=80';

const List<MockEvent> mockEvents = [
  MockEvent(
    title: 'Mkutano Mkuu wa Mwaka 2025',
    desc: 'Mkutano wa mwaka kwa wanajamii wote. Agenda kuu: Bajeti, Mkeka, Uongozi mpya.',
    date: '15 Agosti 2025',
    tag: 'Mkutano',
  ),
  MockEvent(
    title: 'Harusi ya Kijamii — Mwakasege-Temba',
    desc: 'Tunaomba wanajamii wote kushiriki katika sherehe hii kubwa.',
    date: '3 Julai 2025',
    tag: 'Sherehe',
  ),
  MockEvent(
    title: 'Msaada — Familia Nkosi',
    desc: 'Familia ya Nkosi imepoteza mzazi. Michango ya msaada inakusanywa.',
    date: '28 Juni 2025',
    tag: 'Msaada',
  ),
  MockEvent(
    title: 'Siku ya Nyiha Duniani',
    desc: 'Tutaadhimisha utamaduni wetu kwa ngoma, chakula, na sanaa za asili.',
    date: '10 Oktoba 2025',
    tag: 'Utamaduni',
  ),
];

const List<MockProduct> mockProducts = [
  MockProduct(
    name: 'Shati la Nyiha',
    priceLabel: 'TZS 25,000',
    emoji: '👕',
    color: 0xFFD4A017,
    imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=900&q=80',
  ),
  MockProduct(
    name: 'Kofia ya Nyiha',
    priceLabel: 'TZS 12,000',
    emoji: '🧢',
    color: 0xFFC45E1A,
    imageUrl: 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=900&q=80',
  ),
  MockProduct(
    name: 'Mkoba wa Ngozi',
    priceLabel: 'TZS 45,000',
    emoji: '👜',
    color: 0xFF2D8A4E,
    imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=900&q=80',
  ),
  MockProduct(
    name: 'Kitenge cha Nyiha',
    priceLabel: 'TZS 18,000',
    emoji: '🎨',
    color: 0xFF1A5FA8,
    imageUrl: 'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?w=900&q=80',
  ),
  MockProduct(
    name: 'Kikombe cha Kahawa',
    priceLabel: 'TZS 8,000',
    emoji: '☕',
    color: 0xFF8B6914,
    imageUrl: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=900&q=80',
  ),
  MockProduct(
    name: 'Daftari la Nyiha',
    priceLabel: 'TZS 5,000',
    emoji: '📔',
    color: 0xFF7C3D0C,
    imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=900&q=80',
  ),
];
