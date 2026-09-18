<template>
  <q-card flat bordered class="q-pa-lg">
    <div class="text-h6 text-weight-bold q-mb-md">{{ title }}</div>
    <div class="text-body2 text-grey-6 q-mb-lg">{{ subtitle }}</div>

    <div class="row q-col-gutter-md">
      <div v-for="metric in metrics" :key="metric.label" class="col-12 col-sm-6">
        <q-card flat bordered class="metric-card analytics-card q-pa-md">
          <div class="row items-center justify-between q-mb-sm">
            <div class="text-body2 text-grey-7">{{ metric.label }}</div>
            <q-icon :name="metric.icon" :color="metric.color" size="16px" />
          </div>
          <div class="text-h5 text-weight-bold" :class="`text-${metric.color}`">
            {{ metric.value }}
          </div>
          <div
            class="text-caption"
            :class="metric.trendPositive ? 'text-positive' : 'text-negative'"
          >
            {{ metric.trend }}
          </div>
        </q-card>
      </div>
    </div>
  </q-card>
</template>

<script setup lang="ts">
interface QualityMetric {
  label: string;
  value: string | number;
  icon: string;
  color: string;
  trend: string;
  trendPositive: boolean;
}

interface Props {
  title: string;
  subtitle: string;
  metrics: QualityMetric[];
}

defineProps<Props>();
</script>

<style scoped>
.metric-card {
  border-radius: 8px;
  transition: all 0.2s ease;
}

.metric-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}
</style>
<style scoped>
:global(body.body--dark) .analytics-card {
  background: #1d2930 !important;
  border-color: #34434c !important;
}
:global(body.body--dark) .analytics-card .text-grey-7,
:global(body.body--dark) .analytics-card .text-grey-6 {
  color: #b8c7d1 !important;
}
</style>
