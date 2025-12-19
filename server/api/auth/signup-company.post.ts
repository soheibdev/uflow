export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { email, password, companyName, industry, description, website } = body

  if (!email || !password || !companyName) {
    throw createError({
      statusCode: 400,
      message: 'Missing required fields'
    })
  }

  const supabase = useSupabaseServer()

  const { data: authData, error: authError } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true
  })

  if (authError || !authData.user) {
    throw createError({
      statusCode: 400,
      message: authError?.message || 'Failed to create user'
    })
  }

  const { error: profileError } = await supabase
    .from('profiles')
    .insert({
      id: authData.user.id,
      email,
      role: 'company'
    })

  if (profileError) {
    await supabase.auth.admin.deleteUser(authData.user.id)
    throw createError({
      statusCode: 500,
      message: 'Failed to create profile'
    })
  }

  const { error: companyError } = await supabase
    .from('company_profiles')
    .insert({
      id: authData.user.id,
      company_name: companyName,
      industry: industry || '',
      description: description || '',
      website: website || ''
    })

  if (companyError) {
    await supabase.auth.admin.deleteUser(authData.user.id)
    throw createError({
      statusCode: 500,
      message: 'Failed to create company profile'
    })
  }

  return {
    success: true,
    user: authData.user
  }
})
