import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import 'backup_screen.dart';
import 'database_management_screen.dart';
import '../services/cat_service.dart';
import '../services/cat_data_notifier.dart';
import '../services/cat_name_api_service.dart';
import '../models/cat.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CatService _catService = CatService();
  bool _isAdvancedExpanded = false;
  bool _isAddingTestData = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
          // General Section
          _buildSectionCard(
            title: l10n.general,
            children: [
              _buildListTile(
                icon: Icons.backup,
                title: l10n.backup,
                subtitle: l10n.manageBackups,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackupScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.info_outline,
                title: l10n.about,
                subtitle: l10n.appInfo,
                onTap: () => _showAboutDialog(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Advanced Testing Section
          _buildSectionCard(
            title: l10n.testingAdvanced,
            isExpandable: true,
            isExpanded: _isAdvancedExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isAdvancedExpanded = expanded;
              });
            },
            children: _isAdvancedExpanded ? [
              // Warning notice
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.advancedWarning,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildListTile(
                icon: Icons.storage,
                title: l10n.dbManagement,
                subtitle: l10n.manageDatabase,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DatabaseManagementScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.add_circle_outline,
                title: l10n.addTestData,
                subtitle: _isAddingTestData 
                    ? l10n.addingData 
                    : l10n.addExampleCats,
                onTap: _isAddingTestData ? null : () => _showAddTestDataDialog(),
                trailing: _isAddingTestData 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              _buildListTile(
                icon: Icons.delete_forever,
                title: l10n.deleteAllCats,
                subtitle: l10n.deleteAllCatsSubtitle,
                onTap: () => _showClearAllCatsDialog(),
                iconColor: Colors.red,
                titleColor: Colors.red,
              ),
            ] : [],
          ),
        ],
      );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    bool isExpandable = false,
    bool isExpanded = false,
    ValueChanged<bool>? onExpansionChanged,
  }) {
    Widget content = Card(
      elevation: 2,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                if (isExpandable) ...[
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ],
            ),
          ),
          ...children,
        ],
      ),
    );

    if (isExpandable) {
      return GestureDetector(
        onTap: () => onExpansionChanged?.call(!isExpanded),
        child: content,
      );
    }

    return content;
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (iconColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
        child: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _showAboutDialog() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    
    showAboutDialog(
      context: context,
      applicationName: 'gatoDex',
      applicationVersion: packageInfo.version,
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset('assets/icon/icon.png', width: 64, height: 64),
      ),
      children: [
        Text(l10n.appDescription),
        const SizedBox(height: 24),
        // Social media icons section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // GitHub icon and link
            Column(
              children: [
                GestureDetector(
                  onTap: () => _launchURL('https://devinaxo.github.io'),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.asset('assets/images/github-icon.png', width: 60, height: 60, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL('https://devinaxo.github.io'),
                  child: const Text('devinaxo.github.io', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 12)),
                ),
              ],
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () => _launchURL('https://twitter.com/devinachoes'),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.asset('assets/images/twitter-icon.png', width: 60, height: 60, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL('https://twitter.com/devinachoes'),
                  child: const Text(
                    'twitter.com/devinachoes',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.developedWithFlutter,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    final l10n = AppLocalizations.of(context);
    try {
      bool canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
        
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.couldNotOpenLink(url)),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotOpenLinkType(url)),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOpeningLink(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddTestDataDialog() async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addTestDataTitle),
        content: Text(l10n.addTestDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addTestData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(l10n.addData),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearAllCatsDialog() async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(l10n.dangerTitle),
          ],
        ),
        content: Text(l10n.deleteAllCatsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllCats();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.deleteAll),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllCats() async {
    setState(() {
      _isAddingTestData = true;
    });

    try {
      final allCats = await _catService.getAllCats();
      for (var cat in allCats) {
        await _catService.deleteCat(cat.id);
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {});
        CatDataNotifier().notifyDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.allCatsDeleted),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingCats(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingTestData = false;
        });
      }
    }
  }

  Future<void> _addTestData() async {
    setState(() {
      _isAddingTestData = true;
    });

    try {
      final allSpecies = await _catService.getAllSpecies();
      final allPatterns = await _catService.getAllFurPatterns();

      if (allSpecies.isEmpty) {
        final l10n = AppLocalizations.of(context);
        throw Exception(l10n.noSpeciesAvailable);
      }

      final catNames = await CatNameApiService.getMultipleCatNames(limit: 3);

      final testCats = [
        Cat(
          id: 0,
          name: catNames.isNotEmpty ? catNames[0] : 'Miau',
          speciesId: allSpecies.first.id,
          furPatternId: allPatterns.isNotEmpty ? allPatterns.first.id : null,
          dateMet: '2024-01-15',
          picturePath: 'assets/images/default_cat.jpg',
        ),
        Cat(
          id: 0,
          name: catNames.length > 1 ? catNames[1] : 'Luna',
          speciesId: allSpecies.length > 1 ? allSpecies[1].id : allSpecies.first.id,
          furPatternId: allPatterns.length > 1 ? allPatterns[1].id : (allPatterns.isNotEmpty ? allPatterns.first.id : null),
          dateMet: '2024-02-20',
        ),
        Cat(
          id: 0,
          name: catNames.length > 2 ? catNames[2] : 'Garfield',
          speciesId: allSpecies.length > 2 ? allSpecies[2].id : allSpecies.first.id,
          furPatternId: allPatterns.length > 2 ? allPatterns[2].id : (allPatterns.isNotEmpty ? allPatterns.first.id : null),
          dateMet: '2024-03-10',
          picturePath: 'assets/images/default_cat.jpg',
        ),
      ];

      for (var cat in testCats) {
        await _catService.addCat(cat);
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {});
        CatDataNotifier().notifyDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.testCatsAddedSuccess(catNames.join(", "))),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorAddingTestCats(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingTestData = false;
        });
      }
    }
  }
}
