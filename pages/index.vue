<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-neutral-50">
    <nav class="border-b border-neutral-200 bg-white/80 backdrop-blur-sm sticky top-0 z-40">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-blue-600">uflow</h1>
          </div>
          <div class="flex gap-3">
            <UiButton variant="outline" @click="navigateTo('/auth/signin')">
              Sign In
            </UiButton>
            <UiButton @click="navigateTo('/auth/student-signup')">
              Get Started
            </UiButton>
          </div>
        </div>
      </div>
    </nav>

    <section class="py-20 px-4 sm:px-6 lg:px-8">
      <div class="max-w-5xl mx-auto text-center">
        <h2 class="text-5xl sm:text-6xl font-bold text-neutral-900 mb-6">
          Know what to do today
        </h2>
        <p class="text-xl text-neutral-600 mb-10 max-w-2xl mx-auto">
          A simple, ethical platform helping students discover daily opportunities and find relevant jobs, powered by AI recommendations that respect your privacy.
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
          <UiButton size="lg" @click="navigateTo('/auth/student-signup')">
            Student Sign Up
          </UiButton>
          <UiButton size="lg" variant="outline" @click="navigateTo('/auth/company-signup')">
            Company Sign Up
          </UiButton>
        </div>
      </div>
    </section>

    <section class="py-20 px-4 sm:px-6 lg:px-8 bg-white">
      <div class="max-w-6xl mx-auto">
        <h3 class="text-3xl font-bold text-center text-neutral-900 mb-16">
          How it works
        </h3>
        <div class="grid md:grid-cols-4 gap-8">
          <div class="text-center">
            <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Icon name="mdi:emoticon-happy" class="w-8 h-8 text-blue-600" />
            </div>
            <h4 class="text-lg font-semibold mb-2">1. Check In</h4>
            <p class="text-neutral-600">Share how you feel today</p>
          </div>
          <div class="text-center">
            <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Icon name="mdi:robot" class="w-8 h-8 text-green-600" />
            </div>
            <h4 class="text-lg font-semibold mb-2">2. AI Recommends</h4>
            <p class="text-neutral-600">Get personalized daily plans</p>
          </div>
          <div class="text-center">
            <div class="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Icon name="mdi:lightbulb" class="w-8 h-8 text-yellow-600" />
            </div>
            <h4 class="text-lg font-semibold mb-2">3. Discover</h4>
            <p class="text-neutral-600">Explore opportunities & jobs</p>
          </div>
          <div class="text-center">
            <div class="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Icon name="mdi:check-circle" class="w-8 h-8 text-purple-600" />
            </div>
            <h4 class="text-lg font-semibold mb-2">4. Take Action</h4>
            <p class="text-neutral-600">Complete your daily plan</p>
          </div>
        </div>
      </div>
    </section>

    <section class="py-20 px-4 sm:px-6 lg:px-8">
      <div class="max-w-6xl mx-auto">
        <h3 class="text-3xl font-bold text-center text-neutral-900 mb-16">
          Features designed for you
        </h3>
        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          <UiCard>
            <Icon name="mdi:shield-check" class="w-10 h-10 text-blue-600 mb-3" />
            <h4 class="text-lg font-semibold mb-2">Privacy First</h4>
            <p class="text-neutral-600">No public profiles. Your data stays private.</p>
          </UiCard>
          <UiCard>
            <Icon name="mdi:brain" class="w-10 h-10 text-green-600 mb-3" />
            <h4 class="text-lg font-semibold mb-2">Smart AI</h4>
            <p class="text-neutral-600">Recommendations based on your interests and mood.</p>
          </UiCard>
          <UiCard>
            <Icon name="mdi:calendar-today" class="w-10 h-10 text-yellow-600 mb-3" />
            <h4 class="text-lg font-semibold mb-2">Daily Check-In</h4>
            <p class="text-neutral-600">Optional mood tracking for better suggestions.</p>
          </UiCard>
          <UiCard>
            <Icon name="mdi:briefcase" class="w-10 h-10 text-purple-600 mb-3" />
            <h4 class="text-lg font-semibold mb-2">Job Discovery</h4>
            <p class="text-neutral-600">Find relevant jobs matched to your skills.</p>
          </UiCard>
          <UiCard>
            <Icon name="mdi:school" class="w-10 h-10 text-red-600 mb-3" />
            <h4 class="text-lg font-semibold mb-2">Campus Events</h4>
            <p class="text-neutral-600">Stay connected with campus opportunities.</p>
          </UiCard>
          <UiCard>
            <Icon name="mdi:trending-up" class="w-10 h-10 text-blue-600 mb-3" />
            <h4 class="text-lg font-semibold mb-2">Track Progress</h4>
            <p class="text-neutral-600">See your completed tasks and achievements.</p>
          </UiCard>
        </div>
      </div>
    </section>

    <section class="py-20 px-4 sm:px-6 lg:px-8 bg-neutral-900 text-white">
      <div class="max-w-4xl mx-auto text-center">
        <h3 class="text-3xl font-bold mb-6">Privacy & Ethics</h3>
        <div class="space-y-4 text-neutral-300">
          <p class="text-lg">
            <strong class="text-white">No engagement addiction:</strong> We focus on relevance, not endless scrolling.
          </p>
          <p class="text-lg">
            <strong class="text-white">Non-medical:</strong> Mood check-ins are optional and lightweight, not clinical.
          </p>
          <p class="text-lg">
            <strong class="text-white">Your data, your control:</strong> No public profiles, no social feeds.
          </p>
          <p class="text-lg">
            <strong class="text-white">AI that respects you:</strong> Recommendations are helpful, never manipulative.
          </p>
        </div>
      </div>
    </section>

    <footer class="py-12 px-4 sm:px-6 lg:px-8 bg-white border-t border-neutral-200">
      <div class="max-w-7xl mx-auto text-center">
        <div class="flex justify-center gap-8 mb-6">
          <NuxtLink to="/auth/student-signup" class="text-neutral-600 hover:text-neutral-900 transition-colors">
            Student Sign Up
          </NuxtLink>
          <NuxtLink to="/auth/company-signup" class="text-neutral-600 hover:text-neutral-900 transition-colors">
            Company Sign Up
          </NuxtLink>
          <NuxtLink to="/auth/signin" class="text-neutral-600 hover:text-neutral-900 transition-colors">
            Sign In
          </NuxtLink>
        </div>
        <p class="text-neutral-500 text-sm">
          &copy; 2024 uflow. Built with care for students.
        </p>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: []
})
</script>
