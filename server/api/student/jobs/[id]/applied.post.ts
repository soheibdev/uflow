export default defineEventHandler(async (event) => {
  const authHeader = getRequestHeader(event, 'authorization')
  const jobId = getRouterParam(event, 'id')
  const body = await readBody(event)

  if (!authHeader || !jobId) {
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

  const { data, error } = await supabase
    .from('job_applications')
    .upsert({
      student_id: user.id,
      job_id: jobId,
      notes: body.notes || ''
    }, {
      onConflict: 'student_id,job_id'
    })
    .select()
    .maybeSingle()

  if (error) {
    throw createError({
      statusCode: 500,
      message: 'Failed to mark as applied'
    })
  }

  return data
})
