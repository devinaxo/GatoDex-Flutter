// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Gatodex';

  @override
  String get appTagline => 'Your personal кот collection';

  @override
  String get gatoDex => 'gatoDex';

  @override
  String get gatoMapa => 'gatoMapa';

  @override
  String get gatoConfig => 'gatoConfig';

  @override
  String get catList => 'Cat list';

  @override
  String get locationMap => 'Location map';

  @override
  String get appSettings => 'App settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeMaterialYou => 'Material You';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get searchByName => 'Search by name or alias...';

  @override
  String get filters => 'Filters';

  @override
  String get breed => 'Breed';

  @override
  String get furPattern => 'Pattern';

  @override
  String get allBreeds => 'All';

  @override
  String get allPatterns => 'All';

  @override
  String get dateRange => 'Date range';

  @override
  String get clearFilters => 'Clear';

  @override
  String get filteredPrefix => 'Filtered: ';

  @override
  String catsStats(int count, int current, int total) {
    return '$count cats • Page $current of $total';
  }

  @override
  String get listView => 'List View';

  @override
  String get mosaicView => 'Mosaic View';

  @override
  String get refresh => 'Refresh';

  @override
  String get noCatsRegistered => 'No cats registered';

  @override
  String get addYourFirstCat => 'Add your first cat!';

  @override
  String loadingPage(int page) {
    return 'Loading page $page...';
  }

  @override
  String get goToPage => 'Go to page';

  @override
  String enterPageNumber(int total) {
    return 'Enter a page number (1-$total):';
  }

  @override
  String get pageNumber => 'Page number';

  @override
  String pageExample(int page) {
    return 'E.g: $page';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get go => 'Go';

  @override
  String invalidPageNumber(int total) {
    return 'Please enter a valid number between 1 and $total';
  }

  @override
  String get deleteCat => 'Delete Cat';

  @override
  String deleteCatConfirm(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get delete => 'Delete';

  @override
  String catDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get edit => 'Edit';

  @override
  String get addCat => 'Add Cat';

  @override
  String get editCat => 'Edit Cat';

  @override
  String catAddedSuccess(String name) {
    return '$name added successfully';
  }

  @override
  String catUpdatedSuccess(String name) {
    return '$name updated successfully';
  }

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get catName => 'Cat Name';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get generateRandomName => 'Generate random name';

  @override
  String errorGeneratingName(String error) {
    return 'Error generating name: $error';
  }

  @override
  String get breedLabel => 'Breed';

  @override
  String get pleaseSelectBreed => 'Please select a breed';

  @override
  String get furPatternLabel => 'Fur Pattern (Optional)';

  @override
  String get noPattern => 'No Pattern';

  @override
  String get dateMetLabel => 'Date Met (Optional)';

  @override
  String get selectDate => 'Select date';

  @override
  String get locationOptional => 'Location (Optional)';

  @override
  String locationCoords(String lat, String lng) {
    return 'Location: $lat, $lng';
  }

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get deletePhoto => 'Delete photo';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get photosLabel => 'Photos';

  @override
  String photosCount(int count) {
    return '$count/5 photos';
  }

  @override
  String get maxPhotosReached => 'Maximum of 5 photos reached';

  @override
  String get aliasesLabel => 'Aliases (Optional)';

  @override
  String get aliasHint => 'Alias name';

  @override
  String get addAlias => 'Add alias';

  @override
  String get aliasEmpty => 'Please enter an alias';

  @override
  String get saving => 'Saving...';

  @override
  String get unknownBreed => 'Unknown Breed';

  @override
  String get unknownPattern => 'Unknown Pattern';

  @override
  String get unknownDate => 'Unknown Date';

  @override
  String get noLocation => 'No Location';

  @override
  String get breedDetailLabel => 'Breed';

  @override
  String get furPatternDetailLabel => 'Fur Pattern';

  @override
  String get locationLabel => 'Location';

  @override
  String get dateMetDetailLabel => 'Date Met';

  @override
  String get photoLabel => 'Photo';

  @override
  String get aliasesDetailLabel => 'A.K.A';

  @override
  String get tapMapToSelectLocation => 'Tap on the map to select location';

  @override
  String get useMyCurrentLocation => 'Use my current location';

  @override
  String get clear => 'Clear';

  @override
  String get currentLocationSet => 'Current location set';

  @override
  String get locationPermissionDenied => 'Location permissions denied';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permissions are permanently denied. Please enable them in settings.';

  @override
  String get locationServicesDisabled =>
      'Location services are disabled. Please enable them.';

  @override
  String errorGettingLocation(String error) {
    return 'Error getting location: $error';
  }

  @override
  String get doubleTapOrPinchToZoom =>
      'Double tap or pinch to zoom in • Tap outside to close';

  @override
  String get doubleTapToZoomOut => 'Double tap to zoom out';

  @override
  String get total => 'Total';

  @override
  String get withLocation => 'With Location';

  @override
  String get withoutLocation => 'Without Location';

  @override
  String get centerCatLocations => 'Center cat locations';

  @override
  String get refreshData => 'Refresh data';

  @override
  String get noCatsWithLocation => 'No cats with location';

  @override
  String get addLocationsHint =>
      'Add locations to your cats to see them on the map';

  @override
  String get addCats => 'Add Cats';

  @override
  String get general => 'General';

  @override
  String get backup => 'Backup';

  @override
  String get manageBackups => 'Manage backups';

  @override
  String get about => 'About';

  @override
  String get appInfo => 'App information';

  @override
  String get appDescription =>
      'An app and personal passion project to catalog and manage information about cats you encounter, be it strays or your own. Inspired by my need to do exactly that.';

  @override
  String get developedWithFlutter => 'Developed with Flutter and lots of love';

  @override
  String get testingAdvanced => 'Testing (Advanced!)';

  @override
  String get advancedWarning =>
      'These options are mainly for developers. If you don\'t know what you\'re doing, you probably shouldn\'t touch this.';

  @override
  String get dbManagement => 'DB Management';

  @override
  String get manageDatabase => 'Manage database';

  @override
  String get addTestData => 'Add Test Data';

  @override
  String get addingData => 'Adding data...';

  @override
  String get addExampleCats => 'Add example cats';

  @override
  String get deleteAllCats => 'Delete All Cats';

  @override
  String get deleteAllCatsSubtitle => 'Deletes ALL cats from the database';

  @override
  String get addTestDataTitle => 'Add Test Data';

  @override
  String get addTestDataConfirm =>
      'Are you sure you want to add test cats?\n\nThis will add 3 example cats with randomly generated names.\nExisting cats will not be deleted.';

  @override
  String get addData => 'Add Data';

  @override
  String testCatsAddedSuccess(String names) {
    return '3 test cats added successfully with names: $names!';
  }

  @override
  String errorAddingTestCats(String error) {
    return 'Error adding test cats: $error';
  }

  @override
  String get noBreedsAvailable =>
      'No breeds available. You need at least one breed to create test cats.';

  @override
  String get dangerTitle => 'Danger!';

  @override
  String get deleteAllCatsConfirm =>
      'Are you COMPLETELY SURE you want to delete ALL cats?\n\n⚠️ This action CANNOT be undone.\n⚠️ ALL cat data will be lost.\n⚠️ Photos will also be deleted.\n\nOnly proceed if you know exactly what you\'re doing.';

  @override
  String get deleteAll => 'DELETE ALL';

  @override
  String get allCatsDeleted => 'All cats have been deleted!';

  @override
  String errorDeletingCats(String error) {
    return 'Error deleting cats: $error';
  }

  @override
  String couldNotOpenLink(String url) {
    return 'Could not open the link: $url';
  }

  @override
  String cannotOpenLinkType(String url) {
    return 'Cannot open this type of link: $url';
  }

  @override
  String errorOpeningLink(String error) {
    return 'Error opening link: $error';
  }

  @override
  String get backupTitle => 'Backup';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get creating => 'Creating...';

  @override
  String get importFromFile => 'Import from File';

  @override
  String get selectBackupFile => 'Select backup file (.json)';

  @override
  String get selectJsonFile => 'Please select a .json backup file';

  @override
  String errorSelectingFile(String error) {
    return 'Error selecting file: $error';
  }

  @override
  String get backupCreated => 'Backup Created';

  @override
  String backupCreatedMessage(String path) {
    return 'Data exported successfully.\n\nFile saved at:\n$path';
  }

  @override
  String errorCreatingBackup(String error) {
    return 'Error creating backup: $error';
  }

  @override
  String errorLoadingBackups(String error) {
    return 'Error loading backups: $error';
  }

  @override
  String get importBackup => 'Import Backup';

  @override
  String get howToImport => 'How would you like to import the data?';

  @override
  String file(String name) {
    return 'File: $name';
  }

  @override
  String get addOnlyNew => 'Add Only New';

  @override
  String get replaceAll => 'Replace All';

  @override
  String get replaceAllData => 'Replace All Data';

  @override
  String get replaceAllConfirm =>
      'Are you sure? This action will delete all existing cats and replace them with the backup file data.';

  @override
  String get confirm => 'Confirm';

  @override
  String get importSuccess => 'Import Successful';

  @override
  String get importCompleted => 'Import completed:';

  @override
  String catsImported(int count) {
    return '• $count cats imported';
  }

  @override
  String catsSkipped(int count) {
    return '• $count cats skipped (already exist)';
  }

  @override
  String get errors => 'Errors:';

  @override
  String importError(String error) {
    return 'Import error: $error';
  }

  @override
  String errorImportingData(String error) {
    return 'Error importing data: $error';
  }

  @override
  String get deleteBackup => 'Delete Backup';

  @override
  String deleteBackupConfirm(String name) {
    return 'Are you sure you want to delete this backup?\n\n$name';
  }

  @override
  String get backupDeleted => 'Backup deleted';

  @override
  String errorDeletingBackup(String error) {
    return 'Error deleting backup: $error';
  }

  @override
  String errorSharingBackup(String error) {
    return 'Error sharing backup: $error';
  }

  @override
  String get noBackups => 'No backups';

  @override
  String get createFirstBackup => 'Create your first backup above';

  @override
  String catsCount(int count) {
    return '$count cats';
  }

  @override
  String get import => 'Import';

  @override
  String get share => 'Share';

  @override
  String get understood => 'Understood';

  @override
  String get databaseManagement => 'Database Management';

  @override
  String get databaseStatus => 'Database Status';

  @override
  String get status => 'Status';

  @override
  String get existsAndActive => 'Exists and Active';

  @override
  String get doesNotExist => 'Does Not Exist';

  @override
  String get fileName => 'File Name';

  @override
  String get versionLabel => 'Version';

  @override
  String get fileSize => 'File Size';

  @override
  String get lastModified => 'Last Modified';

  @override
  String get filePath => 'File Path';

  @override
  String get errorLoadingDbInfo => 'Error loading database info';

  @override
  String get retry => 'Retry';

  @override
  String get maintenanceActions => 'Maintenance Actions';

  @override
  String get backupButton => 'Backup';

  @override
  String get recreateDb => 'Recreate DB';

  @override
  String get recreateDatabase => 'Recreate Database';

  @override
  String get recreateDbConfirm =>
      'Are you sure you want to recreate the database? This will delete all existing data and create a new database with initial data.';

  @override
  String get recreate => 'Recreate';

  @override
  String get dbRecreatedSuccess => 'Database recreated successfully';

  @override
  String errorRecreatingDb(String error) {
    return 'Error recreating database: $error';
  }

  @override
  String get dbPathCopied => 'Database path copied to clipboard';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String errorLoadingData(String error) {
    return 'Error loading data: $error';
  }

  @override
  String errorRefreshingData(String error) {
    return 'Error refreshing data: $error';
  }

  @override
  String errorLoadingPage(String error) {
    return 'Error loading page: $error';
  }

  @override
  String get breedDomesticShorthair => 'Domestic Shorthair';

  @override
  String get breedDomesticLonghair => 'Domestic Longhair';

  @override
  String get breedPersian => 'Persian';

  @override
  String get breedMaineCoon => 'Maine Coon';

  @override
  String get breedSiamese => 'Siamese';

  @override
  String get breedBritishShorthair => 'British Shorthair';

  @override
  String get breedRussianBlue => 'Russian Blue';

  @override
  String get breedRagdoll => 'Ragdoll';

  @override
  String get breedBengal => 'Bengal';

  @override
  String get breedScottishFold => 'Scottish Fold';

  @override
  String get furPatternSolid => 'Solid';

  @override
  String get furPatternTabby => 'Tabby';

  @override
  String get furPatternCalico => 'Calico';

  @override
  String get furPatternTortoiseshell => 'Tortoiseshell';

  @override
  String get furPatternBicolor => 'Bicolor';

  @override
  String get furPatternTricolor => 'Tricolor';

  @override
  String get furPatternSpotted => 'Spotted';

  @override
  String get furPatternPointed => 'Pointed';

  @override
  String get furPatternColorpoint => 'Colorpoint';

  @override
  String get furPatternSmoke => 'Smoke';

  @override
  String get furPatternShaded => 'Shaded';

  @override
  String get furPatternChinchilla => 'Chinchilla';
}
