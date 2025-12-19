<template>
  <div class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <UiCard class="w-full max-w-md animate-scale-in">
      <div class="text-center mb-8">
        <h1 class="text-4xl font-bold text-neutral-900 mb-3">Welcome back</h1>
        <p class="text-neutral-600 text-lg">Sign in to your uflow account</p>
      </div>

      <form @submit.prevent="handleSignIn" class="space-y-4">
        <UiInput
          v-model="form.email"
          type="email"
          label="Email"
          placeholder="you@example.com"
          required
          :error="errors.email"
        />

        <UiInput
          v-model="form.password"
          type="password"
          label="Password"
          placeholder="••••••••"
          required
          :error="errors.password"
        />

        <div v-if="errors.general" class="p-3 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-sm text-red-600">{{ errors.general }}</p>
        </div>

        <UiButton type="submit" full-width :loading="loading">
          Sign In
        </UiButton>
      </form>

      <div class="mt-6 text-center space-y-2">
        <p class="text-sm text-neutral-600">
          Don't have an account?
        </p>
        <div class="flex gap-2 justify-center">
          <NuxtLink to="/auth/student-signup" class="text-sm text-blue-600 hover:text-blue-700 font-medium">
            Sign up as Student
          </NuxtLink>
          <span class="text-neutral-400">|</span>
          <NuxtLink to="/auth/company-signup" class="text-sm text-blue-600 hover:text-blue-700 font-medium">
            Sign up as Company
          </NuxtLink>
        </div>
      </div>

      <div class="mt-6 text-center">
        <NuxtLink to="/" class="text-sm text-neutral-500 hover:text-neutral-700">
          ← Back to home
        </NuxtLink>
      </div>
    </UiCard>
  </div>
</template>

<script setup lang="ts">
const { $supabase } = useNuxtApp()
const { initialize } = useAuth()

const form = reactive({
  email: '',
  password: ''
})

const errors = reactive({
  email: '',
  password: '',
  general: ''
})

const loading = ref(false)

const handleSignIn = async () => {
  errors.email = ''
  errors.password = ''
  errors.general = ''
  loading.value = true

  try {
    const { data, error } = await $supabase.auth.signInWithPassword({
      email: form.email,
      password: form.password
    })

    if (error) {
      errors.general = error.message
      return
    }

    await initialize()

    const { data: profile } = await $supabase
      .from('profiles')
      .select('role')
      .eq('id', data.user.id)
      .maybeSingle()

    if (profile?.role === 'student') {
      await navigateTo('/student/dashboard')
    } else if (profile?.role === 'company') {
      await navigateTo('/company/dashboard')
    } else if (profile?.role === 'admin') {
      await navigateTo('/admin/dashboard')
    }
  } catch (e: any) {
    errors.general = 'An unexpected error occurred'
  } finally {
    loading.value = false
  }
}
</script>
