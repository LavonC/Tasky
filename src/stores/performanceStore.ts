import { defineStore } from 'pinia';
import { ref } from 'vue';
import { getAuthHeaders, API_URL, readApiResponse } from '@/services/api';
import { useAuthStore } from './authStore';

export type PerformanceRange = 'this_week' | 'this_month' | 'last_3_months';

export const usePerformanceStore = defineStore('performance', () => {
  const summary = ref<any>(null);
  const trend = ref<any[]>([]);
  const priorityReport = ref<any[]>([]);
  const loading = ref(false);
  const error = ref<string | null>(null);
  const range = ref<PerformanceRange>('this_month');

  async function loadAll(requestedRange?: PerformanceRange) {
    const authStore = useAuthStore();
    const selectedRange = requestedRange || range.value;
    if (!authStore.currentUser || authStore.currentUser.role !== 'employee') {
      error.value = 'An authenticated employee session is required.';
      summary.value = null;
      return null;
    }

    loading.value = true;
    error.value = null;
    range.value = selectedRange;

    try {
      const response = await fetch(
        `${API_URL}/api/employee/performance?range=${encodeURIComponent(selectedRange)}`,
        { headers: getAuthHeaders() },
      );
      const data = await readApiResponse<{ success: boolean; performance: any }>(response);
      if (!data.success || !data.performance) {
        throw new Error('The performance API returned no performance data.');
      }

      summary.value = data.performance;
      trend.value = data.performance.weeklyProgress || [];
      priorityReport.value = data.performance.priorityPerformance || [];
      return data.performance;
    } catch (err) {
      summary.value = null;
      trend.value = [];
      priorityReport.value = [];
      error.value = err instanceof Error ? err.message : 'Failed to load performance data.';
      return null;
    } finally {
      loading.value = false;
    }
  }

  function fetchPerformance(requestedRange?: PerformanceRange) {
    return loadAll(requestedRange);
  }

  function fetchSummary(requestedRange?: PerformanceRange) {
    return loadAll(requestedRange);
  }

  function fetchTrend(requestedRange?: PerformanceRange) {
    return loadAll(requestedRange);
  }

  function fetchPriorityReport(requestedRange?: PerformanceRange) {
    return loadAll(requestedRange);
  }

  function fetchTasksByPriority(requestedRange?: PerformanceRange) {
    return loadAll(requestedRange);
  }

  return {
    summary,
    trend,
    priorityReport,
    loading,
    error,
    range,
    loadAll,
    fetchPerformance,
    fetchSummary,
    fetchTrend,
    fetchPriorityReport,
    fetchTasksByPriority,
  };
});