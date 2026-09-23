<template>
  <q-page class="q-pa-md analytics-page">
    <!-- Header -->
    <div class="row items-start justify-between q-mb-md">
      <div class="row items-center">
        <q-avatar
          color="indigo-1"
          text-color="indigo"
          icon="bar_chart"
          size="48px"
          class="q-mr-md"
          style="border-radius: 12px"
        />
        <div class="column">
          <div class="text-h5 text-weight-bold">Analytics & Reports</div>
          <div class="text-grey-7 text-caption">
            Track performance, progress and productivity across your workspace
          </div>
        </div>
      </div>
      <div class="column">
      <div class="column items-end">
        <div class="row items-center q-gutter-md q-mb-md">
          
          <q-avatar
  size="36px"
  class="cursor-pointer"
  clickable
  @click="$router.push('/dashboard/profile')"
>
  <img :src="authStore.currentUser?.avatar || 'https://cdn.quasar.dev/img/avatar.png'" />
</q-avatar>
        </div></div>
        <div class="row items-center q-mb-md" style="flex: 0 0 auto">
        
        <div class="row items-center q-gutter-x-sm q-ml-auto">
          <q-select
            v-model="filterMonth"
            outlined
            dense
            :options="['This Month', 'Last Month', 'This Quarter', 'This Year', 'All Time']"
            style="width: 140px"
            bg-color="white"
            rounded
          >
            <template v-slot:prepend><q-icon name="o_calendar_today" size="18px" /></template>
          </q-select>
          <q-btn
            unelevated
            color="indigo-5"
            icon="o_file_download"
            label="Export Report"
            no-caps
            class="rounded-borders"
            :loading="exporting"
            @click="exportReport"
          />
        </div>
      </div></div>
    </div>

    <!-- Summary Cards -->
    <div class="row q-col-gutter-md q-mb-lg">
      <div class="col">
        <StatCard
          title="Total Projects"
          :value="(analyticsStore.overview?.total_projects || 0).toString()"
          color="indigo"
          icon="o_folder"
          :caption="`${analyticsStore.overview?.active_projects || 0} active`"
        />
      </div>
      <div class="col">
        <StatCard
          title="Completion Rate"
          :value="`${analyticsStore.overview?.taskCompletionRate || 0}%`"
          color="green"
          icon="o_verified_user"
          :caption="`${analyticsStore.overview?.completed_tasks || 0} tasks completed`"
        />
      </div>
      <div class="col">
        <StatCard
          title="At Risk Tasks"
          :value="(analyticsStore.overview?.overdue_tasks || 0).toString()"
          color="orange"
          icon="o_warning_amber"
          caption="delayed"
        />
      </div>
      <div class="col">
        <StatCard
          title="Avg. Progress"
          :value="`${analyticsStore.overview?.avgProjectProgress || 0}%`"
          color="indigo"
          icon="o_pie_chart"
          caption="Across all projects"
        />
      </div>
      <div class="col">
        <StatCard
          title="Team Utilization"
          :value="`${analyticsStore.overview?.avgUtilization || 0}%`"
          color="blue"
          icon="o_groups"
          caption="average capacity"
        />
      </div>
    </div>

    <!-- Main Content Split -->
<div class="row q-col-gutter-lg">
  <!-- Left Column -->
  <div class="col-8 analytics-column">
    <ProjectProgressWidget />
    <ResourceWorkloadTable :compact="true" />
    <ProjectPerformanceTable />
  </div>

  <!-- Right Column -->
  <div class="col-4 analytics-column">
    <TaskCompletionTrend :data="analyticsStore.completionTrend" />
    <TaskStatusDistribution />
    <TaskPriorityDistribution />
    <UpcomingDeadlineRisks />
    <WorkloadScatterChart :resources="resourceStore.resources" />
  </div>
</div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';
import { useQuasar } from 'quasar';
import { useAuthStore } from '../stores/authStore';
import { useAnalyticsStore } from '../stores/analyticsStore';
import { useResourceStore } from '../stores/resourceStore';
import StatCard from '../components/StatCard.vue';
import ProjectProgressWidget from '../components/ProjectProgressWidget.vue';
import ResourceWorkloadTable from '../components/ResourceWorkloadTable.vue';
import ProjectPerformanceTable from '../components/ProjectPerformanceTable.vue';
import TaskStatusDistribution from '../components/TaskStatusDistribution.vue';
import TaskPriorityDistribution from '../components/TaskPriorityDistribution.vue';
import UpcomingDeadlineRisks from '../components/UpcomingDeadlineRisks.vue';
import PerformanceMeter from '../components/PerformanceMeter.vue';
import TaskCompletionTrend from '../components/TaskCompletionTrend.vue';
import WorkloadScatterChart from '../components/WorkloadScatterChart.vue';

const router = useRouter();
const authStore = useAuthStore();
const analyticsStore = useAnalyticsStore();
const resourceStore = useResourceStore();
const $q = useQuasar();

const searchQuery = ref('');
const filterMonth = ref('This Month');
const exporting = ref(false);

onMounted(() => {
  analyticsStore.loadAll('this_month');
  resourceStore.fetchResources();
});

watch(filterMonth, (period) => {
  const periodKey = {
    'This Month': 'this_month',
    'Last Month': 'last_month',
    'This Quarter': 'this_quarter',
    'This Year': 'this_year',
    'All Time': 'all_time',
  }[period];

  if (periodKey) {
    void analyticsStore.loadAll(periodKey);
  }
});

const logout = () => {
  authStore.logout();
  router.replace('/auth/login');
};

const exportReport = async () => {
  exporting.value = true;
  try {
    // Fetch fresh data directly - do NOT rely on store state
    const token = sessionStorage.getItem('tasky_token');
    const headers = {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    };
    
    // Fetch overview data
    const overviewResponse = await fetch(
      `http://localhost:3001/api/pm/analytics/overview?period=${encodeURIComponent(filterMonth.value)}`,
      { headers }
    );
    const overviewData = await overviewResponse.json();
    
    if (!overviewData.success || !overviewData.overview) {
      throw new Error('Failed to fetch overview data');
    }
    
    // Fetch project performance data
    const projectResponse = await fetch(
      'http://localhost:3001/api/pm/analytics/project-performance',
      { headers }
    );
    const projectData = await projectResponse.json();
    
    if (!projectData.success || !projectData.projects) {
      throw new Error('Failed to fetch project performance data');
    }
    
    // Use the fresh response data directly
    const overview = overviewData.overview;
    const projects = projectData.projects;
    
    const generatedAt = new Date().toLocaleString();

    const formatValue = (value: any, defaultValue = 'N/A', suffix = '', isCount = false) => {
      if (value === null || value === undefined || value === '' || value === 'Unknown') return defaultValue;
      if (isCount) return `${value}${suffix}`;
      if (value === 0) return defaultValue;
      return `${value}${suffix}`;
    };

    const rows = projects.map((project: any) => {
      const completionRate = project.total_tasks > 0 ? Math.round((project.completed_tasks / project.total_tasks) * 100) : 0;
      return `<tr><td><strong>${project.name || 'Unnamed project'}</strong></td>
      <td>${project.status || '—'}</td>
      <td>${formatValue(Math.round(project.progress), 'N/A', '%')}</td>
      <td>${formatValue(project.total_tasks, '0', '', true)}</td>
      <td>${formatValue(project.completed_tasks, '0', '', true)}</td>
      <td>${formatValue(completionRate, '0', '%')}</td>
      <td>${formatValue(project.overdue_tasks, '0', '', true)}</td>
      <td>${formatValue(project.total_hours_logged, '0', 'h', true)} / ${formatValue(project.total_estimated_hours, '0', 'h', true)}</td></tr>`;
    }).join('');

    const html = `<!doctype html><html><head><meta charset="utf-8"><title>TASKY Analytics Report</title><style>body{font:14px Arial;color:#263238;margin:48px}header{border-bottom:4px solid #3949ab;padding-bottom:18px;margin-bottom:28px}h1{color:#283593;margin:0 0 8px}.meta{color:#607d8b}.metrics{display:flex;gap:12px;margin:22px 0}.metric{border:1px solid #e0e5ef;border-radius:8px;padding:14px;min-width:130px}.metric b{display:block;font-size:22px;color:#3949ab;margin-top:6px}table{width:100%;border-collapse:collapse;margin-top:18px}th{background:#3949ab;color:white;text-align:left}th,td{padding:11px;border:1px solid #e0e5ef}tr:nth-child(even){background:#f6f8fc}footer{margin-top:36px;color:#78909c;font-size:12px}</style></head><body><header><h1>TASKY Analytics Report</h1><div class="meta">Reporting period: ${filterMonth.value} · Generated: ${generatedAt}</div></header><div class="metrics"><div class="metric">Total active projects<b>${formatValue(overview.total_projects, '0', '', true)}</b></div><div class="metric">Completion rate<b>${formatValue(overview.taskCompletionRate, '0', '%')}</b></div><div class="metric">Avg. progress<b>${formatValue(overview.avgProjectProgress, '0', '%')}</b></div><div class="metric">Team utilization<b>${formatValue(overview.avgUtilization, '0', '%')}</b></div></div><h2>Project Performance Details</h2><table><thead><tr><th>Project</th><th>Status</th><th>Progress</th><th>Total Tasks</th><th>Completed</th><th>Assigned Completion Rate</th><th>Overdue</th><th>Hours logged / estimated</th></tr></thead><tbody>${rows || '<tr><td colspan="8">No project performance data available.</td></tr>'}</tbody></table><footer>Prepared by TASKY · This report is generated from the workspace analytics dashboard.</footer></body></html>`;
    const blob = new Blob([html], { type: 'text/html;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `tasky-analytics-report-${new Date().toISOString().slice(0, 10)}.html`;
    link.click();
    URL.revokeObjectURL(url);
    $q.notify({ type: 'positive', message: 'Analytics report exported' });
  } catch (error) {
    console.error('Export error:', error);
    $q.notify({ type: 'negative', message: 'Failed to export report: ' + (error as Error).message });
  } finally {
    exporting.value = false;
  }
};
</script>

<style scoped>
/* Scrollbar styling */
.col-8::-webkit-scrollbar,
.col-4::-webkit-scrollbar {
  width: 6px;
}
.col-8::-webkit-scrollbar-track,
.col-4::-webkit-scrollbar-track {
  background: transparent;
}
.col-8::-webkit-scrollbar-thumb,
.col-4::-webkit-scrollbar-thumb {
  background: var(--analytics-scrollbar-thumb, #cbd5e1);
  border-radius: 4px;
}
.col-8::-webkit-scrollbar-thumb:hover,
.col-4::-webkit-scrollbar-thumb:hover {
  background: var(--analytics-scrollbar-thumb-hover, #94a3b8);
}

:deep(.q-field--dense .q-field__bottom) {
  display: none;
}
:deep(.q-field--outlined .q-field__control) {
  padding: 0 12px;
}


/* Keep scrollbars readable in both themes. */
:global(body.body--dark) .analytics-page {
  --analytics-scrollbar-thumb: #46555e;
  --analytics-scrollbar-thumb-hover: #5b6c76;
}

.analytics-column {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

</style>
