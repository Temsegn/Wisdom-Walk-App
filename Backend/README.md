# WisdomWalk Backend

A comprehensive backend API for WisdomWalk, a Christian women's community chat application.

## Features

- **User Authentication & Verification**
  - Email verification
  - Admin verification with live photo and national ID
  - JWT-based authentication

- **Group Management**
  - Four main groups: Single & Purposeful, Marriage & Ministry, Healing & Forgiveness, Motherhood in Christ
  - Group-specific content and discussions
  - Group admin nomination system

- **Content Management**
  - Three post types: Prayer requests, Confessions, Location sharing
  - Anonymous posting options
  - Virtual hugs with scripture
  - Prayer responses and comments

- **Chat System**
  - Direct messaging between users
  - Message reactions and replies
  - File attachments support

- **Admin Panel**
  - User verification management
  - Content moderation
  - Report handling
  - User management (block/ban)
  - Notification system

- **Security Features**
  - Rate limiting
  - Input validation
  - File upload security
  - CORS protection

## Installation

1. Clone the repository
2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Set up environment variables:
   \`\`\`bash
   cp .env.example .env
   # Edit .env with your configuration
   \`\`\`

4. Start MongoDB

5. Seed the database (optional):
   \`\`\`bash
   node scripts/seedData.js
   \`\`\`

6. Start the server:
   \`\`\`bash
   npm run dev
   \`\`\`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/verify-email` - Verify email
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password

### Users
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update profile
- `POST /api/users/join-group` - Join a group
- `POST /api/users/leave-group` - Leave a group
- `GET /api/users/search` - Search users

### Posts
- `POST /api/posts` - Create post
- `GET /api/posts/feed` - Get posts feed
- `GET /api/posts/:postId` - Get single post
- `POST /api/posts/:postId/like` - Like/unlike post
- `POST /api/posts/:postId/prayer` - Add prayer
- `POST /api/posts/:postId/virtual-hug` - Send virtual hug

### Chats
- `GET /api/chats` - Get user chats
- `POST /api/chats/direct` - Create direct chat
- `GET /api/chats/:chatId/messages` - Get chat messages
- `POST /api/chats/:chatId/messages` - Send message

### Groups
- `GET /api/groups/:groupType/posts` - Get group posts
- `POST /api/groups/:groupType/posts` - Create group post
- `GET /api/groups/:groupType/members` - Get group members
- `GET /api/groups/:groupType/stats` - Get group statistics

### Admin
- `GET /api/admin/verifications/pending` - Get pending verifications
- `POST /api/admin/users/:userId/verify` - Verify/reject user
- `GET /api/admin/users` - Get all users
- `POST /api/admin/users/:userId/block` - Block/unblock user
- `POST /api/admin/users/:userId/ban` - Ban user
- `GET /api/admin/reports` - Get reported content
- `POST /api/admin/notifications/send` - Send notifications

### Notifications
- `GET /api/notifications` - Get user notifications
- `PUT /api/notifications/:id/read` - Mark as read
- `POST /api/notifications/reports` - Submit report

## Database Models

- **User** - User accounts with verification status
- **Post** - General posts (prayer, confession, location)
- **Comment** - Comments on posts
- **Chat** - Chat conversations
- **Message** - Chat messages
- **Notification** - User notifications
- **Report** - Content reports
- **Group Models** - Single, Marriage, Healing, Motherhood specific content

## Sample Data

Run the seed script to populate the database with sample data:

\`\`\`bash
node scripts/seedData.js
\`\`\`

Sample login credentials:
- Admin: `admin@wisdomwalk.com` / `Admin123!`
- User: `mary@example.com` / `Mary123!`

## Environment Variables

See `.env.example` for all required environment variables.

## Security

- JWT authentication
- Password hashing with bcrypt
- File upload validation
- Rate limiting
- Input sanitization
- CORS protection

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.
