<template>
  <div
    class="analytics-card bg-white q-pa-md shadow-1 q-mb-md"
    style="border-radius: 12px"
  >
    <div class="row items-center justify-between q-mb-lg">
      <div class="text-subtitle1 text-weight-bold">
        Project Progress
      </div>

      <q-btn
        flat
        dense
        no-caps
        color="grey-8"
        label="View All"
        size="12px"
        class="bg-grey-2 q-px-sm rounded-borders"
        style="font-weight: 500"
        @click="router.push('/dashboard/projects')"
      />
    </div>

    <!-- Loading -->
    <div
      v-if="analyticsStore.loading"
      class="flex flex-center q-pa-md"
    >
      <q-spinner-dots
        size="24px"
        color="primary"
      />
    </div>

    <!-- Projects -->
    <div
      v-else-if="
        analyticsStore.projectProgress &&
        analyticsStore.projectProgress.length > 0
      "
      class="column"
    >
      <div class="column q-gutter-y-lg">
        <div
          v-for="project in paginatedProjects"
          :key="project.id"
          class="row items-center no-wrap justify-between"
        >
          <!-- Project Name -->
          <div
            class="row items-center no-wrap"
            style="width: 250px"
          >
            <q-avatar
              :color="project.color || 'primary'"
              text-color="white"
              size="24px"
              class="q-mr-md cursor-pointer"
              style="font-weight: bold; font-size: 11px"
              @click="
                router.push(
                  `/dashboard/projects?open=${project.id}`
                )
              "
            >
              {{ project.name.charAt(0).toUpperCase() }}
            </q-avatar>

            <div
              class="text-weight-bold text-grey-9 text-truncate cursor-pointer"
              style="font-size: 13px"
              @click="
                router.push(
                  `/dashboard/projects?open=${project.id}`
                )
              "
            >
              {{ project.name }}
            </div>
          </div>

          <!-- Progress Bar -->
          <div class="flex-1 q-px-md">
            <q-linear-progress
              :value="(project.progress || 0) / 100"
              :color="getBarColor(project.progress)"
              size="4px"
              class="rounded-borders"
            />
          </div>

          <!-- Progress / Tasks -->
          <div
            class="row items-center no-wrap justify-end"
            style="width: 120px"
          >
            <div
              class="text-weight-bold q-mr-md"
              style="font-size: 14px"
            >
              {{ project.progress || 0 }}%
            </div>

            <div
              class="text-caption text-grey-6"
              style="font-size: 11px"
            >
              {{ project.completed_tasks || 0 }} /
              {{ project.total_tasks || 0 }} tasks
            </div>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div
        v-if="totalPages > 1"
        class="row items-center justify-center q-mt-md"
      >
        <q-pagination
          v-model="currentPage"
          :max="totalPages"
          :max-pages="5"
          direction-links
          boundary-links
          size="sm"
          color="grey-6"
          active-color="primary"
          text-color="grey-8"
          active-text-color="white"
          class="resource-pagination"
        />
      </div>
    </div>

    <!-- No Projects -->
    <div
      v-else
      class="text-center text-grey-6 q-pa-md text-caption"
    >
      No projects available.
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import { useAnalyticsStore } from '../stores/analyticsStore';

const router = useRouter();
const analyticsStore = useAnalyticsStore();

/*
 * Pagination
 */
const currentPage = ref(1);
const itemsPerPage = 2;

/*
 * Calculate total number of pages
 */
const totalPages = computed(() => {
  return Math.ceil(
    (analyticsStore.projectProgress?.length || 0) /
      itemsPerPage
  );
});

/*
 * Projects displayed on the current page
 */
const paginatedProjects = computed(() => {
  const projects = analyticsStore.projectProgress || [];

  const start =
    (currentPage.value - 1) * itemsPerPage;

  const end = start + itemsPerPage;

  return projects.slice(start, end);
});

/*
 * Keep the current page valid when
 * the project list changes.
 */
watch(
  () => analyticsStore.projectProgress?.length,
  () => {
    if (currentPage.value > totalPages.value) {
      currentPage.value = Math.max(
        totalPages.value,
        1
      );
    }
  }
);

/*
 * Progress bar colors
 */
const getBarColor = (progress: number) => {
  const p = progress || 0;

  if (p === 100) return 'green';
  if (p >= 50) return 'blue';
  if (p > 0) return 'orange';

  return 'grey-4';
};
</script>

<style scoped>
.text-truncate {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.flex-1 {
  flex: 1 1 0;
}

/*
 * Pagination
 */
.resource-pagination {
  color: var(--q-dark-page);
}

/*
 * Dark mode pagination
 */
.body--dark .resource-pagination {
  color: #cfd3dc;
}

.body--dark .resource-pagination :deep(.q-btn) {
  color: #cfd3dc;
}

.body--dark .resource-pagination :deep(.q-btn--active) {
  background: var(--q-primary);
  color: white;
}

.body--dark .resource-pagination :deep(.q-btn--disabled) {
  color: #666b75 !important;
}

/*
 * Dark mode card text
 */
:global(body.body--dark)
.analytics-card
.text-grey-9 {
  color: #edf2f7 !important;
}

:global(body.body--dark)
.analytics-card
.text-grey-6 {
  color: #b8c7d1 !important;
}
</style>