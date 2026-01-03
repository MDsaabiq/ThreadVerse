import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:threadverse/core/constants/app_constants.dart';
import 'package:threadverse/core/repositories/community_repository.dart';
import 'package:threadverse/core/repositories/upload_repository.dart';

/// Create community screen with detailed options
class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isPrivate = false;
  bool _isNsfw = false;
  bool _allowText = true;
  bool _allowLink = true;
  bool _allowImage = true;
  bool _allowPoll = true;
  String? _iconUrl;
  String? _bannerUrl;
  bool _uploadingIcon = false;
  bool _uploadingBanner = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  Future<void> _pickAndUploadIcon() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _uploadingIcon = true);
        try {
          final iconUrl = await uploadRepository.uploadPostImage(pickedFile);
          setState(() => _iconUrl = iconUrl);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Icon uploaded successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error uploading icon: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _uploadingIcon = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadBanner() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _uploadingBanner = true);
        try {
          final bannerUrl = await uploadRepository.uploadPostImage(pickedFile);
          setState(() => _bannerUrl = bannerUrl);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Banner uploaded successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error uploading banner: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _uploadingBanner = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleCreateCommunity() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty ||
        name.length < 3 ||
        name.length > AppConstants.maxCommunityNameLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Community name must be 3-${AppConstants.maxCommunityNameLength} characters.',
          ),
        ),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a description.')),
      );
      return;
    }

    () async {
      try {
        await communityRepository.createCommunity(
          name: name,
          description: description,
          isPrivate: _isPrivate,
          isNsfw: _isNsfw,
          allowedPostTypes: [
            if (_allowText) AppConstants.postTypeText,
            if (_allowLink) AppConstants.postTypeLink,
            if (_allowImage) AppConstants.postTypeImage,
            if (_allowPoll) AppConstants.postTypePoll,
          ],
          iconUrl: _iconUrl,
          bannerUrl: _bannerUrl,
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Community r/$name created.')));
          context.go('${AppConstants.routeCommunity}/$name');
        }
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create community')),
        );
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Community'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              maxLength: AppConstants.maxCommunityNameLength,
              decoration: const InputDecoration(
                labelText: 'Community name',
                prefixText: 'r/',
                helperText: '3-21 characters, no spaces',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                helperText: 'What is this community about?',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            Text(
              'Community Icon & Banner',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Community Icon', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: _iconUrl != null
                            ? Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _iconUrl!,
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      onPressed: () =>
                                          setState(() => _iconUrl = null),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(
                                height: 100,
                                width: double.infinity,
                                child: Center(
                                  child: _uploadingIcon
                                      ? const SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : OutlinedButton.icon(
                                          onPressed: _pickAndUploadIcon,
                                          icon: const Icon(Icons.image),
                                          label:
                                              const Text('Upload Icon'),
                                        ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Banner Image',
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: _bannerUrl != null
                            ? Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _bannerUrl!,
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      onPressed: () =>
                                          setState(() => _bannerUrl = null),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(
                                height: 100,
                                width: double.infinity,
                                child: Center(
                                  child: _uploadingBanner
                                      ? const SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : OutlinedButton.icon(
                                          onPressed:
                                              _pickAndUploadBanner,
                                          icon: const Icon(Icons.image),
                                          label: const Text('Upload Banner'),
                                        ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'Privacy',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  RadioListTile<bool>(
                    title: const Text('Public'),
                    subtitle: const Text('Anyone can view, post, and comment'),
                    value: false,
                    groupValue: _isPrivate,
                    onChanged: (v) => setState(() => _isPrivate = v ?? false),
                  ),
                  const Divider(height: 0),
                  RadioListTile<bool>(
                    title: const Text('Private'),
                    subtitle: const Text(
                      'Only approved members can view and participate',
                    ),
                    value: true,
                    groupValue: _isPrivate,
                    onChanged: (v) => setState(() => _isPrivate = v ?? false),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: const Text('18+ / NSFW'),
              subtitle: const Text('Mark this community as adult content'),
              value: _isNsfw,
              onChanged: (v) => setState(() => _isNsfw = v),
            ),
            const SizedBox(height: 20),

            Text(
              'Allowed post types',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Text'),
                  selected: _allowText,
                  onSelected: (v) => setState(() => _allowText = v),
                ),
                FilterChip(
                  label: const Text('Link'),
                  selected: _allowLink,
                  onSelected: (v) => setState(() => _allowLink = v),
                ),
                FilterChip(
                  label: const Text('Image'),
                  selected: _allowImage,
                  onSelected: (v) => setState(() => _allowImage = v),
                ),
                FilterChip(
                  label: const Text('Poll'),
                  selected: _allowPoll,
                  onSelected: (v) => setState(() => _allowPoll = v),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Preview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.primaryColor,
                  child: Text(
                    (_nameController.text.isEmpty
                            ? 'R'
                            : _nameController.text[0])
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  'r/${_nameController.text.isEmpty ? 'your_community' : _nameController.text}',
                ),
                subtitle: Text(
                  _descriptionController.text.isEmpty
                      ? 'A short description of your community'
                      : _descriptionController.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_isPrivate ? 'Private' : 'Public'),
                    if (_isNsfw)
                      const Text('NSFW', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleCreateCommunity,
                icon: const Icon(Icons.check_circle),
                label: const Text('Create Community'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
