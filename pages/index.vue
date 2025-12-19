<template>
  <div class="min-h-screen">
    <nav class="border-b border-neutral-200/50 bg-white/60 backdrop-blur-md sticky top-0 z-40 animate-fade-in-up">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold bg-gradient-to-r from-blue-600 to-blue-500 bg-clip-text text-transparent">uflow</h1>
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

    <section class="py-32 px-4 sm:px-6 lg:px-8">
      <div class="max-w-5xl mx-auto text-center">
        <h2 class="text-5xl sm:text-7xl font-bold text-neutral-900 mb-8 animate-fade-in-up leading-tight">
          Know what to do today
        </h2>
        <p class="text-xl sm:text-2xl text-neutral-600 mb-12 max-w-3xl mx-auto leading-relaxed animate-fade-in-up animate-delay-100">
          A simple, ethical platform helping students discover daily opportunities and find relevant jobs, powered by AI recommendations that respect your privacy.
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center animate-fade-in-up animate-delay-200">
          <UiButton size="lg" @click="navigateTo('/auth/student-signup')">
            Student Sign Up
          </UiButton>
          <UiButton size="lg" variant="outline" @click="navigateTo('/auth/company-signup')">
            Company Sign Up
          </UiButton>
        </div>
      </div>
    </section>

    <section class="py-24 px-4 sm:px-6 lg:px-8">
      <div class="max-w-6xl mx-auto">
        <h3 class="text-4xl font-bold text-center text-neutral-900 mb-20">
          How it works
        </h3>
        <div class="grid md:grid-cols-4 gap-12">
          <div class="text-center animate-scale-in">
            <div class="w-20 h-20 bg-gradient-to-br from-blue-100 to-blue-50 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-sm">
              <Icon name="mdi:emoticon-happy" class="w-10 h-10 text-blue-600" />
            </div>
            <h4 class="text-xl font-semibold mb-3 text-neutral-900">1. Check In</h4>
            <p class="text-neutral-600 leading-relaxed">Share how you feel today</p>
          </div>
          <div class="text-center animate-scale-in animate-delay-100">
            <div class="w-20 h-20 bg-gradient-to-br from-emerald-100 to-emerald-50 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-sm">
              <Icon name="mdi:robot" class="w-10 h-10 text-emerald-600" />
            </div>
            <h4 class="text-xl font-semibold mb-3 text-neutral-900">2. AI Recommends</h4>
            <p class="text-neutral-600 leading-relaxed">Get personalized daily plans</p>
          </div>
          <div class="text-center animate-scale-in animate-delay-200">
            <div class="w-20 h-20 bg-gradient-to-br from-amber-100 to-amber-50 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-sm">
              <Icon name="mdi:lightbulb" class="w-10 h-10 text-amber-600" />
            </div>
            <h4 class="text-xl font-semibold mb-3 text-neutral-900">3. Discover</h4>
            <p class="text-neutral-600 leading-relaxed">Explore opportunities & jobs</p>
          </div>
          <div class="text-center animate-scale-in animate-delay-300">
            <div class="w-20 h-20 bg-gradient-to-br from-blue-100 to-blue-50 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-sm">
              <Icon name="mdi:check-circle" class="w-10 h-10 text-blue-600" />
            </div>
            <h4 class="text-xl font-semibold mb-3 text-neutral-900">4. Take Action</h4>
            <p class="text-neutral-600 leading-relaxed">Complete your daily plan</p>
          </div>
        </div>
      </div>
    </section>

    <section class="py-24 px-4 sm:px-6 lg:px-8">
      <div class="max-w-6xl mx-auto">
        <h3 class="text-4xl font-bold text-center text-neutral-900 mb-20">
          Features designed for you
        </h3>
        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          <UiCard hover class="animate-scale-in">
            <Icon name="mdi:shield-check" class="w-12 h-12 text-blue-600 mb-4" />
            <h4 class="text-xl font-semibold mb-3 text-neutral-900">Privacy First</h4>
            <p class="text-neutral-600 leading-relaxed">No public profiles. Your data stays private.</p>
          </UiCard>
          <UiCard hover class="animate-scale-in animate-delay-100">
            <Icon name="mdi:brain" class="w-12 h-12 text-emerald-600 mb-4" />
            <h4 class="text-xl font-semibold mb-3 text-neutral-900">Smart AI</h4>
            <p class="text-neutral-600 leading-relaxed">Recommendations based on your interests and mood.</p>
          </UiCard>
          <UiCard hover class="animate-scale-in animate-delay-200">
            <Icon name="mdi:calendar-today" class="w-12 h-12 text-amber-600 mb-4" />
            <h4 class="text-xl font-semibold mb-3 text-neutral-900">Daily Check-In</h4>
            <p class="text-neutral-600 leading-relaxed">Optional mood tracking for better suggestions.</p>
          </UiCard>
          <UiCard hover class="animate-scale-in animate-delay-300">
            <Icon name="mdi:briefcase" class="w-12 h-12 text-blue-600 mb-4" />
            <h4 class="text-xl font-semibold mb-3 text-neutral-900">Job Discovery</h4>
            <p class="text-neutral-600 leading-relaxed">Find relevant jobs matched to your skills.</p>
          </UiCard>
          <UiCard hover class="animate-scale-in animate-delay-400">
            <Icon name="mdi:school" class="w-12 h-12 text-rose-600 mb-4" />
            <h4 class="text-xl font-semibold mb-3 text-neutral-900">Campus Events</h4>
            <p class="text-neutral-600 leading-relaxed">Stay connected with campus opportunities.</p>
          </UiCard>
          <UiCard hover class="animate-scale-in">
            <Icon name="mdi:trending-up" class="w-12 h-12 text-emerald-600 mb-4" />
            <h4 class="text-xl font-semibold mb-3 text-neutral-900">Track Progress</h4>
            <p class="text-neutral-600 leading-relaxed">See your completed tasks and achievements.</p>
          </UiCard>
        </div>
      </div>
    </section>

    <section class="py-24 px-4 sm:px-6 lg:px-8 bg-gradient-to-br from-neutral-900 to-neutral-800 text-white">
      <div class="max-w-4xl mx-auto text-center">
        <h3 class="text-4xl font-bold mb-12">Privacy & Ethics</h3>
        <div class="space-y-6 text-neutral-300">
          <p class="text-lg leading-relaxed">
            <strong class="text-white font-semibold">No engagement addiction:</strong> We focus on relevance, not endless scrolling.
          </p>
          <p class="text-lg leading-relaxed">
            <strong class="text-white font-semibold">Non-medical:</strong> Mood check-ins are optional and lightweight, not clinical.
          </p>
          <p class="text-lg leading-relaxed">
            <strong class="text-white font-semibold">Your data, your control:</strong> No public profiles, no social feeds.
          </p>
          <p class="text-lg leading-relaxed">
            <strong class="text-white font-semibold">AI that respects you:</strong> Recommendations are helpful, never manipulative.
          </p>
        </div>
      </div>
    </section>

    <footer class="py-16 px-4 sm:px-6 lg:px-8 border-t border-neutral-200/50 bg-white/40 backdrop-blur-sm">
      <div class="max-w-7xl mx-auto text-center">
        <div class="flex justify-center gap-10 mb-8">
          <NuxtLink to="/auth/student-signup" class="text-neutral-600 hover:text-neutral-900 transition-all duration-300">
            Student Sign Up
          </NuxtLink>
          <NuxtLink to="/auth/company-signup" class="text-neutral-600 hover:text-neutral-900 transition-all duration-300">
            Company Sign Up
          </NuxtLink>
          <NuxtLink to="/auth/signin" class="text-neutral-600 hover:text-neutral-900 transition-all duration-300">
            Sign In
          </NuxtLink>
        </div>
        <p class="text-neutral-500">
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
