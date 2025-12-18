# uflow - Student Opportunity & Job Discovery Platform

**Know what to do today**

A production-ready web platform that helps students decide what to do today and discover relevant opportunities and jobs, in a simple, ethical, and supportive way.

## Overview

uflow combines:
- Simple daily mood check-in
- Student interests, skills, and expertise level
- Campus events, company opportunities, and job offers
- AI recommendations that are relevant, optional, and respectful

The platform is:
- **Privacy-first**: No public profiles, no social feed
- **Non-medical**: Mood is optional and lightweight
- **Focused on relevance**: Not engagement addiction
- **Ethical**: AI that respects you

## Tech Stack

- **Frontend & Backend**: Nuxt 3 (TypeScript)
- **Styling**: Tailwind CSS
- **Database**: Supabase (PostgreSQL with RLS)
- **Authentication**: Supabase Auth
- **AI Integration**: External API (OpenAI or custom)

## Features

### For Students
- **Daily Mood Check-In**: Optional mood tracking for personalized recommendations
- **AI-Powered Daily Plans**: Get a personalized plan based on mood, interests, and skills
- **Opportunities Feed**: Browse campus events and company-posted opportunities
- **Job Discovery**: Find relevant jobs matched to your skills and expertise
- **Track Progress**: Mark tasks as complete and see your achievements

### For Companies
- **Post Opportunities**: Share internships, projects, and events with students
- **Review Applications**: Manage student applications
- **Admin-Reviewed**: All opportunities are reviewed before going live

### For Admins
- **Content Moderation**: Review and approve company-posted opportunities
- **Domain Management**: Manage allowed university domains and blocked public domains
- **System Oversight**: Ensure all content is student-appropriate

## Project Structure

```
uflow/
├── assets/
│   └── css/
│       └── main.css              # Tailwind CSS and custom styles
├── components/
│   └── ui/                       # Reusable UI components
│       ├── Button.vue
│       ├── Input.vue
│       ├── Card.vue
│       ├── Modal.vue
│       └── Badge.vue
├── composables/
│   ├── useAuth.ts                # Authentication composable
│   └── useStudent.ts             # Student-specific composable
├── layouts/
│   ├── student.vue               # Student dashboard layout
│   ├── company.vue               # Company dashboard layout
│   └── admin.vue                 # Admin dashboard layout
├── middleware/
│   └── auth.global.ts            # Global auth middleware with role-based access
├── pages/
│   ├── index.vue                 # Public landing page
│   ├── auth/
│   │   ├── signin.vue
│   │   ├── student-signup.vue
│   │   └── company-signup.vue
│   ├── student/
│   │   ├── dashboard.vue         # Daily plan & check-in
│   │   ├── opportunities.vue
│   │   └── jobs.vue
│   ├── company/
│   │   └── dashboard.vue         # Post & manage opportunities
│   └── admin/
│       ├── dashboard.vue         # Review opportunities
│       └── domains.vue           # Manage domains
├── plugins/
│   └── supabase.client.ts        # Supabase client plugin
├── server/
│   ├── api/
│   │   ├── auth/                 # Authentication endpoints
│   │   ├── student/              # Student endpoints
│   │   ├── company/              # Company endpoints
│   │   ├── admin/                # Admin endpoints
│   │   └── jobs/                 # Job ingestion endpoint
│   └── utils/
│       └── supabase.ts           # Server-side Supabase client
├── types/
│   └── database.ts               # TypeScript type definitions
├── .env.example                  # Environment variables template
├── seed.sql                      # Database seed data
├── nuxt.config.ts                # Nuxt configuration
├── tailwind.config.js            # Tailwind configuration
└── README.md                     # This file
```

## Setup Instructions

### Prerequisites

- Node.js 18+ installed
- A Supabase project (create one at https://supabase.com)
- (Optional) An AI service API key for recommendations

### 1. Clone and Install Dependencies

```bash
npm install
```

### 2. Configure Environment Variables

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Fill in your Supabase credentials:

```env
VITE_SUPABASE_URL=your-supabase-project-url
VITE_SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key

# Optional: AI Service
AI_SERVICE_URL=https://your-ai-service.com/api
AI_SERVICE_API_KEY=your-ai-api-key

# Job Ingestion Secret
INGEST_SECRET=your-random-secret-key
```

### 3. Set Up Database

The database schema has already been applied to your Supabase instance through the migrations system.

#### Load Seed Data

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy the contents of `seed.sql` and run it

This will populate:
- University domains (Stanford, MIT, Berkeley, etc.)
- Blocked domains (gmail.com, yahoo.com, etc.)
- Sample job offers

### 4. Create Admin User

1. Go to Supabase Dashboard → Authentication → Users
2. Create a new user with email: `admin@uflow.com` and a password
3. Copy the user ID
4. Go to SQL Editor and run:

```sql
INSERT INTO profiles (id, email, role) VALUES
  ('USER_ID_HERE', 'admin@uflow.com', 'admin');
```

### 5. Run Development Server

```bash
npm run dev
```

The app will be available at http://localhost:3000

## User Roles & Authentication

### Student Signup
- **Email Requirement**: Must use a university email domain (configured in `university_domains` table)
- **Registration**: Creates both `profiles` and `student_profiles` records
- **Access**: Can view dashboard, opportunities, and jobs

### Company Signup
- **Email Requirement**: Must use professional email (NOT gmail, yahoo, outlook, etc.)
- **Registration**: Creates both `profiles` and `company_profiles` records
- **Access**: Can post opportunities and view applications

### Admin
- **Creation**: Must be manually created in Supabase
- **Access**: Can review opportunities, manage domains, moderate content

## API Endpoints

### Authentication
- `POST /api/auth/signup-student` - Student registration
- `POST /api/auth/signup-company` - Company registration

### Student
- `GET /api/student/me` - Get student profile
- `POST /api/student/checkin` - Submit daily mood check-in
- `GET /api/student/today` - Get today's AI-generated plan
- `PATCH /api/student/plan-items/:id` - Update plan item status
- `GET /api/student/opportunities` - Get approved opportunities
- `GET /api/student/jobs` - Get job offers
- `POST /api/student/jobs/:id/save` - Save a job
- `POST /api/student/jobs/:id/applied` - Mark job as applied

### Company
- `POST /api/company/opportunities` - Create new opportunity

### Admin
- `GET /api/admin/opportunities` - Get opportunities (with status filter)
- `PATCH /api/admin/opportunities/:id/review` - Approve/reject opportunity

### Job Ingestion
- `POST /api/jobs/ingest` - Bulk insert jobs (requires `INGEST_SECRET`)

## AI Integration

The platform supports external AI services for generating daily recommendations.

### Request Format

```json
{
  "context": {
    "mood": 4,
    "interests": ["technology", "music"],
    "skills": ["JavaScript", "Python"],
    "expertise_level": "intermediate",
    "opportunities": [...],
    "jobs": [...]
  },
  "request_type": "daily_recommendations"
}
```

### Expected Response

```json
{
  "recommendations": [
    {
      "item_type": "opportunity",
      "title": "Tech Workshop",
      "description": "Learn about React",
      "reference_id": "uuid",
      "ai_reasoning": "Matches your JavaScript skills"
    }
  ]
}
```

If AI service is not configured, the app will use fallback recommendations.

## Database Schema

### Core Tables
- `profiles` - User accounts with role
- `student_profiles` - Student-specific data
- `company_profiles` - Company-specific data
- `mood_checkins` - Daily mood check-ins
- `daily_plans` - AI-generated daily plans
- `plan_items` - Individual plan items
- `opportunities` - Campus & company opportunities
- `job_offers` - External job listings
- `university_domains` - Allowed email domains
- `blocked_domains` - Blocked public email domains

### Security
- **Row Level Security (RLS)** enabled on all tables
- Students can only access their own data
- Companies can only access their own data and applications
- Admins have full access
- All policies enforce authentication

## Building for Production

```bash
npm run build
```

The build output will be in `.output/` directory.

Preview the production build:

```bash
npm run preview
```

## Deployment

This Nuxt 3 application can be deployed to:
- Vercel
- Netlify
- Railway
- Any Node.js hosting platform

Make sure to set all environment variables in your deployment platform.

## Development Notes

### Adding New Features
1. Create database migration if needed
2. Add API endpoint in `server/api/`
3. Create/update composables in `composables/`
4. Build UI components in `components/`
5. Create pages in `pages/`

### Code Style
- TypeScript strict mode enabled
- Tailwind CSS for styling
- Composition API for Vue components
- Server routes for backend logic

## Security Considerations

- **No Hardcoded Secrets**: All sensitive data in environment variables
- **RLS Policies**: Every table has proper RLS policies
- **Auth Middleware**: Global middleware protects all routes
- **Input Validation**: Server-side validation on all endpoints
- **Email Domain Validation**: Enforced for student/company signup
- **Admin Review**: All company content reviewed before publishing

## Privacy & Ethics

uflow is designed with privacy and ethics at its core:
- **No public profiles**: Student data is private
- **No social feed**: Focus on recommendations, not engagement
- **Optional mood tracking**: Non-medical, lightweight
- **Transparent AI**: Reasoning shown for recommendations
- **Student control**: All actions are optional

## License

This project is proprietary. All rights reserved.

## Support

For questions or issues, please contact the development team.

---

Built with care for students. Made with Nuxt 3, Tailwind CSS, and Supabase.
