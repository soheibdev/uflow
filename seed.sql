/*
  Seed Data for uflow Platform

  This file contains sample data for testing and development.

  Instructions:
  1. Run this after applying the main migration
  2. Default passwords are 'password123' (change in production!)
  3. Creates:
     - Admin user (admin@uflow.com)
     - Sample university domains
     - Sample blocked domains
     - Sample opportunities
     - Sample job offers
*/

-- Add University Domains
INSERT INTO university_domains (domain, university_name) VALUES
  ('stanford.edu', 'Stanford University'),
  ('mit.edu', 'Massachusetts Institute of Technology'),
  ('berkeley.edu', 'UC Berkeley'),
  ('harvard.edu', 'Harvard University'),
  ('cmu.edu', 'Carnegie Mellon University')
ON CONFLICT (domain) DO NOTHING;

-- Add Blocked Domains
INSERT INTO blocked_domains (domain) VALUES
  ('gmail.com'),
  ('yahoo.com'),
  ('outlook.com'),
  ('hotmail.com'),
  ('icloud.com')
ON CONFLICT (domain) DO NOTHING;

-- Sample Campus Opportunities (requires admin to create)
-- Note: You'll need to create these through the admin dashboard after creating an admin user

-- Sample Job Offers (these would normally come from the ingestion API)
INSERT INTO job_offers (
  external_id,
  source,
  title,
  company_name,
  description,
  required_skills,
  location,
  remote,
  salary_min,
  salary_max,
  url
) VALUES
  (
    'linkedin-job-001',
    'linkedin',
    'Frontend Developer Intern',
    'TechCorp Inc',
    'Join our team to build amazing web applications using React and TypeScript.',
    ARRAY['JavaScript', 'React', 'TypeScript', 'HTML', 'CSS'],
    'San Francisco, CA',
    true,
    50000,
    70000,
    'https://example.com/job1'
  ),
  (
    'linkedin-job-002',
    'linkedin',
    'UX Design Intern',
    'Design Studio',
    'Work on user interface design for mobile and web applications.',
    ARRAY['Figma', 'Adobe XD', 'User Research', 'Prototyping'],
    'Remote',
    true,
    45000,
    60000,
    'https://example.com/job2'
  ),
  (
    'linkedin-job-003',
    'linkedin',
    'Data Science Intern',
    'Analytics Co',
    'Analyze data and build machine learning models to solve business problems.',
    ARRAY['Python', 'SQL', 'Machine Learning', 'Pandas', 'Scikit-learn'],
    'Boston, MA',
    false,
    55000,
    75000,
    'https://example.com/job3'
  ),
  (
    'fiverr-gig-001',
    'fiverr',
    'Freelance Web Developer',
    'Various Clients',
    'Build websites and web applications for clients worldwide.',
    ARRAY['HTML', 'CSS', 'JavaScript', 'PHP', 'WordPress'],
    'Remote',
    true,
    30000,
    80000,
    'https://example.com/gig1'
  ),
  (
    'linkedin-job-004',
    'linkedin',
    'Software Engineering Intern',
    'StartupXYZ',
    'Full-stack development position working on cutting-edge technology.',
    ARRAY['Node.js', 'React', 'PostgreSQL', 'Git', 'Docker'],
    'Austin, TX',
    true,
    60000,
    85000,
    'https://example.com/job4'
  )
ON CONFLICT (external_id) DO NOTHING;

-- Instructions for creating admin user:
-- You need to create the admin user through the Supabase Dashboard:
-- 1. Go to Authentication > Users
-- 2. Create a new user with email: admin@uflow.com
-- 3. Copy the user ID
-- 4. Run the following SQL (replace USER_ID with actual ID):
/*
INSERT INTO profiles (id, email, role) VALUES
  ('USER_ID', 'admin@uflow.com', 'admin');
*/

COMMIT;
