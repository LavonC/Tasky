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

    <div v-if="showStats" class="row q-gutter-md q-mb-md">
      <div v-for="stat in stats" :key="stat.label" class="col-auto">
        <div class="row items-center q-gutter-xs">
          <q-icon :name="stat.icon" :color="stat.color" size="16px" />
          <span class="text-body2 text-grey-7">{{ stat.label }}:</span>
          <q-badge :color="stat.color">{{ stat.value }}</q-badge>
        </div>
      </div>
    </div>

    <div v-if="!data.length" class="chart-empty text-grey-6">No task trend data available.</div>
    <div v-else ref="chartContainer" class="chart-container"></div>

    <div class="row justify-center q-gutter-lg q-mt-md">
      <div v-for="series in seriesConfig" :key="series.key" class="row items-center q-gutter-xs">
        <div class="legend-box" :style="{ background: series.color }"></div>
        <span class="text-caption">{{ series.label }}</span>
      </div>
    </div>
  </q-card>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, nextTick } from 'vue';
import * as d3 from 'd3';
import { useD3Resize } from '../composables/useD3Resize';

interface TrendData {
  week: string;
  dateRange?: string;
  assigned?: number;
  completed?: number;
  delayed?: number;
  critical?: number;
  high?: number;
  medium?: number;
  low?: number;
}

interface Props {
  data: TrendData[];
  title: string;
  subtitle: string;
  seriesConfig: { key: string; label: string; color: string }[];
  showStats?: boolean;
  showPeriodSelector?: boolean;
  periodOptions?: string[];
}

const props = withDefaults(defineProps<Props>(), {
  showStats: true,
  showPeriodSelector: true,
  periodOptions: () => ['Weekly', 'Monthly'],
});

const emit = defineEmits(['period-change']);

const selectedPeriod = ref(props.periodOptions[0]);
const chartContainer = ref<HTMLElement | null>(null);

const stats = computed(() => {
  if (!props.data.length) return [];

  const totalAssigned = props.data.reduce((sum, item) => sum + (item.assigned || 0), 0);
  const totalCompleted = props.data.reduce((sum, item) => sum + (item.completed || 0), 0);
  const totalDelayed = props.data.reduce((sum, item) => sum + (item.delayed || 0), 0);

  const completionRate = totalAssigned > 0 ? (totalCompleted / totalAssigned) * 100 : 0;

  return [
    { label: 'Assigned', value: totalAssigned, icon: 'assignment', color: 'grey' },
    { label: 'Completed', value: totalCompleted, icon: 'check_circle', color: 'positive' },
    { label: 'Delayed', value: totalDelayed, icon: 'schedule', color: 'negative' },
    {
      label: 'Completion Rate',
      value: `${completionRate.toFixed(1)}%`,
      icon: 'trending_up',
      color: 'info',
    },
  ];
});

function handlePeriodChange(value: string) {
  emit('period-change', value);
}

function renderChart() {
  if (!chartContainer.value || !props.data.length) return;

  const container = chartContainer.value;
  container.innerHTML = '';

  const width = container.clientWidth || 600;
  const height = 250;
  const margin = { top: 20, right: 20, bottom: 40, left: 40 };

  const svg = d3.select(container).append('svg').attr('width', width).attr('height', height);

  // Get all series keys
  const seriesKeys = props.seriesConfig.map((s) => s.key);

  // Calculate max value for y-axis
  const maxValue =
    d3.max(props.data, (d) => d3.max(seriesKeys, (key) => (d as any)[key] || 0)) || 0;

  // Create scales
  const x = d3
    .scaleBand()
    .domain(props.data.map((d) => d.week))
    .range([margin.left, width - margin.right])
    .padding(0.3);

  const y = d3
    .scaleLinear()
    .domain([0, Math.max(1, maxValue * 1.1)])
    .range([height - margin.bottom, margin.top]);

  // Create color scale
  const colorScale = d3
    .scaleOrdinal<string, string>()
    .domain(seriesKeys)
    .range(props.seriesConfig.map((s) => s.color));

  // Add X axis
  svg
    .append('g')
    .attr('transform', `translate(0, ${height - margin.bottom})`)
    .call(d3.axisBottom(x) as any)
    .selectAll('text')
    .attr('transform', 'rotate(-45)')
    .style('text-anchor', 'end')
    .style('font-size', '11px');

  // Add Y axis
  svg
    .append('g')
    .attr('transform', `translate(${margin.left}, 0)`)
    .call(d3.axisLeft(y) as any)
    .style('font-size', '11px');

  // Add grid lines
  svg
    .append('g')
    .attr('transform', `translate(${margin.left}, 0)`)
    .call(
      d3
        .axisLeft(y)
        .tickSize(-(width - margin.left - margin.right))
        .tickFormat(() => '') as any,
    )
    .selectAll('line')
    .attr('stroke', '#e0e0e0')
    .attr('stroke-dasharray', '3,3');

  // Draw lines for each series
  seriesKeys.forEach((key) => {
    const line = d3
      .line<TrendData>()
      .x((d) => (x(d.week) || 0) + x.bandwidth() / 2)
      .y((d) => y((d as any)[key] || 0))
      .curve(d3.curveMonotoneX);

    const area = d3
      .area<TrendData>()
      .x((d) => (x(d.week) || 0) + x.bandwidth() / 2)
      .y0(height - margin.bottom)
      .y1((d) => y((d as any)[key] || 0))
      .curve(d3.curveMonotoneX);

    const color = colorScale(key) ?? '#1976d2';

    // Add gradient for area
    const defs = svg.append('defs');
    const gradient = defs
      .append('linearGradient')
      .attr('id', `gradient-${key}`)
      .attr('x1', '0%')
      .attr('y1', '0%')
      .attr('x2', '0%')
      .attr('y2', '100%');

    gradient
      .append('stop')
      .attr('offset', '0%')
      .attr('stop-color', color)
      .attr('stop-opacity', 0.3);

    gradient
      .append('stop')
      .attr('offset', '100%')
      .attr('stop-color', color)
      .attr('stop-opacity', 0);

    // Draw area
    svg
      .append('path')
      .datum(props.data)
      .attr('fill', `url(#gradient-${key})`)
      .attr('d', area as any)
      .attr('opacity', 0.5);

    // Draw line
    svg
      .append('path')
      .datum(props.data)
      .attr('fill', 'none')
      .attr('stroke', color)
      .attr('stroke-width', 2)
      .attr('d', line as any)
      .attr('stroke-linejoin', 'round')
      .attr('stroke-linecap', 'round');

    // Draw dots
    svg
      .selectAll(`dot-${key}`)
      .data(props.data)
      .enter()
      .append('circle')
      .attr('cx', (d) => (x(d.week) || 0) + x.bandwidth() / 2)
      .attr('cy', (d) => y((d as any)[key] || 0))
      .attr('r', 4)
      .attr('fill', color)
      .attr('stroke', 'white')
      .attr('stroke-width', 2);
  });
}

onMounted(() => {
  nextTick(() => {
    renderChart();
  });
});

watch(
  () => props.data,
  () => {
    nextTick(() => {
      renderChart();
    });
  },
  { deep: true },
);

useD3Resize(chartContainer, renderChart);
</script>

<style scoped>
.chart-container {
  width: 100%;
  height: 250px;
}

.chart-empty {
  height: 250px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.legend-box {
  width: 12px;
  height: 12px;
  border-radius: 3px;
}
</style>