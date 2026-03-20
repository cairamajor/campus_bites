import 'package:flutter/material.dart';

// ─── App Color Constants ──────────────────────────────────────────────────────
const kBg = Color(0xFFFAFAF8);
const kCard = Color(0xFFFFFFFF);
const kAccent = Color(0xFFFF6B35);
const kAccentLight = Color(0xFFFFF1EC);
const kGreen = Color(0xFF2ECC71);
const kGreenLight = Color(0xFFE8FAF0);
const kPurple = Color(0xFF7C3AED);
const kPurpleLight = Color(0xFFF3EFFE);
const kPink = Color(0xFFF43F5E);
const kPinkLight = Color(0xFFFFF0F3);
const kBlue = Color(0xFF3B82F6);
const kBlueLight = Color(0xFFEFF6FF);
const kText = Color(0xFF1A1A1A);
const kMuted = Color(0xFF9CA3AF);
const kBorder = Color(0xFFF0F0EE);

// ─── Cuisine Emoji Helper ─────────────────────────────────────────────────────
String cuisineEmoji(String cuisine) {
  const map = {
    'American': '🍔',
    'Caribbean': '🌴',
    'Mexican': '🌮',
    'Dessert': '🍰',
    'Halal': '🥙',
    'Healthy': '🥗',
    'Indian': '🍛',
    'Japanese': '🍱',
    'Soul Food': '🍗',
    'BBQ': '🍖',
    'Chinese': '🥡',
  };
  return map[cuisine] ?? '🍽️';
}

