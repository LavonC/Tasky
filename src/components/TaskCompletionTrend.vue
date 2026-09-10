<template>
  <div class="trend-card q-mb-md">
    <div class="trend-title">Task Completion Trend</div>

    <div class="trend-subtitle">
      Tasks completed over the last 7 days
    </div>

    <div ref="chartContainer" class="chart-container"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick, onBeforeUnmount } from 'vue';
import * as d3 from 'd3';

const chartContainer = ref<HTMLElement>();

const data = [
  { day: 'Mon', completed: 2 },
  { day: 'Tue', completed: 4 },
  { day: 'Wed', completed: 3 },
  { day: 'Thu', completed: 6 },
  { day: 'Fri', completed: 5 },
  { day: 'Sat', completed: 8 },
  { day: 'Sun', completed: 7 },
];

function renderChart() {
  if (!chartContainer.value) return;

  chartContainer.value.innerHTML = '';

  const containerWidth = chartContainer.value.clientWidth || 600;

  const width = Math.max(containerWidth, 300);
  const height = 135;

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
    .domain([0, 15])
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
        .tickValues([0, 5, 10, 15])
        .tickSize(-(width - margin.left - margin.right))
        .tickFormat(() => ''),
    )
    .selectAll('line')
    .attr('stroke', '#eeeeee')
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
        .tickValues([0, 5, 10, 15])
        .tickSize(0),
    )
    .call((g) => {
      g.select('.domain').remove();

      g.selectAll('.tick text')
        .attr('fill', '#8a8a8a')
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
        .attr('fill', '#777')
        .attr('font-size', '10px')
        .attr('dy', '12px');
    });

  /*
   * LINE
   */
  const line = d3
    .line<{ day: string; completed: number }>()
    .x((d) => x(d.day) ?? 0)
    .y((d) => y(d.completed))
    .curve(d3.curveMonotoneX);

  /*
   * AREA UNDER LINE
   */
  const area = d3
    .area<{ day: string; completed: number }>()
    .x((d) => x(d.day) ?? 0)
    .y0(height - margin.bottom)
    .y1((d) => y(d.completed))
    .curve(d3.curveMonotoneX);

  /*
   * GRADIENT
   */
  const gradient = svg
    .append('defs')
    .append('linearGradient')
    .attr('id', 'trendGradient')
    .attr('x1', '0%')
    .attr('x2', '0%')
    .attr('y1', '0%')
    .attr('y2', '100%');

  gradient
    .append('stop')
    .attr('offset', '0%')
    .attr('stop-color', '#5b7cfa')
    .attr('stop-opacity', 0.25);

  gradient
    .append('stop')
    .attr('offset', '100%')
    .attr('stop-color', '#5b7cfa')
    .attr('stop-opacity', 0.02);

  /*
   * AREA
   */
  svg
    .append('path')
    .datum(data)
    .attr('fill', 'url(#trendGradient)')
    .attr('d', area);

  /*
   * LINE
   */
  svg
    .append('path')
    .datum(data)
    .attr('fill', 'none')
    .attr('stroke', '#3949ab')
    .attr('stroke-width', 2)
    .attr('stroke-linecap', 'round')
    .attr('stroke-linejoin', 'round')
    .attr('d', line);

  /*
   * POINTS
   */
  svg
    .selectAll('.point')
    .data(data)
    .enter()
    .append('circle')
    .attr('cx', (d) => x(d.day) ?? 0)
    .attr('cy', (d) => y(d.completed))
    .attr('r', 2.5)
    .attr('fill', '#3949ab')
    .attr('stroke', 'white')
    .attr('stroke-width', 1.5);

  /*
   * VALUES ABOVE POINTS
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
    .attr('fill', '#555')
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
  padding: 20px 18px 14px;
  border-radius: 12px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.12);
  width: 100%;
  box-sizing: border-box;
}

.trend-title {
  font-size: 17px;
  font-weight: 700;
  color: #111111;
  margin-bottom: 7px;
}

.trend-subtitle {
  font-size: 13px;
  color: #999999;
  margin-bottom: 8px;
}

.chart-container {
  width: 100%;
  height: 120px;
  overflow: hidden;
}
</style>