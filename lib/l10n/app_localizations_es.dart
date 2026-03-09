// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Gatodex';

  @override
  String get appTagline => 'Tu colección de кошки';

  @override
  String get gatoDex => 'gatoDex';

  @override
  String get gatoMapa => 'gatoMapa';

  @override
  String get gatoConfig => 'gatoConfiguración';

  @override
  String get catList => 'Lista de gatos';

  @override
  String get locationMap => 'Mapa de ubicaciones';

  @override
  String get appSettings => 'Ajustes de la app';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeMaterialYou => 'Material You';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get searchByName => 'Buscar por nombre o alias...';

  @override
  String get filters => 'Filtros';

  @override
  String get breed => 'Raza';

  @override
  String get furPattern => 'Patrón';

  @override
  String get allBreeds => 'Todas';

  @override
  String get allPatterns => 'Todos';

  @override
  String get dateRange => 'Rango de fechas';

  @override
  String get clearFilters => 'Limpiar';

  @override
  String get filteredPrefix => 'Filtrado: ';

  @override
  String catsStats(int count, int current, int total) {
    return '$count gatos • Página $current de $total';
  }

  @override
  String get listView => 'Vista Lista';

  @override
  String get mosaicView => 'Vista Mosaico';

  @override
  String get refresh => 'Actualizar';

  @override
  String get noCatsRegistered => 'No hay gatos registrados';

  @override
  String get addYourFirstCat => '¡Agrega tu primer gato!';

  @override
  String loadingPage(int page) {
    return 'Cargando página $page...';
  }

  @override
  String get goToPage => 'Ir a página';

  @override
  String enterPageNumber(int total) {
    return 'Introduce un número de página (1-$total):';
  }

  @override
  String get pageNumber => 'Número de página';

  @override
  String pageExample(int page) {
    return 'Ej: $page';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get go => 'Ir';

  @override
  String invalidPageNumber(int total) {
    return 'Por favor introduce un número válido entre 1 y $total';
  }

  @override
  String get deleteCat => 'Eliminar Gato';

  @override
  String deleteCatConfirm(String name) {
    return '¿Estás seguro de que quieres eliminar a $name?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String catDeleted(String name) {
    return '$name eliminado';
  }

  @override
  String get edit => 'Editar';

  @override
  String get addCat => 'Agregar Gato';

  @override
  String get editCat => 'Editar Gato';

  @override
  String catAddedSuccess(String name) {
    return '$name agregado exitosamente';
  }

  @override
  String catUpdatedSuccess(String name) {
    return '$name actualizado exitosamente';
  }

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get catName => 'Nombre del Gato';

  @override
  String get pleaseEnterName => 'Por favor ingresa un nombre';

  @override
  String get generateRandomName => 'Generar nombre aleatorio';

  @override
  String errorGeneratingName(String error) {
    return 'Error generando nombre: $error';
  }

  @override
  String get breedLabel => 'Raza';

  @override
  String get pleaseSelectBreed => 'Por favor selecciona una raza';

  @override
  String get furPatternLabel => 'Patrón de Pelaje (Opcional)';

  @override
  String get noPattern => 'Sin Patrón';

  @override
  String get dateMetLabel => 'Fecha de Encuentro (Opcional)';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get locationOptional => 'Ubicación (Opcional)';

  @override
  String locationCoords(String lat, String lng) {
    return 'Ubicación: $lat, $lng';
  }

  @override
  String get tapToAddPhoto => 'Toca para agregar foto';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get chooseFromGallery => 'Elegir de galería';

  @override
  String get deletePhoto => 'Eliminar foto';

  @override
  String get permissionDenied => 'Permiso denegado';

  @override
  String get photosLabel => 'Fotos';

  @override
  String photosCount(int count) {
    return '$count/5 fotos';
  }

  @override
  String get maxPhotosReached => 'Máximo de 5 fotos alcanzado';

  @override
  String get aliasesLabel => 'Alias (Opcional)';

  @override
  String get aliasHint => 'Nombre del alias';

  @override
  String get addAlias => 'Agregar alias';

  @override
  String get aliasEmpty => 'Por favor ingresa un alias';

  @override
  String get saving => 'Guardando...';

  @override
  String get unknownBreed => 'Raza Desconocida';

  @override
  String get unknownPattern => 'Patrón Desconocido';

  @override
  String get unknownDate => 'Fecha Desconocida';

  @override
  String get noLocation => 'Sin Ubicación';

  @override
  String get breedDetailLabel => 'Raza';

  @override
  String get furPatternDetailLabel => 'Patrón de Pelaje';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String get dateMetDetailLabel => 'Fecha de Encuentro';

  @override
  String get photoLabel => 'Foto';

  @override
  String get aliasesDetailLabel => 'Alias';

  @override
  String get tapMapToSelectLocation =>
      'Toca en el mapa para seleccionar ubicación';

  @override
  String get useMyCurrentLocation => 'Usar mi ubicación actual';

  @override
  String get clear => 'Limpiar';

  @override
  String get currentLocationSet => 'Ubicación actual establecida';

  @override
  String get locationPermissionDenied => 'Permisos de ubicación denegados';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Los permisos de ubicación están permanentemente denegados. Por favor, habilítalos en la configuración.';

  @override
  String get locationServicesDisabled =>
      'Los servicios de ubicación están deshabilitados. Por favor, habilítalos.';

  @override
  String errorGettingLocation(String error) {
    return 'Error al obtener la ubicación: $error';
  }

  @override
  String get doubleTapOrPinchToZoom =>
      'Doble toque o pellizque para acercar • Toca fuera para cerrar';

  @override
  String get doubleTapToZoomOut => 'Doble toque para alejar';

  @override
  String get total => 'Total';

  @override
  String get withLocation => 'Con Ubicación';

  @override
  String get withoutLocation => 'Sin Ubicación';

  @override
  String get centerCatLocations => 'Centrar ubicación de gatos';

  @override
  String get refreshData => 'Actualizar datos';

  @override
  String get noCatsWithLocation => 'No hay gatos con ubicación';

  @override
  String get addLocationsHint =>
      'Agrega ubicaciones a tus gatos para verlos en el mapa';

  @override
  String get addCats => 'Agregar Gatos';

  @override
  String get general => 'General';

  @override
  String get backup => 'Copia de Seguridad';

  @override
  String get manageBackups => 'Gestionar copias de seguridad';

  @override
  String get about => 'Acerca de';

  @override
  String get appInfo => 'Información de la aplicación';

  @override
  String get appDescription =>
      'Una aplicación y mi proyecto de pasión personal para catalogar y gestionar información sobre gatos que te encuentres, sean de la calle o no. Inspirada por mi necesidad de hacer exactamente eso en mi vida diaria.';

  @override
  String get developedWithFlutter => 'Desarrollado con Flutter y mucho amor';

  @override
  String get testingAdvanced => 'Testing (Avanzado!)';

  @override
  String get advancedWarning =>
      'Estas opciones son principalmente para desarrolladores. Si no sabes lo que estás haciendo, probablemente no deberías tocar esto.';

  @override
  String get dbManagement => 'Gestión de BD';

  @override
  String get manageDatabase => 'Administrar base de datos';

  @override
  String get addTestData => 'Agregar Datos de Prueba';

  @override
  String get addingData => 'Agregando datos...';

  @override
  String get addExampleCats => 'Añadir gatos de ejemplo';

  @override
  String get deleteAllCats => 'Eliminar Todos los Gatos';

  @override
  String get deleteAllCatsSubtitle =>
      'Borra TODOS los gatos de la base de datos';

  @override
  String get addTestDataTitle => 'Agregar Datos de Prueba';

  @override
  String get addTestDataConfirm =>
      '¿Estás seguro de que quieres agregar gatos de prueba?\n\nEsto agregará 3 gatos de ejemplo con nombres generados aleatoriamente.\nLos gatos existentes no se eliminarán.';

  @override
  String get addData => 'Agregar Datos';

  @override
  String testCatsAddedSuccess(String names) {
    return '¡3 gatos de prueba agregados exitosamente con nombres: $names!';
  }

  @override
  String errorAddingTestCats(String error) {
    return 'Error al agregar gatos de prueba: $error';
  }

  @override
  String get noBreedsAvailable =>
      'No hay razas disponibles. Necesitas al menos una raza para crear gatos de prueba.';

  @override
  String get dangerTitle => '¡Peligro!';

  @override
  String get deleteAllCatsConfirm =>
      '¿Estás COMPLETAMENTE SEGURO de que quieres eliminar TODOS los gatos?\n\n⚠️ Esta acción NO se puede deshacer.\n⚠️ Se perderán TODOS los datos de gatos.\n⚠️ Las fotos también se eliminarán.\n\nSolo procede si sabes exactamente lo que estás haciendo.';

  @override
  String get deleteAll => 'ELIMINAR TODO';

  @override
  String get allCatsDeleted => '¡Todos los gatos han sido eliminados!';

  @override
  String errorDeletingCats(String error) {
    return 'Error al eliminar gatos: $error';
  }

  @override
  String couldNotOpenLink(String url) {
    return 'No se pudo abrir el enlace: $url';
  }

  @override
  String cannotOpenLinkType(String url) {
    return 'No se puede abrir este tipo de enlace: $url';
  }

  @override
  String errorOpeningLink(String error) {
    return 'Error al abrir el enlace: $error';
  }

  @override
  String get backupTitle => 'Copia de Seguridad';

  @override
  String get createBackup => 'Crear Copia de Seguridad';

  @override
  String get creating => 'Creando...';

  @override
  String get importFromFile => 'Importar desde Archivo';

  @override
  String get selectBackupFile =>
      'Seleccionar archivo de copia de seguridad (.json)';

  @override
  String get selectJsonFile =>
      'Por favor selecciona un archivo .json de copia de seguridad';

  @override
  String errorSelectingFile(String error) {
    return 'Error seleccionando archivo: $error';
  }

  @override
  String get backupCreated => 'Copia de Seguridad Creada';

  @override
  String backupCreatedMessage(String path) {
    return 'Los datos se han exportado exitosamente.\n\nArchivo guardado en:\n$path';
  }

  @override
  String errorCreatingBackup(String error) {
    return 'Error creando copia de seguridad: $error';
  }

  @override
  String errorLoadingBackups(String error) {
    return 'Error cargando copias de seguridad: $error';
  }

  @override
  String get importBackup => 'Importar Copia de Seguridad';

  @override
  String get howToImport => '¿Cómo deseas importar los datos?';

  @override
  String file(String name) {
    return 'Archivo: $name';
  }

  @override
  String get addOnlyNew => 'Agregar Solo Nuevos';

  @override
  String get replaceAll => 'Reemplazar Todo';

  @override
  String get replaceAllData => 'Reemplazar Todos los Datos';

  @override
  String get replaceAllConfirm =>
      '¿Estás seguro? Esta acción eliminará todos los gatos existentes y los reemplazará con los datos del archivo de copia de seguridad.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get importSuccess => 'Importación Exitosa';

  @override
  String get importCompleted => 'Importación completada:';

  @override
  String catsImported(int count) {
    return '• $count gatos importados';
  }

  @override
  String catsSkipped(int count) {
    return '• $count gatos omitidos (ya existen)';
  }

  @override
  String get errors => 'Errores:';

  @override
  String importError(String error) {
    return 'Error en la importación: $error';
  }

  @override
  String errorImportingData(String error) {
    return 'Error importando datos: $error';
  }

  @override
  String get deleteBackup => 'Eliminar Copia de Seguridad';

  @override
  String deleteBackupConfirm(String name) {
    return '¿Estás seguro de que deseas eliminar esta copia de seguridad?\n\n$name';
  }

  @override
  String get backupDeleted => 'Copia de seguridad eliminada';

  @override
  String errorDeletingBackup(String error) {
    return 'Error eliminando copia de seguridad: $error';
  }

  @override
  String errorSharingBackup(String error) {
    return 'Error compartiendo copia de seguridad: $error';
  }

  @override
  String get noBackups => 'No hay copias de seguridad';

  @override
  String get createFirstBackup => 'Crea tu primera copia de seguridad arriba';

  @override
  String catsCount(int count) {
    return '$count gatos';
  }

  @override
  String get import => 'Importar';

  @override
  String get share => 'Compartir';

  @override
  String get understood => 'Entendido';

  @override
  String get databaseManagement => 'Gestión de Base de Datos';

  @override
  String get databaseStatus => 'Estado de la Base de Datos';

  @override
  String get status => 'Estado';

  @override
  String get existsAndActive => 'Existe y Activa';

  @override
  String get doesNotExist => 'No Existe';

  @override
  String get fileName => 'Nombre del Archivo';

  @override
  String get versionLabel => 'Versión';

  @override
  String get fileSize => 'Tamaño del Archivo';

  @override
  String get lastModified => 'Última Modificación';

  @override
  String get filePath => 'Ruta del Archivo';

  @override
  String get errorLoadingDbInfo =>
      'Error cargando información de la base de datos';

  @override
  String get retry => 'Reintentar';

  @override
  String get maintenanceActions => 'Acciones de Mantenimiento';

  @override
  String get backupButton => 'Copia de Seguridad';

  @override
  String get recreateDb => 'Recrear BD';

  @override
  String get recreateDatabase => 'Recrear Base de Datos';

  @override
  String get recreateDbConfirm =>
      '¿Estás seguro de que quieres recrear la base de datos? Esto eliminará todos los datos existentes y creará una nueva base de datos con los datos iniciales.';

  @override
  String get recreate => 'Recrear';

  @override
  String get dbRecreatedSuccess => 'Base de datos recreada exitosamente';

  @override
  String errorRecreatingDb(String error) {
    return 'Error recreando la base de datos: $error';
  }

  @override
  String get dbPathCopied => 'Ruta de la base de datos copiada al portapapeles';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String errorLoadingData(String error) {
    return 'Error cargando datos: $error';
  }

  @override
  String errorRefreshingData(String error) {
    return 'Error actualizando datos: $error';
  }

  @override
  String errorLoadingPage(String error) {
    return 'Error cargando página: $error';
  }

  @override
  String get breedDomesticShorthair => 'Pelo Corto Doméstico';

  @override
  String get breedDomesticLonghair => 'Pelo Largo Doméstico';

  @override
  String get breedPersian => 'Persa';

  @override
  String get breedMaineCoon => 'Maine Coon';

  @override
  String get breedSiamese => 'Siamés';

  @override
  String get breedBritishShorthair => 'Británico de Pelo Corto';

  @override
  String get breedRussianBlue => 'Azul Ruso';

  @override
  String get breedRagdoll => 'Ragdoll';

  @override
  String get breedBengal => 'Bengalí';

  @override
  String get breedScottishFold => 'Scottish Fold';

  @override
  String get furPatternSolid => 'Sólido';

  @override
  String get furPatternTabby => 'Atigrado';

  @override
  String get furPatternCalico => 'Carey';

  @override
  String get furPatternTortoiseshell => 'Tortuga';

  @override
  String get furPatternBicolor => 'Bicolor';

  @override
  String get furPatternTricolor => 'Tricolor';

  @override
  String get furPatternSpotted => 'Manchado';

  @override
  String get furPatternPointed => 'Punteado';

  @override
  String get furPatternColorpoint => 'Colorpoint';

  @override
  String get furPatternSmoke => 'Humo';

  @override
  String get furPatternShaded => 'Sombreado';

  @override
  String get furPatternChinchilla => 'Chinchilla';
}
