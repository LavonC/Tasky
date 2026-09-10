import { defineRouter } from '#q-app';
import {
  createMemoryHistory,
  createRouter,
  createWebHashHistory,
  createWebHistory,
} from 'vue-router';

import routes from './routes';

/*
 * If not building with SSR mode, you can
 * directly export the Router instantiation;
 *
 * The function below can be async too; either use
 * async/await or return a Promise which resolves
 * with the Router instance.
 */

export default defineRouter((/* { store, ssrContext } */) => {
  const createHistory = import.meta.env.QUASAR_SERVER
    ? createMemoryHistory
    : import.meta.env.QUASAR_VUE_ROUTER_MODE === 'history'
      ? createWebHistory
      : createWebHashHistory;

  const Router = createRouter({
    scrollBehavior: () => ({ left: 0, top: 0 }),
    routes,

    // Leave this as is and make changes in quasar.conf.js instead!
    // quasar.conf.js -> build -> vueRouterMode
    // quasar.conf.js -> build -> publicPath
    history: createHistory(import.meta.env.QUASAR_VUE_ROUTER_BASE),
  });

  Router.beforeEach((to) => {
    const savedUser = sessionStorage.getItem('tasky_user');
    const savedToken = sessionStorage.getItem('tasky_token');
    const isAuthenticated = Boolean(savedUser && savedToken);
    const isProtectedRoute = to.matched.some((record) => record.meta.requiresAuth);
    const isAuthRoute = to.path.startsWith('/auth');

    if (isProtectedRoute && !isAuthenticated) {
      return { path: '/auth/login', replace: true };
    }

    if (isAuthRoute && isAuthenticated) {
      let role: string | undefined;
      try {
        role = JSON.parse(savedUser || '{}').role;
      } catch {
        sessionStorage.removeItem('tasky_user');
        sessionStorage.removeItem('tasky_token');
      }

      return {
        path: role === 'employee' ? '/employee/task-manager' : '/dashboard',
        replace: true,
      };
    }

    return true;
  });
  return Router;
});
