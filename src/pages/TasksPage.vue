<template>
  <q-page
    class="q-pa-md text-black"
    style="
      background-color: #f8f9fa;
    "
  >
    <!-- Header -->
    <div class="row items-start justify-between q-mb-md" style="flex: 0 0 auto">
      <div class="row items-center">
        <q-avatar
          color="indigo-1"
          text-color="indigo"
          icon="o_calendar_today"
          size="48px"
          class="q-mr-md"
          style="border-radius: 12px"
        />
        <div class="column">
          <div class="text-h5 text-weight-bold">Tasks</div>
          <div class="text-grey-7 text-caption">View and manage all tasks across your projects</div>
        </div>
      </div>
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
        </div>
        <q-btn
          unelevated
          color="indigo"
          icon="add"
          label="New Task"
          no-caps
          class="rounded-borders"
          @click="openCreateDialog"
        />
      </div>
    </div>

    <!-- Summary Stats -->
    <div class="row q-gutter-x-lg q-mb-md" style="flex: 0 0 auto">
      <div class="row items-center">
        <q-icon name="o_schedule" color="blue-grey" size="20px" class="q-mr-xs" />
        <div class="text-weight-bold q-mr-sm">{{ taskStore.stats.notStarted || 0 }}</div>
        <div class="text-caption text-grey-7">Not Started</div>
      </div>
      <div class="row items-center">
        <q-icon name="o_play_circle_outline" color="blue" size="20px" class="q-mr-xs" />
        <div class="text-weight-bold text-blue q-mr-sm">{{ taskStore.stats.inProgress || 0 }}</div>
        <div class="text-caption text-grey-7">In Progress</div>
      </div>
      <div class="row items-center">
        <q-icon name="o_warning_amber" color="red" size="20px" class="q-mr-xs" />
        <div class="text-weight-bold text-red q-mr-sm">{{ taskStore.stats.overdue || 0 }}</div>
        <div class="text-caption text-grey-7">Overdue</div>
      </div>
      <div class="row items-center">
        <q-icon name="o_check_circle" color="green" size="20px" class="q-mr-xs" />
        <div class="text-weight-bold text-green q-mr-sm">{{ taskStore.stats.completed || 0 }}</div>
        <div class="text-caption text-grey-7">Completed</div>
      </div>

    </div>

    <!-- Toolbar -->
    <div class="row items-center q-mb-md" style="flex: 0 0 auto">
    <q-input
            v-model="filters.search"
            outlined
            dense
            rounded
            bg-color="white"
            placeholder="Search tasks, descriptions..."
            style="width: 320px"
            @update:model-value="applyFilters"
          >
            <template v-slot:prepend>
              <q-icon name="search" />
            </template>
          </q-input>
      <div class="row items-center q-gutter-x-sm q-ml-auto">
        <q-select
          v-model="filters.project"
          outlined
          dense
          :options="projectOptions"
          style="width: 150px"
          bg-color="white"
          rounded
          emit-value
          map-options
          @update:model-value="applyFilters"
        >
          <template v-slot:prepend><q-icon name="o_folder" size="17px" /></template>
        </q-select>
        <q-select
          v-model="filters.status"
          outlined
          dense
          :options="statusOptions"
          style="width: 150px"
          bg-color="white"
          rounded
          emit-value
          map-options
          @update:model-value="applyFilters"
        >
          <template v-slot:prepend><q-icon name="o_settings" size="17px" /></template>
        </q-select>
        <q-select
          v-model="filters.priority"
          outlined
          dense
          :options="priorityOptions"
          style="width: 150px"
          bg-color="white"
          rounded
          emit-value
          map-options
          @update:model-value="applyFilters"
        >
          <template v-slot:prepend><q-icon name="o_flag" size="17px" /></template>
        </q-select>
        <q-select
  v-model="filters.assignee"
  outlined
  dense
  :options="assigneeOptions"
  style="width: 150px"
  bg-color="white"
  rounded
  emit-value
  map-options
  @update:model-value="applyFilters"
>
  <template v-slot:prepend>
    <q-icon name="o_person" size="17px" />
  </template>
</q-select>

<q-select
  v-model="filters.deadline"
  outlined
  dense
  :options="deadlineOptions"
  style="width: 150px"
  bg-color="white"
  rounded
  emit-value
  map-options
  @update:model-value="applyFilters"
>
  <template v-slot:prepend>
    <q-icon name="o_event" size="17px" />
  </template>
</q-select>
      </div>

      <div class="row items-center q-gutter-x-sm">
        <q-btn
          v-if="hasActiveFilters"
          flat
          color="grey-7"
          icon="o_filter_alt_off"
          label="Clear Filters"
          no-caps
          size="sm"
          class="bg-white rounded-borders q-px-sm"
          style="border: 1px solid #e0e0e0"
          @click="clearFilters"
        />
      </div>
    </div>

    <!-- Data Table -->
    <div class="row items-center justify-between q-mb-md" style="flex: 0 0 auto">
    <TasksTable
      @edit="openEditDialog"
      @delete="confirmDelete"
      @view="openTaskDetail"
      @assign-reviewer="openAssignReviewerDialog"
      @finalize-review="openFinalizeReviewDialog"
      @send-comment="openSendCommentDialog"
    />
    </div>

    <div class="row q-col-gutter-lg items-stretch">
      <!-- Left Column -->
      <div class="col-5">
        <ProjectProgressWidget style="height: 100%; margin-bottom: 0;" />
      </div>

      <!-- Right Column -->
      <div class="col-4">
        <TaskStatusDistribution style="height: 100%; margin-bottom: 0;" />
      </div>

      <div class="col-3">
        <ProjectSummary
          style="height: 100%; margin-bottom: 0;"
          :projects="analyticsStore.projectProgress"
          :deadline-risks="analyticsStore.deadlineRisks"
          :in-progress-tasks="analyticsStore.taskDistribution?.status?.['in-progress'] || 0"
          :team-utilization="analyticsStore.overview?.avgUtilization || null"
          @view-report="exportReport"
        />
      </div>
    </div>


    <!-- Dialogs -->
    <CreateTaskDialog v-model="showCreateDialog" :task-to-edit="taskToEdit" @saved="onTaskSaved" />
    <TaskDetailDialog
      v-model="showDetailDialog"
      :task-id="selectedTaskId"
      @edit="openEditDialog"
      @deleted="onTaskDeleted"
    />
    <SendCommentDialog
      v-model="showSendCommentDialog"
      :prefilled-task="selectedTaskForComment"
    />

    <!-- Assign Reviewer Dialog -->
    <q-dialog v-model="showAssignReviewerDialog">
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6">Assign Reviewer</div>
        </q-card-section>
        <q-card-section>
          <div class="q-mb-md">
            <div class="text-subtitle2 q-mb-sm">Task: {{ selectedTaskForReview?.title }}</div>
            <div class="text-caption text-grey-7">
              Select a colleague to review this completed task
            </div>
          </div>
          <q-select
            v-model="selectedReviewerId"
            :options="employeeOptions"
            label="Select Reviewer"
            outlined
            emit-value
            map-options
          />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Assign" @click="assignReviewer" :loading="assigning" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Finalize Review Dialog -->
    <q-dialog v-model="showFinalizeReviewDialog">
      <q-card style="min-width: 500px">
        <q-card-section>
          <div class="text-h6">Finalize Review</div>
        </q-card-section>
        <q-card-section>
          <div class="q-mb-md">
            <div class="text-subtitle2">Task: {{ selectedTaskForFinalize?.title }}</div>
            <div class="text-caption text-grey-7 q-mb-sm">
              Reviewer: {{ selectedTaskForFinalize?.reviewer_first_name }}
              {{ selectedTaskForFinalize?.reviewer_last_name }}
            </div>
            <div class="text-caption text-grey-7 q-mb-md">
              Review Comment: {{ selectedTaskForFinalize?.review_comment }}
            </div>
          </div>
          <q-input
            v-model="pmFinalComment"
            label="Final PM Comment"
            type="textarea"
            outlined
            rows="3"
            hint="This comment will be visible to both the task owner and reviewer"
          />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Finalize" @click="finalizeReview" :loading="finalizing" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '../stores/authStore';
import { usePmTaskStore } from '../stores/pmTaskStore';
import { useProjectStore } from '../stores/projectStore';
import { useTaskStore } from '../stores/taskStore';
import { useQuasar } from 'quasar';
import TasksTable from '../components/TasksTable.vue';
import CreateTaskDialog from '../components/CreateTaskDialog.vue';
import TaskDetailDialog from '../components/TaskDetailDialog.vue';
import ProjectProgressWidget from '../components/ProjectProgressWidget.vue';
import TaskStatusDistribution from '../components/TaskStatusDistribution.vue';
import ProjectSummary from '../components/ProjectSummary.vue';
import SendCommentDialog from '../components/SendCommentDialog.vue';
import { useOrgStore } from '../stores/orgStore';
import { useAnalyticsStore } from '../stores/analyticsStore';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();
const taskStore = usePmTaskStore();
const projectStore = useProjectStore();
const taskStoreCommon = useTaskStore();
const $q = useQuasar();
const orgStore = useOrgStore();
const analyticsStore = useAnalyticsStore();

const exportReport = () => {
  const projects = analyticsStore.projectProgress || [];
  const risks = analyticsStore.deadlineRisks || [];

  const escapeHtml = (value: unknown) => {
    const text =
      typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean'
        ? String(value)
        : '';

    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  };

  const formatValue = (value: unknown, defaultValue = 'N/A') => {
    if (value === null || value === undefined || value === '' || value === 'Unknown') {
      return defaultValue;
    }
    return escapeHtml(value);
  };

  const projectRows = projects
    .map((project: any) => {
      const progress = project.progress !== null && project.progress !== undefined ? `${project.progress}%` : 'N/A';
      return `<tr><td><strong>${formatValue(project.project_name || project.name, 'Unnamed Project')}</strong></td><td>${formatValue(project.status, 'Not Specified')}</td><td>${escapeHtml(progress)}</td></tr>`;
    })
    .join('');

  const riskRows = risks
    .map((risk: any) => {
      const days = risk.days_until !== undefined && risk.days_until !== null ? risk.days_until : 'N/A';
      return `<tr><td>${formatValue(risk.task_title || risk.title, 'Unnamed Task')}</td><td>${formatValue(risk.risk_level, 'Not Specified')}</td><td>${escapeHtml(days)}</td></tr>`;
    })
    .join('');

  const generatedAt = new Date().toLocaleString();
  const html = `<!doctype html><html><head><meta charset="utf-8"><title>TASKY Project Report</title><style>body{font:14px Arial;color:#263238;margin:48px}header{border-bottom:4px solid #3949ab;padding-bottom:18px;margin-bottom:28px}h1{color:#283593;margin:0 0 8px}.meta{color:#607d8b}.metrics{display:flex;gap:12px;margin:22px 0}.metric{border:1px solid #e0e5ef;border-radius:8px;padding:14px;min-width:130px}.metric b{display:block;font-size:22px;color:#3949ab;margin-top:6px}table{width:100%;border-collapse:collapse;margin:18px 0 28px}th{background:#3949ab;color:white;text-align:left}th,td{padding:11px;border:1px solid #e0e5ef}tr:nth-child(even){background:#f6f8fc}footer{margin-top:36px;color:#78909c;font-size:12px}</style></head><body><header><h1>TASKY Project Report</h1><div class="meta">Generated: ${escapeHtml(generatedAt)}</div></header><div class="metrics"><div class="metric">Projects<b>${projects.length}</b></div><div class="metric">Deadline risks<b>${risks.length}</b></div><div class="metric">In-progress tasks<b>${escapeHtml(analyticsStore.overview?.taskDistribution?.status?.['in-progress'] ?? 0)}</b></div></div><h2>Project Progress</h2><table><thead><tr><th>Project</th><th>Status</th><th>Progress</th></tr></thead><tbody>${projectRows || '<tr><td colspan="3">No project progress data available.</td></tr>'}</tbody></table><h2>Deadline Risks</h2><table><thead><tr><th>Task</th><th>Risk</th><th>Days Remaining</th></tr></thead><tbody>${riskRows || '<tr><td colspan="3">No deadline risks identified.</td></tr>'}</tbody></table><footer>Prepared by TASKY from the project manager task dashboard.</footer></body></html>`;

  const blob = new Blob([html], { type: 'text/html;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `tasky-project-report-${new Date().toISOString().slice(0, 10)}.html`;
  link.click();
  URL.revokeObjectURL(url);
  $q.notify({ type: 'positive', message: 'Project report exported' });
};

const filters = ref({
  search: (route.query.search as string) || '',
  project: 'all',
  status: 'all',
  priority: 'all',
  assignee: 'all',
  deadline: 'all',
});

const statusOptions = [
  { label: 'All Statuses', value: 'all' },
  { label: 'Not Started', value: 'not-started' },
  { label: 'In Progress', value: 'in-progress' },
  { label: 'Completed (Reviewed)', value: 'completed-reviewed' },
  { label: 'Blocked', value: 'blocked' },
];

const priorityOptions = [
  { label: 'All Priorities', value: 'all' },
  { label: 'Critical', value: 'critical' },
  { label: 'High', value: 'high' },
  { label: 'Medium', value: 'medium' },
  { label: 'Low', value: 'low' },
];

const assigneeOptions = computed(() => {
  const opts = [{ label: 'All Assignees', value: 'all' }];

  orgStore.members.forEach((member: any) => {
    opts.push({
      label: `${member.first_name} ${member.last_name}`,
      value: member.id,
    });
  });

  return opts;
});

const deadlineOptions = [
  { label: 'All Deadlines', value: 'all' },
  { label: 'Overdue', value: 'overdue' },
  { label: 'Due Today', value: 'today' },
  { label: 'Next 7 Days', value: 'next-7-days' },
  { label: 'Next 30 Days', value: 'next-30-days' },
];

const projectOptions = computed(() => {
  const opts = [{ label: 'All Projects', value: 'all' }];
  projectStore.projects.forEach((p: any) => {
    opts.push({ label: p.name, value: p.id });
  });
  return opts;
});

const hasActiveFilters = computed(() => {
  return (
    filters.value.search !== '' ||
    filters.value.project !== 'all' ||
    filters.value.status !== 'all' ||
    filters.value.priority !== 'all' ||
    filters.value.assignee !== 'all' ||
    filters.value.deadline !== 'all'
  );
});

onMounted(async () => {
  console.log('TasksPage mounted');
  console.log('Auth token exists:', !!authStore.token);
  if (projectStore.projects.length === 0) {
    console.log('Fetching projects for task page');
    await projectStore.fetchProjects();
  }
  console.log('Fetching tasks with filters:', filters.value);
  if (orgStore.members.length === 0) {
  await orgStore.fetchMembers();
}
  await Promise.all([
    applyFilters(),
    analyticsStore.loadAll()
  ]);
  console.log('Tasks loaded:', taskStore.tasks.length);
  console.log('Tasks stats:', taskStore.stats);

  // If instructed to open a specific task by URL
  if (route.query.open) {
    selectedTaskId.value = route.query.open as string;
    showDetailDialog.value = true;
  }
});

const applyFilters = async () => {
  await taskStore.fetchTasks(filters.value);
};

const clearFilters = () => {
  filters.value = {
    search: '',
    project: 'all',
    status: 'all',
    priority: 'all',
    assignee: 'all',
    deadline: 'all',
  };

  applyFilters();
};

const logout = () => {
  authStore.logout();
  router.replace('/auth/login');
};

// Dialogs
const showCreateDialog = ref(false);
const showDetailDialog = ref(false);
const showSendCommentDialog = ref(false);
const taskToEdit = ref(null);
const selectedTaskId = ref('');
const selectedTaskForComment = ref<any>(null);

const openCreateDialog = () => {
  taskToEdit.value = null;
  showCreateDialog.value = true;
};

const openSendCommentDialog = (task: any) => {
  selectedTaskForComment.value = task;
  showSendCommentDialog.value = true;
};

const openEditDialog = (task: any) => {
  taskToEdit.value = task;
  showCreateDialog.value = true;
};

const openTaskDetail = (task: any) => {
  selectedTaskId.value = task.id;
  showDetailDialog.value = true;
};

const onTaskSaved = () => {
  applyFilters();
};

const onTaskDeleted = () => {
  applyFilters();
};

const confirmDelete = (task: any) => {
  $q.dialog({
    title: 'Confirm Deletion',
    message: `Are you sure you want to delete "${task.title}"?`,
    cancel: true,
    persistent: true,
    color: 'red',
  }).onOk(async () => {
    try {
      await taskStore.deleteTask(task.id);
      $q.notify({ type: 'positive', message: 'Task deleted' });
      applyFilters();
    } catch (err: any) {
      $q.notify({ type: 'negative', message: err.message || 'Error deleting task' });
    }
  });
};

// Review workflow
const showAssignReviewerDialog = ref(false);
const showFinalizeReviewDialog = ref(false);
const selectedTaskForReview = ref<any>(null);
const selectedTaskForFinalize = ref<any>(null);
const selectedReviewerId = ref<number | null>(null);
const pmFinalComment = ref('');
const assigning = ref(false);
const finalizing = ref(false);

const employeeOptions = computed(() => {
  return taskStoreCommon.employees
    .filter((e: any) => e.id !== authStore.user?.id)
    .map((e: any) => ({ label: `${e.first_name} ${e.last_name}`, value: e.id }));
});

const openAssignReviewerDialog = async (task: any) => {
  selectedTaskForReview.value = task;
  selectedReviewerId.value = null;
  await taskStoreCommon.fetchEmployees();
  showAssignReviewerDialog.value = true;
};

const assignReviewer = async () => {
  if (!selectedReviewerId.value || !selectedTaskForReview.value) return;

  assigning.value = true;
  try {
    const response = await fetch(
      `http://localhost:3001/api/employee/tasks/${selectedTaskForReview.value.id}/submit-review`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
        body: JSON.stringify({
          completion_comment: 'Task completed by employee',
          reviewer_id: selectedReviewerId.value,
        }),
      },
    );

    const data = await response.json();
    if (data.success) {
      $q.notify({ type: 'positive', message: 'Reviewer assigned successfully' });
      showAssignReviewerDialog.value = false;
      applyFilters();
    } else {
      $q.notify({ type: 'negative', message: data.error || 'Error assigning reviewer' });
    }
  } catch (err: any) {
    $q.notify({ type: 'negative', message: err.message || 'Error assigning reviewer' });
  } finally {
    assigning.value = false;
  }
};

const openFinalizeReviewDialog = (task: any) => {
  selectedTaskForFinalize.value = task;
  pmFinalComment.value = '';
  showFinalizeReviewDialog.value = true;
};

const finalizeReview = async () => {
  if (!selectedTaskForFinalize.value) return;

  finalizing.value = true;
  try {
    const response = await fetch(
      `http://localhost:3001/api/pm/tasks/${selectedTaskForFinalize.value.id}/finalize-review`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
        body: JSON.stringify({
          pm_final_comment: pmFinalComment.value,
        }),
      },
    );

    const data = await response.json();
    if (data.success) {
      $q.notify({ type: 'positive', message: 'Review finalized successfully' });
      showFinalizeReviewDialog.value = false;
      applyFilters();
    } else {
      $q.notify({ type: 'negative', message: data.error || 'Error finalizing review' });
    }
  } catch (err: any) {
    $q.notify({ type: 'negative', message: err.message || 'Error finalizing review' });
  } finally {
    finalizing.value = false;
  }
};
</script>

<style scoped>
:deep(.q-field--dense .q-field__bottom) {
  display: none;
}
:deep(.q-field--outlined .q-field__control) {
  padding: 0 12px;
}
</style>
