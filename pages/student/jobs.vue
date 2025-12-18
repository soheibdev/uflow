<template>
  <NuxtLayout name="student">
    <div class="space-y-6">
      <div>
        <h1 class="text-3xl font-bold text-neutral-900 mb-2">Job Opportunities</h1>
        <p class="text-neutral-600">Discover jobs matched to your skills and interests</p>
      </div>

      <div v-if="loading" class="text-center py-12">
        <Icon name="svg-spinners:180-ring" class="w-12 h-12 text-blue-600 mx-auto mb-4" />
        <p class="text-neutral-600">Loading jobs...</p>
      </div>

      <div v-else-if="jobs.length === 0" class="text-center py-12">
        <p class="text-neutral-600">No jobs available at the moment</p>
      </div>

      <div v-else class="space-y-4">
        <UiCard v-for="job in jobs" :key="job.id" hover>
          <div class="flex justify-between items-start">
            <div class="flex-1">
              <div class="flex items-start justify-between mb-2">
                <div>
                  <h3 class="text-lg font-semibold text-neutral-900">{{ job.title }}</h3>
                  <p class="text-sm text-neutral-600">{{ job.company_name }}</p>
                </div>
                <UiBadge v-if="job.remote" variant="blue">Remote</UiBadge>
              </div>

              <p class="text-sm text-neutral-600 mb-3 line-clamp-2">{{ job.description }}</p>

              <div class="flex flex-wrap gap-2 mb-3">
                <div v-if="job.location" class="flex items-center gap-1 text-xs text-neutral-500">
                  <Icon name="mdi:map-marker" class="w-4 h-4" />
                  {{ job.location }}
                </div>
                <div v-if="job.salary_min || job.salary_max" class="flex items-center gap-1 text-xs text-neutral-500">
                  <Icon name="mdi:currency-usd" class="w-4 h-4" />
                  <span v-if="job.salary_min && job.salary_max">
                    ${{ formatSalary(job.salary_min) }} - ${{ formatSalary(job.salary_max) }}
                  </span>
                  <span v-else-if="job.salary_min">
                    From ${{ formatSalary(job.salary_min) }}
                  </span>
                  <span v-else>
                    Up to ${{ formatSalary(job.salary_max) }}
                  </span>
                </div>
              </div>

              <div v-if="job.required_skills.length > 0" class="flex flex-wrap gap-1 mb-3">
                <UiBadge v-for="skill in job.required_skills.slice(0, 5)" :key="skill" size="sm" variant="gray">
                  {{ skill }}
                </UiBadge>
                <UiBadge v-if="job.required_skills.length > 5" size="sm" variant="gray">
                  +{{ job.required_skills.length - 5 }} more
                </UiBadge>
              </div>

              <div class="flex gap-2">
                <UiButton
                  size="sm"
                  :variant="job.is_saved ? 'secondary' : 'outline'"
                  @click="toggleSaveJob(job)"
                >
                  <Icon :name="job.is_saved ? 'mdi:bookmark' : 'mdi:bookmark-outline'" class="w-4 h-4 mr-1" />
                  {{ job.is_saved ? 'Saved' : 'Save' }}
                </UiButton>

                <UiButton
                  size="sm"
                  :variant="job.is_applied ? 'success' : 'primary'"
                  :disabled="job.is_applied"
                  @click="markAsApplied(job)"
                >
                  <Icon :name="job.is_applied ? 'mdi:check' : 'mdi:send'" class="w-4 h-4 mr-1" />
                  {{ job.is_applied ? 'Applied' : 'Mark as Applied' }}
                </UiButton>

                <UiButton
                  v-if="job.url"
                  size="sm"
                  variant="outline"
                  @click="openJobUrl(job.url)"
                >
                  <Icon name="mdi:open-in-new" class="w-4 h-4 mr-1" />
                  View Job
                </UiButton>
              </div>
            </div>
          </div>
        </UiCard>
      </div>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false
})

const { $supabase } = useNuxtApp()

const jobs = ref<any[]>([])
const loading = ref(true)

const fetchJobs = async () => {
  loading.value = true
  try {
    const { data: session } = await $supabase.auth.getSession()
    const token = session.session?.access_token

    const data = await $fetch('/api/student/jobs', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })

    jobs.value = data as any[]
  } catch (e) {
    console.error('Error fetching jobs:', e)
  } finally {
    loading.value = false
  }
}

const toggleSaveJob = async (job: any) => {
  try {
    const { data: session } = await $supabase.auth.getSession()
    const token = session.session?.access_token

    if (!job.is_saved) {
      await $fetch(`/api/student/jobs/${job.id}/save`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`
        }
      })
      job.is_saved = true
    } else {
      await $supabase
        .from('saved_jobs')
        .delete()
        .eq('job_id', job.id)

      job.is_saved = false
    }
  } catch (e) {
    console.error('Error toggling save:', e)
  }
}

const markAsApplied = async (job: any) => {
  try {
    const { data: session } = await $supabase.auth.getSession()
    const token = session.session?.access_token

    await $fetch(`/api/student/jobs/${job.id}/applied`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: {
        notes: ''
      }
    })

    job.is_applied = true
  } catch (e) {
    console.error('Error marking as applied:', e)
  }
}

const openJobUrl = (url: string) => {
  window.open(url, '_blank')
}

const formatSalary = (amount: number) => {
  return new Intl.NumberFormat('en-US').format(amount)
}

onMounted(() => {
  fetchJobs()
})
</script>
