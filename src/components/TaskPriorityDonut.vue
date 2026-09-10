<template>
  <div class="bg-white q-pa-md shadow-1 q-mb-md" style="border-radius: 12px">
    <div class="text-subtitle1 text-weight-bold q-mb-lg">
      Task Priority Distribution
    </div>

    <div v-if="analyticsStore.loading" class="flex flex-center q-pa-md">
      <q-spinner-dots size="24px" color="primary" />
    </div>

    <div v-else-if="items.length > 0" class="row items-center no-wrap">
      <!-- Donut -->
      <div
        class="donut-chart q-mr-lg"
        :style="{ background: donutBackground }"
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
            style="font-size: 16px; color: #333; line-height: 1.2"
          >
            {{ total }}
          </div>
        </div>
      </div>

      <!-- Legend -->
      <div class="column flex-1" style="gap: 12px">
        <div
          v-for="(item, index) in items"
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

    <div v-else class="text-center text-grey-6 q-pa-md text-caption">
      No task priority data available.
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useAnalyticsStore } from '../stores/analyticsStore';

const analyticsStore = useAnalyticsStore();

const priorityColors: Record<string, string> = {
  critical: '#f44336',
  high: '#ff9800',
  medium: '#2196f3',
  low: '#4caf50',
};

const total = computed(() => {
  return Number(analyticsStore.taskDistribution?.total || 0);
});

const items = computed(() => {
  const priorityData = analyticsStore.taskDistribution?.priority;

  if (!priorityData || total.value === 0) {
    return [];
  }

  const order = ['critical', 'high', 'medium', 'low'];

  return order
    .filter((priority) => Number(priorityData[priority]) > 0)
    .map((priority) => {
      const count = Number(priorityData[priority]);

      return {
        label:
          priority.charAt(0).toUpperCase() +
          priority.slice(1),
        value: count,
        percent: Math.round((count / total.value) * 100),
        color: priorityColors[priority],
      };
    });
});

const donutBackground = computed(() => {
  let current = 0;

  const segments = items.value.map((item) => {
    const start = current;
    current += (item.value / total.value) * 360;

    return `${item.color} ${start}deg ${current}deg`;
  });

  return `conic-gradient(${segments.join(', ')})`;
});
</script>

<style scoped>
.donut-chart {
  width: 110px;
  height: 110px;
  min-width: 110px;
  border-radius: 50%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.donut-hole {
  width: 68px;
  height: 68px;
  border-radius: 50%;
  background: white;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}
</style>