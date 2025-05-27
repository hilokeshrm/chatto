import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../app/app.dart'; // Make sure this path is correct for your app structure

enum FontSizeOption { small, medium, large }

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final user = FirebaseAuth.instance.currentUser!;
  String name = '';
  String tag = '';
  String photoUrl = '';
  bool loadingProfile = true;

  bool _darkMode = false;
  bool _notifications = true;
  FontSizeOption _fontSize = FontSizeOption.medium;

  String get _fontSizeLabel {
    switch (_fontSize) {
      case FontSizeOption.small:
        return 'Small';
      case FontSizeOption.medium:
        return 'Medium';
      case FontSizeOption.large:
        return 'Large';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _darkMode = themeModeNotifier.value == ThemeMode.dark;
  }

  Future<void> _loadProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};
      setState(() {
        name = data['name'] ?? '';
        tag = data['tag'] ?? '';
        photoUrl = data['photoUrl'] ?? '';
        loadingProfile = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => loadingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile data')),
      );
    }
  }

  Future<void> _updateProfile(Map<String, String> fields) async {
    try {
      final updateData = {
        ...fields.map((k, v) => MapEntry(k, v.trim())),
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));

      setState(() {
        if (fields.containsKey('name')) name = fields['name']!;
        if (fields.containsKey('tag')) tag = fields['tag']!;
        if (fields.containsKey('photoUrl')) photoUrl = fields['photoUrl']!;
      });
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  Future<void> _editProfileDialog() async {
    final nameCtrl = TextEditingController(text: name);
    final tagCtrl = TextEditingController(text: tag);
    final urlCtrl = TextEditingController(text: photoUrl);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(labelText: 'Photo URL'),
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),
              TextField(
                controller: tagCtrl,
                decoration: const InputDecoration(labelText: 'Your Tag'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateProfile({
                'photoUrl': urlCtrl.text,
                'name': nameCtrl.text,
                'tag': tagCtrl.text,
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFontSize() async {
    await showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Font Size'),
        children: FontSizeOption.values.map((opt) {
          final label = (opt == FontSizeOption.small)
              ? 'Small'
              : (opt == FontSizeOption.medium)
              ? 'Medium'
              : 'Large';
          return RadioListTile<FontSizeOption>(
            title: Text(label),
            value: opt,
            groupValue: _fontSize,
            onChanged: (v) {
              if (v != null) setState(() => _fontSize = v);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (loadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ───── Profile Display ─────
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child:
                photoUrl.isEmpty ? const Icon(Icons.person, size: 32) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? '—' : name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      tag.isEmpty ? '—' : tag,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editProfileDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ───── Dark Mode ─────
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: _darkMode,
              onChanged: (v) {
                setState(() {
                  _darkMode = v;
                  themeModeNotifier.value =
                  v ? ThemeMode.dark : ThemeMode.light;
                });
              },
            ),
          ),
          const Divider(),

          // ───── Font Size ─────
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Font Size'),
            subtitle: Text(_fontSizeLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickFontSize,
          ),
          const Divider(),

          // ───── Notifications ─────
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
          ),
          const SizedBox(height: 32),

          // ───── Logout Button ─────
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            onPressed: _signOut,
          ),
        ],
      ),
    );
  }
}
