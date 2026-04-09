<script setup lang="ts">
import { ref } from 'vue'

defineProps<{
  title: string
  items: string[]
}>()

const open = ref(true)
</script>

<template>
  <div class="border border-gray-200 rounded-lg mb-4 overflow-hidden">
    <button
      @click="open = !open"
      class="w-full flex justify-between items-center px-4 py-3 bg-red-50 text-left font-medium text-red-800"
    >
      {{ title }}
      <span>{{ open ? '▲' : '▼' }}</span>
    </button>
    <ul v-if="open" class="px-4 py-3 space-y-1 bg-white">
      <li v-for="(item, i) in items" :key="i" class="flex gap-2 text-sm text-gray-700">
        <span class="text-red-500 mt-0.5">•</span>
        <span>{{ item }}</span>
      </li>
    </ul>
  </div>
</template>
