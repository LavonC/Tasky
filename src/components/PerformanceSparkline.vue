<template>
  <div ref="sparklineContainer" class="sparkline-container"></div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, nextTick } from 'vue';
import * as d3 from 'd3';
import { useD3Resize } from '../composables/useD3Resize';

interface Props {
  data: number[];
  color: string;
  height?: number;
}

const props = withDefaults(defineProps<Props>(), {
  height: 30,
});

const sparklineContainer = ref<HTMLElement | null>(null);

function renderSparkline() {
  if (!sparklineContainer.value || !props.data.length) return;

  const container = sparklineContainer.value;
  container.innerHTML = '';

  const width = container.clientWidth || 100;
  const height = props.height;

  const svg = d3.select(container).append('svg').attr('width', width).attr('height', height);

  const x = d3
    .scaleLinear()
    .domain([0, props.data.length - 1])
    .range([0, width]);
  const y = d3
    .scaleLinear()
    .domain([d3.min(props.data) || 0, d3.max(props.data) || 0])
    .range([height, 0]);

  const line = d3
    .line<number>()
    .x((d, i) => x(i))
    .y((d) => y(d))
    .curve(d3.curveMonotoneX);

  const area = d3
    .area<number>()
    .x((d, i) => x(i))
    .y0(height)
    .y1((d) => y(d))
    .curve(d3.curveMonotoneX);

  // Add gradient
  const defs = svg.append('defs');
  const gradient = defs
    .append('linearGradient')
    .attr('id', 'sparkline-gradient')
    .attr('x1', '0%')
    .attr('y1', '0%')
    .attr('x2', '0%')
    .attr('y2', '100%');

  gradient
    .append('stop')
    .attr('offset', '0%')
    .attr('stop-color', props.color)
    .attr('stop-opacity', 0.3);

  gradient
    .append('stop')
    .attr('offset', '100%')
    .attr('stop-color', props.color)
    .attr('stop-opacity', 0);

  // Draw area
  svg
    .append('path')
    .datum(props.data)
    .attr('fill', 'url(#sparkline-gradient)')
    .attr('d', area as any);

  // Draw line
  svg
    .append('path')
    .datum(props.data)
    .attr('fill', 'none')
    .attr('stroke', props.color)
    .attr('stroke-width', 2)
    .attr('d', line as any);
}

onMounted(() => {
  nextTick(() => {
    renderSparkline();
  });
});

watch(
  () => props.data,
  () => {
    nextTick(() => {
      renderSparkline();
    });
  },
  { deep: true },
);

useD3Resize(sparklineContainer, renderSparkline);
</script>

<style scoped>
.sparkline-container {
  width: 100%;
  height: 30px;
}
</style>