<template>
  <q-card flat bordered class="q-pa-md bg-white">
    <div class="text-subtitle1 text-weight-bold">
      Team Capacity
    </div>

    <div class="capacity-container">
      <q-circular-progress
        :value="averageUtilization"
        size="125px"
        :thickness="0.18"
        rounded
        show-value
        :color="capacityColor"
        track-color="grey-3"
      >
        <div class="text-center">
          <div class="text-h4 text-weight-bold">
            {{ Math.round(averageUtilization) }}%
          </div>

          <div class="text-caption text-grey-6">
            Utilized
          </div>
        </div>
      </q-circular-progress>

      <div class="capacity-info">
        <div class="text-body2 text-weight-bold q-mb-sm">
          {{ capacityLabel }}
        </div>

        <div class="text-caption text-grey-7">
          {{ resources.length }} resources
        </div>

        <div class="q-mt-md">
          <div class="row justify-between text-caption">
            <span>Weekly hours</span>
            <strong>{{ totalWeeklyHours }}h</strong>
          </div>

          <div class="row justify-between text-caption q-mt-xs">
            <span>Active tasks</span>
            <strong>{{ totalActiveTasks }}</strong>
          </div>
        </div>
      </div>
    </div>
  </q-card>
</template>

<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  resources: any[];
}>();

const averageUtilization = computed(() => {
  if (!props.resources.length) return 0;

  const total = props.resources.reduce(
    (sum, resource) => sum + Number(resource.utilization || 0),
    0
  );

  return Math.min(total / props.resources.length, 100);
});

const totalWeeklyHours = computed(() => {
  return props.resources.reduce(
    (sum, resource) =>
      sum + Number(resource.weekly_required_hours || 0),
    0
  ).toFixed(1);
});

const totalActiveTasks = computed(() => {
  return props.resources.reduce(
    (sum, resource) =>
      sum + Number(resource.active_task_count || 0),
    0
  );
});

const capacityColor = computed(() => {
  if (averageUtilization.value >= 100) return 'negative';
  if (averageUtilization.value >= 85) return 'warning';
  return 'positive';
});

const capacityLabel = computed(() => {
  if (averageUtilization.value >= 100) return 'Team is overloaded';
  if (averageUtilization.value >= 85) return 'Team is near capacity';
  return 'Team has available capacity';
});
</script>

<style scoped>
.capacity-container {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  padding: 15px 0;
  width: 100%;
}

.capacity-info {
  min-width: 0;
  flex: 1;
}

@media (max-width: 600px) {
  .capacity-container {
    flex-direction: column;
    gap: 20px;
  }
}
</style>