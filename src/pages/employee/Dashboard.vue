<template>
  <q-page
    class="q-pa-md text-black"
    style="
      height: 100vh;
      max-height: 100vh;
      min-height: 0 !important;
      overflow: hidden;
      display: flex;
      flex-direction: column;
    "
  >
    <!-- Header -->
    <div class="row items-center justify-between q-mb-md" style="flex: 0 0 auto">
      <div class="column">
        <div class="text-h5 text-weight-bold">My Workspace 👋</div>
        <div class="text-grey-7 text-caption">Overview of your tasks and progress</div>
      </div>
      <div class="row items-center q-gutter-sm">
        <q-avatar size="36px" class="cursor-pointer">
          <img :src="authStore.user?.avatar || 'https://cdn.quasar.dev/img/avatar.png'" />
          <q-menu anchor="bottom right" self="top right">
            <q-list style="min-width: 150px">
              <q-item clickable v-close-popup to="/employee/settings">
                <q-item-section avatar><q-icon name="person" /></q-item-section>
                <q-item-section>Profile</q-item-section>
              </q-item>
              <q-separator />
              <q-item clickable v-close-popup @click="logout">
                <q-item-section avatar><q-icon name="logout" color="red" /></q-item-section>
                <q-item-section class="text-red">Logout</q-item-section>
              </q-item>
            </q-list>
          </q-menu>
        </q-avatar>
      </div>
    </div>

    <!-- Summary Cards -->
    <div class="row q-col-gutter-md q-mb-md" style="flex: 0 0 auto">
      <div class="col-3">
        <StatCard
          title="Total Tasks"
          :value="stats.totalTasks.toString()"
          color="blue"
          icon="o_task_alt"
          caption="Assigned to you"
        />
      </div>
      <div class="col-3">
        <StatCard
          title="Completed"
          :value="stats.completedTasks.toString()"
          color="green"
          icon="o_check_circle"
          caption="Tasks finished"
        />
      </div>
      <div class="col-3">
        <StatCard
          title="In Progress"
          :value="stats.inProgressTasks.toString()"
          color="orange"
          icon="o_pending"
          caption="Currently working"
        />
      </div>
      <div class="col-3">
        <q-card flat class="rounded-borders q-pa-md shadow-1" style="border: 1px solid #edf0f5; border-radius: 14px; min-height: 112px;">
          <div class="row justify-between items-center q-mb-xs">
            <div class="text-grey-7 text-caption text-weight-medium">
              Overdue
            </div>
            <q-avatar size="24px" :color="overdueTasks.length > 0 ? 'red-1' : 'grey-1'" :text-color="overdueTasks.length > 0 ? 'red' : 'grey'" icon="event" />
          </div>
          <div :class="`text-h4 text-weight-bold ${overdueTasks.length > 0 ? 'text-red' : 'text-grey-7'}`" style="line-height: 1">
            {{ overdueTasks.length }}
          </div>
          <div
            class="row items-center text-grey-6"
            style="font-size: 11px; margin-top: 6px"
          >
            {{ overdueTasks.length > 0 ? 'Need attention' : 'No overdue tasks' }}
          </div>
          <div class="q-mt-sm">
            <q-btn
              size="sm"
              color="primary"
              label="View"
              @click="openOverdueDialog"
              dense
            />
          </div>
        </q-card>
      </div>
    </div>

    <!-- Tabs -->
    <q-tabs
      v-model="activeTab"
      dense
      class="text-grey-7 q-mb-md"
      active-color="primary"
      indicator-color="primary"
      align="left"
      style="flex: 0 0 auto"
    >
      <q-tab name="tasks" label="My Tasks" icon="task" />
      <q-tab name="reviews" label="Reviews" icon="rate_review" />
    </q-tabs>

    <q-tab-panels
      v-model="activeTab"
      animated
      class="transparent"
      style="flex: 1 1 0; min-height: 0"
    >
      <!-- My Tasks Tab -->
      <q-tab-panel name="tasks" class="q-pa-none">
        <div class="row q-col-gutter-md" style="height: 100%; min-height: 0">
          <!-- Tasks Column -->
          <div class="col-12" style="height: 100%; display: flex; flex-direction: column">
            <q-card class="full-height flex column">
              <q-card-section class="bg-blue-1 text-blue-9 q-pb-sm">
                <div class="row items-center justify-between">
                  <div class="row items-center">
                    <q-icon name="task" size="24px" class="q-mr-sm" />
                    <div class="text-h6 text-weight-bold">My Tasks</div>
                  </div>
                  <div class="row items-center q-gutter-sm">
                    <q-btn
                      color="primary"
                      label="Automate"
                      icon="auto_fix_high"
                      size="sm"
                      @click="automateFullSchedule"
                      :loading="automating"
                      :disable="myTasks.length === 0"
                    />
                    <q-spinner-dots v-if="loading" size="24px" />
                  </div>
                </div>
                <div class="text-caption">Your assigned tasks across all projects</div>
              </q-card-section>

              <q-card-section
                class="q-pt-none q-px-md q-pb-md"
                style="flex: 1 1 0; overflow-y: auto"
              >
                <q-list separator v-if="myTasks.length > 0">
                  <q-item v-for="task in myTasks" :key="task.id" class="q-py-md">
                    <q-item-section avatar>
                      <q-circular-progress
                        v-if="task.status === 'completed'"
                        show-value
                        class="text-green text-weight-bold"
                        :value="100"
                        size="40px"
                        color="green"
                        track-color="grey-3"
                        style="font-size: 12px"
                      >
                        100
                      </q-circular-progress>
                      <q-circular-progress
                        v-else-if="task.status === 'in-progress'"
                        show-value
                        class="text-blue text-weight-bold"
                        :value="task.progress"
                        size="40px"
                        color="blue"
                        track-color="grey-3"
                        style="font-size: 12px"
                      >
                        {{ task.progress }}
                      </q-circular-progress>
                      <q-icon
                        v-else-if="task.status === 'in-review'"
                        name="rate_review"
                        color="purple"
                        size="40px"
                      />
                      <q-icon v-else name="radio_button_unchecked" color="grey-5" size="40px" />
                    </q-item-section>
                    <q-item-section>
                      <q-item-label
                        class="text-weight-bold"
                        :class="{ 'text-strike text-grey-6': task.status === 'completed' }"
                        >{{ task.title }}</q-item-label
                      >
                      <q-item-label caption>{{ getProjectName(task.project_id) }}</q-item-label>
                      <q-item-label caption>
                        <q-badge
                          :color="`${getPriorityColor(task.priority)}-1`"
                          :text-color="getPriorityColor(task.priority)"
                          :label="task.priority"
                          class="q-mr-xs"
                          style="font-size: 10px"
                        />
                        <q-badge
                          :color="`${getStatusColor(task.status)}-1`"
                          :text-color="getStatusColor(task.status)"
                          :label="task.status"
                          style="font-size: 10px"
                        />
                      </q-item-label>
                    </q-item-section>
                    <q-item-section side>
                      <div class="column items-end q-gutter-xs">
                        <div
                          class="text-caption text-weight-medium"
                          :class="{
                            'text-red': task.status !== 'completed' && isOverdue(task.deadline),
                          }"
                        >
                          {{ formatDate(task.deadline) }}
                        </div>
                        <q-btn
                          v-if="task.status === 'in-progress' || task.status === 'not-started'"
                          flat
                          round
                          dense
                          icon="edit"
                          color="blue"
                          size="sm"
                          label="Edit"
                          @click.stop="openUpdateDialog(task)"
                        />
                        <q-btn
                          v-if="isOverdue(task.deadline) && task.status !== 'completed'"
                          flat
                          round
                          dense
                          icon="event"
                          color="orange"
                          size="sm"
                          label="Set Deadline"
                          @click.stop="openSetDeadlineDialog(task)"
                        />
                        <q-btn
                          v-if="
                            task.status === 'completed' ||
                            task.status === 'in-review' ||
                            (task.status === 'in-progress' && task.progress === 100)
                          "
                          flat
                          round
                          dense
                          icon="rate_review"
                          color="purple"
                          size="sm"
                          label="Review"
                          @click.stop="openSubmitReviewDialog(task)"
                        />
                      </div>
                    </q-item-section>
                  </q-item>
                </q-list>

                <div v-else-if="!loading" class="text-center q-pa-xl text-grey-6">
                  <q-icon name="assignment" size="48px" class="q-mb-sm" />
                  <div class="text-h6">No tasks assigned</div>
                  <div>You have no tasks assigned yet</div>
                </div>
              </q-card-section>
            </q-card>
          </div>
        </div>
      </q-tab-panel>

      <!-- Reviews Tab -->
      <q-tab-panel name="reviews" class="q-pa-none">
        <div class="row q-col-gutter-md" style="height: 100%; min-height: 0">
          <!-- Completed Tasks Ready for Review Column -->
          <div class="col-4" style="height: 100%; display: flex; flex-direction: column">
            <q-card class="full-height flex column">
              <q-card-section class="bg-blue-1 text-blue-9 q-pb-sm">
                <div class="row items-center justify-between">
                  <div class="row items-center">
                    <q-icon name="task_alt" size="24px" class="q-mr-sm" />
                    <div class="text-h6 text-weight-bold">Completed Tasks</div>
                  </div>
                  <q-badge color="blue" :label="completedTasks.length" />
                </div>
                <div class="text-caption">Tasks ready to submit for review</div>
              </q-card-section>

              <q-card-section
                class="q-pt-none q-px-md q-pb-md"
                style="flex: 1 1 0; overflow-y: auto"
              >
                <q-list separator v-if="completedTasks.length > 0">
                  <q-item
                    v-for="task in completedTasks"
                    :key="task.id"
                    class="q-py-md"
                    clickable
                    @click="openSubmitReviewDialog(task)"
                  >
                    <q-item-section avatar>
                      <q-icon name="check_circle" color="green" size="32px" />
                    </q-item-section>
                    <q-item-section>
                      <q-item-label class="text-weight-bold">{{ task.title }}</q-item-label>
                      <q-item-label caption>{{ getProjectName(task.project_id) }}</q-item-label>
                      <q-item-label caption>Progress: {{ task.progress }}%</q-item-label>
                    </q-item-section>
                    <q-item-section side>
                      <q-btn color="primary" label="Put for Review" size="sm" />
                    </q-item-section>
                  </q-item>
                </q-list>

                <div v-else class="text-center q-pa-xl text-grey-6">
                  <q-icon name="task_alt" size="48px" class="q-mb-sm" />
                  <div class="text-h6">No completed tasks</div>
                  <div>Complete tasks to submit for review</div>
                </div>
              </q-card-section>
            </q-card>
          </div>

          <!-- Pending Reviews Column -->
          <div class="col-4" style="height: 100%; display: flex; flex-direction: column">
            <q-card class="full-height flex column">
              <q-card-section class="bg-purple-1 text-purple-9 q-pb-sm">
                <div class="row items-center justify-between">
                  <div class="row items-center">
                    <q-icon name="rate_review" size="24px" class="q-mr-sm" />
                    <div class="text-h6 text-weight-bold">Assigned Reviews</div>
                  </div>
                  <q-badge color="purple" :label="pendingReviews.length" />
                </div>
                <div class="text-caption">Tasks assigned to you for review</div>
              </q-card-section>

              <q-card-section
                class="q-pt-none q-px-md q-pb-md"
                style="flex: 1 1 0; overflow-y: auto"
              >
                <q-list separator v-if="pendingReviews.length > 0">
                  <q-item
                    v-for="review in pendingReviews"
                    :key="review.id"
                    class="q-py-md"
                    clickable
                    @click="openReviewDialog(review)"
                  >
                    <q-item-section avatar>
                      <q-avatar>
                        <img
                          :src="
                            review.task_owner_avatar ||
                            `https://i.pravatar.cc/150?img=${review.task_owner_id}`
                          "
                        />
                      </q-avatar>
                    </q-item-section>
                    <q-item-section>
                      <q-item-label class="text-weight-bold">{{ review.title }}</q-item-label>
                      <q-item-label caption
                        >Owner: {{ review.task_owner_first_name }}
                        {{ review.task_owner_last_name }}</q-item-label
                      >
                      <q-item-label caption>{{ getProjectName(review.project_id) }}</q-item-label>
                    </q-item-section>
                    <q-item-section side>
                      <q-btn color="green" label="Review" size="sm" />
                    </q-item-section>
                  </q-item>
                </q-list>

                <div v-else class="text-center q-pa-xl text-grey-6">
                  <q-icon name="rate_review" size="48px" class="q-mb-sm" />
                  <div class="text-h6">No pending reviews</div>
                  <div>No tasks assigned for review</div>
                </div>
              </q-card-section>
            </q-card>
          </div>

          <!-- Review History Column -->
          <div class="col-4" style="height: 100%; display: flex; flex-direction: column">
            <q-card class="full-height flex column">
              <q-card-section class="bg-green-1 text-green-9 q-pb-sm">
                <div class="row items-center justify-between">
                  <div class="row items-center">
                    <q-icon name="history" size="24px" class="q-mr-sm" />
                    <div class="text-h6 text-weight-bold">Review History</div>
                  </div>
                  <q-badge color="green" :label="reviewHistory.length" />
                </div>
                <div class="text-caption">Your review activity and points earned</div>
              </q-card-section>

              <q-card-section
                class="q-pt-none q-px-md q-pb-md"
                style="flex: 1 1 0; overflow-y: auto"
              >
                <q-list separator v-if="reviewHistory.length > 0">
                  <q-item v-for="review in reviewHistory" :key="review.id" class="q-py-md">
                    <q-item-section avatar>
                      <q-icon
                        :name="
                          review.status === 'finalized'
                            ? 'check_circle'
                            : review.status === 'review-done'
                              ? 'rate_review'
                              : 'pending'
                        "
                        :color="
                          review.status === 'finalized'
                            ? 'green'
                            : review.status === 'review-done'
                              ? 'purple'
                              : 'orange'
                        "
                        size="32px"
                      />
                    </q-item-section>
                    <q-item-section>
                      <q-item-label class="text-weight-bold">{{ review.title }}</q-item-label>
                      <q-item-label caption>{{ getProjectName(review.project_id) }}</q-item-label>
                      <q-item-label caption>
                        <q-badge
                          :color="
                            review.status === 'finalized'
                              ? 'green'
                              : review.status === 'review-done'
                                ? 'purple'
                                : 'orange'
                          "
                          >{{ review.status }}</q-badge
                        >
                      </q-item-label>
                      <q-item-label
                        caption
                        v-if="review.pm_final_comment"
                        class="text-grey-8 q-mt-xs"
                      >
                        PM: "{{ review.pm_final_comment }}"
                      </q-item-label>
                    </q-item-section>
                    <q-item-section side>
                      <div class="column items-end">
                        <q-badge
                          color="green"
                          :label="`+${review.task_owner_points || 0} pts`"
                          v-if="review.task_owner_points > 0"
                        />
                        <div class="text-caption text-grey-6">
                          {{ formatDate(review.submitted_at) }}
                        </div>
                      </div>
                    </q-item-section>
                  </q-item>
                </q-list>

                <div v-else class="text-center q-pa-xl text-grey-6">
                  <q-icon name="history" size="48px" class="q-mb-sm" />
                  <div class="text-h6">No review history</div>
                  <div>Start reviewing tasks to earn points</div>
                </div>
              </q-card-section>
            </q-card>
          </div>
        </div>
      </q-tab-panel>
    </q-tab-panels>

    <!-- Update Task Progress Dialog -->
    <q-dialog v-model="showUpdateDialog">
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6">Update Task Progress</div>
        </q-card-section>
        <q-card-section>
          <div v-if="selectedTask">
            <div class="q-mb-md">
              <div class="text-subtitle2">{{ selectedTask.title }}</div>
              <div class="text-caption text-grey-7">
                {{ getProjectName(selectedTask.project_id) }}
              </div>
            </div>
            <q-slider v-model="progressUpdate" :min="0" :max="100" label-always color="primary" />
            <q-select
              v-model="statusUpdate"
              :options="statusOptions"
              label="Status"
              outlined
              class="q-mt-md"
            />
            <q-input
              v-model="hoursSpent"
              type="number"
              label="Hours Spent"
              outlined
              class="q-mt-md"
            />
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Update" @click="updateTaskProgress" :loading="updating" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Submit for Review Dialog -->
    <q-dialog v-model="showSubmitReviewDialog">
      <q-card style="min-width: 500px">
        <q-card-section>
          <div class="text-h6">Put for Review</div>
        </q-card-section>
        <q-card-section>
          <div v-if="selectedTask">
            <div class="q-mb-md">
              <div class="text-subtitle2">{{ selectedTask.title }}</div>
              <div class="text-caption text-grey-7">
                {{ getProjectName(selectedTask.project_id) }}
              </div>
            </div>
            <q-input
              v-model="completionComment"
              label="Completion Comment"
              type="textarea"
              outlined
              rows="3"
              class="q-mt-md"
            />
            <q-select
              v-model="selectedReviewer"
              :options="reviewerOptions"
              option-label="label"
              option-value="value"
              emit-value
              map-options
              label="Select Reviewer"
              outlined
              class="q-mt-md"
              :loading="employees.length === 0"
              @update:model-value="(val) => console.log('Reviewer selected:', val)"
            >
              <template v-if="reviewerOptions.length === 0" v-slot:no-option>
                <q-item>
                  <q-item-section class="text-grey">
                    No colleagues available
                  </q-item-section>
                </q-item>
              </template>
            </q-select>
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Submit" @click="submitForReview" :loading="submitting" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Review Task Dialog -->
    <q-dialog v-model="showReviewDialog">
      <q-card style="min-width: 500px">
        <q-card-section>
          <div class="text-h6">Review Task</div>
        </q-card-section>
        <q-card-section>
          <div v-if="selectedReview">
            <div class="q-mb-md">
              <div class="text-subtitle2">{{ selectedReview.title }}</div>
              <div class="text-caption text-grey-7">
                Owner: {{ selectedReview.task_owner_first_name }}
                {{ selectedReview.task_owner_last_name }}
              </div>
              <div class="text-caption text-grey-7">
                {{ getProjectName(selectedReview.project_id) }}
              </div>
              <div class="text-caption text-grey-7 q-mt-sm">
                Expected Effort: {{ selectedReview.expected_effort }}h
              </div>
              <div class="text-caption text-grey-7" v-if="selectedReview.employee_comment">
                Owner Comment: "{{ selectedReview.employee_comment }}"
              </div>
            </div>
            <q-input
              v-model="reviewComment"
              label="Review Comment"
              type="textarea"
              outlined
              rows="3"
            />
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn
            color="orange"
            label="Request Changes"
            @click="requestChanges"
            :loading="reviewing"
          />
          <q-btn color="green" label="Mark Done" @click="approveReview" :loading="reviewing" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Deadline Clash Dialog -->
    <q-dialog v-model="showClashDialog">
      <q-card style="min-width: 600px">
        <q-card-section>
          <div class="text-h6 text-negative">
            <q-icon name="warning" class="q-mr-sm" />
            Task Clash Detected
          </div>
        </q-card-section>
        <q-card-section>
          <div v-if="detectedConflicts.length > 0">
            <div v-for="(conflict, index) in detectedConflicts" :key="index" class="q-mb-md">
              <div class="text-subtitle2 q-mb-sm">
                {{ conflict.deadline }} ({{ conflict.count }} tasks)
              </div>
              <q-list bordered separator>
                <q-item v-for="task in conflict.tasks" :key="task.id">
                  <q-item-section avatar>
                    <q-badge :color="getPriorityColor(task.priority)" :label="task.priority" />
                  </q-item-section>
                  <q-item-section>
                    <q-item-label>{{ task.title }}</q-item-label>
                    <q-item-label caption>{{ task.project_name }}</q-item-label>
                  </q-item-section>
                </q-item>
              </q-list>
            </div>
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Automate" @click="resolveClashes" :loading="automating" />
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
          <div v-if="selectedTask">
            <div class="q-mb-md">
              <div class="text-subtitle2">{{ selectedTask.title }}</div>
              <div class="text-caption text-grey-7">
                Current deadline: {{ formatDate(selectedTask.deadline) }}
              </div>
            </div>
            <q-input
              v-model="newDeadline"
              type="date"
              label="New Deadline"
              outlined
              :min="new Date().toISOString().split('T')[0]"
            />
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Set Deadline" @click="setDeadline" :loading="updating" />
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
                <q-badge :color="getPriorityColor(task.priority)" :label="task.priority" />
              </q-item-section>
              <q-item-section>
                <q-item-label class="text-weight-bold">{{ task.title }}</q-item-label>
                <q-item-label caption>{{ getProjectName(task.project_id) }}</q-item-label>
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
            <div class="q-mb-md">
              <div class="text-subtitle2">{{ selectedOverdueTask.title }}</div>
              <div class="text-caption text-grey-7">
                {{ getProjectName(selectedOverdueTask.project_id) }}
              </div>
              <div class="text-caption text-red q-mt-sm">
                Overdue: {{ formatDate(selectedOverdueTask.deadline) }}
              </div>
              <div class="text-caption text-grey-7 q-mt-xs">
                Priority: {{ selectedOverdueTask.priority }}
              </div>
            </div>
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="orange" label="Set Deadline" @click="openSetDeadlineDialog(selectedOverdueTask)" />
          <q-btn color="primary" label="Automate" @click="automateOverdueTask" :loading="automating" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useQuasar } from 'quasar';
import { useAuthStore } from '../../stores/authStore';
import StatCard from '../../components/StatCard.vue';

defineOptions({
  name: 'EmployeeDashboard',
});

const router = useRouter();
const $q = useQuasar();
const authStore = useAuthStore();

const activeTab = ref('tasks');
const loading = ref(false);
const myTasks = ref<any[]>([]);
const projects = ref<any[]>([]);
const employees = ref<any[]>([]);
const pendingReviews = ref<any[]>([]);
const reviewHistory = ref<any[]>([]);
const stats = ref({
  totalTasks: 0,
  completedTasks: 0,
  inProgressTasks: 0,
  points: 0,
});

const showUpdateDialog = ref(false);
const showSubmitReviewDialog = ref(false);
const showReviewDialog = ref(false);
const showSetDeadlineDialog = ref(false);
const selectedTask = ref<any>(null);
const selectedReview = ref<any>(null);
const progressUpdate = ref(0);
const statusUpdate = ref('in-progress');
const hoursSpent = ref(0);
const completionComment = ref('');
const reviewComment = ref('');
const selectedReviewer = ref<number | null>(null);
const newDeadline = ref('');
const updating = ref(false);
const submitting = ref(false);
const reviewing = ref(false);

// Deadline conflict handling
const showClashDialog = ref(false);
const detectedConflicts = ref<any[]>([]);
const automating = ref(false);

// Overdue tasks handling
const showOverdueDialog = ref(false);
const showOverdueTaskDialog = ref(false);
const selectedOverdueTask = ref<any>(null);

const overdueTasks = computed(() => {
  const overdue = myTasks.value.filter((task: any) => task.status !== 'completed' && isOverdue(task.deadline));
  console.log('=== OVERDUE TASKS COMPUTED ===');
  console.log('Total tasks:', myTasks.value.length);
  console.log('Overdue count:', overdue.length);
  console.log('Overdue tasks:', overdue);
  return overdue;
});

const statusOptions = ['not-started', 'in-progress', 'completed', 'blocked'];

const completedTasks = computed(() => {
  return myTasks.value.filter(
    (task) =>
      task.status === 'completed' ||
      task.status === 'in-review' ||
      (task.status === 'in-progress' && task.progress === 100)
  );
});

const reviewerOptions = computed(() => {
  console.log('=== DASHBOARD REVIEWER OPTIONS ===');
  console.log('Employees array:', employees.value);
  console.log('Employees length:', employees.value?.length);
  console.log('Current user:', authStore.user);

  if (!employees.value || employees.value.length === 0) {
    console.log('❌ Dashboard: No employees loaded');
    return [];
  }

  const currentId = Number(authStore.user?.id);
  console.log('Current ID as number:', currentId);

  const filtered = employees.value.filter((e: any) => {
    const empId = Number(e.id);
    const shouldInclude = empId !== currentId;
    console.log(`  Employee ${e.id} (${e.first_name} ${e.last_name}): ID=${empId}, Current=${currentId}, Include=${shouldInclude}`);
    return shouldInclude;
  });

  console.log('Filtered employees count:', filtered.length);

  const options = filtered.map((e: any) => ({
    label: `${e.first_name} ${e.last_name} — ${e.email}`,
    value: e.id,
    id: e.id
  }));

  console.log('✅ Dashboard reviewer options:', options);
  console.log('=== END DASHBOARD REVIEWER OPTIONS ===');
  return options;
});

onMounted(async () => {
  await fetchFromDatabase();
});

async function fetchFromDatabase() {
  console.log('=== FETCH FROM DATABASE CALLED ===');
  console.log('Current user:', authStore.user);

  if (!authStore.user?.id) return;

  loading.value = true;
  try {
    // Fetch tasks directly from database
    const tasksResponse = await fetch(
      `http://localhost:3007/api/tasks/employee/${authStore.user.id}`,
    );
    const tasksData = await tasksResponse.json();
    if (tasksData.success) {
      myTasks.value = tasksData.tasks;
      console.log('✅ Tasks loaded:', myTasks.value.length);
      // Detect deadline clashes after tasks are loaded
      await detectDeadlineClashes();
    }

    // Fetch projects directly from database
    const projectsResponse = await fetch('http://localhost:3007/api/pm/projects');
    const projectsData = await projectsResponse.json();
    if (projectsData.success) {
      projects.value = projectsData.projects;
      console.log('✅ Projects loaded:', projects.value.length);
    }

    // Fetch employees directly from database
    const employeesResponse = await fetch('http://localhost:3007/api/users');
    const employeesData = await employeesResponse.json();
    console.log('Employees API response:', employeesData);
    if (employeesData.success) {
      employees.value = employeesData.users;
      console.log('✅ Employees loaded:', employees.value.length);
      console.log('Employees array:', employees.value);
    } else {
      console.log('❌ Employees fetch failed:', employeesData);
    }

    // Fetch pending reviews
    const pendingResponse = await fetch(
      `http://localhost:3007/api/employee/reviews/pending?user_id=${authStore.user.id}`,
    );
    const pendingData = await pendingResponse.json();
    if (pendingData.success) {
      pendingReviews.value = pendingData.reviews;
    }

    // Fetch review history
    const historyResponse = await fetch(
      `http://localhost:3007/api/employee/reviews/history?user_id=${authStore.user.id}`,
    );
    const historyData = await historyResponse.json();
    if (historyData.success) {
      reviewHistory.value = historyData.reviews;
    }

    // Calculate stats
    calculateStats();
  } catch (error) {
    console.error('❌ Error fetching data:', error);
  } finally {
    loading.value = false;
  }
}

function calculateStats() {
  stats.value.totalTasks = myTasks.value.length;
  stats.value.completedTasks = myTasks.value.filter((t: any) => t.status === 'completed').length;
  stats.value.inProgressTasks = myTasks.value.filter((t: any) => t.status === 'in-progress').length;
  stats.value.points = reviewHistory.value.reduce(
    (acc: number, r: any) => acc + (r.task_owner_points || 0) + (r.reviewer_points || 0),
    0,
  );
}

function getProjectName(projectId: number) {
  const project = projects.value.find((p: any) => p.id === projectId);
  return project?.name || 'Unknown Project';
}

function getPriorityColor(priority: string) {
  const colors: Record<string, string> = {
    critical: 'red',
    high: 'orange',
    medium: 'blue',
    low: 'green',
  };
  return colors[priority] || 'grey';
}

function getStatusColor(status: string) {
  const colors: Record<string, string> = {
    'not-started': 'grey',
    'in-progress': 'blue',
    completed: 'green',
    'in-review': 'purple',
    blocked: 'red',
  };
  return colors[status] || 'grey';
}

function formatDate(date: string) {
  if (!date) return 'No deadline';
  const d = new Date(date);
  if (isNaN(d.getTime())) return 'Invalid Date';
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}

function isOverdue(deadline: string) {
  if (!deadline) return false;
  const d = new Date(deadline);
  if (isNaN(d.getTime())) return false;
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return d < today;
}

function openUpdateDialog(task: any) {
  selectedTask.value = task;
  progressUpdate.value = task.progress;
  statusUpdate.value = task.status;
  hoursSpent.value = 0;
  showUpdateDialog.value = true;
}

function openSetDeadlineDialog(task: any) {
  console.log('openSetDeadlineDialog called with task:', task);
  selectedTask.value = task;
  newDeadline.value = task.deadline ? task.deadline.split('T')[0] : '';
  showSetDeadlineDialog.value = true;
  console.log('Dialog should now show:', showSetDeadlineDialog.value);
}

async function setDeadline() {
  if (!selectedTask.value || !newDeadline.value) return;

  updating.value = true;
  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (authStore.token && authStore.token !== 'undefined' && authStore.token !== 'null') {
      headers['Authorization'] = `Bearer ${authStore.token}`;
    }

    const response = await fetch(
      `http://localhost:3007/api/employee/tasks/${selectedTask.value.id}`,
      {
        method: 'PUT',
        headers,
        body: JSON.stringify({
          deadline: newDeadline.value,
        }),
      },
    );

    const data = await response.json();
    if (data.success) {
      showSetDeadlineDialog.value = false;
      showOverdueTaskDialog.value = false;
      await fetchFromDatabase();
      // Check for clashes after setting deadline
      await detectDeadlineClashes();
    }
  } catch (error) {
    console.error('Error setting deadline:', error);
  } finally {
    updating.value = false;
  }
}

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

async function automateOverdueTask() {
  if (!selectedOverdueTask.value) return;

  automating.value = true;
  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (authStore.token && authStore.token !== 'undefined' && authStore.token !== 'null') {
      headers['Authorization'] = `Bearer ${authStore.token}`;
    }

    const response = await fetch(
      `http://localhost:3007/api/employee/${authStore.user?.id}/automate-schedule`,
      {
        method: 'POST',
        headers,
        body: JSON.stringify({ mode: 'clashes' }),
      },
    );

    const data = await response.json();
    if (data.success) {
      showOverdueTaskDialog.value = false;
      showOverdueDialog.value = false;
      await fetchFromDatabase();
      $q.notify({
        type: 'positive',
        message: `Rescheduled ${data.updatedTasks.length} tasks`,
        position: 'top',
      });
    }
  } catch (error) {
    console.error('Error automating schedule:', error);
  } finally {
    automating.value = false;
  }
}

async function updateTaskProgress() {
  if (!selectedTask.value) return;

  updating.value = true;
  try {
    let finalProgress = progressUpdate.value;
    if (statusUpdate.value === 'completed') {
      finalProgress = 100;
    }

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (authStore.token && authStore.token !== 'undefined' && authStore.token !== 'null') {
      headers['Authorization'] = `Bearer ${authStore.token}`;
    }

    const response = await fetch(
      `http://localhost:3007/api/employee/tasks/${selectedTask.value.id}`,
      {
        method: 'PUT',
        headers,
        body: JSON.stringify({
          progress: finalProgress,
          status: statusUpdate.value,
          hours_spent: hoursSpent.value,
        }),
      },
    );

    const data = await response.json();
    if (data.success) {
      showUpdateDialog.value = false;
      await fetchFromDatabase();
    }
  } catch (error) {
    console.error('Error updating task:', error);
  } finally {
    updating.value = false;
  }
}

function openSubmitReviewDialog(task: any) {
  selectedTask.value = task;
  completionComment.value = '';
  selectedReviewer.value = null;
  showSubmitReviewDialog.value = true;
}

async function submitForReview() {
  console.log('=== SUBMIT FOR REVIEW CALLED ===');
  console.log('selectedTask.value:', selectedTask.value);
  console.log('selectedReviewer.value:', selectedReviewer.value);
  console.log('reviewerOptions:', reviewerOptions.value);

  if (!selectedTask.value) {
    console.log('❌ No task selected');
    return;
  }

  submitting.value = true;
  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (authStore.token && authStore.token !== 'undefined' && authStore.token !== 'null') {
      headers['Authorization'] = `Bearer ${authStore.token}`;
    }

    const requestBody: any = {
      completion_comment: completionComment.value,
      task_owner_id: authStore.user?.id,
    };

    // Only include reviewer_id if a reviewer is selected
    if (selectedReviewer.value !== null && selectedReviewer.value !== undefined) {
      requestBody.reviewer_id = selectedReviewer.value;
    }

    const response = await fetch(
      `http://localhost:3007/api/employee/tasks/${selectedTask.value.id}/submit-review`,
      {
        method: 'POST',
        headers,
        body: JSON.stringify(requestBody),
      },
    );

    const data = await response.json();
    console.log('Submit review response:', data);
    if (data.success) {
      showSubmitReviewDialog.value = false;
      await fetchFromDatabase();
      console.log('✅ Review submitted successfully');
    } else {
      console.log('❌ Submit review failed:', data);
    }
  } catch (error) {
    console.error('❌ Error submitting for review:', error);
  } finally {
    submitting.value = false;
  }
}

function openReviewDialog(review: any) {
  selectedReview.value = review;
  reviewComment.value = '';
  showReviewDialog.value = true;
}

async function approveReview() {
  if (!selectedReview.value) return;

  reviewing.value = true;
  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (authStore.token && authStore.token !== 'undefined' && authStore.token !== 'null') {
      headers['Authorization'] = `Bearer ${authStore.token}`;
    }

    const response = await fetch(
      `http://localhost:3007/api/employee/tasks/${selectedReview.value.task_id}/approve-review`,
      {
        method: 'POST',
        headers,
        body: JSON.stringify({ review_comment: reviewComment.value }),
      },
    );

    const data = await response.json();
    if (data.success) {
      showReviewDialog.value = false;
      await fetchFromDatabase();
    }
  } catch (error) {
    console.error('Error approving review:', error);
  } finally {
    reviewing.value = false;
  }
}

async function requestChanges() {
  if (!selectedReview.value) return;

  reviewing.value = true;
  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (authStore.token && authStore.token !== 'undefined' && authStore.token !== 'null') {
      headers['Authorization'] = `Bearer ${authStore.token}`;
    }

    const response = await fetch(
      `http://localhost:3007/api/employee/tasks/${selectedReview.value.task_id}/request-changes`,
      {
        method: 'POST',
        headers,
        body: JSON.stringify({ review_comment: reviewComment.value }),
      },
    );

    const data = await response.json();
    if (data.success) {
      showReviewDialog.value = false;
      await fetchFromDatabase();
    }
  } catch (error) {
    console.error('Error requesting changes:', error);
  } finally {
    reviewing.value = false;
  }
}

// ============================================================
// DEADLINE CONFLICT HANDLING
// ============================================================

async function detectDeadlineClashes() {
  if (!authStore.user?.id) return;

  try {
    const response = await fetch(
      `http://localhost:3007/api/employee/${authStore.user.id}/deadline-clashes`
    );
    const data = await response.json();
    if (data.success && data.conflicts.length > 0) {
      detectedConflicts.value = data.conflicts;
      showClashDialog.value = true;
    }
  } catch (error) {
    console.error('Error detecting clashes:', error);
  }
}

async function automateFullSchedule() {
  if (!authStore.user?.id) return;

  automating.value = true;
  try {
    const response = await fetch(
      `http://localhost:3007/api/employee/${authStore.user.id}/automate-schedule`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ mode: 'full' }),
      }
    );
    const data = await response.json();
    if (data.success) {
      await fetchFromDatabase();
      // Show notification
      alert(`Schedule automated! ${data.updatedTasks.length} tasks rescheduled.`);
    }
  } catch (error) {
    console.error('Error automating schedule:', error);
    alert('Failed to automate schedule');
  } finally {
    automating.value = false;
  }
}

async function resolveClashes() {
  await automateFullSchedule();
  showClashDialog.value = false;
}

function logout() {
  authStore.logout();
  router.replace('/auth/login');
}
</script>
