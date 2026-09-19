<template>
  <div class="row items-center justify-between q-gutter-md q-mb-md q-px-md">
    <!-- SEARCH BAR -->
    <!-- SEARCH BAR -->
    <div class="search-wrapper row items-center no-wrap">
      <!-- SEARCH TYPE -->
      <q-select
        v-model="searchType"
        :options="searchTypeOptions"
        borderless
        dense
        emit-value
        map-options
        class="search-type"
      />

      <q-separator vertical class="search-divider" />

      <!-- SEARCH INPUT -->
      <q-input
        :model-value="searchQuery"
        borderless
        dense
        :placeholder="searchPlaceholder"
        class="search-input"
        @update:model-value="$emit('search', $event)"
      >
        <template v-slot:prepend>
          <q-icon name="search" size="20px" color="grey-6" />
        </template>

        <!-- CLEAR SEARCH -->
        <template v-slot:append>
          <q-btn
            v-if="
              searchQuery ||
              selectedProject !== 'All Projects' ||
              selectedPriority !== 'All Priorities' ||
              selectedStatus !== 'All Statuses'
            "
            flat
            round
            dense
            icon="close"
            size="sm"
            color="grey-6"
            class="clear-search-btn"
            @click="clearSearch"
          >
            <q-tooltip>Clear search</q-tooltip>
          </q-btn>
        </template>
      </q-input>

      <!-- PROJECT DROPDOWN -->
      <q-select
        v-if="searchType === 'project'"
        :model-value="selectedProject"
        :options="projectOptions"
        outlined
        dense
        rounded
        emit-value
        map-options
        class="inside-filter"
        dropdown-icon="expand_more"
        @update:model-value="$emit('project-change', $event)"
      />

      <!-- PRIORITY DROPDOWN -->
      <q-select
        v-if="searchType === 'priority'"
        :model-value="selectedPriority"
        :options="priorityOptions"
        outlined
        dense
        rounded
        emit-value
        map-options
        class="inside-filter"
        dropdown-icon="expand_more"
        @update:model-value="$emit('priority-change', $event)"
      />

      <!-- STATUS DROPDOWN -->
      <q-select
        v-if="searchType === 'status'"
        :model-value="selectedStatus"
        :options="statusOptions"
        outlined
        dense
        rounded
        class="inside-filter"
        emit-value
        map-options
        dropdown-icon="expand_more"
        @update:model-value="$emit('status-change', $event)"
      />
    </div>

    <!-- ALL / SELF / PM -->
    <div class="task-type-toggle row items-center no-wrap">
      <!-- ALL -->
      <q-btn
        flat
        no-caps
        dense
        icon="list"
        label="All"
        :class="taskView === 'all' ? 'active-task-type' : 'task-type-btn'"
        @click="$emit('task-view-change', 'all')"
      />

      <!-- SELF -->
      <q-btn
        flat
        no-caps
        dense
        icon="person"
        label="Self"
        :class="taskView === 'self' ? 'active-task-type' : 'task-type-btn'"
        @click="$emit('task-view-change', 'self')"
      />

      <!-- PM -->
      <q-btn
        flat
        no-caps
        dense
        icon="groups"
        label="PM"
        :class="taskView === 'pm' ? 'active-task-type' : 'task-type-btn'"
        @click="$emit('task-view-change', 'pm')"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue';

interface Props {
  searchQuery: string;
  selectedProject: string;
  selectedPriority: string;
  selectedStatus: string;
  projects: Array<{ label: string; value: string }>;
  taskView: string;
}

const props = defineProps<Props>();

const emit = defineEmits([
  'search',
  'search-type-change',
  'project-change',
  'priority-change',
  'status-change',
  'task-view-change',
  'clear-filters',
]);

/* SEARCH TYPE */

const searchType = ref('task');

const searchTypeOptions = [
  {
    label: 'Task Name',
    value: 'task',
  },
  {
    label: 'Project',
    value: 'project',
  },
  {
    label: 'Priority',
    value: 'priority',
  },
  {
    label: 'Status',
    value: 'status',
  },
];

/* SEARCH PLACEHOLDER */

const searchPlaceholder = computed(() => {
  switch (searchType.value) {
    case 'project':
      return 'Search projects...';

    case 'priority':
      return 'Search priority...';

    case 'status':
      return 'Search status...';

    default:
      return 'Search tasks...';
  }
});

const clearSearch = () => {
  emit('search', '');

  emit('project-change', 'All Projects');

  emit('priority-change', 'All Priorities');

  emit('status-change', 'All Statuses');
};
/* PROJECT OPTIONS */

const projectOptions = computed(() => [
  {
    label: 'All Projects',
    value: 'All Projects',
  },
  ...props.projects,
]);

/* PRIORITY OPTIONS */

const priorityOptions = [
  {
    label: 'All Priorities',
    value: 'All Priorities',
  },
  {
    label: 'Critical',
    value: 'critical',
  },
  {
    label: 'High',
    value: 'high',
  },
  {
    label: 'Medium',
    value: 'medium',
  },
  {
    label: 'Low',
    value: 'low',
  },
];

/* STATUS OPTIONS */

const statusOptions = [
  {
    label: 'All Statuses',
    value: 'All Statuses',
  },
  {
    label: 'Not Started',
    value: 'not-started',
  },
  {
    label: 'In Progress',
    value: 'in-progress',
  },
  {
    label: 'Completed',
    value: 'completed',
  },
  {
    label: 'Blocked',
    value: 'blocked',
  },
];

/*
 * WHEN SEARCH TYPE CHANGES:
 * Reset search + all filters.
 */

watch(searchType, (newType) => {
  emit('search-type-change', newType);

  emit('search', '');

  emit('project-change', 'All Projects');

  emit('priority-change', 'All Priorities');

  emit('status-change', 'All Statuses');
});
</script>

<style scoped>
.search-wrapper {
  flex: 1;
  min-width: 350px;
  max-width: 650px;
  height: 46px;

  background: white;

  border: 1px solid #dce6f0;
  border-radius: 12px;

  transition: 0.2s ease;
}

.search-wrapper:focus-within {
  border-color: #64b5f6;
  box-shadow: 0 0 0 3px rgba(33, 150, 243, 0.08);
}

/* SEARCH TYPE */

.search-type {
  width: 125px;
  padding-left: 10px;

  color: #1565c0;
  font-size: 13px;
  font-weight: 600;
}

.search-type :deep(.q-field__control) {
  min-height: 44px;
}

/* DIVIDER */

.search-divider {
  height: 24px;
  background: #e3eaf2;
}

/* SEARCH INPUT */

.search-input {
  flex: 1;
  padding-left: 4px;
  padding-right: 8px;
}

.search-input :deep(.q-field__prepend) {
  padding-right: 5px;
}

/* DROPDOWN INSIDE SEARCH BAR */

.inside-filter {
  width: 150px;
  margin-right: 5px;
}

.inside-filter :deep(.q-field__control) {
  min-height: 36px;
}

.inside-filter :deep(.q-field__native) {
  font-size: 13px;
  font-weight: 600;
}

/* ALL / SELF / PM */

.task-type-toggle {
  height: 42px;

  padding: 3px;

  background: white;

  border: 1px solid #dce6f0;
  border-radius: 11px;
}

/* NORMAL BUTTON */

.task-type-btn {
  min-width: 72px;
  height: 34px;

  color: '#607d8b';

  border-radius: 8px;
}

/* ACTIVE BUTTON */

.active-task-type {
  min-width: 72px;
  height: 34px;

  background: #06518e;
  color: white;

  border-radius: 8px;

  box-shadow: 0 2px 6px rgba(33, 150, 243, 0.25);
}

/* RESPONSIVE */

@media (max-width: 900px) {
  .search-wrapper {
    max-width: none;
    width: 100%;
  }

  .task-type-toggle {
    width: 100%;
    justify-content: center;
  }
}

/* Dark mode */
:global(body.body--dark) .search-wrapper,
:global(body.body--dark) .task-type-toggle {
  background: #26343c !important;
  border-color: #34434c !important;
}

:global(body.body--dark) .search-type,
:global(body.body--dark) .search-input,
:global(body.body--dark) .inside-filter,
:global(body.body--dark) .task-type-btn {
  color: #edf2f7 !important;
}

:global(body.body--dark) .search-wrapper :deep(.q-field__control),
:global(body.body--dark) .search-wrapper :deep(.q-field__native),
:global(body.body--dark) .search-wrapper :deep(.q-field__input),
:global(body.body--dark) .search-wrapper :deep(.q-field__label),
:global(body.body--dark) .search-wrapper :deep(.q-field__marginal) {
  color: #edf2f7 !important;
}

:global(body.body--dark) .search-wrapper :deep(input::placeholder) {
  color: #91a2ad !important;
  opacity: 1;
}

:global(body.body--dark) .search-divider {
  background: #46555e !important;
}

:global(body.body--dark) .active-task-type {
  background: #06518e !important;
  color: #ffffff !important;
}

:global(body.body--dark) .task-type-btn {
  color: #b8c7d1 !important;
}

</style>
