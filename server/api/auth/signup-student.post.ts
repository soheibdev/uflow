export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { email, password, firstName, lastName, university, major } = body

  if (!email || !password || !firstName || !lastName) {
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
      role: 'student'
    })

  if (profileError) {
    await supabase.auth.admin.deleteUser(authData.user.id)
    throw createError({
      statusCode: 500,
      message: 'Failed to create profile'
    })
  }

  const { error: studentError } = await supabase
    .from('student_profiles')
    .insert({
      id: authData.user.id,
      first_name: firstName,
      last_name: lastName,
      university: university || '',
      major: major || ''
    })

  if (studentError) {
    await supabase.auth.admin.deleteUser(authData.user.id)
    throw createError({
      statusCode: 500,
      message: 'Failed to create student profile'
    })
  }

  return {
    success: true,
    user: authData.user
  }
})
