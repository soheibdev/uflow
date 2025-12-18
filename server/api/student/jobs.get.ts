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

  const { data: jobs, error } = await supabase
    .from('job_offers')
    .select('*')
    .order('scraped_at', { ascending: false })
    .limit(100)

  if (error) {
    throw createError({
      statusCode: 500,
      message: 'Failed to fetch jobs'
    })
  }

  const { data: savedJobs } = await supabase
    .from('saved_jobs')
    .select('job_id')
    .eq('student_id', user.id)

  const savedJobIds = new Set(savedJobs?.map(sj => sj.job_id) || [])

  const { data: appliedJobs } = await supabase
    .from('job_applications')
    .select('job_id')
    .eq('student_id', user.id)

  const appliedJobIds = new Set(appliedJobs?.map(aj => aj.job_id) || [])

  const enrichedJobs = (jobs || []).map(job => ({
    ...job,
    is_saved: savedJobIds.has(job.id),
    is_applied: appliedJobIds.has(job.id)
  }))

  return enrichedJobs
})
