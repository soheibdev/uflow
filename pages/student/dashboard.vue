<template>
  <NuxtLayout name="student">
    <div class="space-y-8">
      <div>
        <h1 class="text-3xl font-bold text-neutral-900 mb-2">Good day{{ studentProfile?.first_name ? ', ' + studentProfile.first_name : '' }}!</h1>
        <p class="text-neutral-600">Here's your personalized plan for today</p>
      </div>

      <div v-if="!todayCheckin" class="animate-slide-up">
        <UiCard>
          <h2 class="text-xl font-semibold mb-4">How are you feeling today?</h2>
          <div class="flex gap-4 mb-4 justify-center">
            <button
              v-for="mood in moods"
              :key="mood.level"
              type="button"
              :class="[
                'text-5xl p-4 rounded-xl transition-all',
                selectedMood === mood.level
                  ? 'bg-blue-100 ring-2 ring-blue-500 scale-110'
                  : 'hover:bg-neutral-100 hover:scale-105'
              ]"
              @click="selectedMood = mood.level"
            >
              {{ mood.emoji }}
            </button>
          </div>
          <UiInput
            v-model="checkinNote"
            placeholder="How's your day going? (optional)"
            class="mb-4"
          />
          <UiButton
            :disabled="!selectedMood"
            :loading="checkinLoading"
            full-width
            @click="submitCheckin"
          >
            Submit Check-In
          </UiButton>
        </UiCard>
      </div>

      <div v-if="loadingPlan" class="text-center py-12">
        <Icon name="svg-spinners:180-ring" class="w-12 h-12 text-blue-600 mx-auto mb-4" />
        <p class="text-neutral-600">Creating your daily plan...</p>
      </div>

      <div v-else-if="dailyPlan && planItems.length > 0" class="space-y-4">
        <div class="flex items-center justify-between">
          <h2 class="text-2xl font-bold text-neutral-900">Today's Plan</h2>
          <UiBadge :variant="completedCount === planItems.length ? 'green' : 'blue'">
            {{ completedCount }} / {{ planItems.length }} completed
          </UiBadge>
        </div>

        <div class="space-y-3">
          <UiCard
            v-for="item in planItems"
            :key="item.id"
            padding="md"
            :class="[
              'transition-all',
              item.status === 'completed' ? 'opacity-60' : ''
            ]"
          >
            <div class="flex items-start gap-4">
              <div class="flex-shrink-0 pt-1">
                <button
                  type="button"
                  :class="[
                    'w-6 h-6 rounded-full border-2 flex items-center justify-center transition-all',
                    item.status === 'completed'
                      ? 'bg-green-500 border-green-500'
                      : 'border-neutral-300 hover:border-blue-500'
                  ]"
                  @click="toggleItemStatus(item)"
                >
                  <Icon v-if="item.status === 'completed'" name="mdi:check" class="w-4 h-4 text-white" />
                </button>
              </div>
              <div class="flex-1">
                <div class="flex items-start justify-between gap-4">
                  <div>
                    <h3 class="font-semibold text-neutral-900 mb-1">{{ item.title }}</h3>
                    <p class="text-sm text-neutral-600 mb-2">{{ item.description }}</p>
                    <UiBadge size="sm" :variant="getItemTypeBadgeVariant(item.item_type)">
                      {{ item.item_type }}
                    </UiBadge>
                  </div>
                </div>
                <p v-if="item.ai_reasoning" class="text-xs text-neutral-500 mt-2 italic">
                  Why: {{ item.ai_reasoning }}
                </p>
              </div>
            </div>
          </UiCard>
        </div>
      </div>

      <div v-else-if="!loadingPlan && todayCheckin">
        <UiCard class="text-center py-8">
          <p class="text-neutral-600 mb-4">No plan yet for today. Let's create one!</p>
          <UiButton @click="fetchTodayPlan">
            Generate Daily Plan
          </UiButton>
        </UiCard>
      </div>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import type { StudentProfile, MoodCheckin, DailyPlan, PlanItem } from '~/types/database'

definePageMeta({
  layout: false
})

const { $supabase } = useNuxtApp()
const { user } = useAuth()

const studentProfile = ref<StudentProfile | null>(null)
const todayCheckin = ref<MoodCheckin | null>(null)
const dailyPlan = ref<DailyPlan | null>(null)
const planItems = ref<PlanItem[]>([])

const moods = [
  { level: 1, emoji: '😢' },
  { level: 2, emoji: '😕' },
  { level: 3, emoji: '😐' },
  { level: 4, emoji: '🙂' },
  { level: 5, emoji: '😄' }
]

const selectedMood = ref<number | null>(null)
const checkinNote = ref('')
const checkinLoading = ref(false)
const loadingPlan = ref(false)

const completedCount = computed(() => {
  return planItems.value.filter(item => item.status === 'completed').length
})

const fetchStudentProfile = async () => {
  const { data } = await $supabase
    .from('student_profiles')
    .select('*')
    .eq('id', user.value.id)
    .maybeSingle()

  studentProfile.value = data
}

const fetchTodayCheckin = async () => {
  const today = new Date().toISOString().split('T')[0]
  const { data } = await $supabase
    .from('mood_checkins')
    .select('*')
    .eq('student_id', user.value.id)
    .eq('checkin_date', today)
    .maybeSingle()

  todayCheckin.value = data
}

const fetchTodayPlan = async () => {
  loadingPlan.value = true
  try {
    const { data: session } = await $supabase.auth.getSession()
    const token = session.session?.access_token

    const response = await $fetch('/api/student/today', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    }) as any

    dailyPlan.value = response
    planItems.value = response.plan_items || []
  } catch (e) {
    console.error('Error fetching plan:', e)
  } finally {
    loadingPlan.value = false
  }
}

const submitCheckin = async () => {
  if (!selectedMood.value) return

  checkinLoading.value = true
  try {
    const { data: session } = await $supabase.auth.getSession()
    const token = session.session?.access_token

    const moodEmoji = moods.find(m => m.level === selectedMood.value)?.emoji || '😐'

    await $fetch('/api/student/checkin', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: {
        mood_level: selectedMood.value,
        mood_emoji: moodEmoji,
        note: checkinNote.value
      }
    })

    await fetchTodayCheckin()
    await fetchTodayPlan()
  } catch (e) {
    console.error('Error submitting checkin:', e)
  } finally {
    checkinLoading.value = false
  }
}

const toggleItemStatus = async (item: PlanItem) => {
  const newStatus = item.status === 'completed' ? 'pending' : 'completed'

  const { data: session } = await $supabase.auth.getSession()
  const token = session.session?.access_token

  try {
    await $fetch(`/api/student/plan-items/${item.id}`, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: {
        status: newStatus
      }
    })

    item.status = newStatus
  } catch (e) {
    console.error('Error updating item:', e)
  }
}

const getItemTypeBadgeVariant = (type: string) => {
  const variants: Record<string, any> = {
    event: 'blue',
    opportunity: 'green',
    job: 'yellow',
    self_care: 'gray'
  }
  return variants[type] || 'gray'
}

onMounted(async () => {
  await fetchStudentProfile()
  await fetchTodayCheckin()
  if (todayCheckin.value) {
    await fetchTodayPlan()
  }
})
</script>
