import 'package:flutter/material.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import '../models/breed.dart';
import '../models/fur_pattern.dart';

/// Returns the localized display name for a breed.
/// If the breed has a nameKey (seeded breed), uses l10n translation.
/// Otherwise, returns the stored name directly (user-created breed).
String getLocalizedBreedName(BuildContext context, Breed breed) {
  if (breed.nameKey == null) return breed.name;

  final l10n = AppLocalizations.of(context);
  return _breedTranslations(l10n)[breed.nameKey] ?? breed.name;
}

/// Returns the localized display name for a fur pattern.
/// If the pattern has a nameKey (seeded pattern), uses l10n translation.
/// Otherwise, returns the stored name directly (user-created pattern).
String getLocalizedFurPatternName(BuildContext context, FurPattern pattern) {
  if (pattern.nameKey == null) return pattern.name;

  final l10n = AppLocalizations.of(context);
  return _furPatternTranslations(l10n)[pattern.nameKey] ?? pattern.name;
}

Map<String, String> _breedTranslations(AppLocalizations l10n) => {
  'domestic_shorthair': l10n.breedDomesticShorthair,
  'domestic_longhair': l10n.breedDomesticLonghair,
  'persian': l10n.breedPersian,
  'maine_coon': l10n.breedMaineCoon,
  'siamese': l10n.breedSiamese,
  'british_shorthair': l10n.breedBritishShorthair,
  'russian_blue': l10n.breedRussianBlue,
  'ragdoll': l10n.breedRagdoll,
  'bengal': l10n.breedBengal,
  'scottish_fold': l10n.breedScottishFold,
};

Map<String, String> _furPatternTranslations(AppLocalizations l10n) => {
  'solid': l10n.furPatternSolid,
  'tabby': l10n.furPatternTabby,
  'calico': l10n.furPatternCalico,
  'tortoiseshell': l10n.furPatternTortoiseshell,
  'bicolor': l10n.furPatternBicolor,
  'tricolor': l10n.furPatternTricolor,
  'spotted': l10n.furPatternSpotted,
  'pointed': l10n.furPatternPointed,
  'colorpoint': l10n.furPatternColorpoint,
  'smoke': l10n.furPatternSmoke,
  'shaded': l10n.furPatternShaded,
  'chinchilla': l10n.furPatternChinchilla,
};
