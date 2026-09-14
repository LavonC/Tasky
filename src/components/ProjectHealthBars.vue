<template>
  <q-card flat bordered class="bg-white q-pa-md">
    <div class="text-subtitle1 text-weight-bold">Project Health</div>
    <div class="text-caption text-grey-7 q-mb-lg">Progress across active projects</div>
    <div v-if="projects.length" class="column q-gutter-md">
      <div v-for="project in projects" :key="project.id">
        <div class="row justify-between items-center q-mb-xs">
          <span class="text-body2 text-weight-medium ellipsis">{{ project.name }}</span>
          <span class="text-caption text-weight-bold">{{ Math.round(Number(project.progress || 0)) }}%</span>
        </div>
        <q-linear-progress :value="Math.min(Number(project.progress || 0) / 100, 1)" :color="getColor(project.progress)" track-color="grey-3" rounded size="9px" />
      </div>
    </div>
    <div v-else class="text-center text-grey-6 q-pa-md text-caption">No project health data available.</div>
  </q-card>
</template>

<script setup lang="ts">
defineProps<{ projects: any[] }>();
const getColor = (progress: number) => Number(progress || 0) >= 80 ? 'positive' : Number(progress || 0) >= 40 ? 'primary' : 'warning';
</script>
