import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Gatodex'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your cat collection'**
  String get appTagline;

  /// No description provided for @gatoDex.
  ///
  /// In en, this message translates to:
  /// **'gatoDex'**
  String get gatoDex;

  /// No description provided for @gatoMapa.
  ///
  /// In en, this message translates to:
  /// **'gatoMapa'**
  String get gatoMapa;

  /// No description provided for @gatoConfig.
  ///
  /// In en, this message translates to:
  /// **'gatoConfig'**
  String get gatoConfig;

  /// No description provided for @catList.
  ///
  /// In en, this message translates to:
  /// **'Cat list'**
  String get catList;

  /// No description provided for @locationMap.
  ///
  /// In en, this message translates to:
  /// **'Location map'**
  String get locationMap;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeMaterialYou.
  ///
  /// In en, this message translates to:
  /// **'Material You'**
  String get themeMaterialYou;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get searchByName;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @furPattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get furPattern;

  /// No description provided for @allSpecies.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allSpecies;

  /// No description provided for @allPatterns.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allPatterns;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFilters;

  /// No description provided for @filteredPrefix.
  ///
  /// In en, this message translates to:
  /// **'Filtered: '**
  String get filteredPrefix;

  /// No description provided for @catsStats.
  ///
  /// In en, this message translates to:
  /// **'{count} cats • Page {current} of {total}'**
  String catsStats(int count, int current, int total);

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @mosaicView.
  ///
  /// In en, this message translates to:
  /// **'Mosaic View'**
  String get mosaicView;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noCatsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No cats registered'**
  String get noCatsRegistered;

  /// No description provided for @addYourFirstCat.
  ///
  /// In en, this message translates to:
  /// **'Add your first cat!'**
  String get addYourFirstCat;

  /// No description provided for @loadingPage.
  ///
  /// In en, this message translates to:
  /// **'Loading page {page}...'**
  String loadingPage(int page);

  /// No description provided for @goToPage.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get goToPage;

  /// No description provided for @enterPageNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a page number (1-{total}):'**
  String enterPageNumber(int total);

  /// No description provided for @pageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page number'**
  String get pageNumber;

  /// No description provided for @pageExample.
  ///
  /// In en, this message translates to:
  /// **'E.g: {page}'**
  String pageExample(int page);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @invalidPageNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number between 1 and {total}'**
  String invalidPageNumber(int total);

  /// No description provided for @deleteCat.
  ///
  /// In en, this message translates to:
  /// **'Delete Cat'**
  String get deleteCat;

  /// No description provided for @deleteCatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteCatConfirm(String name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @catDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String catDeleted(String name);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @addCat.
  ///
  /// In en, this message translates to:
  /// **'Add Cat'**
  String get addCat;

  /// No description provided for @editCat.
  ///
  /// In en, this message translates to:
  /// **'Edit Cat'**
  String get editCat;

  /// No description provided for @catAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} added successfully'**
  String catAddedSuccess(String name);

  /// No description provided for @catUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} updated successfully'**
  String catUpdatedSuccess(String name);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @catName.
  ///
  /// In en, this message translates to:
  /// **'Cat Name'**
  String get catName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @generateRandomName.
  ///
  /// In en, this message translates to:
  /// **'Generate random name'**
  String get generateRandomName;

  /// No description provided for @errorGeneratingName.
  ///
  /// In en, this message translates to:
  /// **'Error generating name: {error}'**
  String errorGeneratingName(String error);

  /// No description provided for @speciesLabel.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get speciesLabel;

  /// No description provided for @pleaseSelectSpecies.
  ///
  /// In en, this message translates to:
  /// **'Please select a species'**
  String get pleaseSelectSpecies;

  /// No description provided for @furPatternLabel.
  ///
  /// In en, this message translates to:
  /// **'Fur Pattern (Optional)'**
  String get furPatternLabel;

  /// No description provided for @noPattern.
  ///
  /// In en, this message translates to:
  /// **'No Pattern'**
  String get noPattern;

  /// No description provided for @dateMetLabel.
  ///
  /// In en, this message translates to:
  /// **'Date Met (Optional)'**
  String get dateMetLabel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @locationOptional.
  ///
  /// In en, this message translates to:
  /// **'Location (Optional)'**
  String get locationOptional;

  /// No description provided for @locationCoords.
  ///
  /// In en, this message translates to:
  /// **'Location: {lat}, {lng}'**
  String locationCoords(String lat, String lng);

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get deletePhoto;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @unknownSpecies.
  ///
  /// In en, this message translates to:
  /// **'Unknown Species'**
  String get unknownSpecies;

  /// No description provided for @unknownPattern.
  ///
  /// In en, this message translates to:
  /// **'Unknown Pattern'**
  String get unknownPattern;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown Date'**
  String get unknownDate;

  /// No description provided for @noLocation.
  ///
  /// In en, this message translates to:
  /// **'No Location'**
  String get noLocation;

  /// No description provided for @speciesDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get speciesDetailLabel;

  /// No description provided for @furPatternDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Fur Pattern'**
  String get furPatternDetailLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @dateMetDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Date Met'**
  String get dateMetDetailLabel;

  /// No description provided for @photoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoLabel;

  /// No description provided for @tapMapToSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to select location'**
  String get tapMapToSelectLocation;

  /// No description provided for @useMyCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useMyCurrentLocation;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @currentLocationSet.
  ///
  /// In en, this message translates to:
  /// **'Current location set'**
  String get currentLocationSet;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied. Please enable them in settings.'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable them.'**
  String get locationServicesDisabled;

  /// No description provided for @errorGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error getting location: {error}'**
  String errorGettingLocation(String error);

  /// No description provided for @doubleTapOrPinchToZoom.
  ///
  /// In en, this message translates to:
  /// **'Double tap or pinch to zoom in • Tap outside to close'**
  String get doubleTapOrPinchToZoom;

  /// No description provided for @doubleTapToZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Double tap to zoom out'**
  String get doubleTapToZoomOut;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @withLocation.
  ///
  /// In en, this message translates to:
  /// **'With Location'**
  String get withLocation;

  /// No description provided for @withoutLocation.
  ///
  /// In en, this message translates to:
  /// **'Without Location'**
  String get withoutLocation;

  /// No description provided for @centerCatLocations.
  ///
  /// In en, this message translates to:
  /// **'Center cat locations'**
  String get centerCatLocations;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh data'**
  String get refreshData;

  /// No description provided for @noCatsWithLocation.
  ///
  /// In en, this message translates to:
  /// **'No cats with location'**
  String get noCatsWithLocation;

  /// No description provided for @addLocationsHint.
  ///
  /// In en, this message translates to:
  /// **'Add locations to your cats to see them on the map'**
  String get addLocationsHint;

  /// No description provided for @addCats.
  ///
  /// In en, this message translates to:
  /// **'Add Cats'**
  String get addCats;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @manageBackups.
  ///
  /// In en, this message translates to:
  /// **'Manage backups'**
  String get manageBackups;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get appInfo;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'An app to catalog and manage information about cats you encounter.'**
  String get appDescription;

  /// No description provided for @developedWithFlutter.
  ///
  /// In en, this message translates to:
  /// **'Developed with Flutter'**
  String get developedWithFlutter;

  /// No description provided for @testingAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Testing (Advanced!)'**
  String get testingAdvanced;

  /// No description provided for @advancedWarning.
  ///
  /// In en, this message translates to:
  /// **'These options are mainly for developers. If you don\'t know what you\'re doing, you probably shouldn\'t touch this.'**
  String get advancedWarning;

  /// No description provided for @dbManagement.
  ///
  /// In en, this message translates to:
  /// **'DB Management'**
  String get dbManagement;

  /// No description provided for @manageDatabase.
  ///
  /// In en, this message translates to:
  /// **'Manage database'**
  String get manageDatabase;

  /// No description provided for @addTestData.
  ///
  /// In en, this message translates to:
  /// **'Add Test Data'**
  String get addTestData;

  /// No description provided for @addingData.
  ///
  /// In en, this message translates to:
  /// **'Adding data...'**
  String get addingData;

  /// No description provided for @addExampleCats.
  ///
  /// In en, this message translates to:
  /// **'Add example cats'**
  String get addExampleCats;

  /// No description provided for @deleteAllCats.
  ///
  /// In en, this message translates to:
  /// **'Delete All Cats'**
  String get deleteAllCats;

  /// No description provided for @deleteAllCatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deletes ALL cats from the database'**
  String get deleteAllCatsSubtitle;

  /// No description provided for @addTestDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Test Data'**
  String get addTestDataTitle;

  /// No description provided for @addTestDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to add test cats?\n\nThis will add 3 example cats with randomly generated names.\nExisting cats will not be deleted.'**
  String get addTestDataConfirm;

  /// No description provided for @addData.
  ///
  /// In en, this message translates to:
  /// **'Add Data'**
  String get addData;

  /// No description provided for @testCatsAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'3 test cats added successfully with names: {names}!'**
  String testCatsAddedSuccess(String names);

  /// No description provided for @errorAddingTestCats.
  ///
  /// In en, this message translates to:
  /// **'Error adding test cats: {error}'**
  String errorAddingTestCats(String error);

  /// No description provided for @noSpeciesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No species available. You need at least one species to create test cats.'**
  String get noSpeciesAvailable;

  /// No description provided for @dangerTitle.
  ///
  /// In en, this message translates to:
  /// **'Danger!'**
  String get dangerTitle;

  /// No description provided for @deleteAllCatsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you COMPLETELY SURE you want to delete ALL cats?\n\n⚠️ This action CANNOT be undone.\n⚠️ ALL cat data will be lost.\n⚠️ Photos will also be deleted.\n\nOnly proceed if you know exactly what you\'re doing.'**
  String get deleteAllCatsConfirm;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'DELETE ALL'**
  String get deleteAll;

  /// No description provided for @allCatsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All cats have been deleted!'**
  String get allCatsDeleted;

  /// No description provided for @errorDeletingCats.
  ///
  /// In en, this message translates to:
  /// **'Error deleting cats: {error}'**
  String errorDeletingCats(String error);

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link: {url}'**
  String couldNotOpenLink(String url);

  /// No description provided for @cannotOpenLinkType.
  ///
  /// In en, this message translates to:
  /// **'Cannot open this type of link: {url}'**
  String cannotOpenLinkType(String url);

  /// No description provided for @errorOpeningLink.
  ///
  /// In en, this message translates to:
  /// **'Error opening link: {error}'**
  String errorOpeningLink(String error);

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @importFromFile.
  ///
  /// In en, this message translates to:
  /// **'Import from File'**
  String get importFromFile;

  /// No description provided for @selectBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Select backup file (.json)'**
  String get selectBackupFile;

  /// No description provided for @selectJsonFile.
  ///
  /// In en, this message translates to:
  /// **'Please select a .json backup file'**
  String get selectJsonFile;

  /// No description provided for @errorSelectingFile.
  ///
  /// In en, this message translates to:
  /// **'Error selecting file: {error}'**
  String errorSelectingFile(String error);

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup Created'**
  String get backupCreated;

  /// No description provided for @backupCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully.\n\nFile saved at:\n{path}'**
  String backupCreatedMessage(String path);

  /// No description provided for @errorCreatingBackup.
  ///
  /// In en, this message translates to:
  /// **'Error creating backup: {error}'**
  String errorCreatingBackup(String error);

  /// No description provided for @errorLoadingBackups.
  ///
  /// In en, this message translates to:
  /// **'Error loading backups: {error}'**
  String errorLoadingBackups(String error);

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackup;

  /// No description provided for @howToImport.
  ///
  /// In en, this message translates to:
  /// **'How would you like to import the data?'**
  String get howToImport;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File: {name}'**
  String file(String name);

  /// No description provided for @addOnlyNew.
  ///
  /// In en, this message translates to:
  /// **'Add Only New'**
  String get addOnlyNew;

  /// No description provided for @replaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace All'**
  String get replaceAll;

  /// No description provided for @replaceAllData.
  ///
  /// In en, this message translates to:
  /// **'Replace All Data'**
  String get replaceAllData;

  /// No description provided for @replaceAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This action will delete all existing cats and replace them with the backup file data.'**
  String get replaceAllConfirm;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import Successful'**
  String get importSuccess;

  /// No description provided for @importCompleted.
  ///
  /// In en, this message translates to:
  /// **'Import completed:'**
  String get importCompleted;

  /// No description provided for @catsImported.
  ///
  /// In en, this message translates to:
  /// **'• {count} cats imported'**
  String catsImported(int count);

  /// No description provided for @catsSkipped.
  ///
  /// In en, this message translates to:
  /// **'• {count} cats skipped (already exist)'**
  String catsSkipped(int count);

  /// No description provided for @errors.
  ///
  /// In en, this message translates to:
  /// **'Errors:'**
  String get errors;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Import error: {error}'**
  String importError(String error);

  /// No description provided for @errorImportingData.
  ///
  /// In en, this message translates to:
  /// **'Error importing data: {error}'**
  String errorImportingData(String error);

  /// No description provided for @deleteBackup.
  ///
  /// In en, this message translates to:
  /// **'Delete Backup'**
  String get deleteBackup;

  /// No description provided for @deleteBackupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this backup?\n\n{name}'**
  String deleteBackupConfirm(String name);

  /// No description provided for @backupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Backup deleted'**
  String get backupDeleted;

  /// No description provided for @errorDeletingBackup.
  ///
  /// In en, this message translates to:
  /// **'Error deleting backup: {error}'**
  String errorDeletingBackup(String error);

  /// No description provided for @errorSharingBackup.
  ///
  /// In en, this message translates to:
  /// **'Error sharing backup: {error}'**
  String errorSharingBackup(String error);

  /// No description provided for @noBackups.
  ///
  /// In en, this message translates to:
  /// **'No backups'**
  String get noBackups;

  /// No description provided for @createFirstBackup.
  ///
  /// In en, this message translates to:
  /// **'Create your first backup above'**
  String get createFirstBackup;

  /// No description provided for @catsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cats'**
  String catsCount(int count);

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @databaseManagement.
  ///
  /// In en, this message translates to:
  /// **'Database Management'**
  String get databaseManagement;

  /// No description provided for @databaseStatus.
  ///
  /// In en, this message translates to:
  /// **'Database Status'**
  String get databaseStatus;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @existsAndActive.
  ///
  /// In en, this message translates to:
  /// **'Exists and Active'**
  String get existsAndActive;

  /// No description provided for @doesNotExist.
  ///
  /// In en, this message translates to:
  /// **'Does Not Exist'**
  String get doesNotExist;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @lastModified.
  ///
  /// In en, this message translates to:
  /// **'Last Modified'**
  String get lastModified;

  /// No description provided for @filePath.
  ///
  /// In en, this message translates to:
  /// **'File Path'**
  String get filePath;

  /// No description provided for @errorLoadingDbInfo.
  ///
  /// In en, this message translates to:
  /// **'Error loading database info'**
  String get errorLoadingDbInfo;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @maintenanceActions.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Actions'**
  String get maintenanceActions;

  /// No description provided for @backupButton.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupButton;

  /// No description provided for @recreateDb.
  ///
  /// In en, this message translates to:
  /// **'Recreate DB'**
  String get recreateDb;

  /// No description provided for @recreateDatabase.
  ///
  /// In en, this message translates to:
  /// **'Recreate Database'**
  String get recreateDatabase;

  /// No description provided for @recreateDbConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to recreate the database? This will delete all existing data and create a new database with initial data.'**
  String get recreateDbConfirm;

  /// No description provided for @recreate.
  ///
  /// In en, this message translates to:
  /// **'Recreate'**
  String get recreate;

  /// No description provided for @dbRecreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Database recreated successfully'**
  String get dbRecreatedSuccess;

  /// No description provided for @errorRecreatingDb.
  ///
  /// In en, this message translates to:
  /// **'Error recreating database: {error}'**
  String errorRecreatingDb(String error);

  /// No description provided for @dbPathCopied.
  ///
  /// In en, this message translates to:
  /// **'Database path copied to clipboard'**
  String get dbPathCopied;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @errorRefreshingData.
  ///
  /// In en, this message translates to:
  /// **'Error refreshing data: {error}'**
  String errorRefreshingData(String error);

  /// No description provided for @errorLoadingPage.
  ///
  /// In en, this message translates to:
  /// **'Error loading page: {error}'**
  String errorLoadingPage(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
