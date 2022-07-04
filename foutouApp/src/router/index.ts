import { createRouter, createWebHistory } from 'vue-router'
import Start from '../pages/Start.vue';

const routes = [
  {
    path: '/',
    name: 'start',
    component: Start
  },
  {
    path: '/browse',
    name: 'browse',
    component: () => import('../pages/Browse.vue')
  },
  {
    path: '/personal',
    name: 'personal',
    component: () => import('../pages/Personal.vue')
  },
  {
    path: '/create',
    name: 'create',
    component: () => import('../pages/Create.vue')
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router