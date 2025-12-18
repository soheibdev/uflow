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

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .maybeSingle()

  if (profile?.role !== 'student') {
    throw createError({
      statusCode: 403,
      message: 'Forbidden'
    })
  }

  const { data: studentProfile, error } = await supabase
    .from('student_profiles')
    .select('*')
    .eq('id', user.id)
    .maybeSingle()

  if (error) {
    throw createError({
      statusCode: 500,
      message: 'Failed to fetch profile'
    })
  }

  return {
    ...profile,
    ...studentProfile
  }
})
