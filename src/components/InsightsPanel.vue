<template>
  <q-card flat bordered class="q-pa-lg">
    <div class="text-h6 text-weight-bold q-mb-md">{{ title }}</div>
    <div class="text-body2 text-grey-6 q-mb-lg">{{ subtitle }}</div>

    <div class="column q-gutter-md">
      <q-card
        v-for="insight in insights"
        :key="insight.text"
        flat
        bordered
        class="insight-card q-pa-md"
      >
        <div class="row items-start q-gutter-md">
          <q-avatar :color="insight.color" text-color="white" size="32px">
            <q-icon :name="insight.icon" size="18px" />
          </q-avatar>
          <div class="col">
            <div class="text-body1 text-weight-medium">{{ insight.text }}</div>
          </div>
        </div>
      </q-card>
    </div>
  </q-card>
</template>

<script setup lang="ts">
interface Insight {
  icon: string;
  color: string;
  text: string;
}

interface Props {
  title: string;
  subtitle: string;
  insights: Insight[];
}

defineProps<Props>();
</script>

<style scoped>
.insight-card {
  border-radius: 8px;
  transition: all 0.2s ease;
}

.insight-card:hover {
  transform: translateX(4px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
</style>