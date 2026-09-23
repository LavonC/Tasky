<template>
  <div
      class="trend-card q-mb-md"
      :class="{ 'trend-card--dark': $q.dark.isActive }"
    >
    <div class="trend-title">Task Completion Trend</div>

    <div class="trend-subtitle">Tasks completed over the last 7 days</div>

    <div ref="chartContainer" class="chart-container"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick, onBeforeUnmount, watch } from 'vue';
import { useQuasar } from 'quasar';
import * as d3 from 'd3';

const $q = useQuasar();

const props = withDefaults(defineProps<{ data?: Array<{ day?: string; date?: string; completed?: number }> }>(), {
  data: () => [],
});
const chartContainer = ref<HTMLElement>();

function renderChart() {
  if (!chartContainer.value) return;

  const data = props.data.map((item) => ({
    day: item.day || (item.date ? new Date(item.date).toLocaleDateString('en-US', { weekday: 'short' }) : ''),
    completed: Number(item.completed || 0),
  }));
  if (!data.length) return;

  chartContainer.value.innerHTML = '';

  const containerWidth = chartContainer.value.clientWidth || 600;

  const width = Math.max(containerWidth, 300);
  const height = 135;
  const isDark = $q.dark.isActive;
  const chartText = isDark ? '#edf2f7' : '#555';
  const axisText = isDark ? '#b8c7d1' : '#777';
  const gridStroke = isDark ? '#34434c' : '#eeeeee';

  const margin = {
    top: 25,
    right: 20,
    bottom: 35,
    left: 38,
  };

  const svg = d3
    .select(chartContainer.value)
    .append('svg')
    .attr('width', '100%')
    .attr('height', height)
    .attr('viewBox', `0 0 ${width} ${height}`)
    .attr('preserveAspectRatio', 'none');

  /*
   * X AXIS
   */
  const x = d3
    .scalePoint<string>()
    .domain(data.map((d) => d.day))
    .range([margin.left, width - margin.right]);

  /*
   * Y AXIS
   */
  const y = d3
    .scaleLinear()
    .domain([0, Math.max(5, d3.max(data, (d) => d.completed) || 0)])
    .range([height - margin.bottom, margin.top]);

  /*
   * GRID LINES
   */
  svg
    .append('g')
    .attr('class', 'grid')
    .attr('transform', `translate(${margin.left},0)`)
    .call(
      d3
        .axisLeft(y)
        .ticks(3)
        .tickSize(-(width - margin.left - margin.right))
        .tickFormat(() => ''),
    )
    .selectAll('line')
    .attr('stroke', gridStroke)
    .attr('stroke-width', 1);

  svg.select('.grid .domain').remove();

  /*
   * Y AXIS LABELS
   */
  svg
    .append('g')
    .attr('transform', `translate(${margin.left},0)`)
    .call(
      d3
        .axisLeft(y)
        .ticks(3)
        .tickSize(0),
    )
    .call((g) => {
      g.select('.domain').remove();

      g.selectAll('.tick text')
        .attr('fill', axisText)
        .attr('font-size', '10px')
        .attr('dx', '-8px');
    });

  /*
   * X AXIS
   */
  svg
    .append('g')
    .attr(
      'transform',
      `translate(0,${height - margin.bottom})`,
    )
    .call(d3.axisBottom(x).tickSize(0))
    .call((g) => {
      g.select('.domain').remove();

      g.selectAll('.tick text')
        .attr('fill', axisText)
        .attr('font-size', '10px')
        .attr('dy', '12px');
    });

  /*
   * BARS
   */
  const barWidth = Math.min((width - margin.left - margin.right) / data.length * 0.6, 40);

  svg
    .selectAll('.bar')
    .data(data)
    .enter()
    .append('rect')
    .attr('class', 'bar')
    .attr('x', (d) => (x(d.day) ?? 0) - barWidth / 2)
    .attr('y', (d) => y(d.completed))
    .attr('width', barWidth)
    .attr('height', (d) => (height - margin.bottom) - y(d.completed))
    .attr('fill', '#3949ab')
    .attr('stroke', isDark ? '#1d2930' : 'white')
    .attr('stroke-width', 1.5)
    .attr('rx', 4)
    .attr('ry', 4);

  /*
   * VALUES ABOVE BARS
   */
  svg
    .selectAll('.value-label')
    .data(data)
    .enter()
    .append('text')
    .attr('x', (d) => x(d.day) ?? 0)
    .attr('y', (d) => y(d.completed) - 8)
    .attr('text-anchor', 'middle')
    .attr('font-size', '9px')
    .attr('font-weight', '600')
    .attr('fill', chartText)
    .text((d) => d.completed);
}

/*
 * INITIAL RENDER
 */
onMounted(async () => {
  await nextTick();
  renderChart();

  window.addEventListener('resize', renderChart);
});

watch(() => props.data, renderChart, { deep: true });

watch(() => $q.dark.isActive, async () => {
  await nextTick();
  renderChart();
});

/*
 * CLEANUP
 */
onBeforeUnmount(() => {
  window.removeEventListener('resize', renderChart);
});
</script>

<style scoped>
.trend-card {
  background: #ffffff;
  color: #111111;
  padding: 24px 18px 24px;
  border-radius: 12px;
  border: 1px solid #e5eaf0;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.12);
  width: 100%;
  box-sizing: border-box;
  transition:
    background-color 0.2s ease,
    color 0.2s ease,
    border-color 0.2s ease;
}

.trend-card--dark {
  background: #1d2930 !important;
  color: #edf2f7 !important;
  border-color: #34434c !important;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.35);
}

.trend-title {
  font-size: 17px;
  font-weight: 700;
  color: #111111;
  margin-bottom: 7px;
}

.trend-card--dark .trend-title {
  color: #edf2f7 !important;
}

.trend-subtitle {
  font-size: 13px;
  color: #999999;
  margin-bottom: 8px;
}

.trend-card--dark .trend-subtitle {
  color: #b8c7d1 !important;
}

.chart-container {
  width: 100%;
  height: 115px;
  overflow: hidden;
}
</style>
