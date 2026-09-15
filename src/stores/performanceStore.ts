import { defineStore } from 'pinia';
import { getAuthHeaders, API_URL } from '@/services/api';

export const usePerformanceStore = defineStore('performance', {
  state: () => ({
    summary: null as any,
    trend: [] as any[],
    priorityReport: null as any,
    tasksByPriority: [] as any[],
    tasksByPriorityTotal: 0,
    loading: false,
    error: null as string | null,
  }),

  actions: {
    getHeaders() {
      return getAuthHeaders();
    },

    getUserId(): string {
      const storedUser = sessionStorage.getItem('tasky_user');

      if (storedUser) {
        try {
          const user = JSON.parse(storedUser);
          return String(user.id);
        } catch {
          // Fall through to the next method
        }
      }

      const userId = sessionStorage.getItem('user_id');

      if (userId) {
        return userId;
      }

      throw new Error('User ID not found');
    },

    async fetchPerformance() {
      this.loading = true;
      this.error = null;

      try {
        const userId = this.getUserId();

        const response = await fetch(
          `${API_URL}/api/pm/employee-performance/${userId}`,
          {
            headers: this.getHeaders(),
          },
        );

        const data = await response.json();

        if (!response.ok || !data.success) {
          throw new Error(data.error || 'Failed to fetch performance data');
        }

        const performance = data.performance;

        const totalTasks = Number(performance.totalTasks) || 0;
        const completedTasks = Number(performance.completedTasks) || 0;
        const overdueTasks = Number(performance.overdueTasks) || 0;
        const hoursLogged = Number(performance.hoursLogged) || 0;
        const overallScore = Number(performance.overallScore) || 0;
        const utilization = Number(performance.utilization) || 0;

        this.summary = {
          overallScore,
          totalTasks,
          completedTasks,
          overdueTasks,
          hoursLogged,
          utilization,
          taskStats: Object.fromEntries(Object.entries(performance.taskStats || {}).map(([key, value]) => [key, Number(value) || 0])),
          recentTasks: performance.recentTasks,
          productivityScore: overallScore,
          completionRate: totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0,
          onTimeRate: totalTasks > 0 ? Math.round(((totalTasks - overdueTasks) / totalTasks) * 100) : 0,
          focusScore: 75,
          totalEstimatedHours: hoursLogged * 1.2,
          totalHoursLogged: hoursLogged,
          dailyActivity: [],
          timeAllocation: [],
          qualityMetrics: {
            reopenedTasks: 0,
            revisionRequests: 0,
            firstTimeCompletionRate: 85,
            avgSubtaskAccuracy: 90
          }
        };

        this.trend = (performance.weeklyProgress || []).map((item: any) => ({
          ...item,
          hours: Number(item.hours) || 0,
        }));

        this.priorityReport = performance.taskStats || null;

        this.tasksByPriority = [];
        this.tasksByPriorityTotal = 0;

        return performance;
      } catch (err: any) {
        this.error = err.message || 'Failed to load performance data';
        console.error('Error loading performance data:', err);
        return null;
      } finally {
        this.loading = false;
      }
    },

        async fetchSummary(range = 'this_month') {
      void range;
      return this.fetchPerformance();
    },

    async fetchTrend(range = 'this_month') {
      void range;
      return this.fetchPerformance();
    },

    async fetchPriorityReport(filters: any = {}) {
      void filters;
      return this.fetchPerformance();
    },

    async fetchTasksByPriority(
      filters: any = {},
      page = 1,
      perPage = 10,
    ) {
      void filters;
      void page;
      void perPage;
      return this.fetchPerformance();
    },

    async loadAll(range = 'this_month') {
      void range;
      return this.fetchPerformance();
    },
  },
});
