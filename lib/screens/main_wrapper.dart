import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'home_page.dart';
import 'gato_mapa_screen.dart';
import 'settings_screen.dart';
import 'backup_screen.dart';
import '../services/theme_service.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  String _version = '';
  bool _versionLoaded = false;

  final Map<int, Widget> _builtPages = {};
  bool _hasVisitedMap = false;

  static const _fileChannel = MethodChannel('com.devinaxo.gatodex/file_intent');

  @override
  void initState() {
    super.initState();
    _setupFileIntentHandler();
  }

  void _setupFileIntentHandler() {
    // Listen for files received while app is running
    _fileChannel.setMethodCallHandler((call) async {
      if (call.method == 'onFileReceived') {
        final filePath = call.arguments as String;
        _handleIncomingFile(filePath);
      }
    });

    // Check for initial file intent (cold start)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final filePath = await _fileChannel.invokeMethod<String>('getInitialFileIntent');
        if (filePath != null) {
          _handleIncomingFile(filePath);
        }
      } catch (_) {}
    });
  }

  void _handleIncomingFile(String filePath) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BackupScreen(initialImportPath: filePath),
      ),
    );
  }

  Future<void> _loadVersionIfNeeded() async {
    if (_versionLoaded) return;
    _versionLoaded = true;
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  Widget _getPage(int index) {
    if (!_builtPages.containsKey(index)) {
      switch (index) {
        case 0:
          _builtPages[0] = HomePage();
          break;
        case 1:
          _hasVisitedMap = true;
          _builtPages[1] = GatoMapaScreen();
          break;
        case 2:
          _builtPages[2] = const SettingsScreen();
          break;
      }
    }
    return _builtPages[index]!;
  }

  static const _pageTitles = ['gatoDex', 'gatoMapa', 'gatoConfiguración'];

  void _onDrawerItemTapped(int index) {
    // Clear cached map so it reloads fresh data each visit
    if (index == 1) _builtPages.remove(1);
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeService = ThemeService();

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        centerTitle: true,
      ),
      drawer: Builder(
        builder: (context) {
          _loadVersionIfNeeded();
          return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primaryContainer),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/icon/icon.png', width: 48, height: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'gatoDex',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tu colección de gatos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('gatoDex'),
              subtitle: const Text('Lista de gatos'),
              selected: _selectedIndex == 0,
              onTap: () => _onDrawerItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('gatoMapa'),
              subtitle: const Text('Mapa de ubicaciones'),
              selected: _selectedIndex == 1,
              onTap: () => _onDrawerItemTapped(1),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('gatoConfiguración'),
              subtitle: const Text('Ajustes de la app'),
              selected: _selectedIndex == 2,
              onTap: () => _onDrawerItemTapped(2),
            ),
            const Divider(),

            // Theme selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Tema',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListenableBuilder(
                listenable: themeService,
                builder: (context, _) {
                  return SegmentedButton<AppThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: AppThemeMode.light,
                        icon: Icon(Icons.light_mode, size: 18),
                        tooltip: 'Claro',
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        icon: Icon(Icons.dark_mode, size: 18),
                        tooltip: 'Oscuro',
                      ),
                      ButtonSegment(
                        value: AppThemeMode.system,
                        icon: Icon(Icons.phone_android, size: 18),
                        tooltip: 'Sistema',
                      ),
                      ButtonSegment(
                        value: AppThemeMode.materialYou,
                        icon: Icon(Icons.palette, size: 18),
                        tooltip: 'Material You',
                      ),
                    ],
                    selected: {themeService.currentMode},
                    onSelectionChanged: (selection) {
                      themeService.setThemeMode(selection.first);
                    },
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            if (_version.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Versión $_version',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
          ),
          );
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _getPage(0),
          // Only build map after first visit to avoid wasted resources
          if (_hasVisitedMap || _selectedIndex == 1) _getPage(1) else const SizedBox.shrink(),
          _getPage(2),
        ],
      ),
    );
  }
}
