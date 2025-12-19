<template>
  <div :class="cardClasses">
    <div v-if="$slots.header" class="border-b border-neutral-200 pb-4 mb-4">
      <slot name="header" />
    </div>
    <slot />
    <div v-if="$slots.footer" class="border-t border-neutral-200 pt-4 mt-4">
      <slot name="footer" />
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  padding?: 'none' | 'sm' | 'md' | 'lg'
  hover?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  padding: 'md',
  hover: false
})

const cardClasses = computed(() => {
  const base = 'bg-white/80 backdrop-blur-sm rounded-2xl shadow-sm border border-neutral-200/50 transition-all duration-500'

  const paddings = {
    none: '',
    sm: 'p-4',
    md: 'p-6',
    lg: 'p-8'
  }

  const hoverEffect = props.hover ? 'hover:shadow-md hover:-translate-y-1' : ''

  return [base, paddings[props.padding], hoverEffect].join(' ')
})
</script>
