/*
  # uflow Database Schema

  ## Overview
  Complete database schema for uflow platform - a student opportunity and job discovery platform
  with mood tracking and AI-powered daily recommendations.

  ## New Tables

  ### Core User Tables
  1. `profiles`
     - `id` (uuid, FK to auth.users) - User ID
     - `email` (text) - User email
     - `role` (text) - user role: student | company | admin
     - `created_at` (timestamptz) - Account creation time
     - `updated_at` (timestamptz) - Last update time

  2. `student_profiles`
     - `id` (uuid, FK to profiles) - Student ID
     - `first_name` (text) - First name
     - `last_name` (text) - Last name
     - `university` (text) - University name
     - `major` (text) - Major/field of study
     - `interests` (text[]) - Array of interests
     - `skills` (text[]) - Array of skills
     - `expertise_level` (text) - beginner | intermediate | expert
     - `preferences` (jsonb) - Additional preferences

  3. `company_profiles`
     - `id` (uuid, FK to profiles) - Company ID
     - `company_name` (text) - Company name
     - `industry` (text) - Industry
     - `description` (text) - Company description
     - `website` (text) - Company website
     - `logo_url` (text) - Logo URL

  ### Mood & Recommendations
  4. `mood_checkins`
     - `id` (uuid, PK) - Check-in ID
     - `student_id` (uuid, FK to student_profiles) - Student ID
     - `mood_level` (int) - Mood rating (1-5)
     - `mood_emoji` (text) - Emoji representation
     - `note` (text) - Optional note
     - `checkin_date` (date) - Date of check-in
     - `created_at` (timestamptz) - Creation time

  5. `daily_plans`
     - `id` (uuid, PK) - Plan ID
     - `student_id` (uuid, FK to student_profiles) - Student ID
     - `plan_date` (date) - Date of plan
     - `mood_checkin_id` (uuid, FK to mood_checkins) - Associated check-in
     - `ai_context` (jsonb) - AI request context
     - `created_at` (timestamptz) - Creation time

  6. `plan_items`
     - `id` (uuid, PK) - Item ID
     - `daily_plan_id` (uuid, FK to daily_plans) - Parent plan
     - `item_type` (text) - event | opportunity | job | self_care
     - `title` (text) - Item title
     - `description` (text) - Item description
     - `reference_id` (uuid) - ID of referenced entity
     - `status` (text) - pending | completed | skipped
     - `order_index` (int) - Display order
     - `ai_reasoning` (text) - Why AI recommended this

  ### Opportunities & Jobs
  7. `opportunities`
     - `id` (uuid, PK) - Opportunity ID
     - `type` (text) - campus | company
     - `company_id` (uuid, FK to company_profiles) - Company (if company type)
     - `title` (text) - Opportunity title
     - `description` (text) - Full description
     - `category` (text) - event | project | internship | job
     - `required_skills` (text[]) - Required skills
     - `expertise_level` (text) - beginner | intermediate | expert
     - `deadline` (timestamptz) - Application deadline
     - `status` (text) - pending_review | approved | rejected
     - `admin_notes` (text) - Admin review notes
     - `reviewed_at` (timestamptz) - Review timestamp
     - `reviewed_by` (uuid, FK to profiles) - Admin who reviewed
     - `created_at` (timestamptz) - Creation time
     - `updated_at` (timestamptz) - Last update

  8. `job_offers`
     - `id` (uuid, PK) - Job ID
     - `external_id` (text, unique) - External source ID
     - `source` (text) - linkedin | fiverr | other
     - `title` (text) - Job title
     - `company_name` (text) - Company name
     - `description` (text) - Job description
     - `required_skills` (text[]) - Required skills
     - `location` (text) - Job location
     - `remote` (boolean) - Remote work option
     - `salary_min` (int) - Min salary
     - `salary_max` (int) - Max salary
     - `url` (text) - External job URL
     - `scraped_at` (timestamptz) - When scraped
     - `created_at` (timestamptz) - Creation time

  ### Applications & Interactions
  9. `opportunity_applications`
     - `id` (uuid, PK) - Application ID
     - `opportunity_id` (uuid, FK to opportunities) - Opportunity
     - `student_id` (uuid, FK to student_profiles) - Student
     - `cover_letter` (text) - Application message
     - `status` (text) - pending | accepted | rejected
     - `company_message` (text) - Response from company
     - `created_at` (timestamptz) - Application time
     - `updated_at` (timestamptz) - Last update

  10. `saved_jobs`
     - `id` (uuid, PK) - Save ID
     - `student_id` (uuid, FK to student_profiles) - Student
     - `job_id` (uuid, FK to job_offers) - Job
     - `created_at` (timestamptz) - Save time

  11. `job_applications`
     - `id` (uuid, PK) - Application ID
     - `student_id` (uuid, FK to student_profiles) - Student
     - `job_id` (uuid, FK to job_offers) - Job
     - `applied_at` (timestamptz) - Application time
     - `notes` (text) - Student notes

  ### Configuration
  12. `university_domains`
     - `id` (uuid, PK) - Domain ID
     - `domain` (text, unique) - Domain (e.g., stanford.edu)
     - `university_name` (text) - University name
     - `created_at` (timestamptz) - Creation time

  13. `blocked_domains`
     - `id` (uuid, PK) - Domain ID
     - `domain` (text, unique) - Domain (e.g., gmail.com)
     - `created_at` (timestamptz) - Creation time

  ### System
  14. `notifications`
     - `id` (uuid, PK) - Notification ID
     - `user_id` (uuid, FK to profiles) - User
     - `type` (text) - Notification type
     - `title` (text) - Notification title
     - `message` (text) - Notification message
     - `reference_id` (uuid) - Related entity ID
     - `read` (boolean) - Read status
     - `created_at` (timestamptz) - Creation time

  15. `ai_requests`
     - `id` (uuid, PK) - Request ID
     - `user_id` (uuid, FK to profiles) - User making request
     - `request_type` (text) - Type of AI request
     - `request_payload` (jsonb) - Request data
     - `response_payload` (jsonb) - Response data
     - `created_at` (timestamptz) - Request time

  ## Security
  - RLS enabled on all tables
  - Students can only access their own data
  - Companies can only access their own data and applications to their opportunities
  - Admins have full access
  - Public read access to approved opportunities and job offers
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- PROFILES TABLE (Core user data)
-- =====================================================
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  role text NOT NULL CHECK (role IN ('student', 'company', 'admin')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can read all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =====================================================
-- STUDENT PROFILES
-- =====================================================
CREATE TABLE IF NOT EXISTS student_profiles (
  id uuid PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  first_name text NOT NULL DEFAULT '',
  last_name text NOT NULL DEFAULT '',
  university text DEFAULT '',
  major text DEFAULT '',
  interests text[] DEFAULT '{}',
  skills text[] DEFAULT '{}',
  expertise_level text DEFAULT 'beginner' CHECK (expertise_level IN ('beginner', 'intermediate', 'expert')),
  preferences jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE student_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can read own profile"
  ON student_profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Students can update own profile"
  ON student_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Students can insert own profile"
  ON student_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can read all student profiles"
  ON student_profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =====================================================
-- COMPANY PROFILES
-- =====================================================
CREATE TABLE IF NOT EXISTS company_profiles (
  id uuid PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  company_name text NOT NULL DEFAULT '',
  industry text DEFAULT '',
  description text DEFAULT '',
  website text DEFAULT '',
  logo_url text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE company_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Companies can read own profile"
  ON company_profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Companies can update own profile"
  ON company_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Companies can insert own profile"
  ON company_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Anyone can read company profiles"
  ON company_profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can read all company profiles"
  ON company_profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =====================================================
-- MOOD CHECK-INS
-- =====================================================
CREATE TABLE IF NOT EXISTS mood_checkins (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id uuid NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
  mood_level int NOT NULL CHECK (mood_level BETWEEN 1 AND 5),
  mood_emoji text DEFAULT '',
  note text DEFAULT '',
  checkin_date date NOT NULL DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(student_id, checkin_date)
);

ALTER TABLE mood_checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can read own check-ins"
  ON mood_checkins FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

CREATE POLICY "Students can create own check-ins"
  ON mood_checkins FOR INSERT
  TO authenticated
  WITH CHECK (student_id = auth.uid());

CREATE POLICY "Students can update own check-ins"
  ON mood_checkins FOR UPDATE
  TO authenticated
  USING (student_id = auth.uid())
  WITH CHECK (student_id = auth.uid());

-- =====================================================
-- DAILY PLANS
-- =====================================================
CREATE TABLE IF NOT EXISTS daily_plans (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id uuid NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
  plan_date date NOT NULL DEFAULT CURRENT_DATE,
  mood_checkin_id uuid REFERENCES mood_checkins(id) ON DELETE SET NULL,
  ai_context jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  UNIQUE(student_id, plan_date)
);

ALTER TABLE daily_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can read own daily plans"
  ON daily_plans FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

CREATE POLICY "Students can create own daily plans"
  ON daily_plans FOR INSERT
  TO authenticated
  WITH CHECK (student_id = auth.uid());

CREATE POLICY "Students can update own daily plans"
  ON daily_plans FOR UPDATE
  TO authenticated
  USING (student_id = auth.uid())
  WITH CHECK (student_id = auth.uid());

-- =====================================================
-- PLAN ITEMS
-- =====================================================
CREATE TABLE IF NOT EXISTS plan_items (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  daily_plan_id uuid NOT NULL REFERENCES daily_plans(id) ON DELETE CASCADE,
  item_type text NOT NULL CHECK (item_type IN ('event', 'opportunity', 'job', 'self_care')),
  title text NOT NULL,
  description text DEFAULT '',
  reference_id uuid,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'skipped')),
  order_index int DEFAULT 0,
  ai_reasoning text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE plan_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can read own plan items"
  ON plan_items FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM daily_plans
      WHERE id = plan_items.daily_plan_id
      AND student_id = auth.uid()
    )
  );

CREATE POLICY "Students can update own plan items"
  ON plan_items FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM daily_plans
      WHERE id = plan_items.daily_plan_id
      AND student_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM daily_plans
      WHERE id = plan_items.daily_plan_id
      AND student_id = auth.uid()
    )
  );

CREATE POLICY "Students can insert own plan items"
  ON plan_items FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM daily_plans
      WHERE id = plan_items.daily_plan_id
      AND student_id = auth.uid()
    )
  );

-- =====================================================
-- OPPORTUNITIES
-- =====================================================
CREATE TABLE IF NOT EXISTS opportunities (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  type text NOT NULL CHECK (type IN ('campus', 'company')),
  company_id uuid REFERENCES company_profiles(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text DEFAULT '',
  category text NOT NULL CHECK (category IN ('event', 'project', 'internship', 'job')),
  required_skills text[] DEFAULT '{}',
  expertise_level text DEFAULT 'beginner' CHECK (expertise_level IN ('beginner', 'intermediate', 'expert')),
  deadline timestamptz,
  status text DEFAULT 'pending_review' CHECK (status IN ('pending_review', 'approved', 'rejected')),
  admin_notes text DEFAULT '',
  reviewed_at timestamptz,
  reviewed_by uuid REFERENCES profiles(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE opportunities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read approved opportunities"
  ON opportunities FOR SELECT
  TO authenticated
  USING (status = 'approved');

CREATE POLICY "Companies can read own opportunities"
  ON opportunities FOR SELECT
  TO authenticated
  USING (company_id = auth.uid());

CREATE POLICY "Companies can create opportunities"
  ON opportunities FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'company'
    )
  );

CREATE POLICY "Companies can update own opportunities"
  ON opportunities FOR UPDATE
  TO authenticated
  USING (company_id = auth.uid())
  WITH CHECK (company_id = auth.uid());

CREATE POLICY "Admins can read all opportunities"
  ON opportunities FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can update all opportunities"
  ON opportunities FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can insert opportunities"
  ON opportunities FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =====================================================
-- JOB OFFERS
-- =====================================================
CREATE TABLE IF NOT EXISTS job_offers (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  external_id text UNIQUE NOT NULL,
  source text NOT NULL,
  title text NOT NULL,
  company_name text NOT NULL,
  description text DEFAULT '',
  required_skills text[] DEFAULT '{}',
  location text DEFAULT '',
  remote boolean DEFAULT false,
  salary_min int,
  salary_max int,
  url text DEFAULT '',
  scraped_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE job_offers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read job offers"
  ON job_offers FOR SELECT
  TO authenticated
  USING (true);

-- Only allow system/admin to insert jobs via API
CREATE POLICY "System can insert job offers"
  ON job_offers FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =====================================================
-- OPPORTUNITY APPLICATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS opportunity_applications (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  opportunity_id uuid NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
  cover_letter text DEFAULT '',
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  company_message text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(opportunity_id, student_id)
);

ALTER TABLE opportunity_applications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can read own applications"
  ON opportunity_applications FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

CREATE POLICY "Students can create own applications"
  ON opportunity_applications FOR INSERT
  TO authenticated
  WITH CHECK (student_id = auth.uid());

CREATE POLICY "Companies can read applications to their opportunities"
  ON opportunity_applications FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM opportunities
      WHERE id = opportunity_applications.opportunity_id
      AND company_id = auth.uid()
    )
  );

CREATE POLICY "Companies can update applications to their opportunities"
  ON opportunity_applications FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM opportunities
      WHERE id = opportunity_applications.opportunity_id
      AND company_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM opportunities
      WHERE id = opportunity_applications.opportunity_id
      AND company_id = auth.uid()
    )
  );

-- =====================================================
-- SAVED JOBS
-- =====================================================
CREATE TABLE IF NOT EXISTS saved_jobs (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id uuid NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
  job_id uuid NOT NULL REFERENCES job_offers(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(student_id, job_id)
);

ALTER TABLE saved_jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can read own saved jobs"
  ON saved_jobs FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

CREATE POLICY "Students can create own saved jobs"
  ON saved_jobs FOR INSERT
  TO authenticated
  WITH CHECK (student_id = auth.uid());

CREATE POLICY "Students can delete own saved jobs"
  ON saved_jobs FOR DELETE
  TO authenticated
  USING (student_id = auth.uid());

-- =====================================================
-- JOB APPLICATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS job_applications (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id uuid NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
  job_id uuid NOT NULL REFERENCES job_offers(id) ON DELETE CASCADE,
  applied_at timestamptz DEFAULT now(),
  notes text DEFAULT '',
  UNIQUE(student_id, job_id)
);

ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can read own job applications"
  ON job_applications FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

CREATE POLICY "Students can create own job applications"
  ON job_applications FOR INSERT
  TO authenticated
  WITH CHECK (student_id = auth.uid());

-- =====================================================
-- UNIVERSITY DOMAINS
-- =====================================================
CREATE TABLE IF NOT EXISTS university_domains (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  domain text UNIQUE NOT NULL,
  university_name text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE university_domains ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read university domains"
  ON university_domains FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert university domains"
  ON university_domains FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete university domains"
  ON university_domains FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =====================================================
-- BLOCKED DOMAINS
-- =====================================================
CREATE TABLE IF NOT EXISTS blocked_domains (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  domain text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE blocked_domains ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read blocked domains"
  ON blocked_domains FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert blocked domains"
  ON blocked_domains FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete blocked domains"
  ON blocked_domains FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =====================================================
-- NOTIFICATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type text NOT NULL,
  title text NOT NULL,
  message text DEFAULT '',
  reference_id uuid,
  read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own notifications"
  ON notifications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- System can create notifications for any user
CREATE POLICY "System can create notifications"
  ON notifications FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- =====================================================
-- AI REQUESTS LOG
-- =====================================================
CREATE TABLE IF NOT EXISTS ai_requests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  request_type text NOT NULL,
  request_payload jsonb DEFAULT '{}',
  response_payload jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE ai_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own AI requests"
  ON ai_requests FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "System can create AI requests"
  ON ai_requests FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Admins can read all AI requests"
  ON ai_requests FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);

CREATE INDEX IF NOT EXISTS idx_mood_checkins_student ON mood_checkins(student_id);
CREATE INDEX IF NOT EXISTS idx_mood_checkins_date ON mood_checkins(checkin_date);

CREATE INDEX IF NOT EXISTS idx_daily_plans_student ON daily_plans(student_id);
CREATE INDEX IF NOT EXISTS idx_daily_plans_date ON daily_plans(plan_date);

CREATE INDEX IF NOT EXISTS idx_plan_items_plan ON plan_items(daily_plan_id);

CREATE INDEX IF NOT EXISTS idx_opportunities_status ON opportunities(status);
CREATE INDEX IF NOT EXISTS idx_opportunities_company ON opportunities(company_id);
CREATE INDEX IF NOT EXISTS idx_opportunities_type ON opportunities(type);

CREATE INDEX IF NOT EXISTS idx_job_offers_external ON job_offers(external_id);

CREATE INDEX IF NOT EXISTS idx_applications_student ON opportunity_applications(student_id);
CREATE INDEX IF NOT EXISTS idx_applications_opportunity ON opportunity_applications(opportunity_id);

CREATE INDEX IF NOT EXISTS idx_saved_jobs_student ON saved_jobs(student_id);
CREATE INDEX IF NOT EXISTS idx_job_applications_student ON job_applications(student_id);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_student_profiles_updated_at ON student_profiles;
CREATE TRIGGER update_student_profiles_updated_at
  BEFORE UPDATE ON student_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_company_profiles_updated_at ON company_profiles;
CREATE TRIGGER update_company_profiles_updated_at
  BEFORE UPDATE ON company_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_opportunities_updated_at ON opportunities;
CREATE TRIGGER update_opportunities_updated_at
  BEFORE UPDATE ON opportunities
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_plan_items_updated_at ON plan_items;
CREATE TRIGGER update_plan_items_updated_at
  BEFORE UPDATE ON plan_items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_applications_updated_at ON opportunity_applications;
CREATE TRIGGER update_applications_updated_at
  BEFORE UPDATE ON opportunity_applications
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();