<script setup lang="ts">
import { ref } from 'vue'
import api from '@/services/api'

const props = defineProps<{
  role: string
}>()

const emit = defineEmits<{
  added: []
}>()

const name = ref('')
const contact = ref('')

async function save() {
  if (!name.value.trim()) return
  await api.post('/careteam', { role: props.role, name: name.value.trim(), contact: contact.value.trim() })
  name.value = ''
  contact.value = ''
  emit('added')
}
</script>

<template>
  <div class="border rounded-lg p-4 mb-4 bg-gray-50">
    <h3 class="font-semibold text-gray-700 mb-3">{{ role }}</h3>
    <div class="grid grid-cols-2 gap-3">
      <div>
        <label class="block text-xs text-gray-500 mb-1">Name</label>
        <input
          v-model="name"
          class="w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 text-sm"
          placeholder="Dr. Smith"
        />
      </div>
      <div>
        <label class="block text-xs text-gray-500 mb-1">Contact</label>
        <input
          v-model="contact"
          class="w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 text-sm"
          placeholder="(555) 123-4567"
        />
      </div>
    </div>
    <button @click="save" class="mt-3 px-4 py-1.5 bg-red-600 text-white rounded-md text-sm hover:bg-red-700">
      Save Contact
    </button>
  </div>
</template>
