<template>
  <q-card flat bordered class="quick-add-card q-pa-lg q-mb-lg">
    <div class="row items-center">
      <q-avatar size="48px" class="quick-add-icon">
        <q-icon name="add_task" size="25px" />
      </q-avatar>
      <div class="q-ml-md">
        <div class="quick-add-title">Self-Assign Task</div>
        <div class="quick-add-subtitle">
          Create and assign a new task to yourself to track your work.
        </div>
      </div>
      <q-space />
      <q-btn
        unelevated
        no-caps
        color="white"
        text-color="black"
        icon="person_add"
        label="Self-Assign Task"
        class="q-px-lg"
        @click="$emit('create')"
      />
    </div>
  </q-card>
</template>

<script setup lang="ts">
defineEmits(['create']);
</script>

<style scoped>
.quick-add-card {
  border-radius: 12px;
  background: #06518e;
  color: #faffd9;
  border-color: #e5eaf0;
  box-shadow: 0 7px 20px rgba(32, 54, 83, 0.05);
}

.quick-add-icon {
  background: #e8eaf6;
  color: #3949ab;
}

.quick-add-title {
  font-size: 18px;
  font-weight: 600;
  color: #ffffff;
}

.quick-add-subtitle {
  font-size: 14px;
  color: #ffffff;
}

:global(body.body--dark) .quick-add-card {
  background: #07558f !important;
  border-color: #34434c !important;
  color: #faffd9 !important;
}

:global(body.body--dark) .quick-add-title,
:global(body.body--dark) .quick-add-subtitle {
  color: #ffffff !important;
}

</style>
