export default defineEventHandler(async (event) => {
  const authHeader = getRequestHeader(event, 'authorization')
  const opportunityId = getRouterParam(event, 'id')
  const body = await readBody(event)

  if (!authHeader || !opportunityId) {
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

  if (profile?.role !== 'admin') {
    throw createError({
      statusCode: 403,
      message: 'Forbidden'
    })
  }

  const { data, error } = await supabase
    .from('opportunities')
    .update({
      status: body.status,
      admin_notes: body.admin_notes || '',
      reviewed_at: new Date().toISOString(),
      reviewed_by: user.id
    })
    .eq('id', opportunityId)
    .select()
    .maybeSingle()

  if (error) {
    throw createError({
      statusCode: 500,
      message: 'Failed to review opportunity'
    })
  }

  return data
})
