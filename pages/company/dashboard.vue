<template>
  <NuxtLayout name="company">
    <div class="space-y-8">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-3xl font-bold text-neutral-900 mb-2">Company Dashboard</h1>
          <p class="text-neutral-600">Manage your opportunities and connect with students</p>
        </div>
        <UiButton @click="showCreateModal = true">
          <Icon name="mdi:plus" class="w-5 h-5 mr-2" />
          Post Opportunity
        </UiButton>
      </div>

      <div v-if="loading" class="text-center py-12">
        <Icon name="svg-spinners:180-ring" class="w-12 h-12 text-blue-600 mx-auto mb-4" />
        <p class="text-neutral-600">Loading opportunities...</p>
      </div>

      <div v-else-if="opportunities.length === 0" class="text-center py-12">
        <UiCard>
          <p class="text-neutral-600 mb-4">No opportunities posted yet</p>
          <UiButton @click="showCreateModal = true">
            Post Your First Opportunity
          </UiButton>
        </UiCard>
      </div>

      <div v-else class="space-y-4">
        <UiCard v-for="opp in opportunities" :key="opp.id">
          <div class="flex justify-between items-start">
            <div class="flex-1">
              <div class="flex items-start justify-between mb-2">
                <h3 class="text-lg font-semibold text-neutral-900">{{ opp.title }}</h3>
                <UiBadge :variant="getStatusBadgeVariant(opp.status)">
                  {{ opp.status }}
                </UiBadge>
              </div>

              <p class="text-sm text-neutral-600 mb-3">{{ opp.description }}</p>

              <div class="flex gap-3 text-sm text-neutral-500">
                <span>{{ opp.category }}</span>
                <span>•</span>
                <span>{{ opp.expertise_level }}</span>
                <span v-if="opp.deadline">
                  <span>•</span>
                  <span>Deadline: {{ formatDate(opp.deadline) }}</span>
                </span>
              </div>

              <div v-if="opp.admin_notes" class="mt-3 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
                <p class="text-sm text-yellow-800"><strong>Admin Notes:</strong> {{ opp.admin_notes }}</p>
              </div>
            </div>
          </div>
        </UiCard>
      </div>
    </div>

    <UiModal v-model="showCreateModal" title="Post New Opportunity">
      <form @submit.prevent="createOpportunity" class="space-y-4">
        <UiInput
          v-model="newOpp.title"
          label="Title"
          placeholder="Summer Internship Program"
          required
        />

        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1.5">Description</label>
          <textarea
            v-model="newOpp.description"
            rows="4"
            class="w-full px-4 py-2 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Describe the opportunity..."
            required
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1.5">Category</label>
          <select
            v-model="newOpp.category"
            class="w-full px-4 py-2 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          >
            <option value="event">Event</option>
            <option value="project">Project</option>
            <option value="internship">Internship</option>
            <option value="job">Job</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1.5">Expertise Level</label>
          <select
            v-model="newOpp.expertise_level"
            class="w-full px-4 py-2 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          >
            <option value="beginner">Beginner</option>
            <option value="intermediate">Intermediate</option>
            <option value="expert">Expert</option>
          </select>
        </div>

        <UiInput
          v-model="newOpp.skills"
          label="Required Skills (comma-separated)"
          placeholder="JavaScript, React, Node.js"
        />

        <UiInput
          v-model="newOpp.deadline"
          type="date"
          label="Application Deadline"
        />

        <div v-if="createError" class="p-3 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-sm text-red-600">{{ createError }}</p>
        </div>
      </form>

      <template #footer>
        <UiButton variant="outline" @click="showCreateModal = false">
          Cancel
        </UiButton>
        <UiButton :loading="creating" @click="createOpportunity">
          Post Opportunity
        </UiButton>
      </template>
    </UiModal>
  </NuxtLayout>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false
})

const { $supabase } = useNuxtApp()
const { user } = useAuth()

const opportunities = ref<any[]>([])
const loading = ref(true)
const showCreateModal = ref(false)
const creating = ref(false)
const createError = ref('')

const newOpp = reactive({
  title: '',
  description: '',
  category: 'project',
  expertise_level: 'beginner',
  skills: '',
  deadline: ''
})

const fetchOpportunities = async () => {
  loading.value = true
  try {
    const { data } = await $supabase
      .from('opportunities')
      .select('*')
      .eq('company_id', user.value.id)
      .order('created_at', { ascending: false })

    opportunities.value = data || []
  } catch (e) {
    console.error('Error fetching opportunities:', e)
  } finally {
    loading.value = false
  }
}

const createOpportunity = async () => {
  createError.value = ''
  creating.value = true

  try {
    const { data: session } = await $supabase.auth.getSession()
    const token = session.session?.access_token

    const skills = newOpp.skills
      ? newOpp.skills.split(',').map(s => s.trim()).filter(Boolean)
      : []

    await $fetch('/api/company/opportunities', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: {
        title: newOpp.title,
        description: newOpp.description,
        category: newOpp.category,
        expertise_level: newOpp.expertise_level,
        required_skills: skills,
        deadline: newOpp.deadline || null
      }
    })

    showCreateModal.value = false
    newOpp.title = ''
    newOpp.description = ''
    newOpp.category = 'project'
    newOpp.expertise_level = 'beginner'
    newOpp.skills = ''
    newOpp.deadline = ''

    await fetchOpportunities()
  } catch (e: any) {
    createError.value = e.data?.message || 'Failed to create opportunity'
  } finally {
    creating.value = false
  }
}

const getStatusBadgeVariant = (status: string) => {
  const variants: Record<string, any> = {
    pending_review: 'yellow',
    approved: 'green',
    rejected: 'red'
  }
  return variants[status] || 'gray'
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

onMounted(() => {
  fetchOpportunities()
})
</script>
