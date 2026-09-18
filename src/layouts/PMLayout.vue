<template>
  <q-layout view="lHh Lpr lFf" class="page-background">
    <!-- ================= SIDEBAR ================= -->
    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      :width="260"
      :mini="sidebarCollapsed"
      class="text-black column pm-sidebar"
      style="border-radius: 0 32px 32px 0; border-right: 1px solid #e6e5e5"
    >
      <!-- Background decorative shapes -->
      <div class="sidebar-shape shape-top"></div>
      <div class="sidebar-shape shape-bottom"></div>
      <div class="sidebar-shape shape-bottom-small"></div>

      <div class="relative-position sidebar-content" style="z-index: 2">
        <!-- LOGO -->
        <div
          class="row items-center q-pt-md q-mb-xl"
          :class="sidebarCollapsed ? 'justify-center' : 'q-pl-sm'"
        >
          <q-avatar size="42px" class="bg-lime-5 text-dark">
            <q-icon name="o_task_alt" size="25px" />
          </q-avatar>

          <div
            v-if="!sidebarCollapsed"
            class="text-h5 text-weight-bold q-ml-sm"
            style="letter-spacing: -0.5px"
          >
            Tasky
          </div>
        </div>

        <!-- USER PROFILE -->
        <q-item
          clickable
          v-ripple
          to="/dashboard/profile"
          class="q-pa-sm q-mb-lg rounded-borders profile-item"
          :class="sidebarCollapsed ? 'justify-center' : ''"
        >
          <q-item-section avatar>
            <q-avatar size="40px">
              <img :src="authStore.user?.avatar || 'https://i.pravatar.cc/150?img=1'" />
            </q-avatar>
          </q-item-section>

          <q-item-section v-if="!sidebarCollapsed">
            <q-item-label class="text-body2 text-weight-medium text-black">
              {{ authStore.user?.firstName }}
              {{ authStore.user?.surname }}
            </q-item-label>

            <q-item-label caption class="text-blue-grey-4">
              {{ authStore.user?.role === 'pm' ? 'Project Manager' : 'Employee' }}
            </q-item-label>
          </q-item-section>

          <q-item-section v-if="!sidebarCollapsed" side>
            <q-icon name="chevron_right" size="18px" color="lime-5" />
          </q-item-section>
        </q-item>

        <!-- ================= NAVIGATION ================= -->
        <q-list class="q-gutter-y-xs">
          <q-item
            v-for="link in navigationLinks"
            :key="link.label"
            clickable
            v-ripple
            :to="link.link"
            :active="link.link === $route.path"
            active-class="nav-active"
            class="nav-item q-py-sm text-black"
            :class="sidebarCollapsed ? 'justify-center' : ''"
          >
            <q-item-section avatar>
              <q-icon :name="link.icon" size="21px" />
            </q-item-section>

            <q-item-section v-if="!sidebarCollapsed" class="text-body2 text-weight-medium">
              {{ link.label }}
            </q-item-section>
          </q-item>
        </q-list>
      </div>

      <q-space />

      <!-- ================= BOTTOM ================= -->
      <div class="relative-position" style="z-index: 2">
        <q-list class="q-gutter-y-xs">
          <!-- Notifications -->
          <q-item
            clickable
            v-ripple
            to="/dashboard/notifications"
            :active="$route.path === '/dashboard/notifications'"
            active-class="nav-active"
            class="nav-item q-py-sm text-blue-black"
            :class="sidebarCollapsed ? 'justify-center' : ''"
          >
            <q-item-section avatar>
              <q-icon name="o_notifications" size="21px" />
            </q-item-section>

            <q-item-section v-if="!sidebarCollapsed" class="text-body2 text-weight-medium">
              Notifications
            </q-item-section>

            <q-item-section v-if="!sidebarCollapsed" side>
              <q-badge
                v-if="unreadNotifications"
                color="lime-5"
                text-color="dark"
                :label="unreadNotifications"
                rounded
              />
            </q-item-section>
          </q-item>

          <!-- Logout -->
          <q-item
            clickable
            v-ripple
            @click="handleLogout"
            class="nav-item q-py-sm text-blue-black"
            :class="sidebarCollapsed ? 'justify-center' : ''"
          >
            <q-item-section avatar>
              <q-icon name="o_logout" size="21px" />
            </q-item-section>

            <q-item-section v-if="!sidebarCollapsed" class="text-body2 text-weight-medium">
              Logout
            </q-item-section>
          </q-item>

          <!-- Collapse -->
          <q-item
            clickable
            v-ripple
            class="bg-lime-5 collapse-btn nav-item q-py-sm text-blue-black"
            :class="sidebarCollapsed ? 'justify-center' : ''"
            @click="sidebarCollapsed = !sidebarCollapsed"
          >
            <q-item-section avatar>
              <q-icon
                :name="sidebarCollapsed ? 'chevron_right' : 'chevron_left'"
                size="21px"
              />
            </q-item-section>

            <q-item-section v-if="!sidebarCollapsed" class="text-body2 text-weight-medium">
              Collapse
            </q-item-section>
          </q-item>
        </q-list>
      </div>
    </q-drawer>

    <!-- ================= PAGE ================= -->
    <q-page-container class="bg-transparent">
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useQuasar } from 'quasar';
import { useRouter } from 'vue-router';
import { useNotificationStore } from '@/stores/notificationStore';
import { useAuthStore } from '@/stores/authStore';

const authStore = useAuthStore();
const router = useRouter();
const $q = useQuasar();

const leftDrawerOpen = ref(true);
const sidebarCollapsed = ref(false);

const notificationStore = useNotificationStore();
const unreadNotifications = computed(() => notificationStore.unreadCount);

onMounted(() => {
  $q.dark.set(localStorage.getItem('tasky_dark_mode') === 'true');
  void notificationStore.fetchNotifications();
});

const navigationLinks = [
  {
    label: 'Dashboard',
    icon: 'grid_view',
    link: '/dashboard',
  },
  {
    label: 'Projects',
    icon: 'o_folder',
    link: '/dashboard/projects',
  },
  {
    label: 'Tasks',
    icon: 'o_check_circle',
    link: '/dashboard/tasks',
  },
  {
    label: 'Resources',
    icon: 'o_people',
    link: '/dashboard/resources',
  },
  {
    label: 'Analytics',
    icon: 'o_bar_chart',
    link: '/dashboard/analytics',
  },
  {
    label: 'Timeline',
    icon: 'timeline',
    link: '/dashboard/calendar',
  },
  {
    label: 'Organisation',
    icon: 'o_domain',
    link: '/dashboard/organisation',
  },
];

function handleLogout() {
  sessionStorage.removeItem('tasky_user');
  sessionStorage.removeItem('tasky_token');
  sessionStorage.removeItem('pm_auth_token');
  sessionStorage.removeItem('pm_user_data');

  authStore.logout();

  $q.notify({
    type: 'positive',
    message: 'Logged out successfully',
    position: 'top',
    timeout: 2000,
  });

  void router.replace('/auth/login');
}
</script>

<style scoped>
/* ================= FLOATING SIDEBAR ================= */

.pm-sidebar {
  margin: 16px !important;
  height: calc(100vh - 32px) !important;
  border-radius: 24px !important;
  overflow: hidden !important;
  background: transparent !important;
}

.pm-sidebar :deep(.q-drawer__content) {
  background: #ffffff !important;
  border-radius: 24px !important;
  overflow: hidden !important;
  padding: 16px !important;
}

:global(body.body--dark) .pm-sidebar :deep(.q-drawer__content) {
  background: #1d2930 !important;
  border-color: #34434c !important;
}

/* ================= DECORATIVE SHAPES ================= */

.sidebar-shape {
  position: absolute;
  pointer-events: none;
  z-index: 1;
  border: 1px solid transparent;

  background:
    linear-gradient(rgba(76, 175, 80, 0.01), rgba(76, 175, 80, 0.01)) padding-box,
    linear-gradient(
        135deg,
        rgba(76, 175, 80, 0.35),
        rgba(255, 255, 255, 0.04),
        rgba(76, 175, 80, 0.22)
      )
      border-box;
}

.shape-top {
  width: 235px;
  height: 190px;
  top: -105px;
  right: 0;
  border-radius: 48% 52% 60% 40% / 42% 45% 55% 58%;
  transform: rotate(-18deg);
}

.shape-bottom {
  width: 280px;
  height: 150px;
  bottom: -85px;
  left: -115px;
  border-radius: 55% 45% 50% 50% / 60% 45% 55% 40%;
  transform: rotate(-12deg);
}

.shape-bottom-small {
  width: 200px;
  height: 115px;
  bottom: -62px;
  left: 35px;
  border-radius: 60% 40% 45% 55% / 55% 50% 50% 45%;
}

/* ================= PROFILE ================= */

.profile-item {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

/* ================= NAVIGATION ================= */

.nav-item {
  min-height: 46px;
  transition: 0.2s ease;
  border-radius: 8px;
}

.nav-active {
  background: #E1FF6B !important;
  color: #000000 !important;
  border-radius: 8px;

  margin-left: 8px;
  margin-right: 8px;
  width: calc(100% - 16px);
}

.nav-active .q-icon {
  color: #000000 !important;
}

.nav-item:not(.nav-active):hover {
  background: rgba(255, 255, 255, 0.045);
}

/* ================= COLLAPSE ================= */

.collapse-btn {
  margin-top: 4px;
  overflow: hidden !important;
}

/* ================= PAGE ================= */

.page-background {
  background: #ffffff;
}
</style>
