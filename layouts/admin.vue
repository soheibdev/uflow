<template>
  <div class="min-h-screen bg-neutral-50">
    <nav class="bg-white border-b border-neutral-200 sticky top-0 z-40">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center gap-8">
            <NuxtLink to="/admin/dashboard" class="text-2xl font-bold text-blue-600">
              uflow <span class="text-xs text-neutral-500">admin</span>
            </NuxtLink>
            <div class="hidden md:flex gap-4">
              <NuxtLink to="/admin/dashboard" class="px-3 py-2 text-sm font-medium text-neutral-700 hover:text-neutral-900 hover:bg-neutral-100 rounded-lg transition-colors">
                Review Queue
              </NuxtLink>
              <NuxtLink to="/admin/domains" class="px-3 py-2 text-sm font-medium text-neutral-700 hover:text-neutral-900 hover:bg-neutral-100 rounded-lg transition-colors">
                Domains
              </NuxtLink>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <UiButton size="sm" variant="outline" @click="handleSignOut">
              Sign Out
            </UiButton>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
const { signOut } = useAuth()

const handleSignOut = async () => {
  await signOut()
}
</script>
