export default defineEventHandler(async (event) => {
  const authHeader = getRequestHeader(event, 'authorization')
  const body = await readBody(event)

  if (!authHeader) {
    throw createError({
      statusCode: 401,
      message: 'Unauthorized'
    })
  }

  const { mood_level, mood_emoji, note } = body

  if (!mood_level || !mood_emoji) {
    throw createError({
      statusCode: 400,
      message: 'Missing required fields'
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

  const { data, error } = await supabase
    .from('mood_checkins')
    .upsert({
      student_id: user.id,
      mood_level,
      mood_emoji,
      note: note || '',
      checkin_date: today
    }, {
      onConflict: 'student_id,checkin_date'
    })
    .select()
    .maybeSingle()

  if (error) {
    throw createError({
      statusCode: 500,
      message: 'Failed to create check-in'
    })
  }

  return data
})
