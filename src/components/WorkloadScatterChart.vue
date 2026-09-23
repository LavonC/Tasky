<template>
  <q-card flat bordered class="q-pa-lg bg-white workload-card">
    <div class="text-subtitle1 text-weight-bold">
      Workload vs Utilization
    </div>

    <div v-if="resources.length === 0" class="text-center text-grey-6 q-pa-lg">
      No resource data available
    </div>

    <div v-else class="scatter-container">
      <!-- Y Axis -->
      <div class="y-axis-label">
        Utilization
      </div>

      <div class="chart-area">
        <!-- Horizontal grid lines -->
        <div
          v-for="value in gridValues"
          :key="value"
          class="grid-line"
          :style="{ bottom: `${(value / maxUtilization) * 100}%` }"
        >
          <span>{{ value }}%</span>
        </div>

        <!-- Points -->
        <div
          v-for="resource in resources"
          :key="resource.user_id"
          class="scatter-point"
          :style="getPointPosition(resource)"
          :title="`${resource.first_name} ${resource.last_name}: ${resource.active_task_count} tasks, ${resource.utilization}% utilization`"
        >
          <q-tooltip>
            <strong>
              {{ resource.first_name }} {{ resource.last_name }}
            </strong>
            <br />
            Active Tasks: {{ resource.active_task_count }}
            <br />
            Utilization: {{ resource.utilization }}%
          </q-tooltip>
        </div>

        <!-- X Axis -->
        <div class="x-axis">
          <span
            v-for="value in xAxisValues"
            :key="value"
            :style="{ left: `${(value / maxTasks) * 100}%` }"
          >
            {{ value }}
          </span>
        </div>
      </div>

      <div class="x-axis-label">
        Active Tasks
      </div>
    </div>

    <!-- Insight -->
    <div class="row q-gutter-sm insight-row">
      <q-chip
        icon="trending_up"
        color="orange"
        text-color="white"
      >
        High workload: {{ highWorkloadCount }}
      </q-chip>

      <q-chip
        icon="warning"
        color="negative"
        text-color="white"
      >
        High utilization: {{ highUtilizationCount }}
      </q-chip>
    </div>
  </q-card>
</template>

<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  resources: any[];
}>();

const maxTasks = computed(() => {
  const highest = Math.max(
    ...props.resources.map(resource =>
      Number(resource.active_task_count || 0)
    ),
    1
  );

  return Math.ceil(highest / 5) * 5;
});

const maxUtilization = computed(() => {
  const highest = Math.max(
    ...props.resources.map(resource =>
      Number(resource.utilization || 0)
    ),
    100
  );

  return Math.ceil(highest / 20) * 20;
});

const xAxisValues = computed(() => {
  const values = [];

  for (let i = 0; i <= maxTasks.value; i += 5) {
    values.push(i);
  }

  return values;
});

const gridValues = computed(() => {
  const values = [];

  for (let i = 0; i <= maxUtilization.value; i += 20) {
    values.push(i);
  }

  return values;
});

const getPointPosition = (resource: any) => {
  const tasks = Number(resource.active_task_count || 0);
  const utilization = Number(resource.utilization || 0);

  return {
    left: `${(tasks / maxTasks.value) * 100}%`,
    bottom: `${(utilization / maxUtilization.value) * 100}%`
  };
};

const highWorkloadCount = computed(() => {
  return props.resources.filter(
    resource => Number(resource.active_task_count || 0) >= 10
  ).length;
});

const highUtilizationCount = computed(() => {
  return props.resources.filter(
    resource => Number(resource.utilization || 0) >= 85
  ).length;
});
</script>

<style scoped>
.workload-card {
  display: flex;
  flex-direction: column;
}

.scatter-container {
  position: relative;
  height: 130px;
  padding: 5px 5px 10px 42px;
}

.chart-area {
  position: relative;
  width: 100%;
  height: 100%;
  border-left: 1px solid #d5d5d5;
  border-bottom: 1px solid #d5d5d5;
}

.grid-line {
  position: absolute;
  left: 0;
  width: 100%;
  border-top: 1px dashed #e0e0e0;
}

.grid-line span {
  position: absolute;
  right: calc(100% + 8px);
  top: -9px;
  font-size: 11px;
  color: #777;
}

.scatter-point {
  position: absolute;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: #1976d2;
  border: 3px solid white;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.25);
  transform: translate(-50%, 50%);
  cursor: pointer;
  transition: transform 0.2s ease;
}

.scatter-point:hover {
  transform: translate(-50%, 50%) scale(1.5);
}

.x-axis {
  position: absolute;
  left: 0;
  right: 0;
  bottom: -5px;
}

.x-axis span {
  position: absolute;
  transform: translateX(-50%);
  font-size: 11px;
  color: #777;
}

.y-axis-label {
  position: absolute;
  left: -25px;
  top: 45%;
  transform: rotate(-90deg);
  font-size: 12px;
  color: #666;
  white-space: nowrap;
}

.x-axis-label {
  position: absolute;
  bottom: 10;
  left: 50%;
  transform: translateX(-50%);
  font-size: 12px;
  color: #666;
  white-space: nowrap;
}

.insight-row {
  margin-top: auto;
  margin-bottom: -16px;
}
</style>