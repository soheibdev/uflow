export default defineEventHandler(async (event) => {
  const secret = getRequestHeader(event, 'x-ingest-secret')
  const config = useRuntimeConfig()

  if (secret !== config.ingestSecret) {
    throw createError({
      statusCode: 401,
      message: 'Unauthorized'
    })
  }

  const body = await readBody(event)
  const { jobs } = body

  if (!jobs || !Array.isArray(jobs)) {
    throw createError({
      statusCode: 400,
      message: 'Invalid request body'
    })
  }

  const supabase = useSupabaseServer()
  const results = []

  for (const job of jobs) {
    const { data, error } = await supabase
      .from('job_offers')
      .upsert({
        external_id: job.external_id,
        source: job.source || 'unknown',
        title: job.title,
        company_name: job.company_name,
        description: job.description || '',
        required_skills: job.required_skills || [],
        location: job.location || '',
        remote: job.remote || false,
        salary_min: job.salary_min,
        salary_max: job.salary_max,
        url: job.url || '',
        scraped_at: new Date().toISOString()
      }, {
        onConflict: 'external_id'
      })
      .select()
      .maybeSingle()

    if (error) {
      results.push({ external_id: job.external_id, success: false, error: error.message })
    } else {
      results.push({ external_id: job.external_id, success: true, data })
    }
  }

  return {
    processed: jobs.length,
    results
  }
})
