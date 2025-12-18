<template>
  <NuxtLayout name="student">
    <div class="space-y-6">
      <div>
        <h1 class="text-3xl font-bold text-neutral-900 mb-2">Opportunities</h1>
        <p class="text-neutral-600">Discover campus events and company opportunities</p>
      </div>

      <div v-if="loading" class="text-center py-12">
        <Icon name="svg-spinners:180-ring" class="w-12 h-12 text-blue-600 mx-auto mb-4" />
        <p class="text-neutral-600">Loading opportunities...</p>
      </div>

      <div v-else-if="opportunities.length === 0" class="text-center py-12">
        <p class="text-neutral-600">No opportunities available at the moment</p>
      </div>

      <div v-else class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        <UiCard v-for="opp in opportunities" :key="opp.id" hover>
          <div class="flex justify-between items-start mb-3">
            <UiBadge :variant="opp.type === 'campus' ? 'blue' : 'green'">
              {{ opp.type }}
            </UiBadge>
            <UiBadge variant="yellow">
              {{ opp.category }}
            </UiBadge>
          </div>

          <h3 class="text-lg font-semibold text-neutral-900 mb-2">{{ opp.title }}</h3>
          <p class="text-sm text-neutral-600 mb-4 line-clamp-3">{{ opp.description }}</p>

          <div v-if="opp.required_skills.length > 0" class="mb-4">
            <p class="text-xs font-medium text-neutral-700 mb-2">Skills:</p>
            <div class="flex flex-wrap gap-1">
              <UiBadge v-for="skill in opp.required_skills.slice(0, 3)" :key="skill" size="sm" variant="gray">
                {{ skill }}
              </UiBadge>
              <UiBadge v-if="opp.required_skills.length > 3" size="sm" variant="gray">
                +{{ opp.required_skills.length - 3 }} more
              </UiBadge>
            </div>
          </div>

          <div class="flex items-center justify-between text-sm">
            <span class="text-neutral-500">{{ opp.expertise_level }}</span>
            <UiButton size="sm" @click="viewOpportunity(opp)">
              View Details
            </UiButton>
          </div>
        </UiCard>
      </div>
    </div>

    <UiModal v-model="showModal" :title="selectedOpp?.title">
      <div v-if="selectedOpp" class="space-y-4">
        <div>
          <h4 class="font-medium text-neutral-900 mb-2">Description</h4>
          <p class="text-neutral-600">{{ selectedOpp.description }}</p>
        </div>

        <div v-if="selectedOpp.required_skills.length > 0">
          <h4 class="font-medium text-neutral-900 mb-2">Required Skills</h4>
          <div class="flex flex-wrap gap-2">
            <UiBadge v-for="skill in selectedOpp.required_skills" :key="skill" variant="blue">
              {{ skill }}
            </UiBadge>
          </div>
        </div>

        <div>
          <h4 class="font-medium text-neutral-900 mb-2">Expertise Level</h4>
          <UiBadge :variant="getLevelBadgeVariant(selectedOpp.expertise_level)">
            {{ selectedOpp.expertise_level }}
          </UiBadge>
        </div>

        <div v-if="selectedOpp.deadline">
          <h4 class="font-medium text-neutral-900 mb-2">Deadline</h4>
          <p class="text-neutral-600">{{ formatDate(selectedOpp.deadline) }}</p>
        </div>

        <div v-if="selectedOpp.company_profiles">
          <h4 class="font-medium text-neutral-900 mb-2">Company</h4>
          <p class="text-neutral-600">{{ selectedOpp.company_profiles.company_name }}</p>
        </div>
      </div>

      <template #footer>
        <UiButton variant="outline" @click="showModal = false">
          Close
        </UiButton>
        <UiButton @click="applyToOpportunity">
          Apply
        </UiButton>
      </template>
    </UiModal>
  </NuxtLayout>
</template>

<script setup lang="ts">
import type { Opportunity } from '~/types/database'

definePageMeta({
  layout: false
})

const { $supabase } = useNuxtApp()

const opportunities = ref<any[]>([])
const loading = ref(true)
const showModal = ref(false)
const selectedOpp = ref<any>(null)

const fetchOpportunities = async () => {
  loading.value = true
  try {
    const { data: session } = await $supabase.auth.getSession()
    const token = session.session?.access_token

    const data = await $fetch('/api/student/opportunities', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })

    opportunities.value = data as any[]
  } catch (e) {
    console.error('Error fetching opportunities:', e)
  } finally {
    loading.value = false
  }
}

const viewOpportunity = (opp: any) => {
  selectedOpp.value = opp
  showModal.value = true
}

const applyToOpportunity = () => {
  alert('Application feature coming soon!')
  showModal.value = false
}

const getLevelBadgeVariant = (level: string) => {
  const variants: Record<string, any> = {
    beginner: 'green',
    intermediate: 'yellow',
    expert: 'red'
  }
  return variants[level] || 'gray'
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

onMounted(() => {
  fetchOpportunities()
})
</script>
