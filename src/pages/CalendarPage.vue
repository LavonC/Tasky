<template>
  <q-page class="q-pa-md calendar-page" :class="{ 'is-dark': $q.dark.isActive }">
    <div class="row items-center justify-between q-mb-md">
      <div class="row items-center">
        <q-avatar
          color="indigo-1"
          text-color="indigo"
          icon="timeline"
          size="48px"
          class="q-mr-md"
          style="border-radius: 12px"
        />
        <div class="column">
          <div class="text-h5 text-weight-bold">Project Timeline</div>
          <div class="text-grey-7 text-caption">
            Plan schedules, track progress, and manage dependencies across your workspace
          </div>
        </div>
      </div>

      <div class="row items-center q-gutter-md">
        <q-input
          v-model="searchQuery"
          outlined
          dense
          rounded
          :bg-color="$q.dark.isActive ? 'grey-9' : 'white'"
          placeholder="Search tasks..."
          style="width: 260px"
        >
          <template #prepend><q-icon name="search" /></template>
        </q-input>
        <q-avatar
  size="36px"
  class="cursor-pointer"
  clickable
  @click="$router.push('/dashboard/profile')"
>
  <img :src="authStore.currentUser?.avatar || 'https://cdn.quasar.dev/img/avatar.png'" />
</q-avatar>
      </div>
    </div>

    <div class="row q-col-gutter-md q-mb-md">
      <div v-for="item in prioritySummary" :key="item.key" class="col-3">
        <q-card flat bordered class="priority-card bg-white">
          <q-card-section class="row items-center q-pa-md">
            <q-avatar :color="item.color + '-1'" :text-color="item.color" :icon="item.icon" size="40px" class="q-mr-sm" />
            <div>
              <div class="text-caption text-grey-7">{{ item.label }}</div>
              <div class="text-h6 text-weight-bold" :class="`text-${item.color}`">{{ item.count }}</div>
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <q-card flat bordered class="filter-card timeline-toolbar-card q-pa-md q-mb-md">
      <div class="row items-center justify-between q-gutter-md">
        <div class="row items-center q-gutter-sm">
          <span class="text-caption text-grey-7 text-weight-medium">View</span>
          <q-btn-toggle
            v-model="scale"
            unelevated
            no-caps
            toggle-color="indigo-5"
            :color="$q.dark.isActive ? 'grey-9' : 'white'"
             :text-color="$q.dark.isActive ? 'grey-3' : 'grey-8'"
            :options="scaleOptions"
          />
          <q-btn-toggle
            v-model="groupByProject"
            unelevated
            no-caps
            toggle-color="indigo-5"
            :color="$q.dark.isActive ? 'grey-9' : 'white'"
             :text-color="$q.dark.isActive ? 'grey-3' : 'grey-8'"
            :options="hierarchyOptions"
          />
          <q-toggle
            v-model="showDependencies"
            color="indigo-5"
            icon="account_tree"
            label="Dependencies"
            dense
          />
        </div>
      </div>
    </q-card>

    <DhtmlxGanttTimeline
      v-model:search-query="searchQuery"
      v-model:scale="scale"
      v-model:group-by-project="groupByProject"
      v-model:show-extra-columns="showExtraColumns"
      v-model:show-dependencies="showDependencies"
      :tasks="timelineTasks"
      :projects="timelineProjects"
      :resources="timelineResources"
      title="Project Timeline"
      @task-click="openTask"
    />
  </q-page>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';
import { useQuasar } from 'quasar';
import { useAuthStore } from '../stores/authStore';
import DhtmlxGanttTimeline from '../components/DhtmlxGanttTimeline.vue';
import { usePmTaskStore } from '../stores/pmTaskStore';
import { useProjectStore } from '../stores/projectStore';
import { useResourceStore } from '../stores/resourceStore';

const router = useRouter();
const $q = useQuasar();
const authStore = useAuthStore();
const pmTaskStore = usePmTaskStore();
const projectStore = useProjectStore();
const resourceStore = useResourceStore();

const searchQuery = ref('');
const scale = ref<'hour' | 'day' | 'week' | 'month'>('week');
const groupByProject = ref(true);
const showExtraColumns = ref(false);
const showDependencies = ref(true);

const scaleOptions = [
  { label: 'Hour', value: 'hour' },
  { label: 'Day', value: 'day' },
  { label: 'Week', value: 'week' },
  { label: 'Month', value: 'month' },
];
const hierarchyOptions = [
  { label: 'Projects', value: true },
  { label: 'Flat', value: false },
];

const prioritySummary = computed(() => [
  { key: 'critical', label: 'Critical', color: 'red', icon: 'priority_high', count: pmTaskStore.tasks.filter((t: any) => t.priority === 'critical').length },
  { key: 'high', label: 'High', color: 'orange', icon: 'flag', count: pmTaskStore.tasks.filter((t: any) => t.priority === 'high').length },
  { key: 'medium', label: 'Medium', color: 'yellow', icon: 'remove', count: pmTaskStore.tasks.filter((t: any) => t.priority === 'medium').length },
  { key: 'low', label: 'Low', color: 'green', icon: 'arrow_downward', count: pmTaskStore.tasks.filter((t: any) => t.priority === 'low').length },
]);

const timelineTasks = computed(() => pmTaskStore.tasks.map((task: any) => ({
  ...task,
  task_id: task.task_id ?? task.id,
  project_id: task.project_id ?? task.projectId,
  predecessor_task_ids: Array.from(
    new Set(
      [
        ...(Array.isArray(task.predecessor_task_ids) ? task.predecessor_task_ids : []),
        ...(Array.isArray(task.dependsOn)
          ? task.dependsOn.map((dependency: any) => dependency.depends_on_id)
          : []),
      ]
        .map((id) => Number(id))
        .filter((id) => Number.isInteger(id) && id > 0),
    ),
  ),
})));
const timelineProjects = computed(() => projectStore.projects.map((project: any) => ({
  ...project,
  project_id: project.project_id ?? project.id,
})));
const timelineResources = computed(() => resourceStore.resources.map((resource: any) => ({
  ...resource,
  user_id: resource.user_id ?? resource.id,
  name: resource.name ?? `${resource.first_name || ''} ${resource.last_name || ''}`.trim(),
})));

onMounted(() => {
  void Promise.all([pmTaskStore.fetchTasks(), projectStore.fetchProjects(), resourceStore.fetchResources()]);
});

const logout = () => {
  authStore.logout();
  router.replace('/auth/login');
};
const openTask = (task: any) => {
  if (task?.id) router.push(`/dashboard/tasks?open=${task.id}`);
};
</script>

<style scoped>
.calendar-page {
  min-height: 100%;
  background-color: #f8f9fa;
  overflow: auto;
  color: #111827;
}

.priority-card,
.filter-card {
  border-radius: 12px;
  border-color: #e5e7eb;
}

.timeline-toolbar-card {
  background: #f8f9ff;
  border-color: #e7e9f4;
}

.timeline-toolbar-card :deep(.q-btn-group) {
  overflow: hidden;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
}

/* Keep this page in sync with Quasar's dark mode instead of relying on
   light-theme utility classes such as bg-white/f8f9ff. */
.calendar-page.is-dark {
  background-color: #121a1f;
  color: #edf2f7;
}

.calendar-page.is-dark .priority-card,
.calendar-page.is-dark .filter-card {
  background-color: #1d2930 !important;
  border-color: #34434c !important;
  color: #edf2f7;
}

.calendar-page.is-dark .timeline-toolbar-card {
  background-color: #1d2930 !important;
  border-color: #34434c !important;
}

.calendar-page.is-dark :deep(.text-grey-7) {
  color: #b8c7d1 !important;
}

.calendar-page.is-dark :deep(.q-field--outlined .q-field__control) {
  background-color: #26343c !important;
  border-color: #52636e !important;
  color: #edf2f7 !important;
}

.calendar-page.is-dark :deep(.q-field__native),
.calendar-page.is-dark :deep(.q-field__input),
.calendar-page.is-dark :deep(.q-field__marginal) {
  color: #edf2f7 !important;
}

.calendar-page.is-dark :deep(.q-field__native::placeholder),
.calendar-page.is-dark :deep(.q-field__input::placeholder) {
  color: #91a2ad !important;
}

.calendar-page.is-dark .timeline-toolbar-card :deep(.q-btn-group) {
  border-color: #52636e;
}

.calendar-page.is-dark .timeline-toolbar-card :deep(.q-btn) {
  color: #d9e2e8;
}

.calendar-page.is-dark .timeline-toolbar-card :deep(.q-btn:not(.bg-indigo-5)) {
  background-color: #26343c;
}

.calendar-page.is-dark .timeline-toolbar-card :deep(.q-btn.bg-indigo-5) {
  color: #ffffff !important;
}

.calendar-page.is-dark .priority-card :deep(.text-grey-7) {
  color: #b8c7d1 !important;
}
</style>
