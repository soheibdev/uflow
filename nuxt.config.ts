export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: false },

  modules: ['@nuxtjs/tailwindcss', '@nuxt/icon'],

  runtimeConfig: {
    supabaseServiceKey: process.env.SUPABASE_SERVICE_ROLE_KEY,
    aiServiceUrl: process.env.AI_SERVICE_URL || '',
    aiServiceApiKey: process.env.AI_SERVICE_API_KEY || '',
    ingestSecret: process.env.INGEST_SECRET || 'default-secret-change-in-production',
    public: {
      supabaseUrl: process.env.VITE_SUPABASE_URL,
      supabaseAnonKey: process.env.VITE_SUPABASE_ANON_KEY,
    }
  },

  app: {
    head: {
      title: 'uflow - Know what to do today',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'A simple, ethical platform helping students discover what to do today and find relevant opportunities.' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
      ]
    }
  },

  css: ['~/assets/css/main.css'],

  typescript: {
    strict: true,
    typeCheck: false
  }
})
