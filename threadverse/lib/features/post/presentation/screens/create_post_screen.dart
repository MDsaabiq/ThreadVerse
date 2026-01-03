import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:threadverse/core/constants/app_constants.dart';
import 'package:threadverse/core/models/community_model.dart';
import 'package:threadverse/core/models/draft_model.dart';
import 'package:threadverse/core/repositories/community_repository.dart';
import 'package:threadverse/core/repositories/post_repository.dart';
import 'package:threadverse/core/repositories/upload_repository.dart';
import 'dart:async';
import 'package:threadverse/core/widgets/image_picker_widget.dart';
import 'package:threadverse/core/utils/error_handler.dart';

/// Create post screen with detailed options and validation
class CreatePostScreen extends StatefulWidget {
  final String? communityId;
  final String? draftId;

  const CreatePostScreen({super.key, this.communityId, this.draftId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _linkController;
  late List<TextEditingController> _pollOptionControllers;
  String _postType = 'text';
  bool _isSpoiler = false;
  bool _isOc = false;
  String? _selectedCommunity;
  final List<String> _tags = [];
  List<CommunityModel> _communities = const [];
  bool _loadingCommunities = true;
  String? _uploadedImageUrl;
  bool _uploadingImage = false;
  
  // Draft-related fields
  Timer? _autoSaveTimer;
  String? _currentDraftId;
  DateTime? _lastSaved;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _linkController = TextEditingController();
    _pollOptionControllers = [TextEditingController(), TextEditingController()];
    _loadCommunities();
    _loadDraft();
    
    // Setup auto-save listeners
    _titleController.addListener(_scheduleAutoSave);
    _contentController.addListener(_scheduleAutoSave);
    _linkController.addListener(_scheduleAutoSave);
  }

  Future<void> _loadDraft() async {
    if (widget.draftId != null && widget.draftId != 'new') {
      try {
        final draft = await draftRepository.getDraft(widget.draftId!);
        setState(() {
          _currentDraftId = draft.id;
          _titleController.text = draft.title ?? '';
          _contentController.text = draft.body ?? '';
          _linkController.text = draft.linkUrl ?? '';
          _postType = draft.postType ?? 'text';
          _selectedCommunity = draft.communityName;
          _tags.addAll(draft.tags ?? []);
          _isSpoiler = draft.isSpoiler ?? false;
          _isOc = draft.isOc ?? false;
          _uploadedImageUrl = draft.imageUrl;
          
          if (draft.pollOptions != null && draft.pollOptions!.isNotEmpty) {
            _pollOptionControllers = draft.pollOptions!
                .map((opt) => TextEditingController(text: opt))
                .toList();
          }
          
          _lastSaved = draft.lastSavedAt;
        });
      } catch (e) {
        if (mounted) {
          ErrorHandler.handleError(context, e);
        }
      }
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), _autoSaveDraft);
  }

  Future<void> _autoSaveDraft() async {
    if (_isSaving) return;
    
    // Only save if there's content
    if (_titleController.text.trim().isEmpty && 
        _contentController.text.trim().isEmpty &&
        _linkController.text.trim().isEmpty) {
      return;
    }
    
    setState(() => _isSaving = true);
    
    try {
      final draft = await draftRepository.saveDraftPost(
        id: _currentDraftId ?? 'new',
        communityId: _selectedCommunity,
        postType: _postType,
        title: _titleController.text.trim(),
        body: _contentController.text.trim(),
        linkUrl: _linkController.text.trim(),
        imageUrl: _uploadedImageUrl,
        tags: _tags,
        isSpoiler: _isSpoiler,
        isOc: _isOc,
        pollOptions: _postType == 'poll'
            ? _pollOptionControllers.map((c) => c.text.trim()).toList()
            : null,
      );
      
      setState(() {
        _currentDraftId = draft.id;
        _lastSaved = draft.lastSavedAt;
      });
    } catch (e) {
      // Silent fail for auto-save
      debugPrint('Auto-save failed: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _manualSaveDraft() async {
    setState(() => _isSaving = true);
    
    try {
      final draft = await draftRepository.saveDraftPost(
        id: _currentDraftId ?? 'new',
        communityId: _selectedCommunity,
        postType: _postType,
        title: _titleController.text.trim(),
        body: _contentController.text.trim(),
        linkUrl: _linkController.text.trim(),
        imageUrl: _uploadedImageUrl,
        tags: _tags,
        isSpoiler: _isSpoiler,
        isOc: _isOc,
        pollOptions: _postType == 'poll'
            ? _pollOptionControllers.map((c) => c.text.trim()).toList()
            : null,
      );
      
      setState(() {
        _currentDraftId = draft.id;
        _lastSaved = draft.lastSavedAt;
      });
      
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Draft saved');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e);
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _loadCommunities() async {
    setState(() => _loadingCommunities = true);
    try {
      final list = await communityRepository.listCommunities();
      setState(() {
        _communities = list;
        _selectedCommunity =
            widget.communityId ?? (list.isNotEmpty ? list.first.name : null);
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e);
      }
    } finally {
      if (mounted) setState(() => _loadingCommunities = false);
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _linkController.dispose();
    for (final c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isEmpty) return;
    if (_tags.contains(tag)) return;
    setState(() => _tags.add(tag));
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _addPollOption() {
    if (_pollOptionControllers.length >= 4) return;
    setState(() => _pollOptionControllers.add(TextEditingController()));
  }

  void _handleSubmit() {
    // Validate title
    if (!ErrorHandler.validateInput(
      context,
      value: _titleController.text.trim(),
      fieldName: 'Title',
      required: true,
      minLength: 1,
      maxLength: 300,
    )) return;

    // Validate based on post type
    if (_postType == 'text') {
      if (!ErrorHandler.validateInput(
        context,
        value: _contentController.text.trim(),
        fieldName: 'Content',
        required: true,
      )) return;
    }

    if (_postType == 'link') {
      if (!ErrorHandler.validateInput(
        context,
        value: _linkController.text.trim(),
        fieldName: 'Link',
        required: true,
      )) return;
    }

    if (_postType == 'poll') {
      final filled = _pollOptionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (filled.length < 2) {
        ErrorHandler.showWarning(
          context,
          'Poll needs at least 2 options',
        );
        return;
      }
    }

    if (_postType == 'image') {
      if (_uploadingImage) {
        ErrorHandler.showWarning(
          context,
          'Please wait for the image to finish uploading',
        );
        return;
      }

      if (_uploadedImageUrl == null || _uploadedImageUrl!.isEmpty) {
        ErrorHandler.showWarning(
          context,
          'Please select and upload an image first',
        );
        return;
      }
    }

    () async {
      try {
        await postRepository.createPost(
          community: _selectedCommunity,
          title: _titleController.text.trim(),
          type: _postType,
          body: _postType == 'text' ? _contentController.text.trim() : null,
          linkUrl: _postType == 'link' ? _linkController.text.trim() : null,
          imageUrl: _postType == 'image' ? _uploadedImageUrl : null,
          tags: _tags,
          isSpoiler: _isSpoiler,
          isOc: _isOc,
          pollOptions: _postType == 'poll'
              ? _pollOptionControllers
                    .map((c) => c.text.trim())
                    .where((t) => t.isNotEmpty)
                    .toList()
              : null,
        );
        if (mounted) {
          if (_selectedCommunity != null && _selectedCommunity!.isNotEmpty) {
            ErrorHandler.showSuccess(
              context,
              'Posted to r/$_selectedCommunity',
            );
          } else {
            ErrorHandler.showSuccess(context, 'Posted successfully');
          }
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.handleError(context, e);
        }
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push(AppConstants.routeCreateCommunity),
            child: const Text('Create community'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Post to', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _loadingCommunities
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('📢 Public Feed'),
                            selected: _selectedCommunity == null ||
                                _selectedCommunity!.isEmpty,
                            onSelected: (_) =>
                                setState(() => _selectedCommunity = null),
                          ),
                          ..._communities.map((c) {
                            final id = c.name;
                            return ChoiceChip(
                              label: Text('r/$id'),
                              selected: _selectedCommunity == id,
                              onSelected: (_) =>
                                  setState(() => _selectedCommunity = id),
                            );
                          }).toList(),
                        ],
                      ),
                      if (_selectedCommunity == null ||
                          _selectedCommunity!.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Post will be shared to the public feed',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                    ],
                  ),

            const SizedBox(height: 16),
            Text('Post type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'text',
                  label: Text('Text'),
                  icon: Icon(Icons.text_fields),
                ),
                ButtonSegment(
                  value: 'link',
                  label: Text('Link'),
                  icon: Icon(Icons.link),
                ),
                ButtonSegment(
                  value: 'image',
                  label: Text('Image'),
                  icon: Icon(Icons.image_outlined),
                ),
                ButtonSegment(
                  value: 'poll',
                  label: Text('Poll'),
                  icon: Icon(Icons.bar_chart),
                ),
              ],
              selected: {_postType},
              onSelectionChanged: (s) => setState(() => _postType = s.first),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              maxLength: AppConstants.maxPostTitleLength,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'What do you want to share?',
              ),
              onChanged: (_) => setState(() {}),
            ),

            if (_postType == 'text')
              TextField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  alignLabelWithHint: true,
                  hintText: 'Add your thoughts',
                ),
                onChanged: (_) => setState(() {}),
              ),

            if (_postType == 'link')
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Link URL',
                  hintText: 'https://example.com',
                ),
                onChanged: (_) => setState(() {}),
              ),

            if (_postType == 'image')
              ImagePickerWidget(
                label: 'Select Image for Post',
                onImageSelected: (file) async {
                  setState(() {
                    _uploadingImage = true;
                  });
                  try {
                    final imageUrl = await uploadRepository.uploadPostImage(file);
                    setState(() {
                      _uploadedImageUrl = imageUrl;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image uploaded successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error uploading image: $e')),
                    );
                  } finally {
                    if (mounted) {
                      setState(() => _uploadingImage = false);
                    }
                  }
                },
              ),

            if (_postType == 'poll') ...[
              const SizedBox(height: 8),
              Column(
                children: [
                  for (var i = 0; i < _pollOptionControllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: _pollOptionControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Option ${i + 1}',
                          suffixIcon: _pollOptionControllers.length > 2
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => setState(
                                    () => _pollOptionControllers.removeAt(i),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _addPollOption,
                      icon: const Icon(Icons.add),
                      label: const Text('Add option (max 4)'),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('OC'),
                  selected: _isOc,
                  onSelected: (v) => setState(() => _isOc = v),
                ),
                FilterChip(
                  label: const Text('Spoiler'),
                  selected: _isSpoiler,
                  onSelected: (v) => setState(() => _isSpoiler = v),
                ),
                ActionChip(
                  label: const Text('Add tag'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final controller = TextEditingController();
                        return AlertDialog(
                          title: const Text('Add tag'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'e.g. help, showcase',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _addTag(controller.text.trim());
                                Navigator.pop(context);
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ..._tags.map(
                  (tag) => InputChip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            if (_lastSaved != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _isSaving 
                      ? 'Saving draft...' 
                      : 'Last saved: ${_formatSaveTime(_lastSaved!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _isSaving ? Colors.orange : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 360;

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        onPressed: _isSaving ? null : _manualSaveDraft,
                        child: const Text('Save Draft'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _handleSubmit,
                        icon: const Icon(Icons.send),
                        label: const Text('Post'),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : _manualSaveDraft,
                        child: const Text('Save Draft'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _handleSubmit,
                        icon: const Icon(Icons.send),
                        label: const Text('Post'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatSaveTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
