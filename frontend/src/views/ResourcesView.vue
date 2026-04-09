<script setup lang="ts">
const resources = [
  { title: 'Your Health After a Heart Attack — CCS Guide', url: 'https://ccs.ca/afterheartattack/', description: 'The official CCS patient guide this app is based on.' },
  { title: 'Heart & Stroke Foundation', url: 'https://www.heartandstroke.ca/', description: 'Canadian resources for heart attack recovery and prevention.' },
  { title: 'Cardiac Rehabilitation Programs', url: 'https://www.heartandstroke.ca/heart/treatments/cardiac-rehabilitation', description: 'Find a cardiac rehab program near you.' }
]
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 py-6">
    <h2 class="text-xl font-bold text-gray-800 mb-2">Resources</h2>
    <p class="text-sm text-gray-500 mb-6">Helpful links for your recovery journey.</p>
    <div class="space-y-4">
      <a
        v-for="r in resources"
        :key="r.url"
        :href="r.url"
        target="_blank"
        rel="noopener noreferrer"
        class="block border border-gray-200 rounded-lg p-4 hover:border-red-300 hover:bg-red-50 transition-colors"
      >
        <h3 class="font-semibold text-red-700 mb-1">{{ r.title }}</h3>
        <p class="text-sm text-gray-600">{{ r.description }}</p>
        <p class="text-xs text-gray-400 mt-1 truncate">{{ r.url }}</p>
      </a>
    </div>
  </div>
</template>
