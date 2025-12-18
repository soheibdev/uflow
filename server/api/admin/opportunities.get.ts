export default defineEventHandler(async (event) => {
  const authHeader = getRequestHeader(event, 'authorization')
  const query = getQuery(event)

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

  if (profile?.role !== 'admin') {
    throw createError({
      statusCode: 403,
      message: 'Forbidden'
    })
  }

  let queryBuilder = supabase
    .from('opportunities')
    .select('*, company_profiles(*)')
    .order('created_at', { ascending: false })

  if (query.status) {
    queryBuilder = queryBuilder.eq('status', query.status as string)
  }

  const { data, error } = await queryBuilder

  if (error) {
    throw createError({
      statusCode: 500,
      message: 'Failed to fetch opportunities'
    })
  }

  return data
})
