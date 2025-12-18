export type UserRole = 'student' | 'company' | 'admin'
export type ExpertiseLevel = 'beginner' | 'intermediate' | 'expert'
export type OpportunityType = 'campus' | 'company'
export type OpportunityCategory = 'event' | 'project' | 'internship' | 'job'
export type OpportunityStatus = 'pending_review' | 'approved' | 'rejected'
export type ApplicationStatus = 'pending' | 'accepted' | 'rejected'
export type PlanItemType = 'event' | 'opportunity' | 'job' | 'self_care'
export type PlanItemStatus = 'pending' | 'completed' | 'skipped'

export interface Profile {
  id: string
  email: string
  role: UserRole
  created_at: string
  updated_at: string
}

export interface StudentProfile {
  id: string
  first_name: string
  last_name: string
  university: string
  major: string
  interests: string[]
  skills: string[]
  expertise_level: ExpertiseLevel
  preferences: Record<string, any>
  created_at: string
  updated_at: string
}

export interface CompanyProfile {
  id: string
  company_name: string
  industry: string
  description: string
  website: string
  logo_url: string
  created_at: string
  updated_at: string
}

export interface MoodCheckin {
  id: string
  student_id: string
  mood_level: number
  mood_emoji: string
  note: string
  checkin_date: string
  created_at: string
}

export interface DailyPlan {
  id: string
  student_id: string
  plan_date: string
  mood_checkin_id?: string
  ai_context: Record<string, any>
  created_at: string
}

export interface PlanItem {
  id: string
  daily_plan_id: string
  item_type: PlanItemType
  title: string
  description: string
  reference_id?: string
  status: PlanItemStatus
  order_index: number
  ai_reasoning: string
  created_at: string
  updated_at: string
}

export interface Opportunity {
  id: string
  type: OpportunityType
  company_id?: string
  title: string
  description: string
  category: OpportunityCategory
  required_skills: string[]
  expertise_level: ExpertiseLevel
  deadline?: string
  status: OpportunityStatus
  admin_notes: string
  reviewed_at?: string
  reviewed_by?: string
  created_at: string
  updated_at: string
}

export interface JobOffer {
  id: string
  external_id: string
  source: string
  title: string
  company_name: string
  description: string
  required_skills: string[]
  location: string
  remote: boolean
  salary_min?: number
  salary_max?: number
  url: string
  scraped_at: string
  created_at: string
}

export interface OpportunityApplication {
  id: string
  opportunity_id: string
  student_id: string
  cover_letter: string
  status: ApplicationStatus
  company_message: string
  created_at: string
  updated_at: string
}

export interface SavedJob {
  id: string
  student_id: string
  job_id: string
  created_at: string
}

export interface JobApplication {
  id: string
  student_id: string
  job_id: string
  applied_at: string
  notes: string
}

export interface UniversityDomain {
  id: string
  domain: string
  university_name: string
  created_at: string
}

export interface BlockedDomain {
  id: string
  domain: string
  created_at: string
}

export interface Notification {
  id: string
  user_id: string
  type: string
  title: string
  message: string
  reference_id?: string
  read: boolean
  created_at: string
}

export interface AIRequest {
  id: string
  user_id: string
  request_type: string
  request_payload: Record<string, any>
  response_payload: Record<string, any>
  created_at: string
}
