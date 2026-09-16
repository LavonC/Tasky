<template>
  <q-page class="bg-grey-1 q-pa-lg">
    <div class="row items-center justify-between q-mb-lg">
      <div>
        <div class="text-h4 text-weight-bold"></div>
        <div class="text-body1 text-grey-6"></div>
      </div>
      <div class="row q-gutter-sm">
        <q-select v-model="selectedPeriod" :options="periodOptions" outlined dense style="width: 140px" @update:model-value="handlePeriodChange" />
        <q-btn outline color="primary" icon="refresh" label="Refresh" :loading="performanceStore.loading" @click="loadPerformance" />
      </div>
    </div>

    <div v-if="performanceStore.loading" class="flex flex-center" style="min-height: 400px">
      <q-spinner-dots size="40px" color="primary" /><span class="q-ml-sm">Loading...</span>
    </div>
    <q-banner v-else-if="performanceStore.error" class="bg-negative text-white" dense rounded>
      <template #avatar><q-icon name="error" /></template>
      {{ performanceStore.error }}
      <template #action><q-btn flat color="white" label="Retry" @click="loadPerformance" /></template>
    </q-banner>
    <q-banner v-else-if="!hasPerformanceData" class="bg-white" bordered rounded>
      <template #avatar><q-icon name="insights" color="primary" /></template>
      No performance data available
    </q-banner>

    <div v-else class="column q-gutter-lg">
      <div class="row q-col-gutter-md">
        <div v-for="card in statCards" :key="card.label" class="col-12 col-sm-6 col-md-3">
          <PerformanceStatCard v-bind="card" :value="formatMetric(card.value, card.suffix)" trend="" :positive="true" />
        </div>
      </div>

      <PerformanceTrendChart title="Productivity Trend" subtitle="Tasks assigned, completed, and delayed in the selected period" :data="performanceStore.trend" :series-config="seriesConfig" :show-period-selector="false" />
      <InsightsPanel title="Performance Insights" subtitle="Based on your recorded work" :insights="insights" />

      <div class="row q-col-gutter-md">
        <div class="col-12 col-md-6">
          <WorkloadVsOutputCard title="Workload vs Output" subtitle="Estimated effort compared with logged effort" :workload-items="workloadItems" :efficiency="performanceStore.summary.efficiency" @period-change="handlePeriodChange" />
        </div>
        <div class="col-12 col-md-6">
          <TimeAllocationDonut title="Time Allocation" subtitle="Logged hours by project" :data="performanceStore.summary.timeAllocation || []" :center-label="timeCenterLabel" @period-change="handlePeriodChange" />
        </div>
      </div>

      <div class="row q-col-gutter-md">
        <div class="col-12 col-md-6">
          <DailyConsistencyHeatmap title="Daily Consistency" subtitle="Recorded logs, updates, and compliance activity" :data="performanceStore.summary.dailyActivity || []" @period-change="handlePeriodChange" />
        </div>
        <div class="col-12 col-md-6">
          <TaskQualityMetrics title="Task Quality Metrics" subtitle="Quality signals available from the review history" :metrics="qualityMetrics" />
        </div>
      </div>

      <q-card flat bordered class="q-pa-lg">
        <div class="text-h6 text-weight-bold q-mb-md">Priority Performance</div>
        <div class="text-body2 text-grey-6 q-mb-lg">Completion rate by priority level</div>
        <div v-if="priorityPerformance.length" class="column q-gutter-sm">
          <div v-for="priority in priorityPerformance" :key="priority.priority" class="row items-center q-gutter-md">
            <div class="col-2"><q-icon :name="getPriorityIcon(priority.priority)" :color="getPriorityColor(priority.priority)" size="16px" /> <span class="text-capitalize text-weight-medium">{{ priority.priority }}</span></div>
            <div class="col-2 text-right">{{ priority.completed }}</div>
            <div class="col-2 text-right">{{ priority.delayed }}</div>
            <div class="col-4"><q-linear-progress :value="priority.completionRate / 100" :color="getPriorityColor(priority.priority)" rounded size="6px" track-color="grey-3" /></div>
            <div class="col-2 text-right">{{ formatMetric(priority.avgCompletionTime, ' days') }}</div>
          </div>
        </div>
        <div v-else class="text-grey-6">No priority data available.</div>
      </q-card>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { usePerformanceStore, type PerformanceRange } from '../stores/performanceStore';
import PerformanceStatCard from '../components/PerformanceStatCard.vue';
import PerformanceTrendChart from '../components/PerformanceTrendChart.vue';
import InsightsPanel from '../components/InsightsPanel.vue';
import WorkloadVsOutputCard from '../components/WorkloadVsOutputCard.vue';
import TimeAllocationDonut from '../components/TimeAllocationDonut.vue';
import DailyConsistencyHeatmap from '../components/DailyConsistencyHeatmap.vue';
import TaskQualityMetrics from '../components/TaskQualityMetrics.vue';

const performanceStore = usePerformanceStore();
const selectedPeriod = ref('This Month');
const periodOptions = ['This Week', 'This Month', 'Last 3 Months'];
const rangeMap: Record<string, PerformanceRange> = { 'This Week': 'this_week', 'This Month': 'this_month', 'Last 3 Months': 'last_3_months' };
const seriesConfig = [
  { key: 'assigned', label: 'Assigned', color: '#9e9e9e' },
  { key: 'completed', label: 'Completed', color: '#21ba45' },
  { key: 'delayed', label: 'Delayed', color: '#c10015' },
];

const hasPerformanceData = computed(() => {
  const summary = performanceStore.summary;
  return Boolean(summary && (summary.totalTasks > 0 || summary.hoursLogged > 0 || summary.dailyActivity?.some((item: any) => item.activity_count > 0)));
});

const statCards = computed(() => {
  const summary = performanceStore.summary || {};
  return [
    { label: 'Productivity Score', value: summary.productivityScore, suffix: '%', description: 'Completion and on-time delivery', icon: 'trending_up', color: 'primary', background: '#e3f2fd', sparklineData: [] },
    { label: 'Completion Rate', value: summary.completionRate, suffix: '%', description: 'Of assigned tasks', icon: 'check_circle', color: 'positive', background: '#e8f5e9', sparklineData: [] },
    { label: 'On-Time Rate', value: summary.onTimeRate, suffix: '%', description: 'Completed on schedule', icon: 'schedule', color: 'info', background: '#e3f2fd', sparklineData: [] },
    { label: 'Focus Score', value: summary.focusScore, suffix: '%', description: 'Weekdays with recorded activity', icon: 'local_fire_department', color: 'warning', background: '#fff3e0', sparklineData: [] },
  ];
});

const workloadItems = computed(() => {
  const summary = performanceStore.summary;
  if (!summary) return [];
  const estimated = Number(summary.estimatedHours || 0);
  const logged = Number(summary.hoursLogged || 0);
  const remaining = Number(summary.remainingHours || 0);
  const percentageOf = (value: number) => estimated ? Math.min(100, Math.round((value / estimated) * 100)) : 0;
  return [
    { label: 'Assigned Work', value: estimated, percentage: estimated ? 100 : 0, color: 'grey' },
    { label: 'Logged Work', value: logged, percentage: percentageOf(logged), color: 'positive' },
    { label: 'Remaining Work', value: remaining, percentage: percentageOf(remaining), color: 'primary' },
  ];
});

const timeCenterLabel = computed(() => `Total ${Number(performanceStore.summary?.hoursLogged || 0).toFixed(1)}h`);
const priorityPerformance = computed(() => performanceStore.priorityReport || []);

const qualityMetrics = computed(() => {
  const quality = performanceStore.summary?.qualityMetrics || {};
  return [
    { label: 'Reopened Tasks', value: formatMetric(quality.reopenedTasks), icon: 'refresh', color: 'warning', trend: 'Unavailable from current history', trendPositive: false },
    { label: 'Revision Requests', value: quality.revisionRequests, icon: 'edit', color: 'orange', trend: 'Recorded review requests', trendPositive: false },
    { label: 'First-Time Completion', value: formatMetric(quality.firstTimeCompletionRate, '%'), icon: 'check_circle', color: 'positive', trend: 'Based on review lifecycle', trendPositive: true },
    { label: 'Avg Subtask Accuracy', value: formatMetric(quality.avgSubtaskAccuracy, '%'), icon: 'done_all', color: 'info', trend: 'Unavailable from current schema', trendPositive: false },
  ];
});

const insights = computed(() => {
  const summary = performanceStore.summary;
  if (!summary) return [];
  const result = [];
  if (summary.completionRate > 0) result.push({ icon: 'check_circle', color: 'positive', text: `${summary.completedTasks} of ${summary.totalTasks} assigned tasks are complete.` });
  if (summary.overdueTasks > 0) result.push({ icon: 'warning', color: 'warning', text: `${summary.overdueTasks} assigned task${summary.overdueTasks === 1 ? '' : 's'} are overdue.` });
  if (!result.length) result.push({ icon: 'insights', color: 'info', text: 'Keep recording work to build a meaningful performance history.' });
  return result;
});

function formatMetric(value: unknown, suffix = '') {
  if (typeof value !== 'string' && typeof value !== 'number') return '--';
  return `${value}${suffix}`;
}

function loadPerformance() {
  return performanceStore.loadAll(rangeMap[selectedPeriod.value]);
}

function handlePeriodChange(value: string) {
  if (rangeMap[value]) {
    selectedPeriod.value = value;
    void loadPerformance();
  }
}

function getPriorityIcon(priority: string) {
  return { critical: 'flag', high: 'trending_up', medium: 'remove', low: 'trending_down' }[priority] || 'circle';
}

function getPriorityColor(priority: string) {
  return { critical: 'negative', high: 'warning', medium: 'primary', low: 'positive' }[priority] || 'grey';
}

onMounted(() => { void loadPerformance(); });
</script>