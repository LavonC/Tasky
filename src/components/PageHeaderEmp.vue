<template>
  <q-toolbar class="page-header q-px-lg">
    <!-- Current page -->
    <div class="row items-center">
      <q-avatar size="48px" class="page-icon">
        <q-icon :name="icon" size="28px" />
      </q-avatar>

      <div class="q-ml-md">
        <div class="page-title">
          {{ title }}
        </div>

        <div class="page-subtitle">
          {{ subtitle }}
        </div>
      </div>
    </div>

    <q-space />

    <!-- Notifications -->
    <q-btn
      flat
      round
      dense
      icon="notifications_none"
      class="notification-btn q-mr-lg"
      to="/employee/notifications"
    />

    <!-- Avatar -->
    <q-avatar
      size="40px"
      clickable
      v-ripple
      class="cursor-pointer"
      @click="$router.push('/employee/settings')"
    >
      <img :src="avatar || 'https://i.pravatar.cc/150?img=1'" />
    </q-avatar>
  </q-toolbar>
</template>

<script setup lang="ts">
interface Props {
  icon: string;
  title: string;
  subtitle: string;
  avatar?: string;
}

defineProps<Props>();
</script>

<style scoped>
.page-header {
  background: transparent !important;
  border: none !important;
  box-shadow: none !important;
}
.page-title {
  line-height: 1.5;
}

.page-subtitle {
  margin-top: 0;
}
/* Lime icon box */
.page-icon {
  background: #caff33;
  color: #1d2939;
}

/* Notification */
.notification-btn {
  color: #667085;
}
</style>
