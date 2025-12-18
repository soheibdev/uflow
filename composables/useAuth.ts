import type { Profile, UserRole } from '~/types/database'

export const useAuth = () => {
  const { $supabase } = useNuxtApp()
  const user = useState<any>('user', () => null)
  const profile = useState<Profile | null>('profile', () => null)
  const loading = useState<boolean>('auth-loading', () => true)

  const fetchProfile = async () => {
    if (!user.value) return null

    const { data, error } = await $supabase
      .from('profiles')
      .select('*')
      .eq('id', user.value.id)
      .maybeSingle()

    if (error) {
      console.error('Error fetching profile:', error)
      return null
    }

    profile.value = data
    return data
  }

  const initialize = async () => {
    loading.value = true

    const { data } = await $supabase.auth.getSession()
    user.value = data.session?.user || null

    if (user.value) {
      await fetchProfile()
    }

    $supabase.auth.onAuthStateChange((_event: string, session: any) => {
      (async () => {
        user.value = session?.user || null
        if (user.value) {
          await fetchProfile()
        } else {
          profile.value = null
        }
      })()
    })

    loading.value = false
  }

  const signOut = async () => {
    const { error } = await $supabase.auth.signOut()
    if (!error) {
      user.value = null
      profile.value = null
      await navigateTo('/')
    }
    return { error }
  }

  const hasRole = (role: UserRole): boolean => {
    return profile.value?.role === role
  }

  return {
    user,
    profile,
    loading,
    initialize,
    fetchProfile,
    signOut,
    hasRole
  }
}
