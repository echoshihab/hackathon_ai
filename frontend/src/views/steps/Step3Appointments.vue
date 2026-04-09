<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import api from '@/services/api'
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

const formattedAppointments = computed(() =>
  appointments.value.map(a => ({ ...a, appointmentDate: new Date(a.appointmentDate).toLocaleDateString() }))
)

onMounted(load)
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 py-6">
    <h2 class="text-xl font-bold text-gray-800 mb-4">Step 3: Appointments</h2>

    <!-- Add form -->
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

    <!-- Cards -->
    <div v-if="formattedAppointments.length === 0" class="text-center text-gray-400 text-sm py-6">
      No appointments yet.
    </div>

    <div v-for="appt in formattedAppointments" :key="appt.id" class="bg-white rounded-lg border border-gray-200 p-4 mb-3">
      <div class="grid grid-cols-2 gap-x-6 gap-y-3 mb-4">
        <div>
          <p class="text-xs font-medium text-gray-500 uppercase tracking-wide">Date</p>
          <p class="text-sm text-gray-800 mt-0.5">{{ appt.appointmentDate }}</p>
        </div>
        <div>
          <p class="text-xs font-medium text-gray-500 uppercase tracking-wide">Provider</p>
          <p class="text-sm text-gray-800 mt-0.5">{{ appt.providerName }}</p>
        </div>
        <div>
          <p class="text-xs font-medium text-gray-500 uppercase tracking-wide">Purpose</p>
          <p class="text-sm text-gray-800 mt-0.5">{{ appt.purpose || '—' }}</p>
        </div>
        <div>
          <p class="text-xs font-medium text-gray-500 uppercase tracking-wide">Notes</p>
          <p class="text-sm text-gray-800 mt-0.5">{{ appt.notes || '—' }}</p>
        </div>
      </div>
      <div class="border-t border-gray-100 pt-3">
        <button
          @click="remove(appt.id)"
          class="w-full py-1.5 text-sm font-medium text-red-600 hover:text-red-800 hover:bg-red-50 rounded-md transition-colors"
        >
          Delete
        </button>
      </div>
    </div>
  </div>
</template>
