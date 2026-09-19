<template>
  <div class="calendar-toolbar row items-center justify-between q-px-md">
    <div>
      <div class="calendar-month">{{ monthName }} {{ currentYear }}</div>
    </div>
    <div class="row items-center q-gutter-xs">
      <q-btn flat round dense icon="chevron_left" @click="$emit('previous')" />
      <q-btn outline dense no-caps color="primary" label="Today" @click="$emit('today')" />
      <q-btn flat round dense icon="chevron_right" @click="$emit('next')" />
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  monthName: string;
  currentYear: number;
}

defineProps<Props>();

defineEmits(['previous', 'today', 'next']);
</script>

<style scoped>
.calendar-toolbar {
  background: #f8f9fa;
  border-bottom: 1px solid #e0e0e0;
}

.calendar-kicker {
  font-size: 11px;
  font-weight: 600;
  color: #666;
  letter-spacing: 1px;
}

.calendar-month {
  font-size: 24px;
  font-weight: 600;
  color: #333;
}

:global(body.body--dark) .calendar-toolbar {
  background: #1d2930 !important;
  border-bottom-color: #34434c !important;
}

:global(body.body--dark) .calendar-month {
  color: #edf2f7 !important;
}

:global(body.body--dark) .calendar-toolbar .q-btn {
  color: #edf2f7 !important;
}

:global(body.body--dark) .calendar-toolbar .q-btn.q-btn--outline {
  color: #c4f64f !important;
  border-color: #c4f64f !important;
}

:global(body.body--dark) .calendar-toolbar .q-icon {
  color: #edf2f7 !important;
}

</style>
