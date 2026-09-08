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

    <div class="row items-center q-gutter-lg">
      <div ref="donutContainer" class="donut-container"></div>

      <div class="column q-gutter-sm">
        <div v-for="item in data" :key="item.label" class="row items-center q-gutter-sm">
          <div class="legend-dot" :style="{ background: item.color }"></div>
          <span class="text-body2">{{ item.label }}</span>
          <span class="text-body2 text-weight-bold">{{ item.value }}</span>
          <span class="text-caption text-grey-6">({{ item.percentage }}%)</span>
        </div>
      </div>
    </div>
  </q-card>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, nextTick, computed } from 'vue';
import * as d3 from 'd3';
import { useD3Resize } from '../composables/useD3Resize';

interface DonutData {
  label: string;
  value: number;
  percentage: number;
  color: string;
}

interface Props {
  title: string;
  subtitle: string;
  data: DonutData[];
  centerLabel?: string;
  showPeriodSelector?: boolean;
  periodOptions?: string[];
}

const props = withDefaults(defineProps<Props>(), {
  centerLabel: '',
  showPeriodSelector: true,
  periodOptions: () => ['This Week', 'This Month', 'Last 3 Months'],
});

const emit = defineEmits(['period-change']);

const selectedPeriod = ref(props.periodOptions[1]);
const donutContainer = ref<HTMLElement | null>(null);

const totalValue = computed(() => props.data.reduce((sum, item) => sum + item.value, 0));

function handlePeriodChange(value: string) {
  emit('period-change', value);
}

function renderDonut() {
  if (!donutContainer.value || !props.data.length) return;

  const container = donutContainer.value;
  container.innerHTML = '';

  const width = 200;
  const height = 200;
  const margin = 10;
  const radius = Math.min(width, height) / 2 - margin;

  const svg = d3
    .select(container)
    .append('svg')
    .attr('width', width)
    .attr('height', height)
    .append('g')
    .attr('transform', `translate(${width / 2}, ${height / 2})`);

  const pie = d3
    .pie<DonutData>()
    .value((d) => d.value)
    .sort(null);

  const arc = d3
    .arc<d3.PieArcDatum<DonutData>>()
    .innerRadius(radius * 0.6)
    .outerRadius(radius);

  const arcs = svg.selectAll('arc').data(pie(props.data)).enter().append('g').attr('class', 'arc');

  arcs
    .append('path')
    .attr('d', arc as any)
    .attr('fill', (d) => d.data.color)
    .attr('stroke', 'white')
    .attr('stroke-width', 2)
    .transition()
    .duration(1000)
    .attrTween('d', function (d) {
      const interpolate = d3.interpolate({ startAngle: 0, endAngle: 0 }, d);
      return function (t: any) {
        return arc(interpolate(t)) as any;
      };
    });

  // Add center label
  if (props.centerLabel || totalValue.value > 0) {
    const centerText = props.centerLabel || `Total ${totalValue.value}`;
    svg
      .append('text')
      .attr('text-anchor', 'middle')
      .attr('dy', '-0.2em')
      .style('font-size', '14px')
      .style('font-weight', 'bold')
      .text(centerText);

    if (!props.centerLabel) {
      svg
        .append('text')
        .attr('text-anchor', 'middle')
        .attr('dy', '1em')
        .style('font-size', '12px')
        .style('fill', '#666')
        .text('hours');
    }
  }
}

onMounted(() => {
  nextTick(() => {
    renderDonut();
  });
});

watch(
  () => props.data,
  () => {
    nextTick(() => {
      renderDonut();
    });
  },
  { deep: true },
);

useD3Resize(donutContainer, renderDonut);
</script>

<style scoped>
.donut-container {
  width: 200px;
  height: 200px;
}

.legend-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}
</style>