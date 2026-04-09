<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import ContactSection from '@/components/ContactSection.vue'
import DataTable from '@/components/DataTable.vue'

interface Contact {
  id: number
  role: string
  name: string
  contact: string
}

const contacts = ref<Contact[]>([])

async function load() {
  const { data } = await api.get('/careteam')
  contacts.value = data
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
    <ContactSection role="Family Doctor" @added="load" />
    <ContactSection role="Cardiologist" @added="load" />
    <ContactSection role="Pharmacist" @added="load" />
    <ContactSection role="Registered Dietician" @added="load" />
    <ContactSection role="Other" @added="load" />
    <div v-if="contacts.length > 0" class="mt-4">
      <h3 class="font-semibold text-gray-700 mb-2">All Contacts</h3>
      <DataTable
        :columns="['Role', 'Name', 'Contact']"
        :keys="['role', 'name', 'contact']"
        :rows="(contacts as Record<string, unknown>[])"
        @delete="remove"
      />
    </div>
  </div>
</template>
