import { defineStore } from 'pinia'
import api from '@/services/api'

export const useCarePlanStore = defineStore('carePlan', {
  state: () => ({
    treatmentReceived: '',
    notes: '',
    loaded: false
  }),
  actions: {
    async fetch() {
      const { data } = await api.get('/careplan')
      this.treatmentReceived = data.treatmentReceived ?? ''
      this.notes = data.notes ?? ''
      this.loaded = true
    },
    async save() {
      await api.put('/careplan', {
        treatmentReceived: this.treatmentReceived,
        notes: this.notes
      })
    }
  }
})
