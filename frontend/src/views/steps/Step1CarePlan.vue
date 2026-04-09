<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useCarePlanStore } from '@/stores/carePlan'
import InfoCard from '@/components/InfoCard.vue'

const store = useCarePlanStore()
const saved = ref(false)

onMounted(() => store.fetch())

const beforeLeaveItems = [
  'You have been diagnosed with a heart attack (myocardial infarction)',
  'Your care team has treated your blocked artery(ies)',
  'You have been given medication(s) to reduce the risk of another heart attack',
  'You will need to take these medications every day for at least 12 months and possibly for the rest of your life',
  'You may need follow-up tests or procedures',
  'You should not drive for at least 2 weeks after your heart attack',
  'You should avoid strenuous activity until cleared by your doctor',
  'You should watch for signs of complications (chest pain, shortness of breath, swelling)',
  'Cardiac rehabilitation is recommended — ask your care team about enrollment'
]

const afterLeaveItems = [
  'See your family doctor within 1–2 weeks of discharge',
  'See your cardiologist within 4–6 weeks and bring your medication list'
]

async function save() {
  await store.save()
  saved.value = true
  setTimeout(() => { saved.value = false }, 2000)
}
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 py-6">
    <h2 class="text-xl font-bold text-gray-800 mb-4">Step 1: Care Plan</h2>
    <InfoCard title="Before You Leave Hospital" :items="beforeLeaveItems" />
    <InfoCard title="After You Leave Hospital" :items="afterLeaveItems" />
    <div class="mt-6 space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">What were you treated with?</label>
        <textarea
          v-model="store.treatmentReceived"
          rows="3"
          class="w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 text-sm"
          placeholder="e.g., PCI (stent), thrombolytics, CABG..."
        />
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Notes</label>
        <textarea
          v-model="store.notes"
          rows="3"
          class="w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 text-sm"
          placeholder="Any additional notes from your care team..."
        />
      </div>
      <button @click="save" class="w-full py-2 px-4 bg-red-600 text-white font-medium rounded-md hover:bg-red-700">
        {{ saved ? '✓ Saved!' : 'Save Care Plan' }}
      </button>
    </div>
  </div>
</template>
