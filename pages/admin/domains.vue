<template>
  <NuxtLayout name="admin">
    <div class="space-y-8">
      <div>
        <h1 class="text-3xl font-bold text-neutral-900 mb-2">Domain Management</h1>
        <p class="text-neutral-600">Manage allowed university and blocked public email domains</p>
      </div>

      <div class="grid md:grid-cols-2 gap-8">
        <UiCard>
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-xl font-semibold">University Domains</h2>
            <UiButton size="sm" @click="showAddUniversity = true">
              <Icon name="mdi:plus" class="w-4 h-4 mr-1" />
              Add
            </UiButton>
          </div>

          <div class="space-y-2">
            <div
              v-for="domain in universityDomains"
              :key="domain.id"
              class="flex justify-between items-center p-3 bg-neutral-50 rounded-lg"
            >
              <div>
                <p class="font-medium text-sm">{{ domain.domain }}</p>
                <p class="text-xs text-neutral-500">{{ domain.university_name }}</p>
              </div>
              <button
                type="button"
                class="text-red-600 hover:text-red-700"
                @click="deleteUniversityDomain(domain.id)"
              >
                <Icon name="mdi:delete" class="w-5 h-5" />
              </button>
            </div>

            <p v-if="universityDomains.length === 0" class="text-center text-neutral-500 py-4">
              No university domains added yet
            </p>
          </div>
        </UiCard>

        <UiCard>
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-xl font-semibold">Blocked Domains</h2>
            <UiButton size="sm" @click="showAddBlocked = true">
              <Icon name="mdi:plus" class="w-4 h-4 mr-1" />
              Add
            </UiButton>
          </div>

          <div class="space-y-2">
            <div
              v-for="domain in blockedDomains"
              :key="domain.id"
              class="flex justify-between items-center p-3 bg-neutral-50 rounded-lg"
            >
              <p class="font-medium text-sm">{{ domain.domain }}</p>
              <button
                type="button"
                class="text-red-600 hover:text-red-700"
                @click="deleteBlockedDomain(domain.id)"
              >
                <Icon name="mdi:delete" class="w-5 h-5" />
              </button>
            </div>

            <p v-if="blockedDomains.length === 0" class="text-center text-neutral-500 py-4">
              No blocked domains added yet
            </p>
          </div>
        </UiCard>
      </div>
    </div>

    <UiModal v-model="showAddUniversity" title="Add University Domain">
      <form @submit.prevent="addUniversityDomain" class="space-y-4">
        <UiInput
          v-model="newUniversity.domain"
          label="Domain"
          placeholder="stanford.edu"
          required
        />

        <UiInput
          v-model="newUniversity.name"
          label="University Name"
          placeholder="Stanford University"
          required
        />
      </form>

      <template #footer>
        <UiButton variant="outline" @click="showAddUniversity = false">
          Cancel
        </UiButton>
        <UiButton :loading="adding" @click="addUniversityDomain">
          Add Domain
        </UiButton>
      </template>
    </UiModal>

    <UiModal v-model="showAddBlocked" title="Add Blocked Domain">
      <form @submit.prevent="addBlockedDomain" class="space-y-4">
        <UiInput
          v-model="newBlocked.domain"
          label="Domain"
          placeholder="gmail.com"
          required
        />
      </form>

      <template #footer>
        <UiButton variant="outline" @click="showAddBlocked = false">
          Cancel
        </UiButton>
        <UiButton :loading="adding" @click="addBlockedDomain">
          Add Domain
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

const universityDomains = ref<any[]>([])
const blockedDomains = ref<any[]>([])
const showAddUniversity = ref(false)
const showAddBlocked = ref(false)
const adding = ref(false)

const newUniversity = reactive({
  domain: '',
  name: ''
})

const newBlocked = reactive({
  domain: ''
})

const fetchDomains = async () => {
  const { data: universities } = await $supabase
    .from('university_domains')
    .select('*')
    .order('university_name')

  universityDomains.value = universities || []

  const { data: blocked } = await $supabase
    .from('blocked_domains')
    .select('*')
    .order('domain')

  blockedDomains.value = blocked || []
}

const addUniversityDomain = async () => {
  adding.value = true
  try {
    await $supabase
      .from('university_domains')
      .insert({
        domain: newUniversity.domain.toLowerCase(),
        university_name: newUniversity.name
      })

    newUniversity.domain = ''
    newUniversity.name = ''
    showAddUniversity.value = false
    await fetchDomains()
  } catch (e) {
    console.error('Error adding domain:', e)
  } finally {
    adding.value = false
  }
}

const addBlockedDomain = async () => {
  adding.value = true
  try {
    await $supabase
      .from('blocked_domains')
      .insert({
        domain: newBlocked.domain.toLowerCase()
      })

    newBlocked.domain = ''
    showAddBlocked.value = false
    await fetchDomains()
  } catch (e) {
    console.error('Error adding domain:', e)
  } finally {
    adding.value = false
  }
}

const deleteUniversityDomain = async (id: string) => {
  if (!confirm('Are you sure you want to delete this domain?')) return

  await $supabase
    .from('university_domains')
    .delete()
    .eq('id', id)

  await fetchDomains()
}

const deleteBlockedDomain = async (id: string) => {
  if (!confirm('Are you sure you want to delete this domain?')) return

  await $supabase
    .from('blocked_domains')
    .delete()
    .eq('id', id)

  await fetchDomains()
}

onMounted(() => {
  fetchDomains()
})
</script>
