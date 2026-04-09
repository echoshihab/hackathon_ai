import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', redirect: '/step/1' },
    { path: '/login', name: 'login', component: () => import('@/views/auth/LoginView.vue') },
    { path: '/register', name: 'register', component: () => import('@/views/auth/RegisterView.vue') },
    { path: '/step/1', name: 'step1', component: () => import('@/views/steps/Step1CarePlan.vue'), meta: { requiresAuth: true } },
    { path: '/step/2', name: 'step2', component: () => import('@/views/steps/Step2Medications.vue'), meta: { requiresAuth: true } },
    { path: '/step/3', name: 'step3', component: () => import('@/views/steps/Step3Appointments.vue'), meta: { requiresAuth: true } },
    { path: '/step/4', name: 'step4', component: () => import('@/views/steps/Step4Lifestyle.vue'), meta: { requiresAuth: true } },
    { path: '/step/5', name: 'step5', component: () => import('@/views/steps/Step5CareTeam.vue'), meta: { requiresAuth: true } },
    { path: '/resources', name: 'resources', component: () => import('@/views/ResourcesView.vue'), meta: { requiresAuth: true } }
  ]
})

router.beforeEach((to) => {
  const auth = useAuthStore()
  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return { name: 'login' }
  }
})

export default router
