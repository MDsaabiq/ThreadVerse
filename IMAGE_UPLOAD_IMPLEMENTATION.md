# Image Upload System - Implementation Summary

## Overview
Implemented complete image upload system using Cloudinary for posts, user avatars, and community icons/banners.

## Backend Implementation

### Configuration
**File**: `src/config/cloudinary.ts`
- Configured Cloudinary SDK with environment variables
- Cloud name: `dvladkf63`
- API credentials from .env file

### Upload Utilities
**File**: `src/utils/upload.ts`
- **Multer Configuration**: 
  - Memory storage (no disk writes)
  - 5MB file size limit
  - Image-only filter (jpeg, jpg, png, gif, webp)
  
- **Upload Functions**:
  - `uploadToCloudinary(buffer, folder)`: General image upload with 1200x1200 max dimensions, auto quality/format
  - `uploadAvatarToCloudinary(buffer)`: Avatar-specific upload with 400x400 face-cropped thumbnail
  - `deleteFromCloudinary(url)`: Cleanup function for old images

### Controllers
**File**: `src/controllers/uploadController.ts`

#### `uploadAvatar` - POST /api/v1/upload/avatar
- Requires authentication
- Deletes old avatar if exists
- Uploads new avatar (400x400 face-crop)
- Updates User model `avatarUrl` field
- Returns: `{ avatarUrl: string }`

#### `uploadPostImage` - POST /api/v1/upload/post/:postId
- Requires authentication
- Verifies post ownership
- Deletes old image if exists
- Uploads image (1200x1200 max)
- Updates Post model `imageUrl` field
- Returns: `{ imageUrl: string }`

#### `uploadCommunityIcon` - POST /api/v1/upload/community/:name/icon
- Requires authentication
- Verifies user is community creator or moderator
- Deletes old icon if exists
- Uploads icon (400x400 face-crop for circular display)
- Updates Community model `iconUrl` field
- Returns: `{ iconUrl: string }`

#### `uploadCommunityBanner` - POST /api/v1/upload/community/:name/banner
- Requires authentication
- Verifies user is community creator or moderator
- Deletes old banner if exists
- Uploads banner (1200x1200 max)
- Updates Community model `bannerUrl` field
- Returns: `{ bannerUrl: string }`

### Routes
**File**: `src/routes/upload.ts`
- All routes require authentication via `requireAuth` middleware
- All routes use `upload.single("image")` multer middleware
- Mounted at `/api/v1/upload`

### Model Updates

**Community Model** (`src/models/Community.ts`):
```typescript
iconUrl: { type: String },    // Community circular icon
bannerUrl: { type: String },  // Community header banner
```

**User Model** (`src/models/User.ts`):
- Already had `avatarUrl: { type: String }`

**Post Model** (`src/models/Post.ts`):
- Already had `imageUrl: { type: String }`

## API Usage Examples

### Upload User Avatar
```bash
POST /api/v1/upload/avatar
Headers:
  Authorization: Bearer <token>
  Content-Type: multipart/form-data
Body:
  image: <file>

Response:
{
  "avatarUrl": "https://res.cloudinary.com/dvladkf63/image/upload/..."
}
```

### Upload Post Image
```bash
POST /api/v1/upload/post/67933b4d5e0a8e001f4c5678
Headers:
  Authorization: Bearer <token>
  Content-Type: multipart/form-data
Body:
  image: <file>

Response:
{
  "imageUrl": "https://res.cloudinary.com/dvladkf63/image/upload/..."
}
```

### Upload Community Icon
```bash
POST /api/v1/upload/community/flutter/icon
Headers:
  Authorization: Bearer <token>
  Content-Type: multipart/form-data
Body:
  image: <file>

Response:
{
  "iconUrl": "https://res.cloudinary.com/dvladkf63/image/upload/..."
}
```

### Upload Community Banner
```bash
POST /api/v1/upload/community/flutter/banner
Headers:
  Authorization: Bearer <token>
  Content-Type: multipart/form-data
Body:
  image: <file>

Response:
{
  "bannerUrl": "https://res.cloudinary.com/dvladkf63/image/upload/..."
}
```

## Frontend Integration TODO

1. **Add Image Picker Package**:
   ```yaml
   dependencies:
     image_picker: ^1.0.5
   ```

2. **Profile Edit Screen**:
   - Add "Change Avatar" button
   - Use ImagePicker to select image
   - Upload to `/api/v1/upload/avatar`
   - Display new avatar

3. **Post Creation Screen**:
   - Add "Attach Image" button for image posts
   - Upload after post creation to `/api/v1/upload/post/:postId`
   - Or upload before and pass URL to post creation

4. **Community Settings Screen**:
   - Add "Edit Icon" button for moderators
   - Add "Edit Banner" button for moderators
   - Upload to respective endpoints

5. **Image Display**:
   - Update PostCard to display `imageUrl` if present
   - Update UserProfile to display `avatarUrl`
   - Update CommunityHeader to display `iconUrl` and `bannerUrl`

## Security Features

- ✅ Authentication required for all uploads
- ✅ Ownership verification (posts must be owned by uploader)
- ✅ Permission checks (community icons/banners require moderator)
- ✅ File size limit (5MB)
- ✅ File type validation (images only)
- ✅ Old image cleanup (deletes previous upload)

## Image Transformations

**Post Images**:
- Max dimensions: 1200x1200
- Auto quality optimization
- Auto format selection (WebP when supported)

**Avatars & Community Icons**:
- Dimensions: 400x400
- Face detection crop (gravity: faces)
- Circular crop ready

**Community Banners**:
- Max dimensions: 1200x1200
- Auto quality optimization
- Aspect ratio preserved

## Dependencies Installed

```json
{
  "dependencies": {
    "cloudinary": "^2.8.0",
    "multer": "^1.4.5-lts.1"
  },
  "devDependencies": {
    "@types/multer": "^1.4.12",
    "tsx": "^4.19.2"
  }
}
```

## Environment Variables Required

```env
CLOUDINARY_CLOUD_NAME=dvladkf63
CLOUDINARY_API_KEY=163116882596118
CLOUDINARY_API_SECRET=1bMUaifVpSTDUqk93n_K3VOZRv8
```

## Testing Notes

- Backend compiles successfully with TypeScript
- All routes properly integrated
- Error handling in place for:
  - Missing files
  - Unauthorized access
  - Non-existent posts/communities
  - Permission denied scenarios

## Next Steps for Frontend

1. Install `image_picker` Flutter package
2. Create image upload service in `lib/core/network/`
3. Add UI components for image selection
4. Integrate upload API calls
5. Update widgets to display uploaded images
6. Add loading states during upload
7. Handle upload errors gracefully
