export default defineEventHandler(async (event) => {
  const authHeader = getRequestHeader(event, 'authorization')
  const body = await readBody(event)

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

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .maybeSingle()

  if (profile?.role !== 'company') {
    throw createError({
      statusCode: 403,
      message: 'Forbidden'
    })
  }

  const { data, error } = await supabase
    .from('opportunities')
    .insert({
      company_id: user.id,
      type: 'company',
      title: body.title,
      description: body.description,
      category: body.category,
      required_skills: body.required_skills || [],
      expertise_level: body.expertise_level || 'beginner',
      deadline: body.deadline,
      status: 'pending_review'
    })
    .select()
    .maybeSingle()

  if (error) {
    throw createError({
      statusCode: 500,
      message: 'Failed to create opportunity'
    })
  }

  return data
})
