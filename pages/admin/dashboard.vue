<template>
  <NuxtLayout name="admin">
    <div class="space-y-8">
      <div>
        <h1 class="text-3xl font-bold text-neutral-900 mb-2">Content Review Queue</h1>
        <p class="text-neutral-600">Review and approve opportunities posted by companies</p>
      </div>

      <div class="flex gap-3">
        <UiButton
          :variant="filter === 'pending_review' ? 'primary' : 'outline'"
          @click="filter = 'pending_review'; fetchOpportunities()"
        >
          Pending ({{ pendingCount }})
        </UiButton>
        <UiButton
          :variant="filter === 'approved' ? 'primary' : 'outline'"
          @click="filter = 'approved'; fetchOpportunities()"
        >
          Approved
        </UiButton>
        <UiButton
          :variant="filter === 'rejected' ? 'primary' : 'outline'"
          @click="filter = 'rejected'; fetchOpportunities()"
        >
          Rejected
        </UiButton>
      </div>

      <div v-if="loading" class="text-center py-12">
        <Icon name="svg-spinners:180-ring" class="w-12 h-12 text-blue-600 mx-auto mb-4" />
        <p class="text-neutral-600">Loading opportunities...</p>
      </div>

      <div v-else-if="opportunities.length === 0" class="text-center py-12">
        <UiCard>
          <p class="text-neutral-600">No opportunities in this category</p>
        </UiCard>
      </div>

      <div v-else class="space-y-4">
        <UiCard v-for="opp in opportunities" :key="opp.id">
          <div class="space-y-4">
            <div class="flex justify-between items-start">
              <div class="flex-1">
                <div class="flex items-center gap-2 mb-2">
                  <h3 class="text-lg font-semibold text-neutral-900">{{ opp.title }}</h3>
                  <UiBadge :variant="getStatusBadgeVariant(opp.status)">
                    {{ opp.status }}
                  </UiBadge>
                </div>

                <p class="text-sm text-neutral-600 mb-3">{{ opp.description }}</p>

                <div class="flex gap-4 text-sm text-neutral-500 mb-3">
                  <span>{{ opp.category }}</span>
                  <span>•</span>
                  <span>{{ opp.expertise_level }}</span>
                  <span v-if="opp.deadline">
                    <span>•</span>
                    <span>Deadline: {{ formatDate(opp.deadline) }}</span>
                  </span>
                </div>

                <div v-if="opp.company_profiles" class="text-sm text-neutral-600">
                  <strong>Company:</strong> {{ opp.company_profiles.company_name }}
                </div>

                <div v-if="opp.required_skills.length > 0" class="mt-2">
                  <div class="flex flex-wrap gap-1">
                    <UiBadge v-for="skill in opp.required_skills" :key="skill" size="sm" variant="gray">
                      {{ skill }}
                    </UiBadge>
                  </div>
                </div>
              </div>
            </div>

            <div v-if="opp.status === 'pending_review'" class="flex gap-3 pt-4 border-t border-neutral-200">
              <UiButton
                variant="success"
                @click="reviewOpportunity(opp.id, 'approved', '')"
              >
                <Icon name="mdi:check" class="w-4 h-4 mr-1" />
                Approve
              </UiButton>
              <UiButton
                variant="danger"
                @click="showRejectModal(opp)"
              >
                <Icon name="mdi:close" class="w-4 h-4 mr-1" />
                Reject
              </UiButton>
            </div>

            <div v-if="opp.admin_notes" class="p-3 bg-neutral-100 rounded-lg">
              <p class="text-sm text-neutral-700"><strong>Admin Notes:</strong> {{ opp.admin_notes }}</p>
            </div>
          </div>
        </UiCard>
      </div>
    </div>

    <UiModal v-model="showReject" title="Reject Opportunity">
      <div class="space-y-4">
        <p class="text-neutral-600">Please provide a reason for rejecting this opportunity:</p>
        <textarea
          v-model="rejectNotes"
          rows="4"
          class="w-full px-4 py-2 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          placeholder="Reason for rejection..."
        />
      </div>

      <template #footer>
        <UiButton variant="outline" @click="showReject = false">
          Cancel
        </UiButton>
        <UiButton
          variant="danger"
          :loading="reviewing"
          @click="confirmReject"
        >
          Reject
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

const opportunities = ref<any[]>([])
const loading = ref(true)
const filter = ref('pending_review')
const pendingCount = ref(0)
const showReject = ref(false)
const rejectNotes = ref('')
const selectedOppId = ref('')
const reviewing = ref(false)

const fetchOpportunities = async () => {
  loading.value = true
  try {
    const { data: session } = await $supabase.auth.getSession()
    const token = session.session?.access_token

    const data = await $fetch('/api/admin/opportunities', {
      headers: {
        Authorization: `Bearer ${token}`
      },
      query: {
        status: filter.value
      }
    })

    opportunities.value = data as any[]
  } catch (e) {
    console.error('Error fetching opportunities:', e)
  } finally {
    loading.value = false
  }
}

const fetchPendingCount = async () => {
  try {
    const { data: session } = await $supabase.auth.getSession()
    const token = session.session?.access_token

    const data = await $fetch('/api/admin/opportunities', {
      headers: {
        Authorization: `Bearer ${token}`
      },
      query: {
        status: 'pending_review'
      }
    }) as any[]

    pendingCount.value = data.length
  } catch (e) {
    console.error('Error fetching pending count:', e)
  }
}

const reviewOpportunity = async (oppId: string, status: string, notes: string) => {
  reviewing.value = true
  try {
    const { data: session } = await $supabase.auth.getSession()
    const token = session.session?.access_token

    await $fetch(`/api/admin/opportunities/${oppId}/review`, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: {
        status,
        admin_notes: notes
      }
    })

    await fetchOpportunities()
    await fetchPendingCount()
  } catch (e) {
    console.error('Error reviewing opportunity:', e)
  } finally {
    reviewing.value = false
  }
}

const showRejectModal = (opp: any) => {
  selectedOppId.value = opp.id
  rejectNotes.value = ''
  showReject.value = true
}

const confirmReject = async () => {
  await reviewOpportunity(selectedOppId.value, 'rejected', rejectNotes.value)
  showReject.value = false
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

onMounted(async () => {
  await fetchOpportunities()
  await fetchPendingCount()
})
</script>
