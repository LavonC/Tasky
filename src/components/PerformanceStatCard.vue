<template>
  <q-card flat bordered class="stat-card q-pa-md">
    <div class="row items-start justify-between">
      <q-avatar size="44px" :style="{ background: background }">
        <q-icon :name="icon" :style="{ color: color }" size="22px" />
      </q-avatar>
      <div v-if="trend" class="stat-trend" :class="positive ? 'text-positive' : 'text-grey-6'">
        {{ trend }}
      </div>
    </div>
    <div class="text-h4 text-weight-bold q-mt-md">
      {{ value }}
    </div>
    <div class="text-body2 text-weight-medium q-mt-xs">
      {{ label }}
    </div>
    <div class="text-caption text-grey-6 q-mt-xs">
      {{ description }}
    </div>
    <div class="sparkline-wrapper q-mt-sm">
      <PerformanceSparkline
        v-if="safeSparklineData.length > 0"
        :data="safeSparklineData"
        :color="color"
      />
    </div>
  </q-card>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import PerformanceSparkline from './PerformanceSparkline.vue';

interface Props {
  label: string;
  value: string | number;
  description: string;
  icon: string;
  color: string;
  background: string;
  trend?: string;
  positive: boolean;
  sparklineData?: number[];
}

const props = withDefaults(defineProps<Props>(), {
  trend: '',
  sparklineData: () => [],
});

const safeSparklineData = computed(() => props.sparklineData || []);
</script>

<style scoped>
.stat-card {
  border-radius: 12px;
  transition:
    transform 0.2s,
    box-shadow 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.stat-trend {
  font-size: 12px;
  font-weight: 500;
}

.sparkline-wrapper {
  height: 30px;
  width: 100%;
}
</style>