<script setup lang="ts">
import { ref } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const auth = useAuthStore()
const router = useRouter()
const email = ref('')
const password = ref('')
const confirm = ref('')
const error = ref('')
const loading = ref(false)

async function submit() {
  error.value = ''
  if (password.value !== confirm.value) {
    error.value = 'Passwords do not match.'
    return
  }
  loading.value = true
  try {
    await auth.register(email.value, password.value)
    await auth.login(email.value, password.value)
    router.push({ name: 'step1' })
  } catch {
    error.value = 'Registration failed. Password must be 6+ chars with uppercase, number, and symbol.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-red-50 flex items-center justify-center px-4">
    <div class="bg-white rounded-2xl shadow-lg p-8 w-full max-w-sm">
      <div class="text-center mb-6">
        <h1 class="text-2xl font-bold text-red-700">❤️ CCS Recovery</h1>
        <p class="text-sm text-gray-500 mt-1">Create your account</p>
      </div>
      <form @submit.prevent="submit" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
          <input v-model="email" type="email" required class="w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500" />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
          <input v-model="password" type="password" required class="w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500" />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Confirm Password</label>
          <input v-model="confirm" type="password" required class="w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500" />
        </div>
        <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
        <button type="submit" :disabled="loading" class="w-full py-2 px-4 bg-red-600 text-white font-medium rounded-md hover:bg-red-700 disabled:opacity-50">
          {{ loading ? 'Creating account...' : 'Create Account' }}
        </button>
      </form>
      <p class="text-center text-sm text-gray-500 mt-4">
        Already have an account?
        <RouterLink to="/login" class="text-red-600 font-medium hover:underline">Sign in</RouterLink>
      </p>
    </div>
  </div>
</template>
