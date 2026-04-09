<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'

const props = defineProps<{
  category: string
  title: string
}>()

interface Goal {
  id: number
  text: string
  isCompleted: boolean
  category: string
}

const goals = ref<Goal[]>([])
const newText = ref('')

const filtered = computed(() => goals.value.filter(g => g.category === props.category))

async function fetchGoals() {
  const { data } = await api.get('/lifestyle')
  goals.value = data
}

async function addGoal() {
  if (!newText.value.trim()) return
  const { data } = await api.post('/lifestyle', { category: props.category, text: newText.value.trim() })
  goals.value.push(data)
  newText.value = ''
}

async function toggleGoal(id: number) {
  const { data } = await api.patch(`/lifestyle/${id}/toggle`)
  const idx = goals.value.findIndex(g => g.id === id)
  if (idx !== -1) goals.value[idx] = data
}

onMounted(fetchGoals)
</script>

<template>
  <div class="mb-6">
    <h3 class="font-semibold text-gray-800 mb-2">{{ title }}</h3>
    <ul class="space-y-1 mb-3">
      <li v-for="goal in filtered" :key="goal.id" class="flex items-center gap-2">
        <input
          type="checkbox"
          :checked="goal.isCompleted"
          @change="toggleGoal(goal.id)"
          class="rounded border-gray-300 text-red-500 focus:ring-red-500"
        />
        <span :class="goal.isCompleted ? 'line-through text-gray-400' : 'text-gray-700'" class="text-sm">
          {{ goal.text }}
        </span>
      </li>
    </ul>
    <div class="flex gap-2">
      <input
        v-model="newText"
        @keyup.enter="addGoal"
        placeholder="Add a goal..."
        class="flex-1 rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 text-sm"
      />
      <button @click="addGoal" class="px-3 py-1 bg-red-600 text-white rounded-md text-sm hover:bg-red-700">
        Add
      </button>
    </div>
  </div>
</template>
