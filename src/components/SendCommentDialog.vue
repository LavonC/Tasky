<template>
  <q-dialog v-model="isOpen" @hide="onHide">
    <q-card style="min-width: 400px">
      <q-card-section>
        <div class="text-h6">Send Comment</div>
      </q-card-section>

      <q-card-section class="q-pt-none">
        <div v-if="prefilledTask" class="q-mb-md">
          <div class="text-subtitle2">Task: {{ prefilledTask.title }}</div>
        </div>
        <div v-else class="q-mb-md">
          <q-select
            v-model="selectedTaskId"
            :options="taskOptions"
            label="Select Task"
            outlined
            emit-value
            map-options
            class="q-mb-md"
          />
        </div>

        <div v-if="prefilledEmployee" class="q-mb-md">
          <div class="text-subtitle2">Employee: {{ prefilledEmployee.first_name }} {{ prefilledEmployee.last_name }}</div>
        </div>
        <div v-else class="q-mb-md">
          <q-select
            v-model="selectedEmployeeId"
            :options="employeeOptions"
            label="Select Employee"
            outlined
            emit-value
            map-options
            class="q-mb-md"
          />
        </div>

        <q-input
          v-model="comment"
          type="textarea"
          label="Comment"
          outlined
          rows="4"
        />
      </q-card-section>

      <q-card-actions align="right">
        <q-btn flat label="Cancel" color="primary" v-close-popup />
        <q-btn label="Send" color="primary" @click="submitComment" :loading="loading" :disable="!isFormValid" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue';
import { useQuasar } from 'quasar';
import { useAuthStore } from '../stores/authStore';
import { usePmTaskStore } from '../stores/pmTaskStore';
import { useTaskStore } from '../stores/taskStore'; // For employees list

const props = defineProps({
  modelValue: Boolean,
  prefilledTask: { type: Object, default: null },
  prefilledEmployee: { type: Object, default: null },
});

const emit = defineEmits(['update:modelValue', 'sent']);

const $q = useQuasar();
const authStore = useAuthStore();
const pmTaskStore = usePmTaskStore();
const taskStore = useTaskStore();

const isOpen = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val)
});

const selectedTaskId = ref<number | null>(null);
const selectedEmployeeId = ref<number | null>(null);
const comment = ref('');
const loading = ref(false);

const taskOptions = computed(() => {
  let tasks = pmTaskStore.tasks;

  if (props.prefilledEmployee) {
    const employeeId = props.prefilledEmployee.id;

    tasks = tasks.filter(t => {
      return t.assignees && t.assignees.some((a: any) => a.id === employeeId);
    });
  }

  return tasks.map(t => ({
    label: t.title,
    value: t.id
  }));
});

const employeeOptions = computed(() => {
  let employees = taskStore.employees;

  if (props.prefilledTask && props.prefilledTask.assignees) {
    const assigneeIds = props.prefilledTask.assignees.map((a: any) => a.id);
    employees = employees.filter(e => assigneeIds.includes(e.id));
  }

  return employees.map(e => ({
    label: `${e.first_name} ${e.last_name}`,
    value: e.id
  }));
});

const isFormValid = computed(() => {
  const tId = props.prefilledTask ? props.prefilledTask.id : selectedTaskId.value;
  const eId = props.prefilledEmployee ? props.prefilledEmployee.id : selectedEmployeeId.value;
  return tId && eId && comment.value.trim() !== '';
});

watch(() => props.modelValue, async (val) => {
  if (val) {
    if (!props.prefilledEmployee && taskStore.employees.length === 0) {
      await taskStore.fetchEmployees();
    }
    if (!props.prefilledTask && pmTaskStore.tasks.length === 0) {
      await pmTaskStore.fetchTasks();
    }
    selectedTaskId.value = props.prefilledTask ? props.prefilledTask.id : null;
    selectedEmployeeId.value = props.prefilledEmployee ? props.prefilledEmployee.id : null;
    comment.value = '';
  }
});

const onHide = () => {
  selectedTaskId.value = null;
  selectedEmployeeId.value = null;
  comment.value = '';
};

const submitComment = async () => {
  if (!isFormValid.value) return;
  
  loading.value = true;
  try {
    const taskId = props.prefilledTask ? props.prefilledTask.id : selectedTaskId.value;
    const employeeId = props.prefilledEmployee ? props.prefilledEmployee.id : selectedEmployeeId.value;

    const response = await fetch('http://localhost:3001/api/pm/tasks/comment', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${authStore.token}`
      },
      body: JSON.stringify({
        task_id: taskId,
        employee_id: employeeId,
        comment: comment.value
      })
    });

    const data = await response.json();
    if (data.success) {
      $q.notify({ type: 'positive', message: 'Comment sent successfully' });
      emit('sent');
      isOpen.value = false;
    } else {
      $q.notify({ type: 'negative', message: data.error || 'Failed to send comment' });
    }
  } catch (error: any) {
    $q.notify({ type: 'negative', message: error.message || 'Error sending comment' });
  } finally {
    loading.value = false;
  }
};
</script>
