export default defineEventHandler(async (event) => {
  const authHeader = getRequestHeader(event, 'authorization')

  if (!authHeader) {
    throw createError({
      statusCode: 401,
      message: 'Unauthorized'
    })
  }

  const supabase = useSupabaseServer()
  const token = authHeader.replace('Bearer ', '')

  const { data: { user }, error: authError } = await supabase.auth.getUser(token)

  if (authError || !user) {
    throw createError({
      statusCode: 401,
      message: 'Unauthorized'
    })
  }

  const today = new Date().toISOString().split('T')[0]

  const { data: existingPlan } = await supabase
    .from('daily_plans')
    .select('*, plan_items(*)')
    .eq('student_id', user.id)
    .eq('plan_date', today)
    .maybeSingle()

  if (existingPlan) {
    return existingPlan
  }

  const { data: studentProfile } = await supabase
    .from('student_profiles')
    .select('*')
    .eq('id', user.id)
    .maybeSingle()

  const { data: todayCheckin } = await supabase
    .from('mood_checkins')
    .select('*')
    .eq('student_id', user.id)
    .eq('checkin_date', today)
    .maybeSingle()

  const { data: opportunities } = await supabase
    .from('opportunities')
    .select('*')
    .eq('status', 'approved')
    .limit(10)

  const { data: jobs } = await supabase
    .from('job_offers')
    .select('*')
    .limit(10)

  const aiContext = {
    mood: todayCheckin?.mood_level || null,
    interests: studentProfile?.interests || [],
    skills: studentProfile?.skills || [],
    expertise_level: studentProfile?.expertise_level || 'beginner',
    opportunities: opportunities || [],
    jobs: jobs || []
  }

  let planItems = []

  try {
    const config = useRuntimeConfig()

    if (config.aiServiceUrl && config.aiServiceApiKey) {
      const aiResponse = await $fetch(config.aiServiceUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${config.aiServiceApiKey}`
        },
        body: {
          context: aiContext,
          request_type: 'daily_recommendations'
        }
      })

      await supabase
        .from('ai_requests')
        .insert({
          user_id: user.id,
          request_type: 'daily_recommendations',
          request_payload: aiContext,
          response_payload: aiResponse
        })

      planItems = (aiResponse as any).recommendations || []
    }
  } catch (aiError) {
    console.error('AI service error:', aiError)
  }

  if (planItems.length === 0) {
    planItems = [
      {
        item_type: 'self_care',
        title: 'Take a mindful break',
        description: 'Take 10 minutes to relax and recharge',
        ai_reasoning: 'Self-care is important for productivity'
      },
      {
        item_type: 'opportunity',
        title: 'Explore campus events',
        description: 'Check out what\'s happening on campus today',
        ai_reasoning: 'Stay connected with campus life'
      }
    ]
  }

  const { data: newPlan, error: planError } = await supabase
    .from('daily_plans')
    .insert({
      student_id: user.id,
      plan_date: today,
      mood_checkin_id: todayCheckin?.id,
      ai_context: aiContext
    })
    .select()
    .maybeSingle()

  if (planError || !newPlan) {
    throw createError({
      statusCode: 500,
      message: 'Failed to create daily plan'
    })
  }

  const itemsToInsert = planItems.map((item: any, index: number) => ({
    daily_plan_id: newPlan.id,
    item_type: item.item_type || 'self_care',
    title: item.title,
    description: item.description || '',
    reference_id: item.reference_id,
    ai_reasoning: item.ai_reasoning || '',
    order_index: index
  }))

  const { data: createdItems } = await supabase
    .from('plan_items')
    .insert(itemsToInsert)
    .select()

  return {
    ...newPlan,
    plan_items: createdItems || []
  }
})
