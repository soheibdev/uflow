import type { StudentProfile, MoodCheckin, DailyPlan, PlanItem } from '~/types/database'

export const useStudent = () => {
  const { $supabase } = useNuxtApp()
  const { user } = useAuth()

  const getProfile = async (): Promise<StudentProfile | null> => {
    if (!user.value) return null

    const { data, error } = await $supabase
      .from('student_profiles')
      .select('*')
      .eq('id', user.value.id)
      .maybeSingle()

    if (error) {
      console.error('Error fetching student profile:', error)
      return null
    }

    return data
  }

  const updateProfile = async (updates: Partial<StudentProfile>) => {
    if (!user.value) return { error: 'Not authenticated' }

    const { data, error } = await $supabase
      .from('student_profiles')
      .update(updates)
      .eq('id', user.value.id)
      .select()
      .maybeSingle()

    return { data, error }
  }

  const getTodayCheckin = async (): Promise<MoodCheckin | null> => {
    if (!user.value) return null

    const today = new Date().toISOString().split('T')[0]

    const { data, error } = await $supabase
      .from('mood_checkins')
      .select('*')
      .eq('student_id', user.value.id)
      .eq('checkin_date', today)
      .maybeSingle()

    if (error) {
      console.error('Error fetching checkin:', error)
      return null
    }

    return data
  }

  const createCheckin = async (checkin: {
    mood_level: number
    mood_emoji: string
    note?: string
  }) => {
    if (!user.value) return { error: 'Not authenticated' }

    const { data, error } = await $supabase
      .from('mood_checkins')
      .insert({
        student_id: user.value.id,
        ...checkin,
        checkin_date: new Date().toISOString().split('T')[0]
      })
      .select()
      .maybeSingle()

    return { data, error }
  }

  const getTodayPlan = async (): Promise<{ plan: DailyPlan | null; items: PlanItem[] }> => {
    if (!user.value) return { plan: null, items: [] }

    const today = new Date().toISOString().split('T')[0]

    const { data: plan, error: planError } = await $supabase
      .from('daily_plans')
      .select('*')
      .eq('student_id', user.value.id)
      .eq('plan_date', today)
      .maybeSingle()

    if (planError || !plan) {
      return { plan: null, items: [] }
    }

    const { data: items, error: itemsError } = await $supabase
      .from('plan_items')
      .select('*')
      .eq('daily_plan_id', plan.id)
      .order('order_index')

    if (itemsError) {
      console.error('Error fetching plan items:', itemsError)
      return { plan, items: [] }
    }

    return { plan, items: items || [] }
  }

  const updatePlanItem = async (itemId: string, updates: Partial<PlanItem>) => {
    const { data, error } = await $supabase
      .from('plan_items')
      .update(updates)
      .eq('id', itemId)
      .select()
      .maybeSingle()

    return { data, error }
  }

  return {
    getProfile,
    updateProfile,
    getTodayCheckin,
    createCheckin,
    getTodayPlan,
    updatePlanItem
  }
}
