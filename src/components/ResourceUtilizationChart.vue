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
    v-for="resource in paginatedResources"
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

  <!-- ONLY ONE pagination -->
  <div
    v-if="totalPages > 1"
    class="row items-center justify-center q-mt-md"
  >
    <q-pagination
      v-model="currentPage"
      :max="totalPages"
      max-pages="5"
      direction-links
      boundary-links
      size="sm"
    />
  </div>
</div>
  </q-card>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue';

const props = defineProps<{
  resources: any[];
}>();

const currentPage = ref(1);
const rowsPerPage = 5;

const totalPages = computed(() => {
  return Math.ceil(props.resources.length / rowsPerPage);
});

const paginatedResources = computed(() => {
  const start = (currentPage.value - 1) * rowsPerPage;

  return props.resources.slice(
    start,
    start + rowsPerPage
  );
});

watch(
  () => props.resources,
  () => {
    currentPage.value = 1;
  }
);

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