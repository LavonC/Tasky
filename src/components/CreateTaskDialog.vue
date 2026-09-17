<template>
  <q-dialog v-model="isOpen" persistent>
    <q-card class="create-dialog-card" style="width: 540px; max-width: 90vw">
      <q-card-section class="create-dialog-header row items-center q-pb-md">
        <q-avatar color="white" text-color="indigo" icon="add_task" size="42px" class="q-mr-md" />
        <div><div class="text-h6 text-weight-bold">{{ isEdit ? 'Edit Task' : 'Create New Task' }}</div><div class="text-caption text-indigo-1">Turn the next piece of work into a clear action</div></div>
        <q-space />
        <q-btn icon="close" flat round dense v-close-popup />
      </q-card-section>

      <q-card-section class="q-pa-lg scroll" style="max-height: 75vh;">
        <q-form @submit="onSubmit" class="q-gutter-md">
          <q-select
            v-model="form.project_id"
            :options="projectOptions"
            label="Project *"
            outlined
            dense
            emit-value
            map-options
            :rules="[(val) => !!val || 'Project is required']"
            :disable="isEdit && !!taskToEdit?.project_id"
          />

          <q-input
            v-model="form.title"
            label="Task Title *"
            outlined
            dense
            :rules="[(val) => !!val || 'Title is required']"
          />

          <q-input
            v-model="form.description"
            label="Description"
            type="textarea"
            outlined
            dense
            rows="3"
          />

          <div class="row q-col-md" style="gap:20px;">
            <div class="col-12">
              <q-select
                v-model="form.priority"
                :options="priorityOptions"
                label="Priority"
                outlined
                dense
                emit-value
                map-options
              />
            </div>
          </div>

          <div class="row q-col-md" style="gap:10px;">
            <div class="col-4">
              <q-input
                v-model="form.expected_effort"
                label="Expected Effort (Hours)"
                type="number"
                outlined
                dense
                min="0"
              />
            </div>
            <div class="col-4">
              <q-input
                v-model="form.resources_needed"
                label="Resources Needed"
                type="number"
                outlined
                dense
                min="1"
                :readonly="!form.auto_assign"
                :rules="[(val) => val > 0 || 'Must be > 0']"
              />
              <q-toggle
                v-model="form.auto_assign"
                label="Smart Auto Assign"
                dense
                class="q-mt-xs"
              />
            </div>
            <div class="col-3">
              <q-input
                v-model="form.deadline"
                label="Deadline"
                type="date"
                outlined
                dense
                stack-label
                :rules="[(val) => !!val || 'Deadline is required']"
              />
            </div>
          </div>

          <q-select
            v-model="form.assignee_ids"
            :options="resourceOptions"
            label="Assign To"
            outlined
            dense
            multiple
            use-chips
            emit-value
            map-options
            :rules="form.auto_assign ? [(val) => (val && val.length > 0) || 'Please assign at least one employee'] : []"
            hint="Select employees to assign this task to"
          />

          <q-select
            v-model="form.depends_on_ids"
            :options="taskOptions"
            label="Dependencies (Optional)"
            outlined
            dense
            multiple
            use-chips
            emit-value
            map-options
            hint="Select tasks that must be completed before this task can progress"
          />



          <div class="row justify-end q-mt-lg">
            <q-btn label="Cancel" color="grey" flat v-close-popup class="q-mr-sm" />
            <q-btn
              :label="isEdit ? 'Save Changes' : 'Create Task'"
              color="primary"
              type="submit"
              :loading="loading"
            />
          </div>
        </q-form>
      </q-card-section>
    </q-card>
  </q-dialog>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue';
import { usePmTaskStore } from '../stores/pmTaskStore';
import { useProjectStore } from '../stores/projectStore';
import { useOrgStore } from '../stores/orgStore';
import { useAuthStore } from '../stores/authStore';
import { useQuasar } from 'quasar';

const props = defineProps<{
  modelValue: boolean;
  taskToEdit?: any;
  initialProjectId?: number | string;
}>();

const emit = defineEmits(['update:modelValue', 'saved']);
const $q = useQuasar();
const taskStore = usePmTaskStore();
const projectStore = useProjectStore();
const orgStore = useOrgStore();
const authStore = useAuthStore();

const isOpen = ref(props.modelValue);
const isEdit = ref(false);
const loading = ref(false);

const projectOptions = computed(() => {
  return projectStore.projects.map((p) => ({ label: p.name, value: p.id }));
});

const resourceOptions = computed(() => {
  return orgStore.members.map((m) => ({
    label: `${m.first_name} ${m.last_name} (${m.role_name})`,
    value: m.id,
  }));
});

const taskOptions = computed(() => {
  return taskStore.tasks
    .filter((t) => {
      if (props.taskToEdit && t.id === props.taskToEdit.id) return false;
      if (form.value.project_id && t.project_id != form.value.project_id) return false;
      return true;
    })
    .map((t) => ({ label: t.title, value: t.id }));
});



const priorityOptions = [
  { label: 'Critical', value: 'critical' },
  { label: 'High', value: 'high' },
  { label: 'Medium', value: 'medium' },
  { label: 'Low', value: 'low' },
];

const form = ref({
  project_id: null as number | null,
  title: '',
  description: '',
  priority: 'medium',
  progress: 0,
  expected_effort: null as number | null,
  resources_needed: 1,
  deadline: '',
  assignee_ids: [] as number[],
  depends_on_ids: [] as number[],
  auto_assign: false,
});

watch(
  () => props.modelValue,
  (val) => {
    isOpen.value = val;
    if (val) {
      // Always fetch projects and members when dialog opens
      projectStore.fetchProjects();
      orgStore.fetchMembers();

      if (props.taskToEdit) {
        isEdit.value = true;
        form.value = {
          project_id: props.taskToEdit.project_id,
          title: props.taskToEdit.title,
          description: props.taskToEdit.description || '',
          priority: props.taskToEdit.priority || 'medium',
          progress: props.taskToEdit.progress || 0,
          expected_effort: props.taskToEdit.expected_effort,
          resources_needed: props.taskToEdit.resources_needed || 1,
          deadline: props.taskToEdit.deadline ? new Date(new Date(props.taskToEdit.deadline).getTime() - (new Date(props.taskToEdit.deadline).getTimezoneOffset() * 60000)).toISOString().split('T')[0] || '' : '',
          assignee_ids: props.taskToEdit.assignees
            ? props.taskToEdit.assignees.map((a: any) => a.id)
            : [],
          depends_on_ids: props.taskToEdit.dependsOn
            ? props.taskToEdit.dependsOn.map((d: any) => d.depends_on_id)
            : [],
          auto_assign: false,
        };
      } else {
        isEdit.value = false;
        form.value = {
          project_id: props.initialProjectId
            ? Number(props.initialProjectId)
            : projectOptions.value.length > 0
              ? projectOptions.value[0]?.value
              : null,
          title: '',
          description: '',
          priority: 'medium',
          progress: 0,
          expected_effort: null,
          resources_needed: 1,
          deadline: '',
          assignee_ids: [],
          depends_on_ids: [],
          auto_assign: false,
        };
      }
    }
  },
);

watch(() => form.value.assignee_ids, (newVal) => {
  if (!form.value.auto_assign) {
    form.value.resources_needed = newVal.length > 0 ? newVal.length : 1;
  }
}, { deep: true });

watch([() => form.value.auto_assign, () => form.value.resources_needed], async ([autoAssign, numResources]) => {
  if (autoAssign) {
    const n = Number(numResources) || 1;
    try {
      const response = await fetch('http://localhost:3007/api/pm/schedule/recommend-preview', {
        method: 'POST',
        headers: taskStore.getHeaders(),
        body: JSON.stringify({
          project_id: form.value.project_id,
          title: form.value.title,
          description: form.value.description,
        }),
      });
      const data = await response.json();
      if (data.success && data.recommendations) {
        form.value.assignee_ids = data.recommendations.slice(0, n).map((r: any) => r.id);
      } else {
        form.value.assignee_ids = orgStore.members.slice(0, n).map((m: any) => m.id);
      }
    } catch (err) {
      console.error('Error fetching recommendations:', err);
      form.value.assignee_ids = orgStore.members.slice(0, n).map((m: any) => m.id);
    }
  }
});

watch(isOpen, (val) => {
  emit('update:modelValue', val);
});

const onSubmit = async () => {
  loading.value = true;
  try {
    const payload = { ...form.value };
    delete (payload as any).auto_assign;
    if (!payload.deadline) {
      (payload as any).deadline = null;
    }

    if (isEdit.value) {
      await taskStore.updateTask(props.taskToEdit.id, payload);
      $q.notify({ type: 'positive', message: 'Task updated successfully' });
    } else {
      await taskStore.createTask(payload);
      $q.notify({ type: 'positive', message: 'Task created successfully' });
    }
    emit('saved');
    isOpen.value = false;
  } catch (error: any) {
    $q.notify({ type: 'negative', message: error.message || 'An error occurred' });
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.create-dialog-card { border-radius: 18px; overflow: hidden; }
.create-dialog-header { color: white; background: linear-gradient(135deg, #3949ab, #5c6bc0); }
</style>
