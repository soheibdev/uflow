<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 to-white flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <UiCard class="w-full max-w-md">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-neutral-900 mb-2">Student Sign Up</h1>
        <p class="text-neutral-600">Create your uflow account</p>
      </div>

      <form @submit.prevent="handleSignUp" class="space-y-4">
        <div class="grid grid-cols-2 gap-4">
          <UiInput
            v-model="form.firstName"
            label="First Name"
            placeholder="John"
            required
            :error="errors.firstName"
          />

          <UiInput
            v-model="form.lastName"
            label="Last Name"
            placeholder="Doe"
            required
            :error="errors.lastName"
          />
        </div>

        <UiInput
          v-model="form.email"
          type="email"
          label="University Email"
          placeholder="you@university.edu"
          required
          hint="Use your university email address"
          :error="errors.email"
        />

        <UiInput
          v-model="form.password"
          type="password"
          label="Password"
          placeholder="••••••••"
          required
          hint="At least 6 characters"
          :error="errors.password"
        />

        <UiInput
          v-model="form.university"
          label="University"
          placeholder="Stanford University"
          :error="errors.university"
        />

        <UiInput
          v-model="form.major"
          label="Major"
          placeholder="Computer Science"
          :error="errors.major"
        />

        <div v-if="errors.general" class="p-3 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-sm text-red-600">{{ errors.general }}</p>
        </div>

        <div v-if="success" class="p-3 bg-green-50 border border-green-200 rounded-lg">
          <p class="text-sm text-green-600">Account created! Redirecting...</p>
        </div>

        <UiButton type="submit" full-width :loading="loading">
          Create Account
        </UiButton>
      </form>

      <div class="mt-6 text-center">
        <p class="text-sm text-neutral-600">
          Already have an account?
          <NuxtLink to="/auth/signin" class="text-blue-600 hover:text-blue-700 font-medium">
            Sign in
          </NuxtLink>
        </p>
      </div>

      <div class="mt-4 text-center">
        <NuxtLink to="/" class="text-sm text-neutral-500 hover:text-neutral-700">
          ← Back to home
        </NuxtLink>
      </div>
    </UiCard>
  </div>
</template>

<script setup lang="ts">
const { $supabase } = useNuxtApp()

const form = reactive({
  firstName: '',
  lastName: '',
  email: '',
  password: '',
  university: '',
  major: ''
})

const errors = reactive({
  firstName: '',
  lastName: '',
  email: '',
  password: '',
  university: '',
  major: '',
  general: ''
})

const loading = ref(false)
const success = ref(false)

const handleSignUp = async () => {
  Object.keys(errors).forEach(key => {
    (errors as any)[key] = ''
  })
  loading.value = true

  try {
    const response = await $fetch('/api/auth/signup-student', {
      method: 'POST',
      body: {
        email: form.email,
        password: form.password,
        firstName: form.firstName,
        lastName: form.lastName,
        university: form.university,
        major: form.major
      }
    })

    success.value = true

    const { error: signInError } = await $supabase.auth.signInWithPassword({
      email: form.email,
      password: form.password
    })

    if (!signInError) {
      setTimeout(() => {
        navigateTo('/student/dashboard')
      }, 1000)
    }
  } catch (e: any) {
    errors.general = e.data?.message || 'Failed to create account'
  } finally {
    loading.value = false
  }
}
</script>
