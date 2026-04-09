<script setup lang="ts">
import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const auth = useAuthStore()
const router = useRouter()
const isAuth = computed(() => auth.isAuthenticated)

function logout() {
  auth.logout()
  router.push({ name: 'login' })
}

const navItems = [
  { name: 'step1', label: 'Care Plan', icon: '❤️' },
  { name: 'step2', label: 'Meds', icon: '💊' },
  { name: 'step3', label: 'Appts', icon: '📅' },
  { name: 'step4', label: 'Goals', icon: '🎯' },
  { name: 'step5', label: 'Team', icon: '👥' },
]
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <header v-if="isAuth" class="bg-red-700 text-white px-4 py-3 flex justify-between items-center md:px-6">
      <span class="font-bold text-lg">❤️ CCS Recovery</span>
      <div class="flex items-center gap-4">
        <RouterLink to="/resources" class="text-sm text-red-100 hover:text-white">Resources</RouterLink>
        <button @click="logout" class="text-sm text-red-100 hover:text-white">Sign Out</button>
      </div>
    </header>

    <!-- Desktop sidebar + content -->
    <div v-if="isAuth" class="hidden md:flex">
      <nav class="w-48 min-h-screen bg-white border-r border-gray-200 pt-4">
        <RouterLink
          v-for="item in navItems"
          :key="item.name"
          :to="{ name: item.name }"
          class="flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-700"
          active-class="bg-red-50 text-red-700 font-semibold"
        >
          <span>{{ item.icon }}</span>
          <span>{{ item.label }}</span>
        </RouterLink>
        <RouterLink
          to="/resources"
          class="flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-700"
          active-class="bg-red-50 text-red-700 font-semibold"
        >
          <span>🔗</span>
          <span>Resources</span>
        </RouterLink>
      </nav>
      <main class="flex-1 pb-6">
        <RouterView />
      </main>
    </div>

    <!-- Mobile content -->
    <main v-if="isAuth" class="md:hidden pb-20">
      <RouterView />
    </main>

    <!-- Auth views (no nav) -->
    <RouterView v-if="!isAuth" />

    <!-- Mobile bottom nav -->
    <nav v-if="isAuth" class="md:hidden fixed bottom-0 w-full flex justify-around bg-white border-t border-gray-200 z-50">
      <RouterLink
        v-for="item in navItems"
        :key="item.name"
        :to="{ name: item.name }"
        class="flex flex-col items-center py-2 px-1 text-xs text-gray-500 hover:text-red-600"
        active-class="text-red-600 font-semibold"
      >
        <span class="text-lg">{{ item.icon }}</span>
        <span>{{ item.label }}</span>
      </RouterLink>
    </nav>
  </div>
</template>
