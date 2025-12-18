export default defineNuxtRouteMiddleware(async (to) => {
  const { user, profile, loading, initialize } = useAuth()

  if (loading.value) {
    await initialize()
  }

  const publicPaths = ['/', '/auth/student-signup', '/auth/company-signup', '/auth/signin']
  const isPublicPath = publicPaths.includes(to.path)

  if (!user.value && !isPublicPath) {
    return navigateTo('/auth/signin')
  }

  if (user.value && profile.value) {
    const role = profile.value.role

    if (to.path.startsWith('/student') && role !== 'student') {
      return navigateTo('/')
    }

    if (to.path.startsWith('/company') && role !== 'company') {
      return navigateTo('/')
    }

    if (to.path.startsWith('/admin') && role !== 'admin') {
      return navigateTo('/')
    }

    if (isPublicPath && to.path !== '/') {
      if (role === 'student') return navigateTo('/student/dashboard')
      if (role === 'company') return navigateTo('/company/dashboard')
      if (role === 'admin') return navigateTo('/admin/dashboard')
    }
  }
})
