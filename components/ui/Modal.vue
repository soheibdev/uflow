<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="modelValue" class="fixed inset-0 z-50 overflow-y-auto">
        <div class="flex min-h-screen items-center justify-center p-4">
          <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity" @click="close" />
          <div class="relative bg-white rounded-xl shadow-xl max-w-lg w-full p-6 animate-slide-up">
            <div class="flex items-center justify-between mb-4">
              <h3 v-if="title" class="text-xl font-semibold text-neutral-900">{{ title }}</h3>
              <button
                type="button"
                class="text-neutral-400 hover:text-neutral-600 transition-colors"
                @click="close"
              >
                <Icon name="mdi:close" class="w-6 h-6" />
              </button>
            </div>
            <div>
              <slot />
            </div>
            <div v-if="$slots.footer" class="mt-6 flex justify-end gap-3">
              <slot name="footer" />
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
interface Props {
  modelValue: boolean
  title?: string
}

defineProps<Props>()

const emit = defineEmits(['update:modelValue'])

const close = () => {
  emit('update:modelValue', false)
}
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
</style>
