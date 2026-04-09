<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'

interface Goal {
  id: number
  text: string
  isCompleted: boolean
  category: string
}

const CATEGORIES = [
  { value: 'ShortTerm', label: 'Short Term' },
  { value: 'LongTerm',  label: 'Long Term'  },
  { value: 'Health',    label: 'Health'     },
  { value: 'Personal',  label: 'Personal'   },
]

const goals      = ref<Goal[]>([])
const newText    = ref('')
const newCategory = ref('ShortTerm')
const activeTab  = ref('All')

const tabs = [{ value: 'All', label: 'All' }, ...CATEGORIES]

const filtered = computed(() =>
  activeTab.value === 'All'
    ? goals.value
    : goals.value.filter(g => g.category === activeTab.value)
)

async function fetchGoals() {
  const { data } = await api.get('/lifestyle')
  goals.value = data
}

async function addGoal() {
  if (!newText.value.trim()) return
  const { data } = await api.post('/lifestyle', {
    category: newCategory.value,
    text: newText.value.trim(),
  })
  goals.value.push(data)
  newText.value = ''
}

async function toggleGoal(id: number) {
  const { data } = await api.patch(`/lifestyle/${id}/toggle`)
  const idx = goals.value.findIndex(g => g.id === id)
  if (idx !== -1) goals.value[idx] = data
}

function categoryLabel(value: string) {
  return CATEGORIES.find(c => c.value === value)?.label ?? value
}

onMounted(fetchGoals)
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 py-6">
    <h2 class="text-xl font-bold text-gray-800 mb-1">Step 4: Lifestyle Goals</h2>
    <p class="text-sm text-gray-500 mb-6">Add goals and check them off as you achieve them.</p>

    <!-- Add Goal Form -->
    <div class="bg-white border border-gray-200 rounded-xl p-4 shadow-sm mb-6">
      <h3 class="text-sm font-semibold text-gray-700 mb-3">Add a New Goal</h3>
      <div class="flex flex-col sm:flex-row gap-2">
        <input
          v-model="newText"
          @keyup.enter="addGoal"
          placeholder="Describe your goal..."
          class="flex-1 rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 text-sm"
        />
        <select
          v-model="newCategory"
          class="rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 text-sm"
        >
          <option v-for="cat in CATEGORIES" :key="cat.value" :value="cat.value">
            {{ cat.label }}
          </option>
        </select>
        <button
          @click="addGoal"
          class="px-4 py-2 bg-red-600 text-white rounded-md text-sm font-medium hover:bg-red-700 transition-colors"
        >
          Add
        </button>
      </div>
    </div>

    <!-- Filter Dropdown -->
    <div class="flex items-center gap-2 mb-4">
      <label for="filter-category" class="text-sm text-gray-600 font-medium shrink-0">Filter by:</label>
      <select
        id="filter-category"
        v-model="activeTab"
        class="rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 text-sm"
      >
        <option v-for="tab in tabs" :key="tab.value" :value="tab.value">{{ tab.label }}</option>
      </select>
    </div>

    <!-- Goal List -->
    <ul v-if="filtered.length" class="space-y-2">
      <li
        v-for="goal in filtered"
        :key="goal.id"
        class="flex items-center gap-3 bg-white border border-gray-100 rounded-lg px-3 py-2 shadow-sm"
      >
        <input
          type="checkbox"
          :checked="goal.isCompleted"
          @change="toggleGoal(goal.id)"
          class="rounded border-gray-300 text-red-500 focus:ring-red-500 shrink-0"
        />
        <span
          :class="goal.isCompleted ? 'line-through text-gray-400' : 'text-gray-700'"
          class="text-sm flex-1"
        >
          {{ goal.text }}
        </span>
        <span class="text-xs text-gray-400 shrink-0">{{ categoryLabel(goal.category) }}</span>
      </li>
    </ul>
    <p v-else class="text-sm text-gray-400 text-center py-8">
      No goals yet{{ activeTab !== 'All' ? ` in ${categoryLabel(activeTab)}` : '' }}. Add one above!
    </p>
  </div>
</template>
