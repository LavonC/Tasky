<template>
  <q-page class="app-page q-pa-lg">
    <!-- ========================================================= -->
    <!-- PAGE HEADER -->
    <!-- ========================================================= -->

    <div class="row items-center justify-end q-mb-lg">
      <div class="row items-center q-gutter-sm">
        <q-btn
          color="secondary"
          icon="auto_fix_high"
          label="Automate"
          class="q-px-md"
          @click="automateFullSchedule"
          :loading="automating"
        >
          <q-tooltip>Reorganize all tasks by priority with 3-day gaps</q-tooltip>
        </q-btn>
        <q-btn
          flat
          icon="lightbulb"
          color="blue-10"
          @click="showInsightsDialog = true"
          label="Insights"
          class="q-px-md"
        >
          <q-tooltip>View employee insights</q-tooltip>
        </q-btn>
        <div class="points-badge">
          <q-icon name="monetization_on" size="20px" color="#FFD700" />
          <span class="points-text">{{ userPoints }}</span>
          <q-badge color="amber-8" :label="`Rank #${userRank}`" class="q-ml-sm" />
        </div>
      </div>
    </div>

    <!-- ========================================================= -->
    <!-- STAT CARDS -->
    <!-- ========================================================= -->

    <div class="row q-col-gutter-md q-mb-lg">
      <div v-for="stat in stats" :key="stat.label" class="col-12 col-sm-6 col-md-3">
        <div
          v-if="stat.label === 'Overdue'"
          @click="openOverdueDialog"
          class="cursor-pointer"
          style="cursor: pointer;"
        >
          <EmployeeStatCard
            :label="stat.label"
            :value="stat.value"
            :description="stat.description"
            :icon="stat.icon"
            :color="stat.color"
            :trend="stat.trend"
            :positive="stat.positive"
          />
        </div>
        <EmployeeStatCard
          v-else
          :label="stat.label"
          :value="stat.value"
          :description="stat.description"
          :icon="stat.icon"
          :color="stat.color"
          :trend="stat.trend"
          :positive="stat.positive"
        />
      </div>
    </div>

    <!-- ========================================================= -->
    <!-- QUICK ADD TASK -->
    <!-- ========================================================= -->

    <QuickAddTaskCard @create="openAddTask" />

    <!-- ========================================================= -->
    <!-- MY TASKS -->
    <!-- ========================================================= -->

    <q-card flat bordered class="my-tasks-card overflow-hidden" style="align-self: flex-start">
      <!-- ======================================================= -->
      <!-- TASK HEADER -->
      <!-- ======================================================= -->

      <TaskListHeader
        title="My Tasks"
        :task-count="filteredTasks.length"
        :active-tab="activeTab"
        :active-tab-label="activeTabLabel"
        :view-mode="viewMode"
        :tabs="[
          { name: 'all', label: 'All Tasks' },
          { name: 'progress', label: 'In Progress' },
          { name: 'completed', label: 'Completed' },
        ]"
        @view-change="viewMode = $event"
        @tab-change="activeTab = $event"
      />

      <!-- ===================================================== -->
      <!-- FILTERS -->
      <!-- ===================================================== -->

      <TaskFilters
        :search-query="search"
        :selected-project="projectFilter"
        :selected-priority="priorityFilter"
        :selected-status="statusFilter"
        :projects="projectOptions"
        :task-view="taskView"
        @search="search = $event"
        @search-type-change="searchType = $event"
        @project-change="projectFilter = $event"
        @priority-change="priorityFilter = $event"
        @status-change="statusFilter = $event"
        @task-view-change="taskView = $event"
        @clear-filters="clearFilters"
      />

      <q-separator />

      <!-- ========================================================= -->
      <!-- LIST VIEW -->
      <!-- ========================================================= -->

      <q-table
        v-if="viewMode === 'list'"
        :rows="filteredTasks"
        :columns="columns"
        row-key="id"
        flat
        hide-pagination
        :rows-per-page-options="[0]"
        class="task-table"
      >
        <!-- TASK -->

        <template #body-cell-task="props">
          <q-td :props="props" class="cursor-pointer" @click="viewTask(props.row)">
            <div class="row items-center no-wrap">
              <q-avatar
                size="42px"
                :style="{
                  background: projectColor(props.row.project).bg,

                  color: projectColor(props.row.project).color,
                }"
              >
                <q-icon :name="projectIcon(props.row.project)" size="21px" />
              </q-avatar>

              <div class="q-ml-md">
                <div class="task-name">
                  {{ props.row.name }}
                </div>

                <div class="task-description">
                  {{ props.row.description }}
                </div>
              </div>
            </div>
          </q-td>
        </template>

        <!-- PROJECT -->

        <template #body-cell-project="props">
          <q-td :props="props">
            <div class="text-body2 text-weight-medium">
              {{ props.row.project }}
            </div>

            <div class="row items-center q-gutter-xs q-mt-xs">
              <q-badge
                :color="props.row.assignedBy === 'Self-Assigned' ? 'purple-1' : 'blue-1'"
                :text-color="props.row.assignedBy === 'Self-Assigned' ? 'purple-9' : 'blue-9'"
                :label="props.row.assignedBy"
                class="text-weight-medium q-px-xs"
              />
            </div>
          </q-td>
        </template>

        <!-- SUBTASKS -->

        <template #body-cell-subtasks="props">
          <q-td :props="props">
            <div class="subtask-count">
              <q-icon name="checklist" size="17px" class="q-mr-xs" />

              {{ completedSubtasks(props.row) }}
              /
              {{ props.row.subtasks.length }}
            </div>
          </q-td>
        </template>

        <!-- PRIORITY -->

        <template #body-cell-priority="props">
          <q-td :props="props">
            <q-chip
              dense
              square
              :style="{
                background: priorityStyle(props.row.priority).bg,

                color: priorityStyle(props.row.priority).color,
              }"
            >
              <q-icon name="flag" size="14px" class="q-mr-xs" />

              {{ props.row.priority }}
            </q-chip>
          </q-td>
        </template>

        <!-- STATUS -->

        <template #body-cell-status="props">
          <q-td :props="props">
            <q-chip
              dense
              square
              :style="{
                background: statusStyle(props.row.status).bg,

                color: statusStyle(props.row.status).color,
              }"
            >
              {{ props.row.status }}
            </q-chip>
          </q-td>
        </template>

        <!-- PROGRESS -->

        <template #body-cell-progress="props">
          <q-td :props="props">
            <div style="min-width: 145px">
              <div class="row justify-between">
                <span class="text-caption text-grey-6"> Progress </span>

                <span class="text-caption text-weight-bold"> {{ taskProgress(props.row) }}% </span>
              </div>

              <q-linear-progress
                :value="taskProgress(props.row) / 100"
                :color="isTaskDeadlineOnLeave(props.row) ? 'red' : 'primary'"
                track-color="grey-3"
                rounded
                size="7px"
                class="q-mt-xs"
              />
            </div>
          </q-td>
        </template>

        <!-- DEADLINE -->

        <template #body-cell-deadline="props">
          <q-td :props="props">
            <div :class="isOverdue(props.row) ? 'text-negative text-weight-bold' : 'text-dark'">
              {{ formatDate(props.row.deadline) }}
            </div>

            <div v-if="isOverdue(props.row)" class="text-caption text-negative">Overdue</div>

            <div v-if="isTaskDeadlineOnLeave(props.row)" class="text-caption text-negative q-mt-xs">
              <q-icon name="warning" size="12px" />
              Leave affected — {{ formatDate(props.row.deadline) }}
            </div>
          </q-td>
        </template>

        <!-- ACTIONS -->

        <template #body-cell-actions="props">
          <q-td :props="props">
            <q-btn flat round icon="more_horiz" color="grey-7">
              <q-menu>
                <q-list style="min-width: 190px">
                  <!-- VIEW -->

                  <q-item clickable v-close-popup @click="viewTask(props.row)">
                    <q-item-section avatar>
                      <q-icon name="visibility" />
                    </q-item-section>

                    <q-item-section> View Task </q-item-section>
                  </q-item>

                  <!-- EDIT -->

                  <q-item clickable v-close-popup @click="openEditSubtasks(props.row)">
                    <q-item-section avatar>
                      <q-icon name="edit" />
                    </q-item-section>

                    <q-item-section> Edit Subtasks </q-item-section>
                  </q-item>

                  <!-- MANAGE -->

                  <q-item clickable v-close-popup @click="openManage(props.row)">
                    <q-item-section avatar>
                      <q-icon name="tune" color="primary" />
                    </q-item-section>

                    <q-item-section> Manage Progress </q-item-section>
                  </q-item>

                  <q-separator />

                  <!-- DELETE -->

                  <q-item clickable v-close-popup @click="deleteTask(props.row)">
                    <q-item-section avatar>
                      <q-icon name="delete" color="negative" />
                    </q-item-section>

                    <q-item-section class="text-negative"> Delete Task </q-item-section>
                  </q-item>
                </q-list>
              </q-menu>
            </q-btn>
          </q-td>
        </template>
      </q-table>

      <!-- ========================================================= -->
      <!-- GRID VIEW -->
      <!-- ========================================================= -->

      <div v-else class="row q-col-gutter-md q-pa-lg">
        <div v-for="task in filteredTasks" :key="task.id" class="col-12 col-md-6 col-lg-4">
          <q-card flat bordered class="task-grid-card q-pa-md">
            <!-- CARD TOP -->

            <div class="row items-center justify-between">
              <q-chip
                dense
                square
                :style="{
                  background: priorityStyle(task.priority).bg,

                  color: priorityStyle(task.priority).color,
                }"
              >
                {{ task.priority }}
              </q-chip>

              <q-btn flat round dense icon="more_horiz" color="grey-6">
                <q-menu>
                  <q-list>
                    <q-item clickable v-close-popup @click="openEditSubtasks(task)">
                      <q-item-section> Edit Subtasks </q-item-section>
                    </q-item>

                    <q-item clickable v-close-popup @click="openManage(task)">
                      <q-item-section> Manage Progress </q-item-section>
                    </q-item>
                  </q-list>
                </q-menu>
              </q-btn>
            </div>

            <!-- NAME -->

            <div class="task-grid-title q-mt-md">
              {{ task.name }}
            </div>

            <div class="task-description grid-description">
              {{ task.description }}
            </div>

            <!-- PROJECT -->

            <div class="row items-center justify-between q-mt-lg">
              <div class="row items-center">
                <q-icon name="folder" color="grey-6" size="18px" />

                <span class="text-body2 q-ml-xs">
                  {{ task.project }}
                </span>
              </div>

              <q-badge
                :color="task.assignedBy === 'Self-Assigned' ? 'purple-1' : 'blue-1'"
                :text-color="task.assignedBy === 'Self-Assigned' ? 'purple-9' : 'blue-9'"
                :label="task.assignedBy"
                class="text-weight-medium q-px-xs"
              />
            </div>

            <!-- SUBTASK PROGRESS -->

            <div class="q-mt-lg">
              <div class="row justify-between">
                <span class="text-caption text-grey-6"> Subtasks </span>

                <span class="text-caption text-weight-bold">
                  {{ completedSubtasks(task) }}
                  /
                  {{ task.subtasks.length }}
                </span>
              </div>

              <q-linear-progress
                :value="taskProgress(task) / 100"
                color="primary"
                track-color="grey-3"
                rounded
                size="8px"
                class="q-mt-xs"
              />
            </div>

            <!-- BOTTOM -->

            <div class="row items-center justify-between q-mt-lg">
              <q-chip
                dense
                square
                :style="{
                  background: statusStyle(task.status).bg,

                  color: statusStyle(task.status).color,
                }"
              >
                {{ task.status }}
              </q-chip>

              <span class="text-caption text-grey-6">
                {{ formatDate(task.deadline) }}
              </span>
            </div>

            <!-- MANAGE BUTTON -->

            <q-btn
              unelevated
              no-caps
              color="blue-10"
              label="Manage"
              icon="tune"
              class="full-width q-mt-md"
              @click="openManage(task)"
            />
          </q-card>
        </div>
      </div>

      <!-- EMPTY STATE -->

      <div v-if="filteredTasks.length === 0" class="column items-center justify-center q-pa-xl">
        <q-icon name="task_alt" size="64px" color="grey-4" />

        <div class="text-h6 q-mt-md">No tasks found</div>

        <div class="text-body2 text-grey-6">Try changing your filters.</div>
      </div>
    </q-card>

    <!-- ========================================================= -->
    <!-- ADD TASK DIALOG -->
    <!-- ========================================================= -->

    <q-dialog v-model="showAddDialog">
      <q-card class="create-dialog-card">
        <!-- DIALOG HEADER — matched to Project Manager -->
        <q-card-section class="create-dialog-header row items-center q-pb-md">
          <q-avatar color="white" text-color="indigo" icon="add_task" size="42px" class="q-mr-md" />

          <div>
            <div class="text-h6 text-weight-bold">Create New Task</div>

            <div class="text-caption text-indigo-1">
              Turn the next piece of work into a clear action
            </div>
          </div>

          <q-space />

          <q-btn icon="close" flat round dense color="white" @click="showAddDialog = false" />
        </q-card-section>

        <q-card-section class="create-dialog-body q-pa-lg">
          <q-form @submit.prevent="createTask" class="q-gutter-sm">
            <!-- PROJECT -->

            <q-select
              v-model="newTask.project"
              :options="createProjectOptions"
              label="Project *"
              outlined
              dense
              emit-value
              map-options
              :rules="[(val) => !!val || 'Project is required']"
            />

            <!-- TASK NAME -->

            <q-input
              v-model="newTask.name"
              label="Task Title *"
              outlined
              dense
              :rules="[(val) => !!val || 'Task title is required']"
            />

            <!-- DESCRIPTION -->

            <q-input
              v-model="newTask.description"
              label="Description"
              type="textarea"
              outlined
              dense
              rows="3"
            />

            <!-- PRIORITY / DEADLINE / EFFORT -->

            <div class="row q-mt-lg row q-my-lg q-col-gutter-md">
              <div class="col-12 col-sm-4">
                <q-select
                  v-model="newTask.priority"
                  :options="priorityOptions.slice(1)"
                  label="Priority"
                  outlined
                  dense
                />
              </div>

              <div class="col-12 col-sm-4">
                <q-input
                  v-model="newTask.deadline"
                  label="Deadline"
                  type="date"
                  outlined
                  dense
                  stack-label
                />
              </div>

              <div class="col-12 col-sm-4">
                <q-input
                  v-model.number="newTask.expected_effort"
                  label="Est. Hours"
                  type="number"
                  outlined
                  dense
                />
              </div>
            </div>

            <!-- DEPENDENCIES -->
            <q-select
              v-model="newTask.depends_on_ids"
              :options="taskOptions"
              label="Dependencies (Optional)"
              outlined
              dense
              multiple
              use-chips
              emit-value
              map-options
              hint="Tasks that must be completed first"
            />

            <!-- SUBTASKS -->

            <div class="subtask-editor">
              <!-- SUBTASK HEADER -->
              <div class="row items-center justify-between">
                <div>
                  <div class="text-subtitle1 text-weight-bold">Subtasks</div>
                  <div class="text-caption text-grey-6">Break the task into smaller steps.</div>
                </div>

                <q-btn
                  flat
                  round
                  dense
                  :icon="showSubtasks ? 'expand_less' : 'expand_more'"
                  color="grey-7"
                  @click="showSubtasks = !showSubtasks"
                />
              </div>

              <!-- COLLAPSED ADD SUBTASK LINE -->
              <div
                v-if="!showSubtasks"
                class="row items-center q-mt-sm cursor-pointer text-primary"
                @click="showSubtasks = true"
              ></div>

              <!-- EXPANDED SUBTASKS -->
              <div v-if="showSubtasks">
                <div class="row justify-end q-mt-sm">
                  <q-btn
                    flat
                    no-caps
                    dense
                    color="blue-10"
                    icon="add"
                    label="Add Subtask"
                    @click="addNewTaskSubtask"
                  />
                </div>

                <div v-if="newTask.subtasks.length === 0" class="empty-subtasks q-mt-sm">
                  <q-icon name="playlist_add" size="30px" color="grey-5" />

                  <div class="text-caption text-grey-6 q-mt-xs">No subtasks added yet</div>
                </div>

                <div
                  v-for="(subtask, index) in newTask.subtasks"
                  :key="subtask.id"
                  class="subtask-row q-mt-sm row items-center"
                >
                  <!-- DRAG / SHUFFLE HANDLE -->
                  <q-icon name="drag_indicator" size="22px" color="grey-6" class="cursor-grab" />

                  <q-input
                    v-model="subtask.title"
                    outlined
                    dense
                    :placeholder="`Subtask ${index + 1}`"
                    class="col"
                  />

                  <q-input
                    v-model.number="subtask.estimated_hours"
                    type="number"
                    outlined
                    dense
                    placeholder="Hours"
                    style="width: 80px"
                    class="q-ml-sm"
                  />

                  <q-btn
                    flat
                    round
                    dense
                    icon="delete_outline"
                    color="negative"
                    @click="removeNewTaskSubtask(index)"
                  />
                </div>

                <!-- COLLAPSE LINE -->
                <div
                  class="row items-center q-mt-md cursor-pointer text-grey-7"
                  @click="showSubtasks = false"
                >
                  <q-separator class="col q-mr-md" />

                  <div class="row items-center no-wrap">
                    <q-icon name="expand_less" size="18px" class="q-mr-xs" />
                    <span class="text-caption">Collapse</span>
                  </div>

                  <q-separator class="col q-ml-md" />
                </div>
              </div>
            </div>

            <!-- ACTIONS -->

            <div class="row justify-end q-mt-lg">
              <q-btn
                label="Cancel"
                color="grey"
                flat
                type="button"
                @click="showAddDialog = false"
                class="q-mr-sm"
              />

              <q-btn
                unelevated
                no-caps
                color="blue-10"
                icon="add"
                label="Create Task"
                type="submit"
              />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- ========================================================= -->
<!-- EDIT SUBTASKS DIALOG -->
<!-- ========================================================= -->

<q-dialog v-model="showEditDialog">
  <q-card class="edit-subtasks-dialog" v-if="selectedTask">

    <!-- HEADER -->
    <q-card-section class="edit-subtasks-header">
      <div class="row items-center no-wrap">

        <q-avatar
          color="white"
          text-color="indigo"
          icon="edit_note"
          size="46px"
          class="q-mr-md"
        />

        <div class="col">
          <div class="text-h6 text-weight-bold">
            Edit Subtasks
          </div>

          <div class="text-caption text-indigo-1 q-mt-xs">
            Update the subtasks and estimated time for this task
          </div>
        </div>

        <q-btn
          icon="close"
          flat
          round
          dense
          color="white"
          @click="showEditDialog = false"
        />
      </div>
    </q-card-section>

    <!-- TASK INFO -->
    <q-card-section class="edit-task-info">
      <div class="row items-center no-wrap">

        <q-avatar
          color="blue-1"
          text-color="primary"
          icon="assignment"
          size="38px"
          class="q-mr-md"
        />

        <div class="col">
          <div class="text-subtitle1 text-weight-bold text-grey-9">
            {{ selectedTask.name }}
          </div>

          <div class="text-caption text-grey-6 q-mt-xs">
            {{ editSubtasks.length }} subtask{{ editSubtasks.length === 1 ? '' : 's' }}
          </div>
        </div>

      </div>
    </q-card-section>

    <q-separator />

    <!-- SUBTASKS -->
    <q-card-section class="q-pa-lg">

      <div class="row items-center justify-between q-mb-md">

        <div>
          <div class="text-subtitle1 text-weight-bold">
            Subtask List
          </div>

          <div class="text-caption text-grey-6">
            Define what needs to be completed and how long it should take.
          </div>
        </div>

        <q-badge
          color="indigo-1"
          text-color="indigo-9"
          :label="`${editSubtasks.length} items`"
          class="q-px-sm q-py-xs"
        />

      </div>

      <!-- SUBTASK ROWS -->
      <div
        v-for="(subtask, index) in editSubtasks"
        :key="subtask.id"
        class="edit-subtask-card q-mb-md"
      >

        <div class="row items-center no-wrap">

          <!-- NUMBER -->
          <div class="subtask-number">
            {{ index + 1 }}
          </div>

          <!-- TITLE -->
          <div class="col q-ml-md">

            <div class="text-caption text-grey-6 q-mb-xs">
              Subtask name
            </div>

            <q-input
              v-model="subtask.title"
              outlined
              dense
              placeholder="Enter subtask name"
              bg-color="white"
              class="subtask-title-input"
            />

          </div>

          <!-- HOURS -->
          <div class="hours-field q-ml-md">

            <div class="text-caption text-grey-6 q-mb-xs">
              Estimated time
            </div>

            <q-input
              v-model.number="subtask.estimated_hours"
              type="number"
              outlined
              dense
              min="0"
              step="0.5"
              bg-color="white"
              class="hours-input"
              placeholder="0"
            >
              <template #prepend>
                <q-icon name="schedule" color="orange-7" />
              </template>

              <template #append>
                <span class="hours-label">hours</span>
              </template>
            </q-input>

          </div>

          <!-- DELETE -->
          <q-btn
            flat
            round
            dense
            icon="delete_outline"
            color="negative"
            class="q-ml-md delete-subtask-btn"
            @click="removeEditSubtask(subtask.id)"
          >
            <q-tooltip>Remove subtask</q-tooltip>
          </q-btn>

        </div>

      </div>

      <!-- EMPTY -->
      <div
        v-if="editSubtasks.length === 0"
        class="edit-empty-subtasks"
      >
        <q-icon
          name="playlist_add"
          size="42px"
          color="indigo-3"
        />

        <div class="text-subtitle2 text-weight-bold q-mt-sm">
          No subtasks yet
        </div>

        <div class="text-caption text-grey-6 q-mt-xs">
          Add your first subtask to break this task into smaller steps.
        </div>
      </div>

      <!-- ADD -->
      <q-btn
        outline
        no-caps
        color="primary"
        icon="add"
        label="Add Subtask"
        class="full-width q-mt-md add-subtask-btn"
        @click="addEditSubtask"
      />

    </q-card-section>

    <!-- FOOTER -->
    <q-separator />

    <q-card-actions
      align="right"
      class="edit-subtasks-footer q-pa-md"
    >

      <q-btn
        flat
        no-caps
        label="Cancel"
        color="grey-7"
        @click="showEditDialog = false"
      />

      <q-btn
        unelevated
        no-caps
        color="primary"
        icon="save"
        label="Save Changes"
        @click="saveEditedSubtasks"
      />

    </q-card-actions>

  </q-card>
</q-dialog>

    <!-- ========================================================= -->
    <!-- MANAGE DRAWER -->
    <!-- ========================================================= -->

    <q-dialog v-model="showManageDrawer" transition-show="scale" transition-hide="scale">
      <q-card v-if="selectedTask" class="manage-dialog">
        <!-- ================= HEADER ================= -->

        <q-card-section class="manage-header q-pa-lg">
          <div class="row items-start no-wrap">
            <!-- TASK ICON -->
            <q-avatar
              size="50px"
              color="blue-1"
              text-color="primary"
              icon="task_alt"
              class="q-mr-md"
            />

            <!-- TASK INFO -->
            <div class="col">
              <!-- TASK NAME = MAIN HEADING -->
              <div class="manage-task-name">
                {{ selectedTask.name }}
              </div>

              <!-- PROJECT + ASSIGNED BY -->
              <div class="row items-center q-gutter-sm q-mt-sm">
                <div class="task-project">
                  <q-icon name="folder" size="17px" class="q-mr-xs" />
                  {{ selectedTask.project }}
                </div>

                <q-badge
                  :color="selectedTask.assignedBy === 'Self-Assigned' ? 'purple-1' : 'blue-1'"
                  :text-color="selectedTask.assignedBy === 'Self-Assigned' ? 'purple-9' : 'blue-9'"
                  :label="selectedTask.assignedBy"
                  class="text-weight-medium"
                />
              </div>
            </div>

            <!-- DEADLINE -->
            <div class="header-deadline q-mr-lg">
              <div class="row items-center no-wrap q-mt-xs">
                <q-icon name="event" size="19px" color="red" class="q-mr-xs" />
                <span class="text-body2 text-weight-bold text-red">
                  {{ formatDate(selectedTask.deadline) }}
                </span>
              </div>
              <div class="text-caption text-grey-6"></div>
            </div>

            <!-- CLOSE -->
            <q-btn
              flat
              round
              dense
              icon="close"
              color="grey-7"
              class="manage-close-btn"
              @click="showManageDrawer = false"
            />
          </div>
        </q-card-section>

        <!-- ================= TABS ================= -->

        <q-tabs
          v-model="manageTab"
          class="manage-tabs"
          active-color="primary"
          indicator-color="primary"
          align="justify"
          no-caps
          broad-indicator
        >
        </q-tabs>

        <!-- ================= CONTENT ================= -->

        <q-tab-panels
          v-model="manageTab"
          animated
          swipeable
          transition-prev="slide-right"
          transition-next="slide-left"
          class="manage-panels"
        >
          <!-- ================================================= -->
          <!-- DETAILS -->
          <!-- ================================================= -->

          <q-tab-panel name="details" class="manage-panel">
            <!-- PROGRESS -->

            <div class="manage-progress-card">
              <div class="row items-center justify-between">
                <div>
                  <div class="text-caption text-grey-6">Overall Progress</div>

                  <div class="text-h3 text-weight-bold text-primary q-mt-xs">
                    {{ taskProgress(selectedTask) }}%
                  </div>
                </div>

                <q-circular-progress
                  :value="taskProgress(selectedTask)"
                  size="78px"
                  :thickness="0.16"
                  color="primary"
                  track-color="blue-1"
                  show-value
                >
                  {{ taskProgress(selectedTask) }}%
                </q-circular-progress>
              </div>

              <q-linear-progress
                :value="taskProgress(selectedTask) / 100"
                color="primary"
                track-color="blue-1"
                rounded
                size="9px"
                class="q-mt-md"
              />
            </div>

            <!-- ================= SUBTASKS ================= -->

            <div class="section-title q-mt-xl q-mb-md">Subtasks</div>

            <!-- EMPTY -->

            <div v-if="selectedTask.subtasks.length === 0" class="empty-subtasks">
              <q-icon name="playlist_add" size="36px" color="blue-3" />

              <div class="text-body2 text-grey-6 q-mt-sm">No subtasks added.</div>

              <q-btn
                flat
                no-caps
                color="primary"
                icon="add"
                label="Add Subtasks"
                class="q-mt-sm"
                @click="openEditFromManage"
              />
            </div>

            <!-- SUBTASKS -->

            <div v-for="subtask in selectedTask.subtasks" :key="subtask.id" class="manage-subtask">
              <div class="row items-start no-wrap">
                <q-checkbox
                  v-model="subtask.completed"
                  color="primary"
                  :disable="subtask.originally_completed"
                  @update:model-value="updateSubtaskCompletion(selectedTask, subtask)"
                />

                <div class="col q-ml-sm">
                  <div
                    class="manage-subtask-title"
                    :class="{
                      'completed-subtask': subtask.completed,
                    }"
                  >
                    {{ subtask.title }}

                    <span v-if="subtask.estimated_hours" class="text-caption text-grey-6 q-ml-sm">
                      {{ subtask.estimated_hours }} hr
                    </span>
                  </div>

                  <q-select
                    v-model="subtask.status"
                    :options="subtaskStatusOptions"
                    dense
                    outlined
                    class="q-mt-sm"
                    style="max-width: 200px"
                    :disable="subtask.originally_completed"
                    @update:model-value="updateSubtaskStatus(selectedTask, subtask)"
                  />
                </div>
              </div>
            </div>

            <!-- ================= DEPENDENCIES ================= -->
            
            <div class="section-title q-mt-xl q-mb-md">Dependencies</div>
            
            <q-list
              v-if="selectedTask.dependencies && selectedTask.dependencies.length > 0"
              dense
            >
              <q-item
                v-for="dep in selectedTask.dependencies"
                :key="dep.id || dep"
                class="q-px-none q-py-xs"
              >
                <q-item-section avatar style="min-width: 36px">
                  <q-icon name="link" color="grey-6" size="sm" />
                </q-item-section>
                <q-item-section>
                  <q-item-label class="text-body2"
                    >{{ dep.title || dep.name || dep.id || dep }}</q-item-label
                  >
                </q-item-section>
              </q-item>
            </q-list>
            <div v-else class="text-body2 text-grey-6 q-mb-md">No dependencies.</div>

            <!-- ================= TASK STATUS ================= -->

            <div class="section-title q-mt-xl q-mb-md">Task Status</div>

            <q-select
              v-model="selectedTask.status"
              :options="taskStatusOptions"
              outlined
              dense
              label="Current status"
              @update:model-value="handleTaskStatusChange(selectedTask)"
            />

            <!-- ================= TODAY'S UPDATE ================= -->

            <div class="section-title q-mt-xl q-mb-sm">Today's Update</div>

            <q-input
              v-model="selectedTask.todayNote"
              outlined
              type="textarea"
              autogrow
              placeholder="What did you work on today?"
            />

            <!-- ================= COMMENTS ================= -->

            <div class="section-title q-mt-xl q-mb-sm">Task Comment</div>

            <div class="row items-center no-wrap q-gutter-sm q-mb-lg">
              <q-input
                v-model="newComment"
                outlined
                dense
                class="col"
                placeholder="Add a comment to the timeline..."
              />

              <q-btn color="primary" icon="send" dense flat round @click="submitComment" />
            </div>

            <!-- ================= DEADLINE ================= 

            <div
              class="deadline-box q-mt-lg"
              :class="{
                'deadline-overdue': isOverdue(selectedTask),
              }"
            >
              <q-icon name="event" size="21px" />

              <div class="q-ml-sm">
                <div class="text-caption">Deadline</div>

                <div class="text-body2 text-weight-bold">
                  {{ formatDate(selectedTask.deadline) }}
                </div>
              </div>
            </div> -->
          </q-tab-panel>

          <!-- ================================================= -->
          <!-- TIMELINE -->
          <!-- ================================================= -->

          <q-tab-panel name="timeline" class="manage-panel">
            <div class="timeline-card">
              <div class="section-title q-mb-xs">Progress Timeline</div>

              <div class="text-body2 text-grey-7">
                Track updates and comments for this task here.
              </div>

              <q-separator class="q-my-lg" />

              <div class="timeline-item">
                <q-avatar size="42px" color="blue-1" text-color="primary" icon="flag" />

                <div class="q-ml-md">
                  <div class="text-body2 text-weight-bold">Current Status</div>

                  <div class="text-caption text-grey-6 q-mt-xs">
                    {{ selectedTask.status }}
                  </div>
                </div>
              </div>

              <div class="timeline-item q-mt-sm">
                <q-avatar size="42px" color="blue-1" text-color="primary" icon="trending_up" />

                <div class="q-ml-md">
                  <div class="text-body2 text-weight-bold">Current Progress</div>

                  <div class="text-caption text-grey-6 q-mt-xs">
                    {{ taskProgress(selectedTask) }}% completed
                  </div>
                </div>
              </div>
            </div>
          </q-tab-panel>

          <!-- ================================================= -->
          <!-- IMPACT -->
          <!-- ================================================= -->

          <q-tab-panel name="impact" class="manage-panel">
            <div class="timeline-card">
              <div class="section-title q-mb-sm">Simulate Impact</div>

              <div class="text-body2 text-grey-7">
                Review the task's current progress, deadline and remaining work before making an
                update.
              </div>

              <div class="q-mt-lg">
                <div class="row justify-between text-caption text-grey-7">
                  <span>Current Progress</span>

                  <span> {{ taskProgress(selectedTask) }}% </span>
                </div>

                <q-linear-progress
                  :value="taskProgress(selectedTask) / 100"
                  color="primary"
                  track-color="blue-1"
                  rounded
                  size="10px"
                  class="q-mt-sm"
                />
              </div>

              <div class="impact-info q-mt-lg">
                <q-icon name="event" size="22px" color="primary" />

                <div class="q-ml-md">
                  <div class="text-caption text-grey-6">Deadline</div>

                  <div class="text-body2 text-weight-bold">
                    {{ formatDate(selectedTask.deadline) }}
                  </div>
                </div>
              </div>

              <div class="impact-info q-mt-md">
                <q-icon name="flag" size="22px" color="primary" />

                <div class="q-ml-md">
                  <div class="text-caption text-grey-6">Current Status</div>

                  <div class="text-body2 text-weight-bold">
                    {{ selectedTask.status }}
                  </div>
                </div>
              </div>
            </div>
          </q-tab-panel>
        </q-tab-panels>

        <!-- ================= FOOTER ================= -->

        <q-separator />
        <div class="manage-footer q-pa-lg row justify-end q-gutter-md">
          <q-btn
            v-if="selectedTask.status === 'completed'"
            unelevated
            no-caps
            color="positive"
            icon="rate_review"
            label="Put for Review"
            class="mid-width"
            size="md"
            @click="openReviewDialog"
          />

          <q-btn
            v-if="selectedTask.status === 'in-progress'"
            unelevated
            outline
            no-caps
            color="negative"
            icon="warning"
            label="Interrupt Task"
            class="mid-width"
            size="md"
            @click="showInterruptDialog = true"
          />
          <q-btn
            unelevated
            no-caps
            color="blue-10"
            icon="save"
            label="Save Update"
            class="mid-width"
            size="md"
            @click="saveTaskUpdate"
          />
        </div>
      </q-card>
    </q-dialog>

    <!-- ========================================================= -->
    <!-- REVIEW DIALOG -->
    <!-- ========================================================= -->

    <q-dialog v-model="showReviewDialog">
      <q-card class="review-dialog" style="min-width: 400px">
        <q-card-section>
          <div class="text-h6 text-weight-bold">Put Task for Review</div>

          <div class="text-body2 text-grey-6 q-mt-xs">
            {{ selectedTask?.name }}
          </div>
        </q-card-section>

        <q-separator />

        <q-card-section class="q-gutter-md">
          <q-input
            v-model="reviewComment"
            label="Completion Comment"
            type="textarea"
            outlined
            rows="3"
          />
          <q-select
            v-model="selectedReviewer"
            :options="colleagues"
            outlined
            label="Select Colleague for Review"
            option-label="name"
            option-value="id"
            emit-value
            map-options
          />
        </q-card-section>

        <q-card-actions align="right" class="q-pa-md">
          <q-btn flat no-caps label="Cancel" @click="showReviewDialog = false" />

          <q-btn
            unelevated
            no-caps
            color="positive"
            label="Submit for Review"
            @click="submitForReview"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="showInterruptDialog">
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6 text-weight-bold text-negative">Interrupt Task</div>
          <div class="text-body2 text-grey-6 q-mt-xs">
            {{ selectedTask?.name }}
          </div>
        </q-card-section>
        <q-separator />
        <q-card-section>
          <div class="text-caption q-mb-md">
            Interrupting a task indicates a blocker, bug, or priority shift. Your PM will be
            notified and this task will be rescheduled.
          </div>
          <q-input
            v-model="interruptReason"
            type="textarea"
            outlined
            label="Reason for interruption *"
          />
        </q-card-section>
        <q-card-actions align="right" class="q-pa-md">
          <q-btn flat no-caps label="Cancel" @click="showInterruptDialog = false" />
          <q-btn
            unelevated
            no-caps
            color="negative"
            label="Submit Interrupt"
            @click="submitInterrupt"
            :disable="!interruptReason"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- ========================================================= -->
    <!-- INSIGHTS DIALOG -->
    <!-- ========================================================= -->

    <q-dialog v-model="showInsightsDialog">
      <q-card style="min-width: 500px; max-width: 600px">
        <q-card-section>
          <div class="text-h6 text-weight-bold">
            <q-icon name="lightbulb" class="q-mr-sm" color="primary" />
            Employee Insights
          </div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-list separator v-if="insights.length > 0">
            <q-item v-for="(insight, index) in insights" :key="index">
              <q-item-section avatar>
                <q-icon name="info" color="primary" />
              </q-item-section>
              <q-item-section>
                <q-item-label>{{ insight }}</q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
          <div v-else class="text-center q-pa-xl text-grey-6">
            <q-icon name="lightbulb" size="48px" class="q-mb-sm text-grey-4" />
            <div class="text-h6">No insights available</div>
            <div class="text-caption">Complete more tasks to see insights</div>
          </div>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Close" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Task Clash Detected Dialog -->
    <q-dialog v-model="showClashDialog" persistent>
      <q-card style="min-width: 600px; max-width: 750px" class="rounded-borders">
        <q-card-section class="row items-center bg-red-1 text-negative q-pb-md">
          <q-avatar icon="warning" color="negative" text-color="white" size="40px" class="q-mr-md" />
          <div>
            <div class="text-h6 text-weight-bold">Task Clash Detected</div>
            <div class="text-caption text-grey-8">
              Multiple tasks share the exact same deadline date. Click Automate to resolve conflicts according to priority with at least 3-day gaps.
            </div>
          </div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="q-pt-md" style="max-height: 400px; overflow-y: auto">
          <div v-for="(conflict, idx) in detectedConflicts" :key="idx" class="q-mb-md">
            <div class="text-subtitle2 text-weight-bold text-grey-9 q-mb-xs row items-center">
              <q-icon name="event" class="q-mr-xs" color="primary" />
              Deadline: {{ formatDate(conflict.deadline) }}
              <q-badge color="negative" class="q-ml-sm">{{ conflict.count }} conflicting tasks</q-badge>
            </div>
            <q-list bordered separator class="rounded-borders bg-grey-1">
              <q-item v-for="task in conflict.tasks" :key="task.id" class="q-py-sm">
                <q-item-section avatar>
                  <q-badge
                    :color="getPriorityBadgeColor(task.priority)"
                    :label="task.priority"
                    class="text-capitalize text-weight-bold q-px-sm q-py-xs"
                  />
                </q-item-section>
                <q-item-section>
                  <q-item-label class="text-weight-bold">{{ task.name }}</q-item-label>
                  <q-item-label caption class="text-grey-7">
                    Project: {{ task.project || 'Project' }}
                  </q-item-label>
                </q-item-section>
                <q-item-section side>
                  <div class="text-caption text-weight-medium text-grey-8">
                    {{ formatDate(task.deadline) }}
                  </div>
                </q-item-section>
              </q-item>
            </q-list>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right" class="q-pa-md bg-grey-1">
          <q-btn flat label="Cancel" color="grey-7" v-close-popup />
          <q-btn
            unelevated
            color="primary"
            icon="auto_fix_high"
            label="Automate"
            @click="resolveClashes"
            :loading="automating"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Overdue Tasks Dialog -->
    <q-dialog v-model="showOverdueDialog">
      <q-card style="min-width: 600px; max-height: 80vh">
        <q-card-section>
          <div class="text-h6 text-negative">
            <q-icon name="warning" class="q-mr-sm" />
            Overdue Tasks ({{ overdueTasks.length }})
          </div>
        </q-card-section>
        <q-card-section class="q-pt-none">
          <q-list separator>
            <q-item
              v-for="task in overdueTasks"
              :key="task.id"
              clickable
              @click="openOverdueTaskDialog(task)"
              class="q-py-md"
            >
              <q-item-section avatar>
                <q-badge :color="getPriorityBadgeColor(task.priority)" :label="task.priority" />
              </q-item-section>
              <q-item-section>
                <q-item-label class="text-weight-bold">{{ task.name }}</q-item-label>
                <q-item-label caption>{{ task.project || 'Project' }}</q-item-label>
                <q-item-label caption class="text-red">{{ formatDate(task.deadline) }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-icon name="chevron_right" color="grey-5" />
              </q-item-section>
            </q-item>
          </q-list>
          <div v-if="overdueTasks.length === 0" class="text-center q-pa-xl text-grey-6">
            <q-icon name="check_circle" size="48px" class="q-mb-sm" color="green" />
            <div class="text-h6">No overdue tasks</div>
            <div>All your tasks are on schedule!</div>
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Close" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Overdue Task Dialog -->
    <q-dialog v-model="showOverdueTaskDialog">
      <q-card style="min-width: 500px">
        <q-card-section>
          <div class="text-h6">Overdue Task Actions</div>
        </q-card-section>
        <q-card-section>
          <div v-if="selectedOverdueTask">
            <div class="text-subtitle1 text-weight-bold q-mb-sm">{{ selectedOverdueTask.title }}</div>
            <div class="text-caption text-grey-7 q-mb-md">
              Current deadline: {{ formatDate(selectedOverdueTask.deadline) }}
            </div>
            <div class="row q-gutter-md">
              <q-btn
                color="primary"
                label="Set Deadline"
                @click.stop="openSetDeadlineDialog(selectedOverdueTask)"
              />
              <q-btn
                color="secondary"
                label="Automate"
                @click.stop="automateOverdueTask"
              />
            </div>
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Close" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Set Deadline Dialog -->
    <q-dialog v-model="showSetDeadlineDialog">
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6">Set New Deadline</div>
        </q-card-section>
        <q-card-section>
          <q-date v-model="newDeadline" mask="YYYY-MM-DD" @update:model-value="() => {}" />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn 
            color="primary" 
            label="Save" 
            @click.stop="setDeadline" 
            :loading="updatingDeadline"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import { useAuthStore } from '@/stores/authStore';
import { useQuasar, Notify } from 'quasar';
import EmployeeStatCard from '@/components/EmployeeStatCard.vue';
import QuickAddTaskCard from '@/components/QuickAddTaskCard.vue';
import TaskListHeader from '@/components/TaskListHeader.vue';
import TaskFilters from '@/components/TaskFilters.vue';

// ============================================================
// QUASAR
// ============================================================

const $q = useQuasar();
const authStore = useAuthStore();

// ============================================================
// TYPES
// ============================================================
const search = ref('');
const searchType = ref('task');

const projectFilter = ref('All Projects');
const priorityFilter = ref('All Priorities');
const statusFilter = ref('All Statuses');
const activeTab = ref('all');
const viewMode = ref<'list' | 'grid'>('list');
const taskView = ref('all');

type TaskStatus = 'not-started' | 'in-progress' | 'completed' | 'blocked' | 'in-review';

type SubtaskStatus = 'not-started' | 'in-progress' | 'completed';

interface Subtask {
  id: number;

  title: string;

  completed: boolean;

  status: SubtaskStatus;

  estimated_hours?: number;

  originally_completed?: boolean;
}

interface Task {
  id: number;

  name: string;

  description: string;

  project: string;

  priority: string;

  status: TaskStatus;

  deadline: string;

  assignedBy: string;

  subtasks: Subtask[];

  todayNote: string;

  createdAt: string;

  progress: number;

  dependencies?: any[];
}

// ============================================================
// STATE
// ============================================================

const showAddDialog = ref(false);

const showEditDialog = ref(false);

const showManageDrawer = ref(false);

const showInsightsDialog = ref(false);

const userPoints = ref(0);
const userRank = ref(0);

const selectedTask = ref<Task | null>(null);
const manageTab = ref('details');

const showSubtasks = ref(false);
// ============================================================
// FETCH TASKS FROM BACKEND
// ============================================================

const tasks = ref<Task[]>([]);

const newComment = ref('');

const submitComment = async () => {
  if (!selectedTask.value || !newComment.value.trim()) return;

  try {
    const response = await fetch(
      `http://localhost:3007/api/employee/tasks/${selectedTask.value.id}/comment`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
        body: JSON.stringify({ content: newComment.value.trim() }),
      },
    );

    const result = await response.json();
    if (result.success) {
      $q.notify({
        message: 'Comment added successfully',
        color: 'positive',
        icon: 'check_circle',
      });
      newComment.value = '';
    } else {
      $q.notify({
        message: result.error || 'Failed to add comment',
        color: 'negative',
        icon: 'error',
      });
    }
  } catch (error) {
    console.error('Error adding comment:', error);
    $q.notify({
      message: 'Error adding comment',
      color: 'negative',
      icon: 'error',
    });
  }
};

// Review dialog state
const showReviewDialog = ref(false);
const selectedReviewer = ref<number | null>(null);
const reviewComment = ref('');
const colleagues = ref<{ id: number; name: string }[]>([]);

// Fetch colleagues for review selection
const fetchColleagues = async () => {
  try {
    const response = await fetch('http://localhost:3007/api/users/employees', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    });
    const result = await response.json();
    if (result.success && result.users) {
      colleagues.value = result.users
        .filter((u: any) => u.id !== authStore.user?.id) // Exclude current user
        .map((u: any) => ({
          id: u.id,
          name: `${u.first_name} ${u.last_name}`,
        }));
    }
  } catch (error) {
    console.error('Error fetching colleagues:', error);
  }
};

// Open review dialog
const openReviewDialog = () => {
  selectedReviewer.value = null;
  reviewComment.value = '';
  showReviewDialog.value = true;
  fetchColleagues();
};

// Submit task for review
const submitForReview = async () => {
  if (!selectedTask.value || !selectedReviewer.value) {
    $q.notify({
      message: 'Please select a colleague for review',
      color: 'negative',
      icon: 'error',
    });
    return;
  }

  try {
    const response = await fetch(`http://localhost:3007/api/employee/tasks/${selectedTask.value.id}/submit-review`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${authStore.token}`,
      },
      body: JSON.stringify({
        reviewer_id: selectedReviewer.value,
        task_owner_id: authStore.user?.id,
        completion_comment: reviewComment.value || 'Task completed, please review',
      }),
    });

    const result = await response.json();
    if (result.success) {
      // Update task status to in-review
      await updateTaskProgress(selectedTask.value.id, 100, 'in-review');

      showReviewDialog.value = false;
      showManageDrawer.value = false;

      $q.notify({
        message: 'Task submitted for review successfully',
        color: 'positive',
        icon: 'check_circle',
      });
    } else {
      $q.notify({
        message: result.error || 'Failed to submit for review',
        color: 'negative',
        icon: 'error',
      });
    }
  } catch (error) {
    console.error('Error submitting for review:', error);
    $q.notify({
      message: 'Error submitting for review',
      color: 'negative',
      icon: 'error',
    });
  }
};

const fetchTasks = async () => {
  if (!authStore.user?.id) {
    console.error('No user ID found for fetching tasks');
    return;
  }

  try {
    const response = await fetch(`http://localhost:3007/api/tasks/employee/${authStore.user?.id}`);
    const result = await response.json();

    if (result.success && result.tasks) {
      // Fetch leave dates for checking deadline conflicts
      fetchLeaveDates();

      // Fetch subtasks for each task
      const tasksWithSubtasks = await Promise.all(
        result.tasks.map(async (task: any) => {
          try {
            const subtaskResponse = await fetch(
              `http://localhost:3007/api/employee/tasks/${task.id}/subtasks`,
            );
            const subtaskResult = await subtaskResponse.json();
            const subtasks = subtaskResult.success
              ? subtaskResult.subtasks.map((st: any) => ({
                  id: st.id,
                  title: st.title,
                  completed: st.completed === 1,
                  status: st.status,
                  estimated_hours: st.estimated_hours || 0,
                  originally_completed: st.completed === 1,
                }))
              : [];

            const isSelf =
              Boolean(task.is_self_assigned) ||
              task.is_self_assigned === 1 ||
              task.is_self_assigned === '1' ||
              (authStore.user?.id != null &&
                String(task.created_by) === String(authStore.user.id)) ||
              (authStore.user?.id != null &&
                String(task.assignment_assigned_by) === String(authStore.user.id));

            return {
              id: task.id,
              name: task.title,
              description: task.description || '',
              project: task.project_name || 'Unknown Project',
              priority: task.priority || 'medium',
              status: task.status || 'not-started',
              deadline: task.deadline || '',
              assignedBy: isSelf ? 'Self-Assigned' : 'Assigned by PM',
              todayNote: '',
              createdAt: task.created_at || '',
              subtasks: subtasks,
              progress: parseFloat(task.progress) || 0,
              dependencies: task.dependencies || [],
            };
          } catch (error) {
            console.error('Error fetching subtasks for task:', task.id, error);
            const isSelf =
              Boolean(task.is_self_assigned) ||
              task.is_self_assigned === 1 ||
              task.is_self_assigned === '1' ||
              (authStore.user?.id != null &&
                String(task.created_by) === String(authStore.user.id)) ||
              (authStore.user?.id != null &&
                String(task.assignment_assigned_by) === String(authStore.user.id));

            return {
              id: task.id,
              name: task.title,
              description: task.description || '',
              project: task.project_name || 'Unknown Project',
              priority: task.priority || 'medium',
              status: task.status || 'not-started',
              deadline: task.deadline || '',
              assignedBy: isSelf ? 'Self-Assigned' : 'Assigned by PM',
              todayNote: '',
              createdAt: task.created_at || '',
              subtasks: [],
              progress: parseFloat(task.progress) || 0,
              dependencies: task.dependencies || [],
            };
          }
        }),
      );

      tasks.value = tasksWithSubtasks;
      console.log('Mapped tasks with subtasks:', tasks.value);
    } else {
      console.error('Failed to fetch tasks:', result.error);
    }
  } catch (error) {
    console.error('Error fetching tasks:', error);
  }
};

// ============================================================
// DEADLINE CONFLICT HANDLING
// ============================================================
const showClashDialog = ref(false);
const detectedConflicts = ref<any[]>([]);
const automating = ref(false);

// OVERDUE TASKS HANDLING
// ============================================================
const showOverdueDialog = ref(false);
const showOverdueTaskDialog = ref(false);
const showSetDeadlineDialog = ref(false);
const selectedOverdueTask = ref<any>(null);
const newDeadline = ref('');
const updatingDeadline = ref(false);

const overdueTasks = computed(() => {
  return tasks.value.filter((task) => task.status !== 'completed' && isOverdue(task));
});

function openOverdueDialog() {
  console.log('=== OPEN OVERDUE DIALOG ===');
  console.log('Overdue tasks count:', overdueTasks.value.length);
  console.log('Overdue tasks:', overdueTasks.value);
  showOverdueDialog.value = true;
  console.log('Dialog state after setting:', showOverdueDialog.value);
}

function openOverdueTaskDialog(task: any) {
  selectedOverdueTask.value = task;
  showOverdueTaskDialog.value = true;
}

function openSetDeadlineDialog(task: any) {
  console.log('=== OPEN SET DEADLINE DIALOG ===');
  console.log('Task:', task);
  selectedOverdueTask.value = task;
  newDeadline.value = task.deadline ? new Date(new Date(task.deadline).getTime() - (new Date(task.deadline).getTimezoneOffset() * 60000)).toISOString().split('T')[0] || '' : '';
  showSetDeadlineDialog.value = true;
  console.log('Dialog state:', showSetDeadlineDialog.value);
}

async function setDeadline() {
  console.log('=== SET DEADLINE START ===');
  console.log('Task ID:', selectedOverdueTask.value?.id);
  console.log('New deadline:', newDeadline.value);
  console.log('Already updating:', updatingDeadline.value);
  
  if (updatingDeadline.value) {
    console.log('Already updating, skipping duplicate call');
    return;
  }
  
  if (!selectedOverdueTask.value || !newDeadline.value) {
    console.error('Missing task or deadline');
    Notify.create({
      type: 'negative',
      message: 'Missing task or deadline',
    });
    return;
  }

  updatingDeadline.value = true;
  
  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (authStore.token && authStore.token !== 'undefined' && authStore.token !== 'null') {
      headers['Authorization'] = `Bearer ${authStore.token}`;
    }

    const url = `http://localhost:3007/api/employee/tasks/${selectedOverdueTask.value.id}`;
    console.log('API URL:', url);
    console.log('Request body:', JSON.stringify({ deadline: newDeadline.value }));

    const response = await fetch(url, {
      method: 'PUT',
      headers,
      body: JSON.stringify({
        deadline: newDeadline.value,
      }),
    });

    console.log('Response status:', response.status);
    const data = await response.json();
    console.log('Response data:', data);

    if (response.ok) {
      console.log('=== SET DEADLINE SUCCESS ===');
      Notify.create({
        type: 'positive',
        message: 'Deadline updated successfully',
      });
      showSetDeadlineDialog.value = false;
      showOverdueTaskDialog.value = false;
      showOverdueDialog.value = false;
      // Reload page to get fresh data
      window.location.reload();
    } else {
      console.error('API error:', data);
      Notify.create({
        type: 'negative',
        message: `Failed to update deadline: ${data.message || data.error || 'Unknown error'}`,
      });
    }
  } catch (error) {
    console.error('Error setting deadline:', error);
    Notify.create({
      type: 'negative',
      message: 'Error updating deadline',
    });
  } finally {
    updatingDeadline.value = false;
    console.log('=== SET DEADLINE END ===');
  }
}

async function automateOverdueTask() {
  console.log('=== AUTOMATE OVERDUE TASK ===');
  console.log('Selected task:', selectedOverdueTask.value);
  
  if (!selectedOverdueTask.value) return;

  automating.value = true;
  try {
    const empId = authStore.user?.id;
    if (!empId) return;

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (authStore.token && authStore.token !== 'undefined' && authStore.token !== 'null') {
      headers['Authorization'] = `Bearer ${authStore.token}`;
    }

    const response = await fetch(`http://localhost:3007/api/employee/${empId}/automate-schedule`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ mode: 'clashes' }),
    });

    const data = await response.json();
    if (data.success) {
      Notify.create({
        type: 'positive',
        message: `Schedule automated: ${data.updatedTasks?.length || 0} tasks rescheduled`,
      });
      showOverdueTaskDialog.value = false;
      showOverdueDialog.value = false;
      await fetchTasks();
    } else {
      Notify.create({
        type: 'negative',
        message: 'Failed to automate schedule',
      });
    }
  } catch (error) {
    console.error('Error automating schedule:', error);
    Notify.create({
      type: 'negative',
      message: 'Error automating schedule',
    });
  } finally {
    automating.value = false;
  }
}

function getPriorityBadgeColor(priority: string) {
  const p = (priority || '').toLowerCase();
  if (p === 'critical') return 'red';
  if (p === 'high') return 'orange';
  if (p === 'medium') return 'blue';
  return 'green';
}

const detectDeadlineClashes = async () => {
  const empId = authStore.user?.id;
  if (!empId) return;

  try {
    const response = await fetch(`http://localhost:3007/api/employee/${empId}/deadline-clashes`);
    const data = await response.json();
    if (data.success && data.conflicts && data.conflicts.length > 0) {
      detectedConflicts.value = data.conflicts;
      showClashDialog.value = true;
    } else {
      detectedConflicts.value = [];
      showClashDialog.value = false;
    }
  } catch (error) {
    console.error('Error detecting deadline clashes:', error);
  }
};

const leaveDates = ref<string[]>([]);

const fetchLeaveDates = async () => {
  const empId = authStore.user?.id;
  if (!empId) return;

  try {
    const response = await fetch(`http://localhost:3007/api/daily-logs/employee/${empId}/leave-dates`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    });
    const data = await response.json();
    if (data.success && data.leaveDates) {
      leaveDates.value = data.leaveDates;
      console.log('=== LEAVE DATES FETCHED ===');
      console.log('Leave dates:', leaveDates.value);
    }
  } catch (error) {
    console.error('Error fetching leave dates:', error);
  }
};

// Check if task deadline falls on a leave date
const isTaskDeadlineOnLeave = (task: any) => {
  if (!task || !task.deadline) return false;

  // Parse the deadline date and extract YYYY-MM-DD
  const deadlineDate = new Date(task.deadline);
  const year = deadlineDate.getFullYear();
  const month = String(deadlineDate.getMonth() + 1).padStart(2, '0');
  const day = String(deadlineDate.getDate()).padStart(2, '0');
  const dateString = `${year}-${month}-${day}`;

  console.log('=== CHECKING TASK DEADLINE ON LEAVE ===');
  console.log('Task:', task.name);
  console.log('Deadline:', task.deadline);
  console.log('Deadline date string:', dateString);
  console.log('Leave dates:', leaveDates.value);
  console.log('Is on leave:', leaveDates.value.includes(dateString));

  // Check if this date is in the employee's leave dates
  return leaveDates.value.includes(dateString);
};

const resolveClashes = async () => {
  const empId = authStore.user?.id;
  if (!empId) return;

  automating.value = true;
  try {
    const response = await fetch(`http://localhost:3007/api/employee/${empId}/automate-schedule`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ mode: 'clashes' }),
    });
    const data = await response.json();
    if (data.success) {
      showClashDialog.value = false;
      await fetchTasks();
      $q.notify({
        type: 'positive',
        message: data.updatedTasks && data.updatedTasks.length > 0
          ? `Conflicts resolved! ${data.updatedTasks.length} tasks rescheduled with 3-day gaps.`
          : 'All deadline conflicts resolved.',
        position: 'top',
      });
    } else {
      $q.notify({
        type: 'negative',
        message: data.error || 'Failed to resolve conflicts',
        position: 'top',
      });
    }
  } catch (error) {
    console.error('Error resolving clashes:', error);
    $q.notify({
      type: 'negative',
      message: 'Network error resolving conflicts',
      position: 'top',
    });
  } finally {
    automating.value = false;
  }
};

const automateFullSchedule = async () => {
  const empId = authStore.user?.id;
  if (!empId) return;

  automating.value = true;
  try {
    const response = await fetch(`http://localhost:3007/api/employee/${empId}/automate-schedule`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ mode: 'full' }),
    });
    const data = await response.json();
    if (data.success) {
      await fetchTasks();
      showClashDialog.value = false;
      $q.notify({
        type: 'positive',
        message: data.updatedTasks && data.updatedTasks.length > 0
          ? `Schedule automated! ${data.updatedTasks.length} tasks reorganized by priority with 3-day gaps.`
          : 'Schedule is already optimal. No changes needed.',
        position: 'top',
      });
    } else {
      $q.notify({
        type: 'negative',
        message: data.error || 'Failed to automate schedule',
        position: 'top',
      });
    }
  } catch (error) {
    console.error('Error automating schedule:', error);
    $q.notify({
      type: 'negative',
      message: 'Network error automating schedule',
      position: 'top',
    });
  } finally {
    automating.value = false;
  }
};

// Fetch tasks on component mount
onMounted(() => {
  fetchProjects();
  fetchTasks();
  fetchColleagues();
  fetchUserPointsAndRank();
  void detectDeadlineClashes();
});

const projects = ref<any[]>([]);

const fetchProjects = async () => {
  try {
    const response = await fetch(`http://localhost:3007/api/employee/${authStore.user?.id}/projects`, {
      headers: { Authorization: `Bearer ${authStore.token}` },
    });
    const result = await response.json();
    if (result.success && result.projects) {
      projects.value = result.projects;
    }
  } catch (error) {
    console.error('Error fetching projects:', error);
  }
};

const createProjectOptions = computed(() =>
  projects.value.map((p: any) => ({
    label: p.name,
    value: p.id,
  })),
);

// Watch for tab changes and reset status filter when switching to completed tab
watch(activeTab, (newTab) => {
  if (newTab === 'completed') {
    statusFilter.value = 'All Statuses';
  }
});

// Fetch user points and rank
const fetchUserPointsAndRank = async () => {
  if (!authStore.user?.id) return;

  try {
    // Fetch user points
    const userResponse = await fetch(`http://localhost:3007/api/users/${authStore.user?.id}`);
    const userResult = await userResponse.json();
    if (userResult.success && userResult.user) {
      userPoints.value = userResult.user.points || 0;
    }

    // Fetch all users to calculate rank
    const allUsersResponse = await fetch('http://localhost:3007/api/users', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    });
    const allUsersResult = await allUsersResponse.json();
    if (allUsersResult.success && allUsersResult.users) {
      const sortedUsers = allUsersResult.users.sort(
        (a: any, b: any) => (b.points || 0) - (a.points || 0),
      );
      console.log(
        'Sorted users:',
        sortedUsers.map((u: any) => ({ id: u.id, points: u.points })),
      );
      const userRankIndex = sortedUsers.findIndex((u: any) => u.id === authStore.user?.id);
      console.log('User ID:', authStore.user?.id, 'Rank index:', userRankIndex);
      userRank.value = userRankIndex >= 0 ? userRankIndex + 1 : 1; // Default to rank 1 if not found
    }
  } catch (error) {
    console.error('Error fetching user points and rank:', error);
    userRank.value = 1; // Default to rank 1 on error
  }
};

// Employee Insights
const insights = computed(() => {
  const insightsList: string[] = [];
  const total = tasks.value.length;
  const completed = tasks.value.filter((t) => t.status === 'completed').length;
  const inProgress = tasks.value.filter((t) => t.status === 'in-progress').length;
  const notStarted = tasks.value.filter((t) => t.status === 'not-started').length;
  const blocked = tasks.value.filter((t) => t.status === 'blocked').length;

  const avgProgress =
    total > 0 ? Math.round(tasks.value.reduce((sum, t) => sum + taskProgress(t), 0) / total) : 0;

  if (total === 0) {
    insightsList.push('No tasks assigned yet. Check with your Project Manager.');
  } else {
    if (inProgress > 0) {
      insightsList.push(`${inProgress} tasks are currently in progress.`);
    }

    if (completed > 0) {
      insightsList.push(`${completed} tasks completed. Great work!`);
    }

    if (notStarted > 0) {
      insightsList.push(`${notStarted} tasks haven't been started yet.`);
    }

    if (blocked > 0) {
      insightsList.push(`${blocked} tasks are blocked. Consider resolving dependencies.`);
    }

    if (avgProgress < 50 && total > 0) {
      insightsList.push('Average progress is below 50%. Focus on completing tasks.');
    }

    const overdue = tasks.value.filter((t) => isOverdue(t)).length;
    if (overdue > 0) {
      insightsList.push(`${overdue} tasks are overdue. Prioritize these!`);
    }

    const highPriority = tasks.value.filter(
      (t) => t.priority === 'high' && t.status !== 'completed',
    ).length;
    if (highPriority > 0) {
      insightsList.push(`${highPriority} high-priority tasks need attention.`);
    }
  }

  return insightsList;
});

// Update task progress/status to backend
const updateTaskProgress = async (
  taskId: number,
  progress: number,
  status: string,
  todayNote?: string,
) => {
  try {
    console.log('Updating task:', taskId, 'progress:', progress, 'status:', status);
    const response = await fetch(`http://localhost:3007/api/employee/tasks/${taskId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${authStore.token}`,
      },
      body: JSON.stringify({ progress, status, todayNote, user_id: authStore.user?.id }),
    });
    const result = await response.json();
    console.log('Update task result:', result);
    if (result.success) {
      // If task was completed, switch to completed tab
      if (status === 'completed') {
        activeTab.value = 'completed';
      }
      // Refresh tasks to get latest data
      await fetchTasks();
    } else {
      console.error('Update task failed:', result.error);
      $q.notify({
        message: result.error || 'Update task failed',
        color: 'negative',
        icon: 'error',
      });
      // Revert the local changes by refreshing tasks
      await fetchTasks();
    }
  } catch (error) {
    console.error('Error updating task progress:', error);
    $q.notify({
      message: 'Server error updating progress',
      color: 'negative',
      icon: 'error',
    });
  }
};

// ============================================================
// NEW TASK
// ============================================================

const newTask = ref({
  name: '',

  description: '',

  project: null as number | null,

  priority: 'Medium',

  deadline: '',
  
  expected_effort: 0,

  subtasks: [] as { id?: number; title: string; estimated_hours: number }[],

  depends_on_ids: [] as number[],
});

const taskOptions = computed(() => {
  return tasks.value.map((t) => ({ label: t.name, value: t.id }));
});

// ============================================================
// EDIT SUBTASK COPY
// ============================================================

const editSubtasks = ref<Subtask[]>([]);

// ============================================================
// OPTIONS
// ============================================================

const projectOptions = computed(() => [
  { label: 'All Projects', value: 'All Projects' },
  ...Array.from(new Set(tasks.value.map((task) => task.project))).map((p) => ({
    label: p,
    value: p,
  })),
]);

const priorityOptions = ['All Priorities', 'Critical', 'High', 'Medium', 'Low'];

const taskStatusOptions: TaskStatus[] = [
  'not-started',

  'in-progress',

  'completed',

  'blocked',

  'in-review',
];

const subtaskStatusOptions: SubtaskStatus[] = ['not-started', 'in-progress', 'completed'];

// ============================================================
// TAB LABEL
// ============================================================

const activeTabLabel = computed(() => {
  switch (activeTab.value) {
    case 'my':
      return 'Assigned to you';

    case 'progress':
      return 'Currently active';

    case 'completed':
      return 'Finished tasks';

    default:
      return 'All tasks';
  }
});

// ============================================================
// FILTERED TASKS
// ============================================================
const filteredTasks = computed(() => {
  let result = tasks.value;

  /* SEARCH */

  if (search.value.trim()) {
    const query = search.value.toLowerCase().trim();

    result = result.filter((task) => {
      if (searchType.value === 'project') {
        return task.project?.toLowerCase().includes(query);
      }

      if (searchType.value === 'priority') {
        return task.priority?.toLowerCase().includes(query);
      }

      if (searchType.value === 'status') {
        return task.status?.toLowerCase().includes(query);
      }

      // DEFAULT = TASK NAME
      return task.name?.toLowerCase().includes(query);
    });
  }

  /* PROJECT FILTER */

  if (projectFilter.value !== 'All Projects') {
    result = result.filter((task) => task.project === projectFilter.value);
  }

  /* PRIORITY FILTER */

  if (priorityFilter.value !== 'All Priorities') {
    result = result.filter((task) => task.priority === priorityFilter.value);
  }

  /* STATUS FILTER */

  if (statusFilter.value !== 'All Statuses') {
    result = result.filter((task) => task.status === statusFilter.value);
  }

  /* SELF / PM */

  if (taskView.value === 'self') {
    result = result.filter((task) => task.assignedBy === 'Self-Assigned');
  }

  if (taskView.value === 'pm') {
    result = result.filter((task) => task.assignedBy !== 'Self-Assigned');
  }

  if (activeTab.value === 'progress') {
    result = result.filter((task) => task.status === 'in-progress');
  }

  if (activeTab.value === 'completed') {
    result = result.filter((task) => task.status === 'completed');
  }

  // "All" tab should only show non-completed tasks (exclude completed and in-review)
  if (activeTab.value === 'all') {
    result = result.filter((task) => task.status !== 'completed' && task.status !== 'in-review');
  }

  return result;
});

// ============================================================
// STATISTICS
// ============================================================

const stats = computed(() => [
  {
    label: 'Total Tasks',

    value: tasks.value.length,

    description: 'Assigned to you',

    icon: 'assignment',

    color: '#7c3aed',

    trend: 'All tasks',

    positive: true,
  },

  {
    label: 'In Progress',

    value: tasks.value.filter((task) => task.status === 'in-progress').length,

    description: 'Currently active',

    icon: 'pending_actions',

    color: '#3b82f6',

    trend: 'Active',

    positive: true,
  },

  {
    label: 'Completed',

    value: tasks.value.filter((task) => task.status === 'completed').length,

    description: 'Successfully finished',

    icon: 'check_circle',

    color: '#22c55e',

    trend: 'Good progress',

    positive: true,
  },

  {
    label: 'Overdue',

    value: tasks.value.filter((task) => isOverdue(task)).length,

    description: 'Need attention',

    icon: 'warning',

    color: '#ef4444',

    trend: 'Review',

    positive: false,
  },
]);

// ============================================================
// TABLE COLUMNS
// ============================================================

const columns = [
  {
    name: 'task',

    label: 'TASK',

    field: 'name',

    align: 'left' as const,

    sortable: true,
  },

  {
    name: 'project',

    label: 'PROJECT',

    field: 'project',

    align: 'left' as const,

    sortable: true,
  },

  {
    name: 'subtasks',

    label: 'SUBTASKS',

    field: 'subtasks',

    align: 'left' as const,
  },

  {
    name: 'priority',

    label: 'PRIORITY',

    field: 'priority',

    align: 'left' as const,
  },

  {
    name: 'status',

    label: 'STATUS',

    field: 'status',

    align: 'left' as const,
  },

  {
    name: 'progress',

    label: 'PROGRESS',

    field: 'progress',

    align: 'left' as const,
  },

  {
    name: 'deadline',

    label: 'DEADLINE',

    field: 'deadline',

    align: 'left' as const,
  },

  {
    name: 'actions',

    label: '',

    field: 'actions',

    align: 'right' as const,
  },
];

// ============================================================
// SUBTASK CALCULATIONS
// ============================================================

function completedSubtasks(task: Task) {
  return task.subtasks.filter((subtask) => subtask.completed).length;
}

function taskProgress(task: Task) {
  // If task has no subtasks, use database progress
  if (task.subtasks.length === 0) {
    if (task.status === 'completed') {
      return 100;
    }
    return task.progress || 0;
  }

  const completed = completedSubtasks(task);

  return Math.round((completed / task.subtasks.length) * 100);
}

// ============================================================
// AUTOMATIC STATUS
// ============================================================

function recalculateTask(task: Task) {
  const progress = taskProgress(task);

  if (task.subtasks.length > 0 && progress === 100) {
    task.status = 'completed';

    return;
  }

  if (progress > 0) {
    task.status = 'in-progress';

    return;
  }

  task.status = 'not-started';
}

// ============================================================
// SUBTASK COMPLETION
// ============================================================

function updateSubtaskCompletion(task: Task, subtask: Subtask) {
  if (subtask.completed) {
    subtask.status = 'completed';
  } else {
    subtask.status = 'not-started';
  }
}

function updateSubtaskStatus(task: Task, subtask: Subtask) {
  // Update completed based on status
  if (subtask.status === 'completed') {
    subtask.completed = true;
  } else {
    subtask.completed = false;
  }
}

// ============================================================
// TASK STATUS CHANGE
// ============================================================

function handleTaskStatusChange(task: Task) {
  if (task.status === 'completed') {
    task.subtasks.forEach((subtask) => {
      subtask.completed = true;

      subtask.status = 'completed';
    });
  }

  if (task.status === 'not-started') {
    task.subtasks.forEach((subtask) => {
      subtask.completed = false;

      subtask.status = 'not-started';
    });
  }

  // Sync with backend
  const progress = taskProgress(task);
  updateTaskProgress(task.id, progress, task.status, task.todayNote);
}

// ============================================================
// ADD TASK
// ============================================================

function openAddTask() {
  newTask.value = {
    name: '',

    description: '',

    project: null,

    priority: 'Medium',

    deadline: '',
    
    expected_effort: 0,

    subtasks: [],

    depends_on_ids: [],
  };

  showAddDialog.value = true;
}

function addNewTaskSubtask() {
  newTask.value.subtasks.push({
    id: Date.now(),
    title: '',
    estimated_hours: 0,
  });
}

function removeNewTaskSubtask(index: number) {
  newTask.value.subtasks.splice(index, 1);
}

async function createTask() {
  if (!newTask.value.name.trim()) {
    $q.notify({
      message: 'Please enter a task name',
      color: 'negative',
      icon: 'error',
    });
    return;
  }

  if (!newTask.value.project) {
    $q.notify({
      message: 'Please select a project',
      color: 'negative',
      icon: 'error',
    });
    return;
  }

  try {
    const payload = {
      title: newTask.value.name.trim(),
      description: newTask.value.description || 'No description added.',
      project_id: newTask.value.project,
      priority: newTask.value.priority.toLowerCase(),
      deadline: newTask.value.deadline || new Date(new Date().getTime() - (new Date().getTimezoneOffset() * 60000)).toISOString().split('T')[0],
      expected_effort: newTask.value.expected_effort || 0,
      user_id: authStore.user?.id ? Number(authStore.user.id) : undefined,
      assignee_ids: authStore.user ? [Number(authStore.user.id)] : [],
      is_self_assigned: 1,
      depends_on_ids: newTask.value.depends_on_ids,
    };

    const response = await fetch('http://localhost:3007/api/employee/tasks', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${authStore.token}`,
      },
      body: JSON.stringify(payload),
    });

    const result = await response.json();
    if (!result.success) throw new Error(result.error);

    const taskId = result.taskId || result.task?.id;

    // Create subtasks
    const subtasks = newTask.value.subtasks.filter((subtask) => subtask.title.trim());

    for (const subtask of subtasks) {
      await fetch(`http://localhost:3007/api/employee/tasks/${taskId}/subtasks`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
        body: JSON.stringify({
          title: subtask.title.trim(),
          estimated_hours: subtask.estimated_hours || 0,
        }),
      });
    }

    await fetchTasks();

    showAddDialog.value = false;
    $q.notify({
      message: 'Task created successfully',
      color: 'positive',
      icon: 'check_circle',
    });
  } catch (error) {
    console.error('Error creating task:', error);
    $q.notify({
      message: 'Error creating task',
      color: 'negative',
      icon: 'error',
    });
  }
}

// ============================================================
// EDIT SUBTASKS
// ============================================================

function openEditSubtasks(task: Task) {
  selectedTask.value = task;

  editSubtasks.value = task.subtasks.map((subtask) => ({
    ...subtask,
  }));

  showEditDialog.value = true;
}

function addEditSubtask() {
  editSubtasks.value.push({
    id: Date.now(),

    title: '',

    completed: false,

    status: 'not-started',

    estimated_hours: 0,
  });
}

function removeEditSubtask(id: number) {
  editSubtasks.value = editSubtasks.value.filter((subtask) => subtask.id !== id);
}

async function saveEditedSubtasks() {
  if (!selectedTask.value) {
    return;
  }

  try {
    const originalSubtasks = selectedTask.value.subtasks;
    const newSubtaskIds = editSubtasks.value.map((s) => s.id);

    // Delete subtasks that were removed
    const subtasksToDelete = originalSubtasks.filter((s) => !newSubtaskIds.includes(s.id));
    for (const subtask of subtasksToDelete) {
      await fetch(`http://localhost:3007/api/employee/subtasks/${subtask.id}`, {
        method: 'DELETE',
      });
    }

    for (const subtask of editSubtasks.value) {
      if (!subtask.title.trim()) continue;

      if (originalSubtasks.find((s) => s.id === subtask.id)) {
        // Update existing subtask
        await fetch(`http://localhost:3007/api/employee/subtasks/${subtask.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            title: subtask.title.trim(),
            status: subtask.status,
            completed: subtask.completed,
            user_id: authStore.user?.id,
          }),
        });
      } else {
        // Create new subtask
        const response = await fetch(
          `http://localhost:3007/api/employee/tasks/${selectedTask.value.id}/subtasks`,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              title: subtask.title.trim(),
              estimated_hours: subtask.estimated_hours || 0,
            }),
          },
        );
        const data = await response.json();
        if (!response.ok || !data.success) {
          throw new Error(data.error || 'Failed to add subtask');
        }
      }
    }

    // Refresh tasks to get updated subtasks
    await fetchTasks();
    const updatedTask = tasks.value.find((t) => t.id === selectedTask.value!.id);
    if (updatedTask) {
      selectedTask.value = updatedTask;
      recalculateTask(selectedTask.value);
      const progress = taskProgress(selectedTask.value);
      await updateTaskProgress(selectedTask.value.id, progress, selectedTask.value.status);
    }

    showEditDialog.value = false;

    $q.notify({
      message: 'Subtasks updated successfully',
      color: 'positive',
      icon: 'check_circle',
    });
  } catch (error: any) {
    console.error('Error saving subtasks:', error);
    $q.notify({
      message: error.message || 'Error saving subtasks',
      color: 'negative',
      icon: 'error',
    });
  }
}

// ============================================================
// MANAGE DRAWER
// ============================================================

function openManage(task: Task) {
  selectedTask.value = task;
  manageTab.value = 'details';

  showManageDrawer.value = true;
}

function openEditFromManage() {
  if (!selectedTask.value) {
    return;
  }

  showManageDrawer.value = false;

  openEditSubtasks(selectedTask.value);
}

async function saveTaskUpdate() {
  if (!selectedTask.value) {
    return;
  }

  // Save to database
  try {
    const promises = selectedTask.value.subtasks.map((subtask) =>
      fetch(`http://localhost:3007/api/employee/subtasks/${subtask.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: subtask.title,
          status: subtask.status,
          completed: subtask.completed,
          user_id: authStore.user?.id,
        }),
      }),
    );
    await Promise.all(promises);
  } catch (error) {
    console.error('Error saving subtasks:', error);
  }

  recalculateTask(selectedTask.value);
  const progress = taskProgress(selectedTask.value);
  await updateTaskProgress(
    selectedTask.value.id,
    progress,
    selectedTask.value.status,
    selectedTask.value.todayNote,
  );

  // Refresh tasks to get latest state including originally_completed
  await fetchTasks();
  if (selectedTask.value) {
    const updatedTask = tasks.value.find((t) => t.id === selectedTask.value!.id);
    if (updatedTask) selectedTask.value = updatedTask;
  }

  $q.notify({
    message: 'Task progress updated',

    color: 'positive',

    icon: 'save',
  });
}

// ============================================================
// VIEW TASK
// ============================================================

function viewTask(task: Task) {
  selectedTask.value = task;

  showManageDrawer.value = true;
}

// ============================================================
// DELETE
// ============================================================

function deleteTask(task: Task) {
  $q.dialog({
    title: 'Delete Task',

    message: `Delete "${task.name}"?`,

    cancel: true,

    persistent: true,
  }).onOk(() => {
    tasks.value = tasks.value.filter((item) => item.id !== task.id);

    $q.notify({
      message: 'Task deleted',

      color: 'positive',

      icon: 'delete',
    });
  });
}

// ============================================================
// FILTERS
// ============================================================

function clearFilters() {
  search.value = '';

  projectFilter.value = 'All Projects';

  priorityFilter.value = 'All Priorities';

  statusFilter.value = 'All Statuses';
}

// ============================================================
// PRIORITY STYLE
// ============================================================

function priorityStyle(priority: string) {
  switch (priority) {
    case 'Critical':
      return {
        bg: 'var(--priority-critical-bg)',

        color: 'var(--priority-critical)',
      };

    case 'High':
      return {
        bg: 'var(--priority-high-bg)',

        color: 'var(--priority-high)',
      };

    case 'Medium':
      return {
        bg: 'var(--priority-medium-bg)',

        color: 'var(--priority-medium)',
      };

    default:
      return {
        bg: 'var(--priority-low-bg)',

        color: 'var(--priority-low)',
      };
  }
}

// ============================================================
// STATUS STYLE
// ============================================================

function statusStyle(status: string) {
  switch (status) {
    case 'Completed':
      return {
        bg: 'var(--status-completed-bg)',

        color: 'var(--status-completed)',
      };

    case 'In Progress':
      return {
        bg: 'var(--status-progress-bg)',

        color: 'var(--status-progress)',
      };

    default:
      return {
        bg: 'var(--status-not-started-bg)',

        color: 'var(--status-not-started)',
      };
  }
}

// ============================================================
// PROJECT STYLE
// ============================================================

function projectColor(project: string) {
  if (project === 'Mobile Banking') {
    return {
      bg: '#eff6ff',

      color: '#3b82f6',
    };
  }

  if (project === 'Website Redesign') {
    return {
      bg: '#f3e8ff',

      color: '#7c3aed',
    };
  }

  return {
    bg: 'var(--color-teal-light)',

    color: 'var(--color-teal)',
  };
}

function projectIcon(project: string) {
  if (project === 'Mobile Banking') {
    return 'account_balance';
  }

  if (project === 'Website Redesign') {
    return 'web';
  }

  return 'folder';
}

// ============================================================
// DATE
// ============================================================

function formatDate(date: string) {
  if (!date) {
    return '-';
  }

  const parsedDate = new Date(date);
  if (isNaN(parsedDate.getTime())) {
    return '-';
  }

  return parsedDate.toLocaleDateString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

// ============================================================
// OVERDUE
// ============================================================

function isOverdue(task: Task) {
  if (task.status === 'completed') {
    return false;
  }

  return new Date(task.deadline) < new Date();
}
const showInterruptDialog = ref(false);
const interruptReason = ref('');

async function submitInterrupt() {
  if (!selectedTask.value || !interruptReason.value) return;
  try {
    const response = await fetch(
      `http://localhost:3007/api/pm/tasks/${selectedTask.value.id}/interrupt`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
        body: JSON.stringify({ reason: interruptReason.value }),
      },
    );

    const data = await response.json();
    if (data.success) {
      $q.notify({ color: 'positive', message: 'Task interrupted successfully. PM notified.' });
      showInterruptDialog.value = false;
      showManageDrawer.value = false;
      interruptReason.value = '';
    } else {
      $q.notify({ color: 'negative', message: data.error || 'Failed to interrupt task' });
    }
  } catch (error) {
    console.error('Interrupt task error:', error);
    $q.notify({ color: 'negative', message: 'Server error' });
  }
}
</script>

<style scoped>
.stat-card {
  border-radius: var(--radius-lg);
  background: #ffffff;
  transition: all 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.stat-trend {
  font-size: 11px;
  font-weight: 600;
}

.my-tasks-card {
  overflow: hidden;

  display: flex;
  flex-direction: column;

  background: #f5f8fc;
}

.my-task-icon {
  background: #f3e8ff;
  color: #7c3aed;
}

.task-name {
  font-size: 16px;
  font-weight: 650;
  line-height: 1.3;
  color: #111827;
}

.task-description {
  max-width: 330px;
  margin-top: 4px;
  font-size: 12px;
  color: #64748b;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.task-table :deep(th) {
  background: #fafbfc;
  color: #64748b;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
}

.task-table :deep(td) {
  padding-top: 16px;
  padding-bottom: 16px;
  border-color: #edf0f5;
}

.task-table :deep(tbody tr) {
  transition: background 0.15s ease;
}

.task-table :deep(tbody tr:hover) {
  background: #fafaff;
}

.subtask-count {
  display: flex;
  align-items: center;
  color: #64748b;
  font-size: 13px;
  font-weight: 600;
}

.task-grid-card {
  border-radius: var(--radius-lg);
  transition: all 0.2s ease;
}

.task-grid-card:hover {
  transform: translateY(-3px);
  box-shadow: var(--shadow-md);
}

.task-grid-title {
  font-size: 18px;
  font-weight: 700;
  line-height: 1.3;
  color: #111827;
}

.grid-description {
  height: 40px;
  line-height: 20px;

  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;

  overflow: hidden;
  text-overflow: ellipsis;
}

/* Create Task dialog — visually matched to the Project Manager dialog */
.create-dialog-card {
  width: 540px;
  max-width: 90vw;
  border-radius: 18px;
  overflow: hidden;
}

.create-dialog-header {
  color: white;
  background: linear-gradient(135deg, #3949ab, #5c6bc0);
}
.create-dialog-body {
  max-height: calc(90vh - 110px);
  overflow-y: auto;
}

.subtask-editor {
  padding: 16px;
  border: 1px solid #e5e7eb;
  border-radius: var(--radius-md);
  background: var(--color-surface-hover);
}

.subtask-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 8px;
}

.empty-subtasks {
  padding: 25px;
  text-align: center;
  border: 1px dashed #e5e7eb;
  border-radius: var(--radius-md);
  background: #ffffff;
}

.points-badge {
  background: linear-gradient(135deg, #ffd700 0%, #ffa500 100%);
  padding: 6px 12px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 6px;
  box-shadow: 0 2px 8px rgba(255, 215, 0, 0.3);
}

.points-text {
  font-size: 16px;
  font-weight: bold;
  color: #8b4513;
}

.edit-subtask-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
}

.manage-dialog {
  width: 850px;
  max-width: 94vw;

  height: 88vh;
  max-height: 900px;

  border-radius: 20px;
  overflow: hidden;

  display: flex;
  flex-direction: column;

  background: #f5f8fc;
}

/* ================= HEADER ================= */

.manage-header {
  flex-shrink: 0;

  background: #ffffff;
  color: #263238;

  border-bottom: 1px solid #e3edf7;
}

.manage-task-name {
  font-size: 25px;
  line-height: 1.3;

  font-weight: 800;

  color: #1565c0;
}

.task-project {
  display: flex;
  align-items: center;

  color: #607d8b;
  font-size: 13px;
  font-weight: 500;
}

.manage-close-btn {
  color: #607d8b !important;
}

.manage-close-btn:hover {
  background: #eaf4ff;
  color: #1565c0 !important;
}

/* ================= TABS ================= */
.manage-tabs {
  flex-shrink: 0;
  min-height: 16px;
  background: #ffffff;
}

.manage-tabs .q-tab {
  min-height: 16px;
  font-size: 13px;
  font-weight: 600;
  color: #78909c;
}

/* Put icon + text horizontally */
.manage-tabs .q-tab__content {
  flex-direction: row !important;
  justify-content: center;
  align-items: center;
}

/* Icon spacing */
.manage-tabs .q-tab__icon {
  margin-right: 8px !important;
  margin-bottom: 0 !important;
}

/* Text */
.manage-tabs .q-tab__label {
  margin: 0 !important;
}

.manage-tabs .q-tab--active {
  color: #1565c0;
}
/* ================= CONTENT ================= */

.manage-panels {
  flex: 1;
  min-height: 0;

  background: #f5f8fc;
}

.manage-panel {
  padding: 28px 40px;
}

/* ================= PROGRESS ================= */

.manage-progress-card {
  padding: 22px;

  background: #ffffff;

  border: 1px solid #e0eaf4;
  border-radius: 16px;

  box-shadow: 0 3px 14px rgba(21, 101, 192, 0.06);
}

/* ================= SECTION TITLES ================= */

.section-title {
  font-size: 16px;
  font-weight: 700;

  color: #263238;
}

/* ================= SUBTASK ================= */

.manage-subtask {
  padding: 15px 16px;

  margin-bottom: 10px;

  background: #ffffff;

  border: 1px solid #e1eaf3;
  border-radius: 13px;

  transition: all 0.2s ease;
}

.manage-subtask:hover {
  border-color: #90caf9;

  box-shadow: 0 4px 14px rgba(33, 150, 243, 0.08);
}

.manage-subtask-title {
  font-size: 14px;
  font-weight: 600;

  color: #37474f;

  line-height: 1.5;
}

.completed-subtask {
  text-decoration: line-through;
  color: #9e9e9e;
}

/* ================= EMPTY ================= */

.empty-subtasks {
  padding: 36px 20px;

  text-align: center;

  background: #ffffff;

  border: 1px dashed #b8cce0;
  border-radius: 14px;
}

/* ================= TIMELINE ================= */

.timeline-card {
  padding: 24px;

  background: #ffffff;

  border: 1px solid #e0eaf4;
  border-radius: 16px;

  box-shadow: 0 3px 14px rgba(21, 101, 192, 0.05);
}

.timeline-item {
  display: flex;
  align-items: center;

  padding: 15px;

  background: #f5f9ff;

  border-radius: 12px;
}

/* ================= IMPACT ================= */

.impact-info {
  display: flex;
  align-items: center;

  padding: 16px;

  background: #f5f9ff;

  border: 1px solid #e2edf8;
  border-radius: 12px;
}

/* ================= DEADLINE ================= */

.deadline-box {
  display: flex;
  align-items: center;

  padding: 15px;

  background: #eaf4ff;

  border: 1px solid #bbdefb;
  border-radius: 12px;

  color: #1565c0;
}

.deadline-overdue {
  background: #ffebee;

  border-color: #ffcdd2;

  color: #c62828;
}

/* ================= FOOTER ================= */

.manage-footer {
  flex-shrink: 0;

  background: transparent !important;
}

.completed-subtask {
  color: #94a3b8;
  text-decoration: line-through;
}

/* =========================================================
   EDIT SUBTASKS DIALOG
   ========================================================= */

.edit-subtasks-dialog {
  width: 680px;
  max-width: 94vw;
  max-height: 90vh;
  border-radius: 20px;
  overflow: hidden;
  background: #f7f9fc;
}

/* HEADER */

.edit-subtasks-header {
  color: white;
  background: linear-gradient(135deg, #3949ab 0%, #5c6bc0 100%);
  padding: 20px 24px;
}

/* TASK INFO */

.edit-task-info {
  background: #ffffff;
  padding: 16px 24px;
}

/* SUBTASK CARD */

.edit-subtask-card {
  padding: 14px;
  background: #ffffff;
  border: 1px solid #e1e7f0;
  border-radius: 14px;
  transition: all 0.2s ease;
}

.edit-subtask-card:hover {
  border-color: #9fa8da;
  box-shadow: 0 4px 14px rgba(63, 81, 181, 0.10);
  transform: translateY(-1px);
}

/* NUMBER */

.subtask-number {
  width: 32px;
  height: 32px;
  min-width: 32px;
  border-radius: 10px;

  display: flex;
  align-items: center;
  justify-content: center;

  background: #eef0ff;
  color: #3949ab;

  font-size: 13px;
  font-weight: 700;
}

/* TITLE */

.subtask-title-input :deep(.q-field__control) {
  border-radius: 9px;
}

/* HOURS */

.hours-field {
  width: 155px;
  min-width: 155px;
}

.hours-input :deep(.q-field__control) {
  border-radius: 9px;
}

.hours-input :deep(.q-field__native) {
  font-weight: 600;
  font-size: 15px;
}

.hours-input :deep(.q-field__prepend) {
  padding-right: 4px;
}

.hours-label {
  color: #e67e22;
  font-size: 13px;
  font-weight: 700;
}

/* DELETE */

.delete-subtask-btn {
  background: #fff5f5;
}

.delete-subtask-btn:hover {
  background: #ffebee;
}

/* EMPTY */

.edit-empty-subtasks {
  padding: 35px 20px;
  text-align: center;

  background: #ffffff;
  border: 1px dashed #c5cae9;
  border-radius: 14px;
}

/* ADD BUTTON */

.add-subtask-btn {
  border-radius: 10px;
  border-style: dashed;
  min-height: 44px;
}

/* FOOTER */

.edit-subtasks-footer {
  background: #ffffff;
}

:global(body.body--dark) .my-tasks-card,
:global(body.body--dark) .manage-dialog,
:global(body.body--dark) .manage-header,
:global(body.body--dark) .manage-tabs,
:global(body.body--dark) .manage-panels,
:global(body.body--dark) .manage-progress-card,
:global(body.body--dark) .manage-subtask,
:global(body.body--dark) .timeline-card,
:global(body.body--dark) .edit-subtasks-dialog,
:global(body.body--dark) .edit-task-info,
:global(body.body--dark) .edit-subtask-card,
:global(body.body--dark) .edit-empty-subtasks,
:global(body.body--dark) .edit-subtasks-footer,
:global(body.body--dark) .empty-subtasks {
  background: #1d2930;
  border-color: #34434c;
  color: #edf2f7;
}

:global(body.body--dark) .task-table :deep(th) {
  background: #26343c;
  color: #edf2f7;
}

:global(body.body--dark) .task-table :deep(td) {
  border-color: #34434c;
}

:global(body.body--dark) .task-table :deep(tbody tr:hover) {
  background: #26343c;
}

:global(body.body--dark) .manage-task-name,
:global(body.body--dark) .section-title {
  color: #a8c7ff;
}

:global(body.body--dark) .manage-subtask-title,
:global(body.body--dark) .task-grid-title,
:global(body.body--dark) .task-name {
  color: #edf2f7;
}

:global(body.body--dark) .timeline-item,
:global(body.body--dark) .impact-info {
  background: #26343c;
  border-color: #34434c;
}

/* ============================================================
   DARK MODE — TASK MANAGER
   Keep all Task Manager-specific light-theme styles readable.
   ============================================================ */
:global(body.body--dark) .app-page {
  background: #121a1f !important;
  color: #edf2f7 !important;
}

:global(body.body--dark) .my-tasks-card,
:global(body.body--dark) .task-grid-card,
:global(body.body--dark) .create-dialog-card,
:global(body.body--dark) .manage-dialog,
:global(body.body--dark) .edit-subtasks-dialog {
  background: #1d2930 !important;
  color: #edf2f7 !important;
  border-color: #34434c !important;
}

:global(body.body--dark) .task-name,
:global(body.body--dark) .task-grid-title,
:global(body.body--dark) .my-tasks-card .text-body1,
:global(body.body--dark) .my-tasks-card .text-body2,
:global(body.body--dark) .my-tasks-card .text-subtitle1,
:global(body.body--dark) .my-tasks-card .text-subtitle2,
:global(body.body--dark) .my-tasks-card .text-h6 {
  color: #edf2f7 !important;
}

:global(body.body--dark) .task-description,
:global(body.body--dark) .subtask-count,
:global(body.body--dark) .my-tasks-card .text-grey-6,
:global(body.body--dark) .my-tasks-card .text-grey-7 {
  color: #b8c7d1 !important;
}

:global(body.body--dark) .task-table,
:global(body.body--dark) .task-table :deep(.q-table__container),
:global(body.body--dark) .task-table :deep(.q-table__middle),
:global(body.body--dark) .task-table :deep(table),
:global(body.body--dark) .task-table :deep(thead),
:global(body.body--dark) .task-table :deep(tbody),
:global(body.body--dark) .task-table :deep(tr),
:global(body.body--dark) .task-table :deep(td) {
  background: #1d2930 !important;
  color: #edf2f7 !important;
  border-color: #34434c !important;
}

:global(body.body--dark) .task-table :deep(th) {
  background: #26343c !important;
  color: #b8c7d1 !important;
  border-color: #34434c !important;
}

:global(body.body--dark) .task-table :deep(tbody tr:hover) {
  background: #26343c !important;
}

:global(body.body--dark) .task-table :deep(.q-table__top),
:global(body.body--dark) .task-table :deep(.q-table__bottom) {
  background: #1d2930 !important;
  color: #edf2f7 !important;
}

:global(body.body--dark) .create-dialog-body,
:global(body.body--dark) .edit-task-info,
:global(body.body--dark) .manage-header,
:global(body.body--dark) .manage-tabs,
:global(body.body--dark) .manage-panels,
:global(body.body--dark) .manage-progress-card,
:global(body.body--dark) .manage-subtask,
:global(body.body--dark) .timeline-card,
:global(body.body--dark) .edit-subtask-card,
:global(body.body--dark) .edit-empty-subtasks,
:global(body.body--dark) .empty-subtasks {
  background: #1d2930 !important;
  color: #edf2f7 !important;
  border-color: #34434c !important;
}

:global(body.body--dark) .subtask-editor,
:global(body.body--dark) .timeline-item,
:global(body.body--dark) .impact-info {
  background: #26343c !important;
  color: #edf2f7 !important;
  border-color: #34434c !important;
}

:global(body.body--dark) .manage-task-name,
:global(body.body--dark) .section-title {
  color: #a8c7ff !important;
}

:global(body.body--dark) .manage-subtask-title,
:global(body.body--dark) .task-project {
  color: #edf2f7 !important;
}

:global(body.body--dark) .manage-tabs .q-tab {
  color: #b8c7d1 !important;
}

:global(body.body--dark) .manage-tabs .q-tab--active {
  color: #9fd2ff !important;
}

:global(body.body--dark) .deadline-box {
  background: #20374a !important;
  border-color: #34434c !important;
  color: #9fd2ff !important;
}

:global(body.body--dark) .deadline-overdue {
  background: #45222a !important;
  border-color: #6b3440 !important;
  color: #ffb4b4 !important;
}

:global(body.body--dark) .subtask-title-input :deep(.q-field__control),
:global(body.body--dark) .hours-input :deep(.q-field__control) {
  background: #26343c !important;
}

:global(body.body--dark) .subtask-title-input :deep(.q-field__native),
:global(body.body--dark) .hours-input :deep(.q-field__native),
:global(body.body--dark) .subtask-title-input :deep(.q-field__label),
:global(body.body--dark) .hours-input :deep(.q-field__label) {
  color: #edf2f7 !important;
}

:global(body.body--dark) .edit-subtask-footer,
:global(body.body--dark) .edit-subtasks-footer {
  background: #1d2930 !important;
  color: #edf2f7 !important;
  border-color: #34434c !important;
}

</style>
