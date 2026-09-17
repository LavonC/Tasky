<template>
  <q-card flat bordered class="bg-white q-pa-md">
    <div class="text-subtitle1 text-weight-bold">Project Health</div>
    <div class="text-caption text-grey-7 q-mb-lg">
      Progress across active projects
    </div>

    <div v-if="projects.length" class="column q-gutter-md">
      <div v-for="project in paginatedProjects" :key="project.id">
        <div class="row justify-between items-center q-mb-xs">
          <span class="text-body2 text-weight-medium ellipsis">
            {{ project.name }}
          </span>

          <span class="text-caption text-weight-bold">
            {{ Math.round(Number(project.progress || 0)) }}%
          </span>
        </div>

        <q-linear-progress
          :value="Math.min(Number(project.progress || 0) / 100, 1)"
          :color="getColor(project.progress)"
          track-color="grey-3"
          rounded
          size="9px"
        />
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="row justify-center q-mt-md">
        <q-pagination
          v-model="currentPage"
          :max="totalPages"
          :max-pages="5"
          boundary-numbers
          direction-links
          color="primary"
        />
      </div>
    </div>

    <div
      v-else
      class="text-center text-grey-6 q-pa-md text-caption"
    >
      No project health data available.
    </div>
  </q-card>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue';

const props = defineProps<{
  projects: any[];
}>();

const currentPage = ref(1);
const itemsPerPage = 2;

const totalPages = computed(() =>
  Math.ceil(props.projects.length / itemsPerPage)
);

const paginatedProjects = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  const end = start + itemsPerPage;

  return props.projects.slice(start, end);
});

// Reset to page 1 if the project list changes
// and the current page no longer exists.
watch(
  () => props.projects.length,
  () => {
    if (currentPage.value > totalPages.value) {
      currentPage.value = Math.max(totalPages.value, 1);
    }
  }
);

const getColor = (progress: number) =>
  Number(progress || 0) >= 80
    ? 'positive'
    : Number(progress || 0) >= 40
      ? 'primary'
      : 'warning';
</script>