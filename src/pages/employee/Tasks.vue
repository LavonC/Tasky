<template>
  <q-page class="q-pa-md text-black">
    <!-- Header -->
    <div class="row items-center justify-between q-mb-md">
      <div class="column">
        <div class="text-h5 text-weight-bold">Task Manager</div>
        <div class="text-grey-7 text-caption">Manage your assigned tasks</div>
      </div>
      <div class="row items-center q-gutter-sm">
        <q-btn
          color="primary"
          label="Automate Schedule"
          icon="auto_fix_high"
          @click="automateSchedule"
          :loading="automating"
        />
        <q-input
          v-model="searchQuery"
          outlined
          dense
          rounded
          bg-color="white"
          placeholder="Search tasks..."
          style="width: 250px"
        >
          <template v-slot:prepend>
            <q-icon name="search" />
          </template>
        </q-input>
      </div>
    </div>

    <!-- Filters -->
    <div class="row q-col-gutter-sm q-mb-md">
      <div class="col-3">
        <q-select
          v-model="statusFilter"
          :options="statusOptions"
          label="Status"
          outlined
          dense
          emit-value
          map-options
          clearable
        />
      </div>
      <div class="col-3">
        <q-select
          v-model="priorityFilter"
          :options="priorityOptions"
          label="Priority"
          outlined
          dense
          emit-value
          map-options
          clearable
        />
      </div>
      <div class="col-3">
        <q-select
          v-model="projectFilter"
          :options="projectOptions"
          label="Project"
          outlined
          dense
          emit-value
          map-options
          clearable
        />
      </div>
      <div class="col-3">
        <q-btn color="primary" label="Apply Filters" @click="applyFilters" class="full-height" />
      </div>
    </div>

    <!-- Tasks Table -->
    <q-card>
      <q-card-section>
        <div class="text-h6 text-weight-bold">My Tasks ({{ filteredTasks.length }})</div>
      </q-card-section>
      <q-card-section>
        <q-table
          :rows="filteredTasks"
          :columns="columns"
          row-key="id"
          flat
          bordered
          :loading="loading"
        >
          <template v-slot:body-cell-title="props">
            <q-td :props="props">
              <div class="text-weight-bold">{{ props.row.title }}</div>
              <div class="text-caption text-grey-7">{{ props.row.description }}</div>
            </q-td>
          </template>

          <template v-slot:body-cell-project="props">
            <q-td :props="props">
              <div>{{ getProjectName(props.row.project_id) }}</div>
            </q-td>
          </template>

          <template v-slot:body-cell-priority="props">
            <q-td :props="props">
              <q-badge
                :color="`${getPriorityColor(props.row.priority)}-1`"
                :text-color="getPriorityColor(props.row.priority)"
              >
                {{ props.row.priority }}
              </q-badge>
            </q-td>
          </template>

          <template v-slot:body-cell-status="props">
            <q-td :props="props">
              <q-badge
                :color="`${getStatusColor(props.row.status)}-1`"
                :text-color="getStatusColor(props.row.status)"
              >
                {{ props.row.status }}
              </q-badge>
            </q-td>
          </template>

          <template v-slot:body-cell-progress="props">
            <q-td :props="props">
              <q-linear-progress
                :value="props.row.progress / 100"
                :color="props.row.progress === 100 ? 'green' : 'primary'"
                size="8px"
              />
              <div class="text-caption q-mt-xs">{{ props.row.progress }}%</div>
            </q-td>
          </template>

          <template v-slot:body-cell-deadline="props">
            <q-td :props="props">
              <div
                :class="{
                  'text-red': isOverdue(props.row.deadline) && props.row.status !== 'completed',
                }"
              >
                {{ formatDate(props.row.deadline) }}
              </div>
            </q-td>
          </template>

          <template v-slot:body-cell-actions="props">
            <q-td :props="props">
              <div class="row q-gutter-xs">
                <q-btn
                  v-if="props.row.status === 'in-progress' || props.row.status === 'not-started'"
                  flat
                  round
                  dense
                  icon="edit"
                  color="blue"
                  size="sm"
                  @click="openUpdateDialog(props.row)"
                />
                <q-btn
                  v-if="
                    props.row.status === 'completed' ||
                    props.row.status === 'in-review' ||
                    (props.row.status === 'in-progress' && props.row.progress === 100)
                  "
                  flat
                  round
                  dense
                  icon="rate_review"
                  color="purple"
                  size="sm"
                />
              </div>
            </q-td>
          </template>
        </q-table>
      </q-card-section>
    </q-card>

    <!-- Update Task Progress Dialog -->
    <q-dialog v-model="showUpdateDialog">
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6">Update Task Progress</div>
        </q-card-section>
        <q-card-section>
          <div v-if="selectedTask">
            <div class="q-mb-md">
              <div class="text-subtitle2">{{ selectedTask.title }}</div>
              <div class="text-caption text-grey-7">
                {{ getProjectName(selectedTask.project_id) }}
              </div>
            </div>
            <q-slider v-model="progressUpdate" :min="0" :max="100" label-always color="primary" />
            <q-select
              v-model="statusUpdate"
              :options="statusOptions"
              label="Status"
              outlined
              class="q-mt-md"
            />
            <q-input
              v-model="hoursSpent"
              type="number"
              label="Hours Spent"
              outlined
              class="q-mt-md"
            />
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Update" @click="updateTaskProgress" :loading="updating" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Submit for Review Dialog -->
    <q-dialog v-model="showSubmitReviewDialog">
      <q-card style="min-width: 500px">
        <q-card-section>
          <div class="text-h6">Put for Review</div>
        </q-card-section>
        <q-card-section>
          <div v-if="selectedTask">
            <div class="q-mb-md">
              <div class="text-subtitle2">{{ selectedTask.title }}</div>
              <div class="text-caption text-grey-7">
                {{ getProjectName(selectedTask.project_id) }}
              </div>
            </div>
            <q-input
              v-model="completionComment"
              label="Completion Comment"
              type="textarea"
              outlined
              rows="3"
              class="q-mt-md"
            />
            <q-select
              v-model="selectedReviewer"
              :options="reviewerOptions"
              label="Select Reviewer"
              emit-value
              map-options
              outlined
              class="q-mt-md"
            />
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Submit" @click="submitForReview" :loading="submitting" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Task Clash Detected Dialog -->
    <q-dialog v-model="showClashDialog" persistent>
      <q-card style="min-width: 600px; max-width: 750px" class="rounded-borders">
        <q-card-section class="row items-center bg-red-1 text-negative q-pb-md">
          <q-avatar icon="warning" color="negative" text-color="white" size="40px" class="q-mr-md" />
          <div>
            <div class="text-h6 text-weight-bold">Task Clash Detected</div>
            <div class="text-caption text-grey-8">
              Multiple tasks share the exact same deadline date. Click Automate to resolve conflicts according to priority with at least 3-day gaps.
            </div>
          </div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="q-pt-md" style="max-height: 400px; overflow-y: auto">
          <div v-for="(conflict, idx) in detectedConflicts" :key="idx" class="q-mb-md">
            <div class="text-subtitle2 text-weight-bold text-grey-9 q-mb-xs row items-center">
              <q-icon name="event" class="q-mr-xs" color="primary" />
              Deadline: {{ formatDate(conflict.deadline) }}
              <q-badge color="negative" class="q-ml-sm">{{ conflict.count }} conflicting tasks</q-badge>
            </div>
            <q-list bordered separator class="rounded-borders bg-grey-1">
              <q-item v-for="task in conflict.tasks" :key="task.id" class="q-py-sm">
                <q-item-section avatar>
                  <q-badge
                    :color="getPriorityColor(task.priority)"
                    :label="task.priority"
                    class="text-capitalize text-weight-bold q-px-sm q-py-xs"
                  />
                </q-item-section>
                <q-item-section>
                  <q-item-label class="text-weight-bold">{{ task.title }}</q-item-label>
                  <q-item-label caption class="text-grey-7">
                    Project: {{ task.project_name || getProjectName(task.project_id) }}
                  </q-item-label>
                </q-item-section>
                <q-item-section side>
                  <div class="text-caption text-weight-medium text-grey-8">
                    {{ formatDate(task.deadline) }}
                  </div>
                </q-item-section>
              </q-item>
            </q-list>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right" class="q-pa-md bg-grey-1">
          <q-btn flat label="Cancel" color="grey-7" v-close-popup />
          <q-btn
            unelevated
            color="primary"
            icon="auto_fix_high"
            label="Automate"
            @click="resolveClashes"
            :loading="automating"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useAuthStore } from '../../stores/authStore';
import { Notify } from 'quasar';

defineOptions({
  name: 'EmployeeTasks',
});

const authStore = useAuthStore();

const loading = ref(false);
const searchQuery = ref('');
const statusFilter = ref('');
const priorityFilter = ref('');
const projectFilter = ref('');
const myTasks = ref<any[]>([]);
const projects = ref<any[]>([]);
const employees = ref<any[]>([]);

// Deadline conflict handling
const showClashDialog = ref(false);
const detectedConflicts = ref<any[]>([]);
const automating = ref(false);

const showUpdateDialog = ref(false);
const showSubmitReviewDialog = ref(false);
const selectedTask = ref<any>(null);
const progressUpdate = ref(0);
const statusUpdate = ref('in-progress');
const hoursSpent = ref(0);
const completionComment = ref('');
const selectedReviewer = ref<number | null>(null);
const updating = ref(false);
const submitting = ref(false);

const statusOptions = ['not-started', 'in-progress', 'completed', 'blocked', 'in-review'];
const priorityOptions = ['critical', 'high', 'medium', 'low'];

const columns = [
  { name: 'title', label: 'Task', field: 'title', align: 'left' as const, sortable: true },
  {
    name: 'project',
    label: 'Project',
    field: 'project_id',
    align: 'left' as const,
    sortable: true,
  },
  {
    name: 'priority',
    label: 'Priority',
    field: 'priority',
    align: 'left' as const,
    sortable: true,
  },
  { name: 'status', label: 'Status', field: 'status', align: 'left' as const, sortable: true },
  {
    name: 'progress',
    label: 'Progress',
    field: 'progress',
    align: 'left' as const,
    sortable: true,
  },
  {
    name: 'deadline',
    label: 'Deadline',
    field: 'deadline',
    align: 'left' as const,
    sortable: true,
  },
  { name: 'actions', label: 'Actions', field: 'id', align: 'center' as const },
];

const projectOptions = computed(() =>
  projects.value.map((p: any) => ({ label: p.name, value: p.id })),
);

const reviewerOptions = computed(() => {
  if (!employees.value || employees.value.length === 0) {
    console.log('❌ Tasks: No employees loaded');
    return [];
  }

  const options = employees.value
    .filter((e: any) => e.id !== authStore.user?.id)
    .map((e: any) => ({
      label: `${e.first_name} ${e.last_name} — ${e.email}`,
      value: e.id,
      id: e.id
    }));

  console.log('✅ Tasks reviewer options:', options);
  return options;
});

const filteredTasks = computed(() => {
  let tasks = [...myTasks.value];

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    tasks = tasks.filter(
      (t: any) =>
        t.title.toLowerCase().includes(query) || t.description?.toLowerCase().includes(query),
    );
  }

  if (statusFilter.value) {
    tasks = tasks.filter((t: any) => t.status === statusFilter.value);
  }

  if (priorityFilter.value) {
    tasks = tasks.filter((t: any) => t.priority === priorityFilter.value);
  }

  if (projectFilter.value) {
    tasks = tasks.filter((t: any) => t.project_id === projectFilter.value);
  }

  return tasks;
});

onMounted(async () => {
  await fetchFromDatabase();
  await detectDeadlineClashes();
});

async function fetchFromDatabase() {
  if (!authStore.user?.id) return;

  loading.value = true;
  try {
    const tasksResponse = await fetch(
      `http://localhost:3007/api/tasks/employee/${authStore.user.id}`,
    );
    const tasksData = await tasksResponse.json();
    if (tasksData.success) {
      myTasks.value = tasksData.tasks;
    }

    const projectsResponse = await fetch(`http://localhost:3007/api/employee/${authStore.user?.id}/projects`, {
      headers: { Authorization: `Bearer ${authStore.token}` },
    });
    const projectsData = await projectsResponse.json();
    if (projectsData.success) {
      projects.value = projectsData.projects;
    }

    const employeesResponse = await fetch('http://localhost:3007/api/users', {
      headers: { Authorization: `Bearer ${authStore.token}` },
    });
    const employeesData = await employeesResponse.json();
    if (employeesData.success) {
      employees.value = employeesData.users;
    }
  } catch (error) {
    console.error('Error fetching data:', error);
  } finally {
    loading.value = false;
  }
}

function applyFilters() {
  // Filters are applied via computed property
}

function getProjectName(projectId: number) {
  const project = projects.value.find((p: any) => p.id === projectId);
  return project?.name || 'Unknown Project';
}

function getPriorityColor(priority: string) {
  const colors: Record<string, string> = {
    critical: 'red',
    high: 'orange',
    medium: 'blue',
    low: 'green',
  };
  return colors[priority] || 'grey';
}

function getStatusColor(status: string) {
  const colors: Record<string, string> = {
    'not-started': 'grey',
    'in-progress': 'blue',
    completed: 'green',
    'in-review': 'purple',
    blocked: 'red',
  };
  return colors[status] || 'grey';
}

function formatDate(date: string) {
  if (!date) return 'No deadline';
  const d = new Date(date);
  if (isNaN(d.getTime())) return 'Invalid Date';
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}

function isOverdue(deadline: string) {
  if (!deadline) return false;
  const d = new Date(deadline);
  if (isNaN(d.getTime())) return false;
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return d < today;
}

function openUpdateDialog(task: any) {
  selectedTask.value = task;
  progressUpdate.value = task.progress;
  statusUpdate.value = task.status;
  hoursSpent.value = 0;
  showUpdateDialog.value = true;
}

async function updateTaskProgress() {
  if (!selectedTask.value) return;

  updating.value = true;
  try {
    let finalProgress = progressUpdate.value;
    if (statusUpdate.value === 'completed') {
      finalProgress = 100;
    }

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (authStore.token && authStore.token !== 'undefined' && authStore.token !== 'null') {
      headers['Authorization'] = `Bearer ${authStore.token}`;
    }

    const response = await fetch(
      `http://localhost:3007/api/employee/tasks/${selectedTask.value.id}`,
      {
        method: 'PUT',
        headers,
        body: JSON.stringify({
          progress: finalProgress,
          status: statusUpdate.value,
          hours_spent: hoursSpent.value,
        }),
      },
    );

    const data = await response.json();
    if (data.success) {
      showUpdateDialog.value = false;
      await fetchFromDatabase();
    }
  } catch (error) {
    console.error('Error updating task:', error);
  } finally {
    updating.value = false;
  }
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
function openSubmitReviewDialog(task: any) {
  selectedTask.value = task;
  completionComment.value = '';
  selectedReviewer.value = null;
  showSubmitReviewDialog.value = true;
}

async function submitForReview() {
  if (!selectedTask.value || !selectedReviewer.value) return;

  submitting.value = true;
  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (authStore.token && authStore.token !== 'undefined' && authStore.token !== 'null') {
      headers['Authorization'] = `Bearer ${authStore.token}`;
    }

    console.log('=== SUBMIT REVIEW START ===');
    console.log('Task ID:', selectedTask.value.id);
    console.log('Task owner ID:', authStore.user?.id);
    console.log('Reviewer ID:', selectedReviewer.value);
    console.log('Completion comment:', completionComment.value);
    
    const requestBody = {
      completion_comment: completionComment.value,
      reviewer_id: selectedReviewer.value || null,
      task_owner_id: authStore.user?.id,
    };
    console.log('Request body:', requestBody);
    
    const response = await fetch(
      `http://localhost:3007/api/employee/tasks/${selectedTask.value.id}/submit-review`,
      {
        method: 'POST',
        headers,
        body: JSON.stringify(requestBody),
      },
    );

    console.log('Submit review response status:', response.status);
    const data = await response.json();
    console.log('Submit review response data:', data);
    
    if (data.success) {
      console.log('=== SUBMIT REVIEW SUCCESS ===');
      showSubmitReviewDialog.value = false;
      completionComment.value = '';
      await fetchFromDatabase();
      Notify.create({
        type: 'positive',
        message: 'Task submitted for review successfully',
      });
    } else {
      console.error('Submit review failed:', data);
      Notify.create({
        type: 'negative',
        message: `Failed to submit: ${data.error || 'Unknown error'}`,
      });
    }
  } catch (error) {
    console.error('Error submitting for review:', error);
    Notify.create({
      type: 'negative',
      message: 'Error submitting for review',
    });
  } finally {
    submitting.value = false;
    console.log('=== SUBMIT REVIEW END ===');
  }
}

// ============================================================
// DEADLINE CONFLICT HANDLING
// ============================================================

async function detectDeadlineClashes() {
  if (!authStore.user?.id) return;
  
  try {
    const response = await fetch(
      `http://localhost:3007/api/employee/${authStore.user.id}/deadline-clashes`
    );
    const data = await response.json();
    if (data.success && data.conflicts.length > 0) {
      detectedConflicts.value = data.conflicts;
      showClashDialog.value = true;
    }
  } catch (error) {
    console.error('Error detecting clashes:', error);
  }
}

async function automateSchedule() {
  if (!authStore.user?.id) return;
  
  automating.value = true;
  try {
    const response = await fetch(
      `http://localhost:3007/api/employee/${authStore.user.id}/automate-schedule`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ mode: 'full' }),
      }
    );
    const data = await response.json();
    if (data.success) {
      showClashDialog.value = false;
      await fetchFromDatabase();
      Notify.create({
        type: 'positive',
        message: data.updatedTasks && data.updatedTasks.length > 0
          ? `Schedule automated! ${data.updatedTasks.length} tasks organized with 3-day gaps.`
          : 'Schedule is already optimized with no conflicts.',
        position: 'top',
      });
    } else {
      Notify.create({
        type: 'negative',
        message: data.error || 'Failed to automate schedule',
        position: 'top',
      });
    }
  } catch (error) {
    console.error('Error automating schedule:', error);
    Notify.create({
      type: 'negative',
      message: 'Network error automating schedule',
      position: 'top',
    });
  } finally {
    automating.value = false;
  }
}

async function resolveClashes() {
  if (!authStore.user?.id) return;

  automating.value = true;
  try {
    const response = await fetch(
      `http://localhost:3007/api/employee/${authStore.user.id}/automate-schedule`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ mode: 'clashes' }),
      }
    );
    const data = await response.json();
    if (data.success) {
      showClashDialog.value = false;
      await fetchFromDatabase();
      Notify.create({
        type: 'positive',
        message: data.updatedTasks && data.updatedTasks.length > 0
          ? `Conflicts resolved! ${data.updatedTasks.length} tasks rescheduled with 3-day gaps.`
          : 'All deadline conflicts resolved.',
        position: 'top',
      });
    } else {
      Notify.create({
        type: 'negative',
        message: data.error || 'Failed to resolve conflicts',
        position: 'top',
      });
    }
  } catch (error) {
    console.error('Error resolving clashes:', error);
    Notify.create({
      type: 'negative',
      message: 'Network error resolving conflicts',
      position: 'top',
    });
  } finally {
    automating.value = false;
  }
}
</script>
