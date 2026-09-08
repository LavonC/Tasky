<template>
  <q-card flat bordered class="q-pa-md bg-white">
    <div class="text-subtitle1 text-weight-bold q-mb-xs">
      Resource Utilization
    </div>

    <div class="text-caption text-grey-7 q-mb-md">
      Team members by current workload utilization
    </div>

    <div v-if="resources.length === 0" class="text-center text-grey-6 q-pa-lg">
      No resource data available
    </div>

    <div v-else>
      <div
        v-for="resource in resources"
        :key="resource.user_id"
        class="q-mb-md"
      >
        <div class="row items-center justify-between q-mb-xs">
          <div class="text-body2 text-weight-medium">
            {{ resource.first_name }} {{ resource.last_name }}
          </div>

          <div
            class="text-body2 text-weight-bold"
            :class="getUtilizationColor(resource.utilization)"
          >
            {{ Math.round(resource.utilization || 0) }}%
          </div>
        </div>

        <q-linear-progress
          :value="Math.min((resource.utilization || 0) / 100, 1)"
          size="10px"
          rounded
          :color="getProgressColor(resource.utilization)"
          track-color="grey-3"
        />
      </div>
    </div>
  </q-card>
</template>

<script setup lang="ts">
defineProps<{
  resources: any[];
}>();

const getUtilizationColor = (utilization: number) => {
  if (utilization >= 100) return 'text-red';
  if (utilization >= 85) return 'text-orange';
  if (utilization < 50) return 'text-blue';
  return 'text-green';
};

const getProgressColor = (utilization: number) => {
  if (utilization >= 100) return 'red';
  if (utilization >= 85) return 'orange';
  if (utilization < 50) return 'blue';
  return 'green';
};
</script>