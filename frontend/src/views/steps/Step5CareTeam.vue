<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import FormInput from '@/components/FormInput.vue'

interface Contact {
  id: number
  role: string
  name: string
  contact: string
}

const ROLES = ['Cardiologist', 'Pharmacist', 'Registered Dietician', 'Other']

const contacts = ref<Contact[]>([])
const name = ref('')
const contact = ref('')
const role = ref(ROLES[0])

async function load() {
  const { data } = await api.get('/careteam')
  contacts.value = data
}

async function add() {
  if (!name.value.trim() || !contact.value.trim()) return
  const { data } = await api.post('/careteam', { role: role.value, name: name.value, contact: contact.value })
  contacts.value.push(data)
  name.value = ''
  contact.value = ''
  role.value = ROLES[0]
}

async function remove(id: number) {
  await api.delete(`/careteam/${id}`)
  contacts.value = contacts.value.filter(c => c.id !== id)
}

onMounted(load)
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 py-6">
    <h2 class="text-xl font-bold text-gray-800 mb-4">Step 5: Care Team</h2>

    <!-- Add form -->
    <div class="bg-white rounded-lg border border-gray-200 p-4 mb-6">
      <h3 class="font-semibold text-gray-700 mb-3">Add Contact</h3>

      <div class="mb-4">
        <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
        <select v-model="role" class="w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 text-sm">
          <option v-for="r in ROLES" :key="r" :value="r">{{ r }}</option>
        </select>
      </div>

      <FormInput label="Name" v-model="name" placeholder="e.g., Dr. Smith" />
      <FormInput label="Contact" v-model="contact" placeholder="Phone or email" />

      <button @click="add" class="w-full py-2 px-4 bg-red-600 text-white font-medium rounded-md hover:bg-red-700">
        Add Contact
      </button>
    </div>

    <!-- Cards -->
    <div v-if="contacts.length === 0" class="text-center text-gray-400 text-sm py-6">
      No contacts added yet.
    </div>

    <div v-for="c in contacts" :key="c.id" class="bg-white rounded-lg border border-gray-200 p-4 mb-3">
      <div class="grid grid-cols-2 gap-x-6 gap-y-3 mb-4">
        <div>
          <p class="text-xs font-medium text-gray-500 uppercase tracking-wide">Role</p>
          <p class="text-sm text-gray-800 mt-0.5">{{ c.role }}</p>
        </div>
        <div>
          <p class="text-xs font-medium text-gray-500 uppercase tracking-wide">Name</p>
          <p class="text-sm text-gray-800 mt-0.5">{{ c.name }}</p>
        </div>
        <div class="col-span-2">
          <p class="text-xs font-medium text-gray-500 uppercase tracking-wide">Contact</p>
          <p class="text-sm text-gray-800 mt-0.5">{{ c.contact }}</p>
        </div>
      </div>
      <div class="border-t border-gray-100 pt-3">
        <button
          @click="remove(c.id)"
          class="w-full py-1.5 text-sm font-medium text-red-600 hover:text-red-800 hover:bg-red-50 rounded-md transition-colors"
        >
          Delete
        </button>
      </div>
    </div>
  </div>
</template>
