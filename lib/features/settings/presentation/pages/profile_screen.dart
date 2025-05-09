import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/settings_header.dart';

/// A screen for viewing and editing user profile information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  bool _formChanged = false;
  File? _profileImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fetch profile data when screen loads
    context.read<ProfileBloc>().add(const ProfileFetched());
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _formChanged = true;
        });
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          // Handle state changes
          if (state is ProfileLoaded) {
            // Update controller if profile is loaded and controller is empty
            if (_displayNameController.text.isEmpty) {
              _displayNameController.text = state.userProfile.displayName;
              _formChanged = false;
            }
          } else if (state is ProfileError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is ProfileUpdating) {
            // Show loading indicator
          } else if (state is ProfileUpdated) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Reset form changed state
            setState(() {
              _formChanged = false;
            });
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded || state is ProfileUpdating || state is ProfileUpdated) {
            String displayName = '';
            String avatarUrl = '';
            
            if (state is ProfileLoaded) {
              displayName = state.userProfile.displayName;
              avatarUrl = state.userProfile.avatarUrl ?? '';
            } else if (state is ProfileUpdating) {
              displayName = state.userProfile.displayName;
              avatarUrl = state.userProfile.avatarUrl ?? '';
            } else if (state is ProfileUpdated) {
              displayName = state.userProfile.displayName;
              avatarUrl = state.userProfile.avatarUrl ?? '';
            }
            
            return _buildForm(
              context, 
              displayName,
              avatarUrl,
              state is ProfileUpdating,
            );
          } else if (state is ProfileError) {
            if (state.userProfile != null) {
              return _buildForm(
                context, 
                state.userProfile!.displayName,
                state.userProfile!.avatarUrl ?? '',
                false,
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load profile',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(const ProfileFetched());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, String displayName, String avatarUrl, bool isUpdating) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        onChanged: () {
          if (!_formChanged) {
            setState(() {
              _formChanged = true;
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: isUpdating ? null : _showImageSourceSheet,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      backgroundImage: _profileImage != null 
                          ? FileImage(_profileImage!) as ImageProvider
                          : (avatarUrl.isNotEmpty 
                              ? NetworkImage(avatarUrl) as ImageProvider
                              : null),
                      child: _profileImage == null && avatarUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: isUpdating ? null : _showImageSourceSheet,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: theme.colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Display email (read-only)
            Text(
              'Email',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: Text(
                _getEmailFromState(context.watch<ProfileBloc>().state),
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24),
            
            // Display name (editable)
            Text(
              'Display Name',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                hintText: 'Enter your display name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Display name is required';
                }
                if (value.length < 2) {
                  return 'Display name must be at least 2 characters';
                }
                return null;
              },
              enabled: !isUpdating,
            ),
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUpdating || !_formChanged
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<ProfileBloc>().add(
                                ProfileUpdateRequested(
                                  displayName: _displayNameController.text.trim(),
                                  avatarUrl: _profileImage != null ? _profileImage!.path : null,
                                ),
                              );
                        }
                      },
                child: isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmailFromState(ProfileState state) {
    if (state is ProfileLoaded) {
      return state.userProfile.email;
    }
    if (state is ProfileUpdating) {
      return state.userProfile.email;
    }
    if (state is ProfileUpdated) {
      return state.userProfile.email;
    }
    if (state is ProfileError && state.userProfile != null) {
      return state.userProfile!.email;
    }
    return 'Loading...';
  }
} 