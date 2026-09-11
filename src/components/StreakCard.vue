<template>
  <div class="row items-center justify-between q-px-md q-py-sm">
    <div class="streak-card row items-center">
      <q-icon name="local_fire_department" color="orange" size="22px" />

      <div class="q-ml-sm">
        <div class="text-weight-bold text-caption">{{ streak }} Day streak</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  streak: number;
}

defineProps<Props>();
</script>

<style scoped>
.streak-card {
  background: linear-gradient(135deg, #ffd700 0%, #ffa500 100%);
  padding: 6px 12px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 6px;
  box-shadow: 0 2px 8px rgba(255, 215, 0, 0.3);

  font-size: 16px;
  font-weight: bold;
  color: #8b4513;
}
</style>
