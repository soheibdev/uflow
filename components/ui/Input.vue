<template>
  <div class="w-full">
    <label v-if="label" :for="id" class="block text-sm font-medium text-neutral-700 mb-1.5">
      {{ label }}
      <span v-if="required" class="text-red-500">*</span>
    </label>
    <input
      :id="id"
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      :required="required"
      :disabled="disabled"
      :class="inputClasses"
      @input="$emit('update:modelValue', ($event.target as HTMLInputElement).value)"
    />
    <p v-if="error" class="mt-1 text-sm text-red-600">{{ error }}</p>
    <p v-else-if="hint" class="mt-1 text-sm text-neutral-500">{{ hint }}</p>
  </div>
</template>

<script setup lang="ts">
interface Props {
  id?: string
  type?: string
  label?: string
  placeholder?: string
  modelValue?: string | number
  required?: boolean
  disabled?: boolean
  error?: string
  hint?: string
}

const props = withDefaults(defineProps<Props>(), {
  type: 'text',
  required: false,
  disabled: false
})

defineEmits(['update:modelValue'])

const inputClasses = computed(() => {
  const base = 'w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 transition-all disabled:bg-neutral-100 disabled:cursor-not-allowed'
  const errorStyle = props.error
    ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
    : 'border-neutral-300 focus:border-blue-500 focus:ring-blue-500'

  return [base, errorStyle].join(' ')
})
</script>
