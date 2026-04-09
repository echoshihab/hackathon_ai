<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import api from '@/services/api'
import DataTable from '@/components/DataTable.vue'
import FormInput from '@/components/FormInput.vue'

interface Appointment {
  id: number
  appointmentDate: string
  providerName: string
  purpose: string
  notes: string
}

const appointments = ref<Appointment[]>([])
const appointmentDate = ref('')
const providerName = ref('')
const purpose = ref('')
const notes = ref('')

async function load() {
  const { data } = await api.get('/appointments')
  appointments.value = data
}

async function add() {
  if (!appointmentDate.value || !providerName.value.trim()) return
  const { data } = await api.post('/appointments', { appointmentDate: appointmentDate.value, providerName: providerName.value, purpose: purpose.value, notes: notes.value })
  appointments.value.push(data)
  appointmentDate.value = ''
  providerName.value = ''
  purpose.value = ''
  notes.value = ''
}

async function remove(id: number) {
  await api.delete(`/appointments/${id}`)
  appointments.value = appointments.value.filter(a => a.id !== id)
}

const formattedRows = computed(() =>
  appointments.value.map(a => ({ ...a, appointmentDate: new Date(a.appointmentDate).toLocaleDateString() }))
)

onMounted(load)
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 py-6">
    <h2 class="text-xl font-bold text-gray-800 mb-4">Step 3: Appointments</h2>
    <div class="bg-white rounded-lg border border-gray-200 p-4 mb-6">
      <h3 class="font-semibold text-gray-700 mb-3">Add Appointment</h3>
      <div class="mb-4">
        <label class="block text-sm font-medium text-gray-700 mb-1">Date</label>
        <input v-model="appointmentDate" type="date" class="w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 text-sm" />
      </div>
      <FormInput label="Provider Name" v-model="providerName" placeholder="Dr. Smith" />
      <FormInput label="Purpose" v-model="purpose" placeholder="e.g., Cardiology follow-up" />
      <FormInput label="Notes" v-model="notes" placeholder="Any notes..." />
      <button @click="add" class="w-full py-2 px-4 bg-red-600 text-white font-medium rounded-md hover:bg-red-700">
        Add Appointment
      </button>
    </div>
    <DataTable
      :columns="['Date', 'Provider', 'Purpose', 'Notes']"
      :keys="['appointmentDate', 'providerName', 'purpose', 'notes']"
      :rows="(formattedRows as unknown as Record<string, unknown>[])"
      @delete="remove"
    />
  </div>
</template>
