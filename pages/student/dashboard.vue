<template>
  <NuxtLayout name="student">
    <div class="space-y-10">
      <div class="animate-fade-in-up">
        <h1 class="text-4xl font-bold text-neutral-900 mb-3">Good day{{ studentProfile?.first_name ? ', ' + studentProfile.first_name : '' }}!</h1>
        <p class="text-neutral-600 text-lg">Here's your personalized plan for today</p>
      </div>

      <div v-if="!todayCheckin" class="animate-scale-in animate-delay-100">
        <UiCard padding="lg">
          <h2 class="text-2xl font-semibold mb-8 text-center text-neutral-900">How are you feeling today?</h2>
          <div class="flex gap-6 mb-6 justify-center flex-wrap">
            <button
              v-for="mood in moods"
              :key="mood.level"
              type="button"
              :class="[
                'text-6xl p-6 rounded-2xl transition-all duration-500',
                selectedMood === mood.level
                  ? 'bg-blue-50 ring-2 ring-blue-400 scale-110 shadow-lg'
                  : 'hover:bg-neutral-50 hover:scale-105 hover:shadow-md'
              ]"
              @click="selectedMood = mood.level"
            >
              {{ mood.emoji }}
            </button>
          </div>
          <UiInput
            v-model="checkinNote"
            placeholder="How's your day going? (optional)"
            class="mb-6"
          />
          <UiButton
            :disabled="!selectedMood"
            :loading="checkinLoading"
            full-width
            size="lg"
            @click="submitCheckin"
          >
            Submit Check-In
          </UiButton>
        </UiCard>
      </div>

      <div v-if="loadingPlan" class="text-center py-16 animate-fade-in-up">
        <Icon name="svg-spinners:180-ring" class="w-16 h-16 text-blue-600 mx-auto mb-6" />
        <p class="text-neutral-600 text-lg">Creating your daily plan...</p>
      </div>

      <div v-else-if="dailyPlan && planItems.length > 0" class="space-y-6 animate-fade-in-up animate-delay-200">
        <div class="flex items-center justify-between">
          <h2 class="text-3xl font-bold text-neutral-900">Today's Plan</h2>
          <UiBadge :variant="completedCount === planItems.length ? 'green' : 'blue'">
            {{ completedCount }} / {{ planItems.length }} completed
          </UiBadge>
        </div>

        <div class="space-y-4">
          <UiCard
            v-for="(item, index) in planItems"
            :key="item.id"
            hover
            padding="md"
            :class="[
              'transition-all duration-500',
              item.status === 'completed' ? 'opacity-60' : '',
              'animate-scale-in',
              index === 0 ? 'animate-delay-100' : index === 1 ? 'animate-delay-200' : 'animate-delay-300'
            ]"
          >
            <div class="flex items-start gap-4">
              <div class="flex-shrink-0 pt-1">
                <button
                  type="button"
                  :class="[
                    'w-7 h-7 rounded-full border-2 flex items-center justify-center transition-all duration-500',
                    item.status === 'completed'
                      ? 'bg-emerald-500 border-emerald-500'
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
                    <h3 class="font-semibold text-neutral-900 mb-2 text-lg">{{ item.title }}</h3>
                    <p class="text-neutral-600 mb-3 leading-relaxed">{{ item.description }}</p>
                    <UiBadge size="sm" :variant="getItemTypeBadgeVariant(item.item_type)">
                      {{ item.item_type }}
                    </UiBadge>
                  </div>
                </div>
                <p v-if="item.ai_reasoning" class="text-sm text-neutral-500 mt-3 italic leading-relaxed">
                  Why: {{ item.ai_reasoning }}
                </p>
              </div>
            </div>
          </UiCard>
        </div>
      </div>

      <div v-else-if="!loadingPlan && todayCheckin">
        <UiCard class="text-center py-12 animate-scale-in">
          <p class="text-neutral-600 mb-6 text-lg">No plan yet for today. Let's create one!</p>
          <UiButton @click="fetchTodayPlan" size="lg">
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
