<template>
  <q-page class="q-pa-lg text-black" style="background:#f8f9fa">
    <!-- Header -->
    <div class="row items-center justify-between q-mb-md">
      <div class="row items-center">
        </div>
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
                <img :src="avatar || authStore.user?.avatar || 'https://cdn.quasar.dev/img/avatar.png'" />
              </q-avatar>
              <q-input
                v-model="avatar"
                label="Avatar URL"
                outlined
                dense
                class="q-mt-md full-width"
                hint="Use a publicly accessible image URL"
              />
            </div>
            <q-input v-model="firstName" label="First Name" outlined class="q-mb-md" />
            <q-input v-model="lastName" label="Last Name" outlined class="q-mb-md" />
            <q-input v-model="email" label="Email" outlined class="q-mb-md" />
            <q-input v-model="phone" label="Phone" outlined class="q-mb-md" />
            <q-btn color="primary" label="Save Changes" @click="saveProfile" class="full-width" />
          </q-card-section>
        </q-card>

        <q-card flat bordered class="settings-card q-mt-md">
          <q-card-section>
            <div class="text-h6 text-weight-bold">Change Password</div>
          </q-card-section>
          <q-card-section>
            <q-input v-model="currentPassword" label="Current Password" type="password" outlined class="q-mb-md" />
            <q-input v-model="newPassword" label="New Password" type="password" outlined class="q-mb-md" />
            <q-input v-model="confirmPassword" label="Confirm New Password" type="password" outlined class="q-mb-md" />
            <q-btn
              color="primary"
              label="Update Password"
              class="full-width"
              :loading="changingPassword"
              @click="changePassword"
            />
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
                  <q-toggle :model-value="darkMode" color="dark" @update:model-value="setDarkMode" />
                </q-item-section>
              </q-item>
              <q-item>
                <q-item-section>
                  <q-item-label>Email Notifications</q-item-label>
                  <q-item-label caption>Receive email updates</q-item-label>
                </q-item-section>
                <q-item-section side>
                  <q-toggle v-model="emailNotifications" color="dark" />
                </q-item-section>
              </q-item>
              <q-item>
                <q-item-section>
                  <q-item-label>Task Reminders</q-item-label>
                  <q-item-label caption>Get reminded of deadlines</q-item-label>
                </q-item-section>
                <q-item-section side>
                  <q-toggle v-model="taskReminders" color="dark" />
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
            <div class="text-h6 text-weight-bold text-negative">Delete account</div>
            <div class="text-caption text-grey-7 q-mt-xs">
              Your account will be permanently deleted and your access will be removed. Your completed work history is retained under a generic project manager.
            </div>
          </q-card-section>
          <q-card-section>
            <q-btn
              color="negative"
              outline
              icon="delete"
              label="Delete my account"
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
import { getThemeStorageKey } from '../../services/theme';

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
const avatar = ref('');
const currentPassword = ref('');
const newPassword = ref('');
const confirmPassword = ref('');
const darkMode = ref(false);
const emailNotifications = ref(true);
const taskReminders = ref(true);
const resigning = ref(false);
const changingPassword = ref(false);

onMounted(() => {
  darkMode.value = sessionStorage.getItem(getThemeStorageKey(authStore.user?.id)) === 'true';
  $q.dark.set(darkMode.value);
  if (authStore.user) {
    firstName.value = authStore.user.firstName || '';
    lastName.value = authStore.user.surname || '';
    email.value = authStore.user.email || '';
    phone.value = authStore.user.phone || '';
    avatar.value = authStore.user.avatar || '';
  }
});

function confirmResignation() {
  $q.dialog({
    title: 'Delete Account?',
    message: 'Your account will be permanently deleted and you will be signed out immediately.',
    cancel: true,
    ok: { label: 'Delete', color: 'negative' },
  }).onOk(() => resign());
}

async function resign() {
  if (!authStore.user?.id) return;
  resigning.value = true;
  try {
    const response = await fetch('http://localhost:3001/api/employee/resign', {
      method: 'POST',
      headers: { Authorization: `Bearer ${authStore.token}` },
    });
    const result = await response.json();
    if (!response.ok || !result.success) throw new Error(result.error || 'Unable to delete account');
    $q.notify({ type: 'positive', message: 'Your account has been deleted.' });
    logout();
  } catch (error) {
    $q.notify({ type: 'negative', message: error instanceof Error ? error.message : 'Unable to delete account' });
  } finally {
    resigning.value = false;
  }
}

function setDarkMode(value: boolean) {
  darkMode.value = value;
  $q.dark.set(value);
  sessionStorage.setItem(getThemeStorageKey(authStore.user?.id), String(value));
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
    avatar: avatar.value.trim(),
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

async function changePassword() {
  if (!authStore.user?.id) return;
  if (!currentPassword.value || !newPassword.value) {
    $q.notify({ type: 'negative', message: 'Enter your current and new passwords', position: 'top' });
    return;
  }
  if (newPassword.value.length < 8) {
    $q.notify({ type: 'negative', message: 'New password must be at least 8 characters', position: 'top' });
    return;
  }
  if (newPassword.value !== confirmPassword.value) {
    $q.notify({ type: 'negative', message: 'New passwords do not match', position: 'top' });
    return;
  }

  changingPassword.value = true;
  const result = await authStore.changePassword(authStore.user.id, currentPassword.value, newPassword.value);
  changingPassword.value = false;

  if (result.success) {
    currentPassword.value = '';
    newPassword.value = '';
    confirmPassword.value = '';
    $q.notify({ type: 'positive', message: 'Password changed successfully', position: 'top' });
  } else {
    $q.notify({ type: 'negative', message: result.error || 'Failed to change password', position: 'top' });
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
