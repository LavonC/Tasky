import { defineStore } from 'pinia';
import { useAuthStore } from './authStore';

export const useNotificationStore = defineStore('notification', {
  state: () => ({
    notifications: [] as any[],
    loading: false,
    error: null as string | null,
  }),

  getters: {
    unreadCount: (state) => state.notifications.filter((n) => !n.is_read).length,
  },

  actions: {
    getHeaders() {
      const auth = useAuthStore();
      return { Authorization: `Bearer ${auth.token}` };
    },

    async fetchNotifications() {
      this.loading = true;
      this.error = null;
      try {
        const auth = useAuthStore();
        const userId = auth.user?.id;
        const response = await fetch(`http://localhost:3007/api/employee/notifications?user_id=${userId}`, {
          headers: this.getHeaders(),
        });
        const data = await response.json();
        if (!response.ok || !data.success) throw new Error(data.error || 'Failed to load notifications');
        this.notifications = Array.isArray(data.notifications) ? data.notifications : [];
      } catch (err: any) {
        this.error = err.message;
        this.notifications = [];
      } finally {
        this.loading = false;
      }
    },

    async checkDeadlines() {
      try {
        const response = await fetch('http://localhost:3007/api/notifications/check-deadlines', {
          method: 'POST',
          headers: this.getHeaders(),
        });
        const data = await response.json();
        if (!response.ok || !data.success) throw new Error(data.error || 'Failed to check deadlines');
        // Refresh notifications after checking
        await this.fetchNotifications();
        return data;
      } catch (err: any) {
        console.error('Error checking deadlines:', err);
        throw err;
      }
    },

    async markAsRead(id: string) {
      try {
        const auth = useAuthStore();
        const userId = auth.user?.id;
        const response = await fetch(`http://localhost:3007/api/employee/notifications/${id}/read`, {
          method: 'PUT',
          headers: { ...this.getHeaders(), 'Content-Type': 'application/json' },
          body: JSON.stringify({ user_id: userId }),
        });
        const data = await response.json();
        if (!response.ok || !data.success) throw new Error(data.error || 'Failed to mark notification as read');
        const n = this.notifications.find((n) => n.id == id);
        if (n) n.is_read = 1;
      } catch (err: any) {
        console.error(err);
      }
    },

    async markAllAsRead() {
      try {
        const auth = useAuthStore();
        const userId = auth.user?.id;
        const response = await fetch('http://localhost:3007/api/employee/notifications/read-all', {
          method: 'PUT',
          headers: { ...this.getHeaders(), 'Content-Type': 'application/json' },
          body: JSON.stringify({ user_id: userId }),
        });
        const data = await response.json();
        if (!response.ok || !data.success) throw new Error(data.error || 'Failed to mark notifications as read');
        this.notifications.forEach((n) => (n.is_read = 1));
      } catch (err: any) {
        console.error(err);
      }
    },

    async deleteNotification(id: string) {
      try {
        const auth = useAuthStore();
        const userId = auth.user?.id;
        const response = await fetch(`http://localhost:3007/api/employee/notifications/${id}`, {
          method: 'DELETE',
          headers: { ...this.getHeaders(), 'Content-Type': 'application/json' },
          body: JSON.stringify({ user_id: userId }),
        });
        const data = await response.json();
        if (!response.ok || !data.success) throw new Error(data.error || 'Failed to delete notification');
        this.notifications = this.notifications.filter((n) => n.id != id);
        return true;
      } catch (err: any) {
        console.error(err);
      }
      return false;
    },
  },
});
