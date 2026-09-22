<template>
  <q-card flat bordered class="q-pa-lg">
    <div class="row justify-between items-center q-mb-md">
      <div>
        <div class="text-h6 text-weight-bold">{{ title }}</div>
        <div class="text-body2 text-grey-6">{{ subtitle }}</div>
      </div>
      <q-select
        v-if="showPeriodSelector"
        v-model="selectedPeriod"
        :options="periodOptions"
        outlined
        dense
        style="width: 140px"
        @update:model-value="handlePeriodChange"
      />
    </div>

    <div ref="heatmapContainer" class="heatmap-container"></div>

    <div class="row justify-center q-gutter-md q-mt-md">
      <div class="row items-center q-gutter-xs">
        <span class="text-caption text-grey-6">Less activity</span>
        <div class="legend-box" style="background: #f0f0f0"></div>
        <div class="legend-box" style="background: #d9e7f2"></div>
        <div class="legend-box" style="background: #a6c8e8"></div>
        <div class="legend-box" style="background: #5b9bd5"></div>
        <div class="legend-box" style="background: #2e5c8a"></div>
        <span class="text-caption text-grey-6">More activity</span>
      </div>
    </div>
  </q-card>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, nextTick } from 'vue';
import * as d3 from 'd3';
import { useD3Resize } from '../composables/useD3Resize';

interface ActivityData {
  activity_date: string;
  activity_count: number;
  day_status?: string;
}

interface Props {
  title: string;
  subtitle: string;
  data: ActivityData[];
  showPeriodSelector?: boolean;
  periodOptions?: string[];
  selectedPeriod?: string;
}

const props = withDefaults(defineProps<Props>(), {
  showPeriodSelector: true,
  periodOptions: () => ['This Week', 'This Month', 'Last 3 Months'],
});

const emit = defineEmits(['period-change']);

const selectedPeriod = ref(props.selectedPeriod || props.periodOptions[1]);
const heatmapContainer = ref<HTMLElement | null>(null);

watch(() => props.selectedPeriod, (value) => {
  if (value) selectedPeriod.value = value;
});

function handlePeriodChange(value: string) {
  emit('period-change', value);
}

function renderHeatmap() {
  if (!heatmapContainer.value) return;

  const container = heatmapContainer.value;
  container.innerHTML = '';

  const width = container.clientWidth || 500;
  const height = 200;
  const margin = { top: 30, right: 20, bottom: 40, left: 50 };

  const svg = d3.select(container).append('svg').attr('width', width).attr('height', height);

  // Use the selected data range rather than anchoring cells to the current day.
  const dates = props.data.map((item) => new Date(`${item.activity_date}T00:00:00Z`));
  const firstDate = dates.length ? new Date(Math.min(...dates.map((date) => date.getTime()))) : new Date();
  const lastDate = dates.length ? new Date(Math.max(...dates.map((date) => date.getTime()))) : firstDate;
  const firstMonday = new Date(firstDate);
  firstMonday.setUTCDate(firstMonday.getUTCDate() - (firstMonday.getUTCDay() || 7) + 1);
  const weeks = Math.max(1, Math.ceil((lastDate.getTime() - firstMonday.getTime() + 86400000) / (7 * 86400000)));
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const cellSize = (width - margin.left - margin.right) / weeks;
  const rowHeight = (height - margin.top - margin.bottom) / days.length;

  // Create activity map
  const activityMap = new Map<string, { count: number; status: string }>();
  props.data.forEach((item) => {
    const date = new Date(`${item.activity_date}T00:00:00Z`);
    const dayIndex = date.getDay();
    const adjustedDayIndex = dayIndex === 0 ? 6 : dayIndex - 1; // Convert to Mon-Sun (0-6)
    const weekIndex = Math.floor((date.getTime() - firstMonday.getTime()) / (7 * 24 * 60 * 60 * 1000));
    const key = `${weekIndex}-${adjustedDayIndex}`;
    activityMap.set(key, { count: item.activity_count, status: item.day_status || 'no-entry' });
  });

  // Color scale
  const maxActivity = d3.max(props.data, (d) => d.activity_count) || 1;
  const colorScale = d3
    .scaleLinear<string>()
    .domain([0, maxActivity])
    .range(['#f0f0f0', '#2e5c8a']);

  // Draw cells
  for (let week = 0; week < weeks; week++) {
    for (let day = 0; day < days.length; day++) {
      const key = `${week}-${day}`;
      const activityData = activityMap.get(key) || { count: 0, status: 'no-entry' };

      const x = margin.left + week * cellSize;
      const y = margin.top + day * rowHeight;

      // Red color for leave days
      let fillColor = '#f0f0f0';
      if (activityData.status === 'leave') {
        fillColor = '#ef5350'; // Red for leave
      } else if (activityData.count > 0) {
        fillColor = colorScale(activityData.count);
      }

      svg
        .append('rect')
        .attr('x', x)
        .attr('y', y)
        .attr('width', cellSize - 2)
        .attr('height', rowHeight - 2)
        .attr('fill', fillColor)
        .attr('rx', 3)
        .attr('stroke', '#e0e0e0')
        .attr('stroke-width', 1)
        .style('cursor', 'pointer')
        .on('mouseover', function () {
          d3.select(this).attr('stroke', '#1976d2').attr('stroke-width', 2);
        })
        .on('mouseout', function () {
          d3.select(this).attr('stroke', '#e0e0e0').attr('stroke-width', 1);
        })
        .append('title')
        .text(`${days[day]}: ${activityData.count} activities${activityData.status === 'leave' ? ' (Leave)' : ''}`);
    }
  }

  // Add day labels
  days.forEach((day, index) => {
    svg
      .append('text')
      .attr('x', margin.left - 10)
      .attr('y', margin.top + index * rowHeight + rowHeight / 2)
      .attr('text-anchor', 'end')
      .attr('dominant-baseline', 'middle')
      .style('font-size', '11px')
      .style('fill', '#666')
      .text(day);
  });

  // Add week labels
  for (let week = 0; week < weeks; week++) {
    svg
      .append('text')
      .attr('x', margin.left + week * cellSize + cellSize / 2)
      .attr('y', margin.top - 10)
      .attr('text-anchor', 'middle')
      .style('font-size', '11px')
      .style('fill', '#666')
      .text(`W${week + 1}`);
  }
}

onMounted(() => {
  nextTick(() => {
    renderHeatmap();
  });
});

watch(
  () => props.data,
  () => {
    nextTick(() => {
      renderHeatmap();
    });
  },
  { deep: true },
);

useD3Resize(heatmapContainer, renderHeatmap);
</script>

<style scoped>
.heatmap-container {
  width: 100%;
  height: 200px;
}

.legend-box {
  width: 16px;
  height: 16px;
  border-radius: 3px;
  border: 1px solid #e0e0e0;
}
</style>