<template>
  <q-card flat bordered class="project-summary-card">
    <q-card-section class="q-pa-lg">
      <div class="row items-center justify-between q-mb-sm">
        <div class="row items-center q-gutter-sm">
          <div class="text-h6 text-weight-bold">Project Summary</div>
        </div>
        <q-btn
          unelevated
          color="green-6"
          icon="o_assessment"
          label="View Reports"
          no-caps
          class="rounded-borders"
          @click="emit('view-report')"
        />


      </div>

      <div class="text-body1 text-grey-8 summary-text">
        {{ summaryText }}
      </div>
    </q-card-section>
  </q-card>
</template>

<script setup lang="ts">
import { computed } from 'vue';

interface Project {
  status?: string;
  progress?: number;
}

interface DeadlineRisk {
  [key: string]: unknown;
}

interface Props {
  projects?: Project[];
  deadlineRisks?: DeadlineRisk[];
  inProgressTasks?: number;
  teamUtilization?: number | null;
}

const props = withDefaults(defineProps<Props>(), {
  projects: () => [],
  deadlineRisks: () => [],
  inProgressTasks: 0,
  teamUtilization: null,
});

const emit = defineEmits<{
  (event: 'view-report'): void;
}>();

const summaryText = computed(() => {
  const totalProjects = props.projects.length;

  const onTrackProjects = props.projects.filter((project) => {
    const status = String(project.status || '').toLowerCase().replace(/[_-]/g, ' ');
    return status === 'on track' || status === 'ontrack';
  }).length;

  const atRiskProjects = props.projects.filter((project) => {
    const status = String(project.status || '').toLowerCase().replace(/[_-]/g, ' ');
    return status === 'at risk' || status === 'atrisk';
  }).length;

  const approachingDeadlines = props.deadlineRisks.length;

  const projectPart =
    totalProjects > 0
      ? `${onTrackProjects} of ${totalProjects} projects are on track`
      : 'No project progress data is available';

  const taskPart =
    props.inProgressTasks === 1
      ? '1 task is in progress'
      : `${props.inProgressTasks} tasks are in progress`;

  const deadlinePart =
    approachingDeadlines === 1
      ? '1 task is approaching its deadline'
      : `${approachingDeadlines} tasks are approaching their deadlines`;

  let utilizationPart = 'Team utilization data is currently unavailable.';
  if (props.teamUtilization !== null && props.teamUtilization !== undefined) {
    utilizationPart = `Team utilization is currently ${Math.round(props.teamUtilization)}%.`;
  }

  const riskPart =
    atRiskProjects > 0
      ? ` ${atRiskProjects} project${atRiskProjects === 1 ? ' is' : 's are'} at risk.`
      : '';

  return `${projectPart}, ${taskPart}, while ${deadlinePart}.${riskPart} ${utilizationPart}`;
});
</script>

<style scoped>
.project-summary-card {
  border-radius: 12px;
  background: #ffffff;
}

.summary-text {
  line-height: 1.6;
  max-width: 900px;
}

.summary-link {
  font-weight: 600;
}
</style>
