import { createRouter, createWebHistory } from 'vue-router'
import Start from '../pages/Start.vue';

const routes = [
  {
    path: '/',
    name: 'start',
    component: Start
  },
  {
    path: '/home',
    name: 'home',
    component: () => import('../pages/Home.vue')
  },
  {
    path: '/personal',
    name: 'personal',
    component: () => import('../pages/Personal.vue')
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router