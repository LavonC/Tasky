<template>
  <div class="analytics-card bg-white q-pa-md shadow-1 q-mb-md" style="border-radius: 12px">
    <div class="text-subtitle1 text-weight-bold q-mb-lg">
      Task Status Distribution
    </div>

    <div v-if="analyticsStore.loading" class="flex flex-center q-pa-md">
      <q-spinner-dots size="24px" color="primary" />
    </div>

    <div
      v-else-if="analyticsStore.taskDistribution && legendItems.length > 0"
      class="row items-center no-wrap"
    >
      <!-- Donut Chart -->
      <div class="donut-wrapper q-mr-lg">
        <div
          class="donut-chart"
          :style="{ background: donutGradient }"
        >
          <div class="donut-hole">
            <div
              class="text-caption text-grey-6"
              style="font-size: 11px; line-height: 1.2"
            >
              Total
            </div>

            <div
              class="text-weight-bold"
              style="font-size: 16px; line-height: 1.2"
            >
              {{ analyticsStore.taskDistribution.total || 0 }}
            </div>
          </div>
        </div>
      </div>

      <!-- Legend -->
      <div class="column flex-1" style="gap: 12px">
        <div
          v-for="(item, index) in legendItems"
          :key="index"
          class="row items-center justify-between no-wrap"
        >
          <div class="row items-center no-wrap">
            <div
              class="legend-dot q-mr-sm"
              :style="{ backgroundColor: item.color }"
            ></div>

            <div class="text-grey-8" style="font-size: 12px">
              {{ item.label }}
            </div>
          </div>

          <div
            class="text-weight-bold text-grey-8"
            style="font-size: 12px"
          >
            {{ item.value }}

            <span class="text-grey-6 text-weight-regular q-ml-xs">
              ({{ item.percent }}%)
            </span>
          </div>
        </div>
      </div>
    </div>

    <div
      v-else
      class="text-center text-grey-6 q-pa-md text-caption"
    >
      No task distribution data available.
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useAnalyticsStore } from '../stores/analyticsStore';

const analyticsStore = useAnalyticsStore();

const statusColors: Record<string, string> = {
  'not-started': '#9e9e9e',
  'in-progress': '#2196f3',
  'in-review': '#9c27b0',
  completed: '#4caf50',
  blocked: '#f44336',
};

const legendItems = computed(() => {
  if (
    !analyticsStore.taskDistribution ||
    !analyticsStore.taskDistribution.status
  ) {
    return [];
  }

  const statusData = analyticsStore.taskDistribution.status;
  const total = analyticsStore.taskDistribution.total || 0;

  if (total === 0) return [];

  const items = [];

  for (const [status, count] of Object.entries(statusData)) {
    const value = Number(count);

    if (value > 0) {
      items.push({
        label: status
          .split('-')
          .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
          .join(' '),

        value,

        percent: Math.round((value / total) * 100),

        color: statusColors[status] || '#757575',
      });
    }
  }

  return items.sort((a, b) => b.value - a.value);
});

const donutGradient = computed(() => {
  if (legendItems.value.length === 0) {
    return '#e5e7eb';
  }

  let currentPercentage = 0;

  const segments = legendItems.value.map((item) => {
    const start = currentPercentage;
    const end = currentPercentage + item.percent;

    currentPercentage = end;

    return `${item.color} ${start}% ${end}%`;
  });

  return `conic-gradient(${segments.join(', ')})`;
});
</script>

<style scoped>
.donut-wrapper {
  width: 110px;
  height: 110px;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.donut-chart {
  width: 110px;
  height: 110px;
  border-radius: 50%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.donut-hole {
  position: absolute;
  width: 75px;
  height: 75px;
  border-radius: 50%;
  background: var(--donut-hole-bg, white);

  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  z-index: 1;
}

.legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

:global(body.body--dark) .analytics-card {
  --donut-hole-bg: #1d2930;
}
</style>