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

    <div class="column q-gutter-md q-mb-lg">
      <div v-for="item in workloadItems" :key="item.label">
        <div class="row justify-between q-mb-xs">
          <span class="text-body2 text-grey-7">{{ item.label }}</span>
          <span class="text-body2 text-weight-bold">{{ item.value.toFixed(1) }}h</span>
        </div>
        <q-linear-progress
          :value="item.percentage / 100"
          :color="item.color"
          rounded
          size="8px"
          track-color="grey-3"
        />
      </div>
    </div>

    <div class="row items-center q-gutter-lg">
      <div class="column items-center">
        <q-circular-progress
          :value="efficiency === null ? 0 : efficiency / 100"
          size="80px"
          :thickness="0.2"
          color="primary"
          track-color="grey-3"
          class="q-mb-sm"
        >
          <div class="text-h6 text-weight-bold">{{ efficiency === null ? '--' : `${efficiency}%` }}</div>
          <div class="text-caption text-grey-6">Efficiency</div>
        </q-circular-progress>
      </div>

      <q-banner v-if="efficiencyMessage" class="bg-blue-1 text-blue-9" dense rounded>
        <template v-slot:avatar>
          <q-icon name="trending_up" color="primary" />
        </template>
        {{ efficiencyMessage }}
      </q-banner>
    </div>
  </q-card>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';

interface WorkloadItem {
  label: string;
  value: number;
  percentage: number;
  color: string;
}

interface Props {
  title: string;
  subtitle: string;
  workloadItems: WorkloadItem[];
  efficiency: number | null;
  efficiencyMessage?: string;
  showPeriodSelector?: boolean;
  periodOptions?: string[];
  selectedPeriod?: string;
}

const props = withDefaults(defineProps<Props>(), {
  showPeriodSelector: true,
  periodOptions: () => ['This Week', 'This Month', 'Last 3 Months'],
  efficiencyMessage: '',
});

const emit = defineEmits(['period-change']);

const selectedPeriod = ref(props.selectedPeriod || props.periodOptions[1]);

watch(() => props.selectedPeriod, (value) => {
  if (value) selectedPeriod.value = value;
});

function handlePeriodChange(value: string) {
  emit('period-change', value);
}
</script>

<style scoped>
.q-circular-progress {
  font-size: 12px;
}
</style>