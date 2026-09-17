<template>
  <router-view />
</template>

<script setup lang="ts">
import { useAuthStore } from './stores/authStore';

const authStore = useAuthStore();

// Initialize auth before the first render so protected child pages cannot start
// requests with an empty token.
const urlParams = new URLSearchParams(window.location.search);
const token = urlParams.get('token');
const userData = urlParams.get('user');

if (token && userData) {
  try {
    sessionStorage.setItem('tasky_token', token);
    sessionStorage.setItem('tasky_user', userData);
    window.history.replaceState({}, document.title, window.location.pathname);
  } catch (error) {
    console.error('Error storing auth data:', error);
  }
}

authStore.initializeAuth();
</script>
