import { defineStore } from 'pinia'
import api from '@/services/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: sessionStorage.getItem('token') ?? null as string | null
  }),
  getters: {
    isAuthenticated: (state) => !!state.token
  },
  actions: {
    async login(email: string, password: string) {
      const { data } = await api.post('/auth/login', { email, password })
      this.token = data.token
      sessionStorage.setItem('token', data.token)
    },
    async register(email: string, password: string) {
      await api.post('/auth/register', { email, password })
    },
    logout() {
      this.token = null
      sessionStorage.removeItem('token')
    }
  }
})
