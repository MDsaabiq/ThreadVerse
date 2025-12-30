# 🚀 Feature Development Guide

This guide explains how to add new features to ThreadVerse following clean architecture principles.

---

## Step-by-Step: Adding a New Feature

Let's use **Creating a Post** as an example.

### Step 1: Create Feature Folder Structure

```bash
mkdir -p lib/features/post/{presentation/{screens,widgets},data/{models,repositories,services},domain}
```

Structure:
```
lib/features/post/
├── presentation/
│   ├── screens/
│   │   ├── create_post_screen.dart
│   │   └── post_detail_screen.dart
│   └── widgets/
│       ├── post_card.dart
│       └── comment_widget.dart
├── data/
│   ├── models/
│   │   ├── post_dto.dart
│   │   └── comment_dto.dart
│   ├── repositories/
│   │   └── post_repository_impl.dart
│   └── services/
│       └── post_api.dart
└── domain/
    └── models/
        ├── post.dart
        └── comment.dart
```

---

### Step 2: Define Domain Models (Business Logic)

```dart
// lib/features/post/domain/models/post.dart

class Post {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String communityId;
  final PostType type;
  final int score;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.communityId,
    required this.type,
    required this.score,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.createdAt,
  });

  // Helpful methods
  bool get isNew => DateTime.now().difference(createdAt).inHours < 24;
  
  Post copyWith({
    String? title,
    int? score,
    int? commentCount,
  }) {
    return Post(
      id: id,
      title: title ?? this.title,
      content: content,
      authorId: authorId,
      communityId: communityId,
      type: type,
      score: score ?? this.score,
      upvotes: upvotes,
      downvotes: downvotes,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
    );
  }
}

enum PostType { text, image, link, poll }
```

---

### Step 3: Create Data Transfer Objects (DTO)

```dart
// lib/features/post/data/models/post_dto.dart

class PostDTO extends Post {
  PostDTO({
    required String id,
    required String title,
    required String content,
    required String authorId,
    required String communityId,
    required PostType type,
    required int score,
    required int upvotes,
    required int downvotes,
    required int commentCount,
    required DateTime createdAt,
  }) : super(
    id: id,
    title: title,
    content: content,
    authorId: authorId,
    communityId: communityId,
    type: type,
    score: score,
    upvotes: upvotes,
    downvotes: downvotes,
    commentCount: commentCount,
    createdAt: createdAt,
  );

  // Convert API JSON to DTO
  factory PostDTO.fromJson(Map<String, dynamic> json) {
    return PostDTO(
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      authorId: json['author'],
      communityId: json['community'],
      type: PostType.values.byName(json['type']),
      score: json['score'],
      upvotes: json['upvotes'],
      downvotes: json['downvotes'],
      commentCount: json['commentCount'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert DTO to JSON for API
  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'content': content,
    'author': authorId,
    'community': communityId,
    'type': type.name,
    'score': score,
    'upvotes': upvotes,
    'downvotes': downvotes,
    'commentCount': commentCount,
    'createdAt': createdAt.toIso8601String(),
  };

  // Convert DTO to Domain Model
  Post toDomain() => Post(
    id: id,
    title: title,
    content: content,
    authorId: authorId,
    communityId: communityId,
    type: type,
    score: score,
    upvotes: upvotes,
    downvotes: downvotes,
    commentCount: commentCount,
    createdAt: createdAt,
  );
}
```

---

### Step 4: Create API Service

```dart
// lib/features/post/data/services/post_api.dart

import 'package:dio/dio.dart';
import 'package:threadverse/core/constants/app_constants.dart';
import 'post_dto.dart';

class PostAPI {
  final Dio _dio;

  PostAPI(this._dio);

  /// Get all posts with pagination and sorting
  Future<List<PostDTO>> getPosts({
    required int page,
    required int limit,
    required String sort,
    String? communityId,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/posts',
        queryParameters: {
          'page': page,
          'limit': limit,
          'sort': sort,
          if (communityId != null) 'communityId': communityId,
        },
      );

      final List<dynamic> data = response.data['posts'];
      return data.map((json) => PostDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get single post by ID
  Future<PostDTO> getPost(String postId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/posts/$postId',
      );
      return PostDTO.fromJson(response.data['post']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new post
  Future<PostDTO> createPost({
    required String title,
    required String content,
    required String communityId,
    required String type,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}/posts',
        data: {
          'title': title,
          'content': content,
          'community': communityId,
          'type': type,
        },
      );
      return PostDTO.fromJson(response.data['post']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update post
  Future<PostDTO> updatePost({
    required String postId,
    required String title,
    required String content,
  }) async {
    try {
      final response = await _dio.put(
        '${AppConstants.baseUrl}/posts/$postId',
        data: {
          'title': title,
          'content': content,
        },
      );
      return PostDTO.fromJson(response.data['post']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _dio.delete(
        '${AppConstants.baseUrl}/posts/$postId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    return Exception('API Error: ${error.message}');
  }
}
```

---

### Step 5: Create Repository (Data Abstraction)

```dart
// lib/features/post/data/repositories/post_repository.dart

abstract class PostRepository {
  Future<List<Post>> getPosts({
    required int page,
    String? communityId,
    String? sort,
  });

  Future<Post> getPost(String postId);

  Future<Post> createPost({
    required String title,
    required String content,
    required String communityId,
    required String type,
  });

  Future<Post> updatePost({
    required String postId,
    required String title,
    required String content,
  });

  Future<void> deletePost(String postId);
}

// Implementation
class PostRepositoryImpl implements PostRepository {
  final PostAPI _api;

  PostRepositoryImpl(this._api);

  @override
  Future<List<Post>> getPosts({
    required int page,
    String? communityId,
    String? sort = 'hot',
  }) async {
    final dtos = await _api.getPosts(
      page: page,
      limit: AppConstants.postsPerPage,
      sort: sort ?? 'hot',
      communityId: communityId,
    );
    
    // Convert DTOs to Domain Models
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Post> getPost(String postId) async {
    final dto = await _api.getPost(postId);
    return dto.toDomain();
  }

  @override
  Future<Post> createPost({
    required String title,
    required String content,
    required String communityId,
    required String type,
  }) async {
    final dto = await _api.createPost(
      title: title,
      content: content,
      communityId: communityId,
      type: type,
    );
    return dto.toDomain();
  }

  @override
  Future<Post> updatePost({
    required String postId,
    required String title,
    required String content,
  }) async {
    final dto = await _api.updatePost(
      postId: postId,
      title: title,
      content: content,
    );
    return dto.toDomain();
  }

  @override
  Future<void> deletePost(String postId) async {
    await _api.deletePost(postId);
  }
}
```

---

### Step 6: Create Riverpod Providers

```dart
// lib/features/post/presentation/providers/post_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/services/post_api.dart';
import '../../data/repositories/post_repository.dart';
import '../../domain/models/post.dart';

// API provider
final postAPIProvider = Provider((ref) => PostAPI(Dio()));

// Repository provider
final postRepositoryProvider = Provider((ref) {
  final api = ref.watch(postAPIProvider);
  return PostRepositoryImpl(api);
});

// Get all posts (paginated)
final postsProvider = FutureProvider.family<List<Post>, int>((ref, page) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getPosts(page: page);
});

// Get single post by ID
final postDetailProvider = FutureProvider.family<Post, String>((ref, postId) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getPost(postId);
});

// Create post (state notifier)
final createPostProvider = StateNotifierProvider<CreatePostNotifier, AsyncValue<Post?>>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return CreatePostNotifier(repository);
});

class CreatePostNotifier extends StateNotifier<AsyncValue<Post?>> {
  final PostRepository _repository;

  CreatePostNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createPost({
    required String title,
    required String content,
    required String communityId,
    required String type,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final post = await _repository.createPost(
        title: title,
        content: content,
        communityId: communityId,
        type: type,
      );
      state = AsyncValue.data(post);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
```

---

### Step 7: Create UI Screens & Widgets

```dart
// lib/features/post/presentation/screens/create_post_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/post_providers.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String? communityId;

  const CreatePostScreen({Key? key, this.communityId}) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _postType = 'text';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleCreatePost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Create post using provider
    await ref.read(createPostProvider.notifier).createPost(
      title: _titleController.text,
      content: _contentController.text,
      communityId: widget.communityId ?? '',
      type: _postType,
    );

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final createPostState = ref.watch(createPostProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Post title',
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: 300,
            ),
            const SizedBox(height: 16),

            // Content field
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Write your post...',
                prefixIcon: Icon(Icons.edit),
              ),
              minLines: 5,
              maxLines: 10,
              maxLength: 40000,
            ),
            const SizedBox(height: 16),

            // Post type selector
            DropdownButtonFormField<String>(
              value: _postType,
              items: const [
                DropdownMenuItem(value: 'text', child: Text('Text')),
                DropdownMenuItem(value: 'image', child: Text('Image')),
                DropdownMenuItem(value: 'link', child: Text('Link')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _postType = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Create button
            ElevatedButton(
              onPressed: createPostState.isLoading ? null : _handleCreatePost,
              child: createPostState.when(
                data: (_) => const Text('Create Post'),
                loading: () => const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, st) => const Text('Create Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Step 8: Add Route

```dart
// lib/routing/app_router.dart

GoRoute(
  path: '/create-post',
  name: 'create-post',
  pageBuilder: (context, state) {
    final communityId = state.uri.queryParameters['communityId'];
    return MaterialPage(
      key: state.pageKey,
      child: CreatePostScreen(communityId: communityId),
    );
  },
),
```

---

### Step 9: Use in Widgets

```dart
// Navigate to create post
context.push('/create-post?communityId=r_flutter');

// Or use named route
context.pushNamed('create-post', queryParameters: {'communityId': 'r_flutter'});
```

---

## Best Practices

✅ **DO:**
- Keep domain models independent
- Use repositories for data abstraction
- Create reusable providers
- Validate input on UI layer
- Handle errors properly
- Write meaningful variable names
- Comment complex logic

❌ **DON'T:**
- Make API calls directly from UI
- Store credentials in code
- Use deeply nested widgets
- Ignore error states
- Create circular dependencies
- Make models too complex

---

## Testing the Feature

```dart
// test/features/post/post_repository_test.dart

void main() {
  group('PostRepository', () {
    test('getPosts returns list of posts', () async {
      final api = MockPostAPI();
      final repo = PostRepositoryImpl(api);

      final posts = await repo.getPosts(page: 1);

      expect(posts, isNotEmpty);
      expect(posts.first, isA<Post>());
    });

    test('createPost returns new post', () async {
      final api = MockPostAPI();
      final repo = PostRepositoryImpl(api);

      final post = await repo.createPost(
        title: 'Test',
        content: 'Content',
        communityId: 'r_test',
        type: 'text',
      );

      expect(post.title, 'Test');
    });
  });
}
```

