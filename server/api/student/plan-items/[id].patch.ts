export default defineEventHandler(async (event) => {
  const authHeader = getRequestHeader(event, 'authorization')
  const itemId = getRouterParam(event, 'id')
  const body = await readBody(event)

  if (!authHeader || !itemId) {
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
    .from('plan_items')
    .update(body)
    .eq('id', itemId)
    .select()
    .maybeSingle()

  if (error) {
    throw createError({
      statusCode: 500,
      message: 'Failed to update plan item'
    })
  }

  return data
})
