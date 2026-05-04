import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';

/// Screen for viewing and editing the user's profile.
/// Shows name email profile picture and allows logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) _nameController.text = user.name;
  }

  /// Picks an image from the gallery and updates the user's profile.
  Future<void> _pickImage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await userProvider.updateProfile(profileImagePath: image.path);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Custom app bar with edit toggle
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            color: AppTheme.primary,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                ),
                Text('Profile', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                  icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile image picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.primaryLight,
                      backgroundImage: user.profileImagePath != null ? FileImage(File(user.profileImagePath!)) : null,
                      child: user.profileImagePath == null
                          ? const Icon(Icons.person, size: 60, color: AppTheme.primary)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Tap to change photo', style: GoogleFonts.quicksand(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 20),
                  // Editable name field or static text
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        onFieldSubmitted: (_) async {
                          await userProvider.updateProfile(name: _nameController.text);
                          if (mounted) setState(() => _isEditing = false);
                        },
                      ),
                    )
                  else
                    Text(user.name, style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(user.email, style: GoogleFonts.quicksand(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 40),
                  // Logout button
                  ElevatedButton(
                    onPressed: () async {
                      await userProvider.logout();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}