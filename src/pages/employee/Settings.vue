<template>
  <q-page class="q-pa-lg text-black" style="background:#f8f9fa">
    <!-- Header -->
    <div class="row items-center justify-between q-mb-md">
      <div class="row items-center">
        <q-avatar color="indigo-1" text-color="indigo" icon="settings" size="48px" class="q-mr-md" style="border-radius:12px" />
        <div class="column"><div class="text-h5 text-weight-bold">Settings</div>
        <div class="text-grey-7 text-caption">Manage your account preferences</div>
      </div></div>
    </div>

    <div class="row q-col-gutter-md">
      <!-- Profile Settings -->
      <div class="col-6">
        <q-card flat bordered class="settings-card">
          <q-card-section>
            <div class="text-h6 text-weight-bold">Profile Settings</div>
          </q-card-section>
          <q-card-section>
            <div class="column items-center q-mb-md">
              <q-avatar size="100px">
                <img :src="authStore.user?.avatar || 'https://cdn.quasar.dev/img/avatar.png'" />
              </q-avatar>
              <q-btn flat color="primary" label="Change Avatar" class="q-mt-sm" />
            </div>
            <q-input v-model="firstName" label="First Name" outlined class="q-mb-md" />
            <q-input v-model="lastName" label="Last Name" outlined class="q-mb-md" />
            <q-input v-model="email" label="Email" outlined class="q-mb-md" />
            <q-input v-model="phone" label="Phone" outlined class="q-mb-md" />
            <q-btn color="primary" label="Save Changes" @click="saveProfile" class="full-width" />
          </q-card-section>
        </q-card>
      </div>

      <!-- Preferences -->
      <div class="col-6">
        <q-card flat bordered class="settings-card">
          <q-card-section>
            <div class="text-h6 text-weight-bold">Preferences</div>
          </q-card-section>
          <q-card-section>
            <q-list>
              <q-item>
                <q-item-section>
                  <q-item-label>Dark Mode</q-item-label>
                  <q-item-label caption>Uses dark theme</q-item-label>
                </q-item-section>
                <q-item-section side>
                  <q-toggle :model-value="darkMode" color="primary" @update:model-value="setDarkMode" />
                </q-item-section>
              </q-item>
              <q-item>
                <q-item-section>
                  <q-item-label>Email Notifications</q-item-label>
                  <q-item-label caption>Receive email updates</q-item-label>
                </q-item-section>
                <q-item-section side>
                  <q-toggle v-model="emailNotifications" color="primary" />
                </q-item-section>
              </q-item>
              <q-item>
                <q-item-section>
                  <q-item-label>Task Reminders</q-item-label>
                  <q-item-label caption>Get reminded of deadlines</q-item-label>
                </q-item-section>
                <q-item-section side>
                  <q-toggle v-model="taskReminders" color="primary" />
                </q-item-section>
              </q-item>
            </q-list>
          </q-card-section>
        </q-card>

        <q-card flat bordered class="settings-card q-mt-md">
          <q-card-section>
            <div class="text-h6 text-weight-bold">Account Actions</div>
          </q-card-section>
          <q-card-section>
            <q-btn color="red" label="Logout" @click="logout" class="full-width" />
          </q-card-section>
        </q-card>

        <q-card class="settings-card q-mt-md" bordered>
          <q-card-section>
            <div class="text-h6 text-weight-bold text-negative">Leave organization</div>
            <div class="text-caption text-grey-7 q-mt-xs">
              Your access and active membership will be removed. Your completed work history is retained.
            </div>
          </q-card-section>
          <q-card-section>
            <q-btn
              color="negative"
              outline
              icon="logout"
              label="Resign from organization"
              class="full-width"
              :loading="resigning"
              @click="confirmResignation"
            />
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useQuasar } from 'quasar';
import { useAuthStore } from '../../stores/authStore';

defineOptions({
  name: 'EmployeeSettings',
});

const router = useRouter();
const $q = useQuasar();
const authStore = useAuthStore();

const firstName = ref('');
const lastName = ref('');
const email = ref('');
const phone = ref('');
const darkMode = ref(false);
const emailNotifications = ref(true);
const taskReminders = ref(true);
const resigning = ref(false);

onMounted(() => {
  darkMode.value = localStorage.getItem('tasky_dark_mode') === 'true';
  $q.dark.set(darkMode.value);
  if (authStore.user) {
    firstName.value = authStore.user.firstName || '';
    lastName.value = authStore.user.surname || '';
    email.value = authStore.user.email || '';
    phone.value = authStore.user.phone || '';
  }
});

function confirmResignation() {
  $q.dialog({
    title: 'Resign from organization?',
    message: 'You will be signed out immediately and will no longer appear in your organization.',
    cancel: true,
    ok: { label: 'Resign', color: 'negative' },
  }).onOk(() => resign());
}

async function resign() {
  if (!authStore.user?.id) return;
  resigning.value = true;
  try {
    const response = await fetch('http://localhost:3007/api/employee/resign', {
      method: 'POST',
      headers: { Authorization: `Bearer ${authStore.token}` },
    });
    const result = await response.json();
    if (!response.ok || !result.success) throw new Error(result.error || 'Unable to resign');
    $q.notify({ type: 'positive', message: 'You have left the organization.' });
    logout();
  } catch (error) {
    $q.notify({ type: 'negative', message: error instanceof Error ? error.message : 'Unable to resign' });
  } finally {
    resigning.value = false;
  }
}

function setDarkMode(value: boolean) {
  darkMode.value = value;
  $q.dark.set(value);
  localStorage.setItem('tasky_dark_mode', String(value));
}

async function saveProfile() {
  if (!authStore.user?.id) {
    $q.notify({
      type: 'negative',
      message: 'User information not available',
    });
    return;
  }

  const profileData = {
    firstName: firstName.value.trim(),
    surname: lastName.value.trim(),
    email: email.value.trim(),
    phone: phone.value.trim(),
    ...(authStore.user.avatar !== undefined ? { avatar: authStore.user.avatar } : {}),
  };

  const result = await authStore.updateProfile(authStore.user.id, profileData);

  if (result.success) {
    $q.notify({
      type: 'positive',
      message: 'Profile updated successfully',
      position: 'top',
    });
  } else {
    $q.notify({
      type: 'negative',
      message: result.error || 'Failed to update profile',
      position: 'top',
    });
  }
}

function logout() {
  authStore.logout();
  router.replace('/auth/login');
}
</script>

<style scoped>
.settings-card { border-radius: 14px; border-color: #e5eaf0; box-shadow: 0 7px 20px rgba(32, 54, 83, .05); }
</style>
