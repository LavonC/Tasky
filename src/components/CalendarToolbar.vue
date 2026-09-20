<template>
  <div class="calendar-toolbar">
    <!-- MONTH + YEAR -->
    <div class="calendar-month">
      {{ monthName }} {{ currentYear }}
    </div>

    <!-- NAVIGATION -->
    <div class="calendar-navigation">
      <q-btn
        flat
        round
        dense
        icon="chevron_left"
        aria-label="Previous month"
        class="calendar-nav-btn"
        @click="$emit('previous')"
      />

      <q-btn
        outline
        dense
        no-caps
        label="Today"
        class="today-btn"
        @click="$emit('today')"
      />

      <q-btn
        flat
        round
        dense
        icon="chevron_right"
        aria-label="Next month"
        class="calendar-nav-btn"
        @click="$emit('next')"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  monthName: string
  currentYear: number
}

defineProps<Props>()

defineEmits<{
  previous: []
  today: []
  next: []
}>()
</script>

<style scoped>
/* =========================================================
   CALENDAR TOOLBAR
   ========================================================= */

.calendar-toolbar {
  min-height: 74px;
  width: 100%;

  display: flex;
  align-items: center;
  justify-content: space-between;

  /* IMPORTANT:
     Do not use a white/light background here.
     The parent calendar-card controls the background.
  */
  background: transparent !important;

  border-bottom: 1px solid rgba(148, 163, 184, 0.25);

  padding: 0 18px;
  box-sizing: border-box;

  color: inherit;
}

/* =========================================================
   MONTH + YEAR
   ========================================================= */

.calendar-month {
  font-size: 32px !important;
  line-height: 1.2;
  font-weight: 700;
  letter-spacing: -0.02em;
}

/* =========================================================
   NAVIGATION
   ========================================================= */

.calendar-navigation {
  display: flex;
  align-items: center;
  gap: 4px;
}

.calendar-nav-btn {
  color: inherit !important;
}

.calendar-nav-btn :deep(.q-icon) {
  color: inherit !important;
}

/* =========================================================
   TODAY BUTTON
   ========================================================= */

.today-btn {
  color: inherit !important;
  border-color: currentColor !important;
}

.today-btn :deep(.q-btn__content) {
  color: inherit !important;
}

/* =========================================================
   LIGHT MODE
   ========================================================= */

:global(body:not(.body--dark)) .calendar-toolbar {
  background: #ffffff !important;
  color: #1f2937 !important;
  border-bottom-color: #e5e7eb;
}

:global(body:not(.body--dark)) .calendar-month {
  color: #1f2937 !important;
}

:global(body:not(.body--dark)) .calendar-nav-btn {
  color: #475569 !important;
}

:global(body:not(.body--dark)) .today-btn {
  color: #334155 !important;
  border-color: #cbd5e1 !important;
}

/* =========================================================
   DARK MODE
   ========================================================= */

/*
 * No hard-coded dark background here.
 * The toolbar simply inherits the dark calendar-card.
 */

:global(body.body--dark) .calendar-toolbar {
  background: transparent !important;
  color: #edf2f7 !important;
  border-bottom-color: #34434c !important;
}

:global(body.body--dark) .calendar-month {
  color: #edf2f7 !important;
}

:global(body.body--dark) .calendar-nav-btn {
  color: #edf2f7 !important;
}

:global(body.body--dark) .calendar-nav-btn :deep(.q-icon) {
  color: #edf2f7 !important;
}

:global(body.body--dark) .today-btn {
  color: #edf2f7 !important;
  border-color: #667781 !important;
}

:global(body.body--dark) .today-btn :deep(.q-btn__content) {
  color: #edf2f7 !important;
}
</style>