import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'home_page.dart';
import 'gato_mapa_screen.dart';
import 'settings_screen.dart';

class MainWrapper extends StatefulWidget {
  @override
  _MainWrapperState createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late PackageInfo packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  List<Widget> get _pages {
    return [
      HomePage(),
      GatoMapaScreen(),
      SettingsScreen(),
    ];
  }

  List<String> get _pageTitles {
    return ['gatoDex', 'gatoMapa', 'Configuración'];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDrawerItemTapped(int index) {
    if (index >= _pages.length) {
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.pets,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'gatoDex',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tu colección de gatos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('gatoDex'),
              subtitle: Text('Lista de gatos'),
              selected: _selectedIndex == 0,
              onTap: () => _onDrawerItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('gatoMapa'),
              subtitle: Text('Mapa de ubicaciones'),
              selected: _selectedIndex == 1,
              onTap: () => _onDrawerItemTapped(1),
            ),
            Divider(),
            if (_pages.length == 3)
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
                subtitle: Text('Ajustes de la app'),
                selected: _selectedIndex == 2,
                onTap: () => _onDrawerItemTapped(2),
              ),
            if (_pages.length < 3)
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
                subtitle: Text('Ajustes de la app'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Versión ${packageInfo.version}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Disable swiping between main sections
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
    );
  }
}
