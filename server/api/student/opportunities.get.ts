export default defineEventHandler(async (event) => {
  const authHeader = getRequestHeader(event, 'authorization')

  if (!authHeader) {
    throw createError({
      statusCode: 401,
      message: 'Unauthorized'
    })
  }

  const supabase = useSupabaseServer()

  const { data, error } = await supabase
    .from('opportunities')
    .select('*, company_profiles(*)')
    .eq('status', 'approved')
    .order('created_at', { ascending: false })

  if (error) {
    throw createError({
      statusCode: 500,
      message: 'Failed to fetch opportunities'
    })
  }

  return data
})
