<template>
  <q-page class="bg-grey-1 q-pa-lg">
    <!-- HEADER -->
    <div class="row items-center justify-between q-mb-lg">
      <div>
        <div class="text-h4 text-weight-bold">My Performance</div>
        <div class="text-body1 text-grey-6">
          Track your productivity, consistency, and delivery quality over time.
        </div>
      </div>
      <div class="row q-gutter-sm">
        <q-select
          v-model="selectedPeriod"
          :options="periodOptions"
          outlined
          dense
          style="width: 140px"
          @update:model-value="handlePeriodChange"
        />
        <q-btn unelevated color="primary" icon="download" label="Export Report" />
        <q-btn outline icon="share" label="Share Summary" />
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="performanceStore.loading" class="flex flex-center" style="min-height: 400px">
      <q-spinner-dots size="40px" color="primary" />
    </div>

    <!-- Error State -->
    <q-banner v-else-if="performanceStore.error" class="bg-negative text-white" dense rounded>
      <template v-slot:avatar>
        <q-icon name="error" />
      </template>
      Error loading performance data: {{ performanceStore.error }}
    </q-banner>

    <!-- Main Content -->
    <div v-else class="column q-gutter-lg">
      <!-- Performance Stat Cards -->
      <div class="row q-col-gutter-md">
        <div class="col-12 col-sm-6 col-md-3">
          <PerformanceStatCard
            label="Productivity Score"
            :value="performanceStore.summary?.productivityScore || 0"
            description="Overall performance metric"
            icon="trending_up"
            color="primary"
            background="#e3f2fd"
            trend="+12% vs last month"
            :positive="true"
            :sparkline-data="generateSparklineData('productivity')"
          />
        </div>
        <div class="col-12 col-sm-6 col-md-3">
          <PerformanceStatCard
            label="Completion Rate"
            :value="`${performanceStore.summary?.completionRate || 0}%`"
            description="Of assigned tasks"
            icon="check_circle"
            color="positive"
            background="#e8f5e9"
            trend="+6% vs last month"
            :positive="true"
            :sparkline-data="generateSparklineData('completion')"
          />
        </div>
        <div class="col-12 col-sm-6 col-md-3">
          <PerformanceStatCard
            label="On-Time Rate"
            :value="`${performanceStore.summary?.onTimeRate || 0}%`"
            description="Completed on schedule"
            icon="schedule"
            color="info"
            background="#e3f2fd"
            trend="+3% vs last month"
            :positive="true"
            :sparkline-data="generateSparklineData('ontime')"
          />
        </div>
        <div class="col-12 col-sm-6 col-md-3">
          <PerformanceStatCard
            label="Focus Score"
            :value="performanceStore.summary?.focusScore || 0"
            description="Consistency metric"
            icon="local_fire_department"
            color="warning"
            background="#fff3e0"
            trend="+8% vs last month"
            :positive="true"
            :sparkline-data="generateSparklineData('focus')"
          />
        </div>
      </div>

      <!-- Productivity Trend -->
      <div class="col-12">
        <PerformanceTrendChart
          title="Productivity Trend"
          subtitle="Tasks completed vs assigned"
          :data="performanceStore.trend"
          :series-config="[
            { key: 'assigned', label: 'Assigned', color: '#9e9e9e' },
            { key: 'completed', label: 'Completed', color: '#21ba45' },
            { key: 'delayed', label: 'Delayed', color: '#c10015' },
          ]"
          @period-change="handleTrendPeriodChange"
        />
      </div>

      <!-- Performance Insights -->
      <div class="col-12">
        <InsightsPanel
          title="Performance Insights"
          subtitle="AI-powered insights for you"
          :insights="insights"
        />
      </div>

      <!-- Workload vs Output and Time Allocation -->
      <div class="row q-col-gutter-md">
        <div class="col-12 col-md-6">
          <WorkloadVsOutputCard
            title="Workload vs Output"
            subtitle="How much work you received vs completed"
            :workload-items="workloadItems"
            :efficiency="performanceStore.summary?.efficiency || 0"
            efficiency-message="You are 16% more efficient than last month"
            @period-change="handleWorkloadPeriodChange"
          />
        </div>
        <div class="col-12 col-md-6">
          <TimeAllocationDonut
            title="Time Allocation"
            subtitle="Where your time is spent"
            :data="timeAllocationData"
            center-label="Total 49h"
            @period-change="handleTimeAllocationPeriodChange"
          />
        </div>
      </div>

      <!-- Daily Consistency and Task Quality Metrics -->
      <div class="row q-col-gutter-md">
        <div class="col-12 col-md-6">
          <DailyConsistencyHeatmap
            title="Daily Consistency"
            subtitle="Your daily activity and updates"
            :data="performanceStore.summary?.dailyActivity || []"
            @period-change="handleConsistencyPeriodChange"
          />
        </div>
        <div class="col-12 col-md-6">
          <TaskQualityMetrics
            title="Task Quality Metrics"
            subtitle="Quality of your deliverables"
            :metrics="qualityMetrics"
          />
        </div>
      </div>

      <!-- Priority Performance -->
      <div class="col-12">
        <q-card flat bordered class="q-pa-lg">
          <div class="text-h6 text-weight-bold q-mb-md">Priority Performance</div>
          <div class="text-body2 text-grey-6 q-mb-lg">Completion rate by priority level</div>

          <div class="column q-gutter-sm">
            <div
              v-for="priority in priorityPerformance"
              :key="priority.priority"
              class="row items-center q-gutter-md"
            >
              <div class="col-2">
                <div class="row items-center q-gutter-xs">
                  <q-icon
                    :name="getPriorityIcon(priority.priority)"
                    :color="getPriorityColor(priority.priority)"
                    size="16px"
                  />
                  <span class="text-capitalize text-weight-medium">{{ priority.priority }}</span>
                </div>
              </div>
              <div class="col-2 text-right">
                <span class="text-body2">{{ priority.completed }}</span>
              </div>
              <div class="col-2 text-right">
                <span class="text-body2">{{ priority.delayed }}</span>
              </div>
              <div class="col-4">
                <q-linear-progress
                  :value="priority.completionRate / 100"
                  :color="getPriorityColor(priority.priority)"
                  rounded
                  size="6px"
                  track-color="grey-3"
                />
              </div>
              <div class="col-2 text-right">
                <span class="text-body2 text-weight-medium"
                  >{{ priority.avgCompletionTime }} days</span
                >
              </div>
            </div>
          </div>

          <div class="q-mt-md">
            <router-link to="/employee/performance/priority-report">
              <q-btn
                flat
                color="primary"
                icon="arrow_forward"
                label="View detailed priority report"
              />
            </router-link>
          </div>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { usePerformanceStore } from '../stores/performanceStore';
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

const insights = computed(() => {
  const summary = performanceStore.summary;
  if (!summary) return [];

  const insightsList = [];

  // Generate insights based on data
  if (summary.productivityScore > 80) {
    insightsList.push({
      icon: 'check_circle',
      color: 'positive',
      text: 'Strongest Area: Overall productivity is excellent this month.',
    });
  }

  if (summary.onTimeRate < 85) {
    insightsList.push({
      icon: 'warning',
      color: 'warning',
      text: 'Needs Attention: Improve on-time delivery rate by planning ahead.',
    });
  }

  insightsList.push({
    icon: 'lightbulb',
    color: 'info',
    text: 'Improvement Tip: Consider breaking down large tasks into smaller subtasks.',
  });

  return insightsList;
});

const workloadItems = computed(() => {
  const summary = performanceStore.summary;
  if (!summary) return [];

  const totalEstimated = summary.totalEstimatedHours || 1;
  const totalLogged = summary.totalHoursLogged || 0;
  const remaining = Math.max(0, totalEstimated - totalLogged);

  return [
    {
      label: 'Assigned Work',
      value: totalEstimated,
      percentage: Math.round((totalEstimated / totalEstimated) * 100),
      color: 'grey',
    },
    {
      label: 'Completed Work',
      value: totalLogged,
      percentage: Math.round((totalLogged / totalEstimated) * 100),
      color: 'positive',
    },
    {
      label: 'Remaining Work',
      value: remaining,
      percentage: Math.round((remaining / totalEstimated) * 100),
      color: 'primary',
    },
  ];
});

const timeAllocationData = computed(() => {
  const summary = performanceStore.summary;
  if (!summary || !summary.timeAllocation) return [];

  return summary.timeAllocation.map((item: any) => ({
    label: item.project_name,
    value: item.hours_spent,
    percentage: item.percentage,
    color: item.project_color || '#1976d2',
  }));
});

const qualityMetrics = computed(() => {
  const summary = performanceStore.summary;
  if (!summary || !summary.qualityMetrics) return [];

  const quality = summary.qualityMetrics;
  return [
    {
      label: 'Reopened Tasks',
      value: quality.reopenedTasks,
      icon: 'refresh',
      color: 'warning',
      trend: '+2 vs last month',
      trendPositive: false,
    },
    {
      label: 'Revision Requests',
      value: quality.revisionRequests,
      icon: 'edit',
      color: 'orange',
      trend: '+1 vs last month',
      trendPositive: false,
    },
    {
      label: 'First-Time Completion',
      value: `${quality.firstTimeCompletionRate}%`,
      icon: 'check_circle',
      color: 'positive',
      trend: '+6% vs last month',
      trendPositive: true,
    },
    {
      label: 'Avg Subtask Accuracy',
      value: `${quality.avgSubtaskAccuracy}%`,
      icon: 'done_all',
      color: 'info',
      trend: '+4% vs last month',
      trendPositive: true,
    },
  ];
});

const priorityPerformance = computed(() => {
  // Use data from performanceStore.priorityReport
  if (performanceStore.priorityReport) {
    return performanceStore.priorityReport;
  }
  
  // Calculate from summary data if priority report not available
  const summary = performanceStore.summary;
  if (!summary) return [];
  
  // Return empty array until data is loaded
  return [];
});

function generateSparklineData(type: string): number[] {
  // Use trend data from performanceStore if available
  if (performanceStore.trend && performanceStore.trend.length > 0) {
    const trendData = performanceStore.trend;
    
    switch (type) {
      case 'productivity':
        return trendData.map((t: any) => t.productivityScore || 0);
      case 'completion':
        return trendData.map((t: any) => t.completionRate || 0);
      case 'ontime':
        return trendData.map((t: any) => t.onTimeRate || 0);
      case 'focus':
        return trendData.map((t: any) => t.focusScore || 0);
      default:
        return [];
    }
  }
  
  // Return empty array until data is loaded
  return [];
}

function handlePeriodChange(value: string) {
  const rangeMap: Record<string, string> = {
    'This Week': 'this_week',
    'This Month': 'this_month',
    'Last 3 Months': 'last_3_months',
  };
  performanceStore.fetchSummary(rangeMap[value]);
  performanceStore.fetchTrend(rangeMap[value]);
}

function handleTrendPeriodChange(value: string) {
  const rangeMap: Record<string, string> = {
    Weekly: 'this_week',
    Monthly: 'this_month',
  };
  performanceStore.fetchTrend(rangeMap[value]);
}

function handleWorkloadPeriodChange(value: string) {
  // Reload summary data for the new period
  handlePeriodChange(value);
}

function handleTimeAllocationPeriodChange(value: string) {
  // Reload summary data for the new period
  handlePeriodChange(value);
}

function handleConsistencyPeriodChange(value: string) {
  // Reload summary data for the new period
  handlePeriodChange(value);
}

function getPriorityIcon(priority: string): string {
  const iconMap: Record<string, string> = {
    critical: 'flag',
    high: 'trending_up',
    medium: 'remove',
    low: 'trending_down',
  };
  return iconMap[priority] || 'circle';
}

function getPriorityColor(priority: string): string {
  const colorMap: Record<string, string> = {
    critical: 'negative',
    high: 'warning',
    medium: 'primary',
    low: 'positive',
  };
  return colorMap[priority] || 'grey';
}

onMounted(() => {
  performanceStore.loadAll();
});
</script>