<template>
  <q-page class="planner-page q-pa-md">
    <!-- =========================================================
         HEADER
    ========================================================= -->

    <!-- =========================================================
         CALENDAR VIEW
    ========================================================= -->

    <div class="calendar-container q-mt-xl">
      <q-card flat bordered class="calendar-card">
        <!-- HEADER -->
        <CalendarToolbar
          :month-name="monthName"
          :current-year="currentYear"
          @previous="previousMonth"
          @today="goCalendarToday"
          @next="nextMonth"
        />

        <!-- MONTH STATS -->
        <div class="compact-stats row items-center justify-between q-px-md q-py-sm">
          <div class="row items-center q-gutter-lg">
            <div class="compact-stat">
              <div class="stat-icon worked-stat">
                <q-icon name="check" size="15px" />
              </div>
              <div>
                <div class="stat-value">
                  {{ monthlyWorkedDays }}
                </div>
                <div class="stat-label">Worked</div>
              </div>
            </div>

            <div class="compact-stat">
              <div class="stat-icon activity-stat">
                <q-icon name="task_alt" size="15px" />
              </div>
              <div>
                <div class="stat-value">
                  {{ monthlyTaskCount }}
                </div>
                <div class="stat-label">Tasks</div>
              </div>
            </div>

            <div class="compact-stat">
              <div class="stat-icon hours-stat">
                <q-icon name="schedule" size="15px" />
              </div>
              <div>
                <div class="stat-value">{{ monthlyHours }}h</div>
                <div class="stat-label">Logged</div>
              </div>
            </div>
          </div>

          <!-- STREAK ON RIGHT -->
          <StreakCard :streak="streak" />
        </div>

        <!-- WEEK DAYS -->
        <div class="calendar-grid calendar-week-header q-px-md">
          <div
            v-for="day in weekDays"
            :key="day"
            class="calendar-weekday"
            :class="{
              'weekend-heading': day === 'SAT' || day === 'SUN',
            }"
          >
            {{ day }}
          </div>
        </div>

        <!-- CALENDAR -->

        <div class="calendar-grid calendar-body q-pa-md">
          <div
            v-for="day in calendarDays"
            :key="day.key"
            class="calendar-cell"
            :class="{
              'calendar-empty': !day.date,

              'weekend-cell': day.isWeekend && day.status === 'weekend',

              'worked-cell': day.status === 'worked',

              'leave-cell': day.status === 'leave',

              'holiday-cell': day.status === 'holiday',

              'today-cell': day.isToday,

              'selected-cell': selectedDate === day.date,
            }"
            @click="day.date ? selectCalendarDay(day) : null"
          >
            <template v-if="day.date">
              <div class="row items-center justify-between">
                <div
                  class="calendar-day-number"
                  :class="{
                    'today-number': day.isToday,
                  }"
                >
                  {{ day.dayNumber }}
                </div>

                <div v-if="day.isToday" class="today-pill">TODAY</div>
              </div>

              <!-- STATUS -->

              <div class="calendar-status" :class="statusClass(day.status)">
                <q-icon :name="statusIcon(day.status)" size="11px" />

                {{ statusLabel(day.status) }}
              </div>

              <!-- LEAVE IMPACT INDICATOR -->

              <div
                v-if="isDayAffectedByLeave(day.date)"
                class="calendar-leave-impact cursor-pointer"
                @click.stop="openLeaveImpactDialog(day.date)"
              >
                <q-icon name="warning" size="11px" color="red" />
                <span class="text-negative" style="font-size: 10px;">Leave Impact</span>
                <q-linear-progress
                  :value="1"
                  color="red"
                  size="2px"
                  class="q-mt-xs"
                />
              </div>

              <!-- MISSED WORK INDICATOR -->

              <div v-if="isDayMissedWork(day.date)" class="calendar-missed-work">
                <q-icon name="warning" size="11px" color="red" />
                <span class="text-negative" style="font-size: 10px;">Hurry up — Missed work</span>
                <q-linear-progress
                  :value="1"
                  color="red"
                  size="2px"
                  class="q-mt-xs"
                />
              </div>

              <!-- LOG COUNT -->

              <div v-if="day.workLogs.length" class="calendar-work-summary">
                <q-icon name="task_alt" size="12px" />

                {{ day.workLogs.length }}

                {{ day.workLogs.length === 1 ? 'task' : 'tasks' }}

                <span> · {{ totalHours(day.workLogs) }}h </span>
              </div>

              <!-- ACTIVITY -->

              <div v-if="day.workLogs.length" class="activity-dots">
                <span v-for="index in Math.min(day.workLogs.length, 4)" :key="index" />
              </div>
            </template>
          </div>
        </div>
      </q-card>

      <!-- =======================================================
           SELECTED DAY
      ======================================================== -->

      <div class="row q-col-gutter-md q-mt-md">
        <!-- STATUS -->

        <div class="col-12 col-md-5">
          <q-card flat bordered class="compact-info-card">
            <div class="q-pa-md">
              <div class="row items-center justify-between">
                <div>
                  <div class="section-kicker">SELECTED DAY</div>

                  <div class="selected-date">
                    {{ selectedDateFormatted }}
                  </div>
                </div>
              </div>

              <!-- STATUS OPTIONS -->

              <div class="compact-status-grid q-mt-md">
                <div
                  v-for="option in dayStatusOptions"
                  :key="option.value"
                  class="compact-status-option"
                  :class="{
                    'compact-status-active': selectedDayStatus === option.value,
                  }"
                  @click="selectDayStatus(option.value)"
                >
                  <q-icon :name="option.icon" size="16px" />

                  <span>
                    {{ option.label }}
                  </span>
                </div>
              </div>

              <div
                v-if="selectedDayCompliance?.status === 'submitted'"
                class="text-positive text-weight-bold flex items-center justify-center q-gutter-x-sm q-mt-md"
              >
                <q-icon name="check_circle" size="sm" /> <span>Submitted for Review</span>
              </div>
              <div
                v-else-if="selectedDayCompliance?.status === 'reviewed'"
                class="text-primary text-weight-bold flex items-center justify-center q-mt-md"
              >
                <div class="flex items-center q-gutter-x-sm">
                  <q-icon name="verified" size="sm" /> <span>Reviewed by PM</span>
                </div>
              </div>
              <q-btn
                v-else
                unelevated
                dense
                no-caps
                color="primary"
                class="full-width q-mt-md"
                label="Save Day Status"
                @click="submitDayToPM"
              />
            </div>
          </q-card>
        </div>

        <!-- ACTIVITY -->

        <div class="col-12 col-md-7">
          <q-card flat bordered class="compact-info-card">
            <div class="q-pa-md">
              <div class="row items-center justify-between">
                <div>
                  <div class="section-kicker">WORK ACTIVITY</div>

                  <div class="selected-date">
                    {{ selectedDayActivity.length }}
                    {{ selectedDayActivity.length === 1 ? 'task' : 'tasks' }}
                    logged
                  </div>
                </div>

                <div class="row items-center q-gutter-x-sm">
                  <div v-if="selectedDayActivity.length" class="text-caption text-grey-6">
                    {{ totalHours(selectedDayActivity) }}h total
                  </div>
                  <q-btn
                    unelevated
                    dense
                    no-caps
                    color="primary"
                    icon="add"
                    label="Add Log"
                    @click="openCreateLogDialog"
                    class="q-px-sm"
                  />
                </div>
              </div>

              <div v-if="selectedDayActivity.length" class="compact-activity-list q-mt-sm">
                <div v-for="log in selectedDayActivity" :key="log.id" class="compact-activity-row">
                  <div class="activity-task-icon">
                    <q-icon
                      :name="log.taskTitle === 'Manual Entry' ? 'edit_note' : 'task_alt'"
                      size="15px"
                    />
                  </div>

                  <div class="col">
                    <div class="compact-task-name">
                      {{ log.taskTitle || 'Manual Entry' }}
                      <q-icon v-if="isTaskAffectedByLeave(log, selectedDate)" name="warning" color="red" size="14px" class="q-ml-xs" />
                    </div>

                    <div v-if="log.project" class="text-caption text-grey-6">
                      {{ log.project }}
                    </div>

                    <div v-if="log.note" class="text-caption text-grey-5 q-mt-xs log-note-text">
                      {{ log.note }}
                    </div>
                  </div>

                  <div v-if="log.progress > 0" class="compact-progress">
                    <div class="text-caption">{{ log.progress }}%</div>

                    <q-linear-progress
                      :value="log.progress / 100"
                      rounded
                      :color="isTaskAffectedByLeave(log, selectedDate) ? 'red' : 'primary'"
                      size="4px"
                    />
                  </div>
                </div>
              </div>

              <div v-else class="compact-empty">
                <q-icon name="event_note" size="25px" />

                <span> No work logged for this day </span>
                <q-btn
                  unelevated
                  no-caps
                  color="primary"
                  icon="add"
                  label="Add Work Entry"
                  class="q-mt-md"
                  @click="openCreateLogDialog"
                />
              </div>

              <!-- Submit to PM moved to Save Day Status above -->
            </div>
          </q-card>
        </div>
      </div>
    </div>

    <!-- =========================================================
         CREATE WORK LOG DIALOG
    ========================================================= -->

    <q-dialog v-model="showCreateLogDialog">
      <q-card style="min-width: 400px; max-width: 600px">
        <q-card-section>
          <div class="text-h6">Add Work Entry for {{ selectedDateFormatted }}</div>
        </q-card-section>
        <q-card-section class="q-pt-none">
          <q-form @submit="submitWorkLog">
            <q-input
              v-model="newLog.workCompleted"
              label="Work Note"
              outlined
              type="textarea"
              rows="4"
              class="q-mb-md"
              :rules="[(val) => !!val || 'Please add a note']"
            />
          </q-form>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Submit" @click="submitWorkLog" :loading="isSubmittingLog" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- =========================================================
         SAVED DIALOG
    ========================================================= -->

    <q-dialog v-model="showSavedDialog">
      <q-card style="min-width: 300px">
        <q-card-section class="text-center">
          <q-icon name="check_circle" color="positive" size="45px" />

          <div class="text-h6 text-weight-bold q-mt-sm">Updates Saved</div>

          <div class="text-caption text-grey-6 q-mt-xs">Your work log has been updated.</div>
        </q-card-section>

        <q-card-actions align="center">
          <q-btn flat no-caps color="primary" label="Done" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- =========================================================
         DEADLINE ON LEAVE DIALOG
    ========================================================= -->

    <q-dialog v-model="showDeadlineOnLeaveDialog">
      <q-card style="min-width: 450px">
        <q-card-section>
          <div class="text-h6 text-weight-bold text-negative">
            <q-icon name="warning" class="q-mr-sm" />
            Task deadline falls on your leave
          </div>
        </q-card-section>
        <q-card-section v-if="selectedAffectedTask">
          <div class="q-mb-md">
            <div class="text-subtitle2">{{ selectedAffectedTask.title }}</div>
            <div class="text-caption text-grey-7">
              Deadline: {{ formatDate(parseDate(selectedAffectedTask.deadline)) }}
            </div>
            <div class="text-caption text-negative q-mt-xs">
              Leave period: {{ selectedAffectedTask.leave_start }} to {{ selectedAffectedTask.leave_end }}
            </div>
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn
            color="primary"
            label="Set Deadline"
            @click="openSetDeadlineDialog"
          />
          <q-btn
            color="secondary"
            label="Automate It"
            @click="automateDeadline"
            :loading="automatingDeadline"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- =========================================================
         LEAVE IMPACT DIALOG
    ========================================================= -->

    <q-dialog v-model="showLeaveImpactDialog">
      <q-card style="min-width: 500px; max-width: 600px">
        <q-card-section>
          <div class="text-h6 text-weight-bold text-negative">
            <q-icon name="warning" class="q-mr-sm" />
            Leave Impact
          </div>
          <div class="text-caption text-grey-7 q-mt-sm">
            Leave date: {{ formatDate(parseDate(selectedLeaveDate)) }}
          </div>
        </q-card-section>

        <q-card-section v-if="affectedTasks.length > 0">
          <div class="text-subtitle2 q-mb-md">Affected task(s)</div>
          <q-list separator>
            <q-item v-for="task in affectedTasks" :key="task.id">
              <q-item-section avatar>
                <q-icon :name="task.deadline_on_leave ? 'warning' : 'info'" :color="task.deadline_on_leave ? 'red' : 'primary'" />
              </q-item-section>
              <q-item-section>
                <q-item-label>{{ task.title }}</q-item-label>
                <q-item-label caption>
                  Deadline: {{ formatDate(parseDate(task.deadline)) }}
                </q-item-label>
                <q-item-label caption>
                  Progress: {{ task.progress }}% · Status: {{ task.status }}
                </q-item-label>
                <q-item-label v-if="task.deadline_on_leave" caption class="text-negative">
                  ⚠️ Task deadline falls on your leave
                </q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
        </q-card-section>

        <q-card-section v-else>
          <div class="text-caption text-grey-6">No affected tasks found.</div>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Close" v-close-popup />
          <q-btn
            v-if="affectedTasks.some(t => t.deadline_on_leave)"
            color="primary"
            label="Set Deadline"
            @click="handleDeadlineOnLeaveTask"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- =========================================================
         SET DEADLINE DIALOG
    ========================================================= -->

    <q-dialog v-model="showSetDeadlineDialog">
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6">Set New Deadline</div>
        </q-card-section>
        <q-card-section>
          <q-date v-model="newDeadline" mask="YYYY-MM-DD" />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Save" @click="saveNewDeadline" :loading="automatingDeadline" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup lang="ts">
import { computed, ref, watch, onMounted } from 'vue';
import StreakCard from '@/components/StreakCard.vue';
import CalendarToolbar from '@/components/CalendarToolbar.vue';
import { useAuthStore } from '@/stores/authStore';

/* ============================================================
   TYPES
============================================================ */

type DayStatus = 'worked' | 'leave' | 'holiday' | 'weekend' | 'no-entry';

type TaskStatus = 'Pending' | 'In Progress' | 'Completed' | 'Blocked';

interface Subtask {
  id: number;
  title: string;
  completed: boolean;
}

interface WorkLog {
  id: number;
  taskTitle: string;
  title?: string;
  project: string;
  progress: number;
  hours: number;
  note: string;
  status?: TaskStatus;
  priority?: string;
}

interface Task {
  id: number;
  title: string;
  project: string;
  priority: string;
  status: TaskStatus;
  progress: number;
  note: string;
  subtasks: Subtask[];
}

interface CalendarDay {
  key: string;
  date: string;
  dayNumber: number;
  isWeekend: boolean;
  isToday: boolean;
  status: DayStatus;
  workLogs: WorkLog[];
}

/* ============================================================
   CONSTANTS
============================================================ */

const weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

const monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const dayStatusOptions: Array<{ label: string; value: DayStatus; icon: string }> = [
  {
    label: 'Worked',
    value: 'worked',
    icon: 'check_circle',
  },
  {
    label: 'Leave',
    value: 'leave',
    icon: 'event_busy',
  },
];

/* ============================================================
   TODAY
============================================================ */

const today = new Date();

const todayString = formatDate(today);

/* ============================================================
   CALENDAR MONTH
============================================================ */

const calendarMonth = ref(today.getMonth());

const calendarYear = ref(today.getFullYear());

/* ============================================================
   SELECTED DATE
============================================================ */

const selectedDate = ref(todayString);

const selectedDayStatus = ref<DayStatus>('worked');

/* ============================================================
   STREAK
============================================================ */

const streak = ref(5);

/* ============================================================
   WORK LOG STORAGE
============================================================ */

/*
  This object acts as your temporary frontend database.

  Later this can be replaced by:
  Pinia store
  +
  Node.js API
  +
  MySQL
*/

const workLogs = ref<Record<string, WorkLog[]>>({});

/* ============================================================
   DAY STATUS STORAGE
============================================================ */

const dayStatuses = ref<Record<string, DayStatus>>({});

/* ============================================================
   LEAVE DATA
============================================================ */

const leaves = ref<any[]>([]);
const affectedTasks = ref<any[]>([]);
const dayComplianceStatuses = ref<Record<string, any>>({});

/* ============================================================
   DEADLINE ON LEAVE DIALOG
============================================================ */

const showDeadlineOnLeaveDialog = ref(false);
const showLeaveImpactDialog = ref(false);
const selectedAffectedTask = ref<any>(null);
const newDeadline = ref('');
const automatingDeadline = ref(false);
const selectedLeaveDate = ref('');

/* ============================================================
   TASKS
============================================================ */

const tasks = ref<Task[]>([]);

const authStore = useAuthStore();

// Fetch tasks from database
const fetchTasks = async () => {
  if (!authStore.user?.id) {
    // Fallback to mock data if no user
    tasks.value = [
      {
        id: 1,
        title: 'Vehicle booking API',
        project: 'wheelO',
        priority: 'High',
        status: 'In Progress',
        progress: 70,
        note: '',
        subtasks: [],
      },
      {
        id: 2,
        title: 'Dashboard UI',
        project: 'wheelO',
        priority: 'Medium',
        status: 'In Progress',
        progress: 45,
        note: '',
        subtasks: [],
      },
    ];
    return;
  }

  try {
    const response = await fetch(`http://localhost:3007/api/tasks/employee/${authStore.user?.id}`, {
      headers: { Authorization: `Bearer ${authStore.token}` },
    });
    const result = await response.json();

    if (result.success && result.tasks) {
      // Fetch subtasks for each task
      const tasksWithSubtasks = await Promise.all(
        result.tasks.map(async (task: any) => {
          const subtaskResponse = await fetch(
            `http://localhost:3007/api/employee/tasks/${task.id}/subtasks`,
            {
              headers: { Authorization: `Bearer ${authStore.token}` },
            },
          );
          const subtaskResult = await subtaskResponse.json();
          const subtasks = subtaskResult.success ? subtaskResult.subtasks : [];

          return {
            id: task.id,
            title: task.title,
            project: task.project_name || 'Unknown',
            priority: task.priority || 'Medium',
            status: task.status || 'Pending',
            progress: parseFloat(task.progress) || 0,
            note: task.description || '',
            subtasks: subtasks,
          };
        }),
      );

      tasks.value = tasksWithSubtasks;
    } else {
      // Fallback to mock data on error
      tasks.value = [
        {
          id: 1,
          title: 'Vehicle booking API',
          project: 'wheelO',
          priority: 'High',
          status: 'In Progress',
          progress: 70,
          note: '',
          subtasks: [],
        },
      ];
    }
  } catch (error) {
    console.error('Error fetching tasks:', error);
    // Fallback to mock data on error
    tasks.value = [
      {
        id: 1,
        title: 'Vehicle booking API',
        project: 'wheelO',
        priority: 'High',
        status: 'In Progress',
        progress: 70,
        note: '',
        subtasks: [],
      },
    ];
  }
};

// Fetch work logs from database
const fetchWorkLogs = async () => {
  if (!authStore.user?.id) {
    // Fallback to empty object if no user
    workLogs.value = {};
    return;
  }

  try {
    const response = await fetch(
      `http://localhost:3007/api/employee/work-logs/${authStore.user?.id}`,
      {
        headers: { Authorization: `Bearer ${authStore.token}` },
      },
    );
    const result = await response.json();

    if (result.success && result.logs) {
      // Group work logs by date
      const logsByDate: Record<string, WorkLog[]> = {};
      result.logs.forEach((log: any) => {
        let date = log.log_date;
        if (date) {
          const d = new Date(date);
          date =
            d.getFullYear() +
            '-' +
            String(d.getMonth() + 1).padStart(2, '0') +
            '-' +
            String(d.getDate()).padStart(2, '0');
        }

        if (!logsByDate[date]) {
          logsByDate[date] = [];
        }
        logsByDate[date]!.push({
          id: log.id,
          taskTitle:
            log.task_title || (log.task_id == 0 || !log.task_id ? 'Manual Entry' : 'Unknown Task'),
          project: log.project_name || log.project || '',
          progress: parseFloat(log.task_progress ?? log.progress) || 0,
          hours: parseFloat(log.hours_spent) || 0,
          note: log.work_completed || log.notes || '',
        });
      });
      workLogs.value = logsByDate;
    } else {
      // Fallback to empty object on error
      workLogs.value = {};
    }
  } catch (error) {
    console.error('Error fetching work logs:', error);
    // Fallback to empty object on error
    workLogs.value = {};
  }
};

// Fetch leaves from database
const fetchLeaves = async () => {
  if (!authStore.user?.id) {
    leaves.value = [];
    return;
  }

  try {
    const response = await fetch(
      `http://localhost:3007/api/leaves/employee/${authStore.user?.id}`,
      {
        headers: { Authorization: `Bearer ${authStore.token}` },
      },
    );
    const result = await response.json();

    if (result.success && result.leaves) {
      leaves.value = result.leaves;
    } else {
      leaves.value = [];
    }
  } catch (error) {
    console.error('Error fetching leaves:', error);
    leaves.value = [];
  }
};

// Fetch day compliance statuses (includes manually marked leave days)
const fetchDayComplianceStatuses = async () => {
  if (!authStore.user?.id) {
    dayComplianceStatuses.value = {};
    return;
  }

  try {
    // Get first and last day of current month
    const firstDay = new Date(calendarYear.value, calendarMonth.value, 1);
    const lastDay = new Date(calendarYear.value, calendarMonth.value + 1, 0);

    const response = await fetch(
      `http://localhost:3007/api/daily-logs/compliance/${authStore.user?.id}?start_date=${formatDate(firstDay)}&end_date=${formatDate(lastDay)}`,
      {
        headers: { Authorization: `Bearer ${authStore.token}` },
      },
    );

    // Note: This endpoint might not exist yet, so we'll handle gracefully
    // For now, we'll use the existing fetchDayCompliance for selected date only
  } catch (error) {
    console.error('Error fetching day compliance statuses:', error);
  }
};

// Fetch leave impact on tasks
const fetchLeaveImpact = async () => {
  if (!authStore.user?.id) {
    affectedTasks.value = [];
    return;
  }

  try {
    const response = await fetch(
      `http://localhost:3007/api/leaves/employee/${authStore.user?.id}/impact`,
      {
        headers: { Authorization: `Bearer ${authStore.token}` },
      },
    );
    const result = await response.json();

    if (result.success && result.affected_tasks) {
      affectedTasks.value = result.affected_tasks;

      // Check for deadline on leave and show dialog
      for (const task of result.affected_tasks) {
        if (task.deadline_on_leave) {
          selectedAffectedTask.value = task;
          showDeadlineOnLeaveDialog.value = true;
          break; // Show dialog for first affected task
        }
      }
    } else {
      affectedTasks.value = [];
    }
  } catch (error) {
    console.error('Error fetching leave impact:', error);
    affectedTasks.value = [];
  }
};

// Fetch day statuses from database
const fetchDayStatuses = async () => {
  if (!authStore.user?.id) {
    dayStatuses.value = {};
    return;
  }

  try {
    // Get first and last day of current month
    const firstDay = new Date(calendarYear.value, calendarMonth.value, 1);
    const lastDay = new Date(calendarYear.value, calendarMonth.value + 1, 0);

    const statuses: Record<string, DayStatus> = {};

    for (let day = 1; day <= lastDay.getDate(); day++) {
      const date = new Date(calendarYear.value, calendarMonth.value, day);
      const dateString = formatDate(date);

      try {
        const response = await fetch(
          `http://localhost:3007/api/daily-logs/${authStore.user?.id}/${dateString}`,
          {
            headers: { Authorization: `Bearer ${authStore.token}` },
          },
        );
        const result = await response.json();
        console.log(`Day ${dateString} compliance:`, result);
        if (result.success && result.compliance) {
          // Check both day_status and status fields
          const dayStatus = result.compliance.day_status || result.compliance.status;
          if (dayStatus) {
            statuses[dateString] = dayStatus as DayStatus;
          }
        }
      } catch (error) {
        console.error(`Error fetching day ${dateString}:`, error);
      }
    }

    console.log('Final day statuses:', statuses);
    dayStatuses.value = statuses;
  } catch (error) {
    console.error('Error fetching day statuses:', error);
  }
};

// Fetch data on mount
onMounted(() => {
  fetchTasks();
  fetchWorkLogs();
  fetchLeaves();
  fetchLeaveImpact();
  fetchDayStatuses();
});

// Watch for month changes to refetch day statuses
watch([calendarMonth, calendarYear], () => {
  fetchDayStatuses();
});

/* ============================================================
   CREATE LOG DIALOG
============================================================ */

const showCreateLogDialog = ref(false);
const isSubmittingLog = ref(false);

const newLog = ref({
  workCompleted: '',
});

function openCreateLogDialog() {
  newLog.value = {
    workCompleted: '',
  };
  showCreateLogDialog.value = true;
}

async function submitWorkLog() {
  if (!newLog.value.workCompleted || !authStore.user?.id) return;

  isSubmittingLog.value = true;
  try {
    const response = await fetch('http://localhost:3007/api/employee/work-log', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${authStore.token}`,
      },
      body: JSON.stringify({
        task_id: null,
        user_id: authStore.user.id,
        log_date: selectedDate.value,
        status: 'completed',
        work_completed: newLog.value.workCompleted,
        remaining_work: '',
        comments: '',
        hours_spent: 0,
      }),
    });

    const data = await response.json();
    if (data.success) {
      await fetchWorkLogs();
      showCreateLogDialog.value = false;
    }
  } catch (error) {
    console.error('Error submitting work log:', error);
  } finally {
    isSubmittingLog.value = false;
  }
}

/* ============================================================
   SAVE DIALOG
============================================================ */

const showSavedDialog = ref(false);

/* ============================================================
   MONTH NAME
============================================================ */

const monthName = computed(() => {
  return monthNames[calendarMonth.value] || 'January';
});

const currentYear = computed(() => {
  return calendarYear.value;
});

/* ============================================================
   LEAVE IMPACT HELPERS
============================================================ */

function isDayAffectedByLeave(dateString: string): boolean {
  if (!dateString) return false;

  // First check if manually marked as leave in dayStatuses
  if (dayStatuses.value[dateString] === 'leave') {
    return true;
  }

  // Check if this date falls within any approved leave period
  for (const leave of leaves.value) {
    const leaveStart = new Date(leave.start_date);
    const leaveEnd = new Date(leave.end_date);
    const checkDate = new Date(dateString);

    if (checkDate >= leaveStart && checkDate <= leaveEnd) {
      return true;
    }
  }

  return false;
}

function isDayMissedWork(dateString: string): boolean {
  if (!dateString) return false;

  const checkDate = new Date(dateString);
  const today = new Date();

  // Only show missed work for past dates
  if (checkDate >= today) return false;

  // Check if this date was during leave and has incomplete tasks
  if (isDayAffectedByLeave(dateString)) {
    // Check if there are tasks that were scheduled but not completed
    for (const task of affectedTasks.value) {
      const taskDeadline = new Date(task.deadline);
      const assignedDate = new Date(task.assigned_at);

      // If task was scheduled before leave and deadline after leave check date
      if (assignedDate <= checkDate && taskDeadline > checkDate) {
        // Check if task is still incomplete
        if (task.status !== 'completed' && task.progress < 100) {
          return true;
        }
      }
    }
  }

  return false;
}

function isTaskAffectedByLeave(log: any, dateString: string): boolean {
  if (!log || !dateString) return false;

  // Check if this day is affected by leave
  if (!isDayAffectedByLeave(dateString)) return false;

  // Check if this task's deadline falls on the leave date
  // First, find the task in affectedTasks
  for (const task of affectedTasks.value) {
    if (task.id === log.task_id || task.title === log.taskTitle) {
      const taskDeadline = new Date(task.deadline);
      const checkDate = new Date(dateString);
      return taskDeadline.toDateString() === checkDate.toDateString();
    }
  }

  return false;
}

/* ============================================================
   CALENDAR DAYS
============================================================ */

const calendarDays = computed<CalendarDay[]>(() => {
  const firstDay = new Date(calendarYear.value, calendarMonth.value, 1);

  const lastDay = new Date(calendarYear.value, calendarMonth.value + 1, 0);

  /*
      JS:
      Sunday = 0
      Monday = 1
  
      Convert to:
      Monday = 0
      Sunday = 6
    */

  const firstWeekDay = (firstDay.getDay() + 6) % 7;

  const days: CalendarDay[] = [];

  /* EMPTY CELLS */

  for (let i = 0; i < firstWeekDay; i++) {
    days.push({
      key: `empty-${i}`,
      date: '',
      dayNumber: 0,
      isWeekend: false,
      isToday: false,
      status: 'weekend',
      workLogs: [],
    });
  }

  /* ACTUAL DAYS */

  for (let day = 1; day <= lastDay.getDate(); day++) {
    const date = new Date(calendarYear.value, calendarMonth.value, day);

    const dateString = formatDate(date);

    const jsDay = date.getDay();

    const isWeekend = jsDay === 0 || jsDay === 6;

    const savedStatus = dayStatuses.value[dateString];

    const hasWorkLogs = workLogs.value[dateString] && workLogs.value[dateString].length > 0;

    // Check if this date is on leave from database
    const isOnLeave = isDayAffectedByLeave(dateString);

    let status: DayStatus;
    if (savedStatus) {
      status = savedStatus;
    } else if (isOnLeave) {
      status = 'leave';
    } else if (hasWorkLogs) {
      status = 'worked';
    } else if (isWeekend) {
      status = 'weekend';
    } else {
      status = 'no-entry';
    }

    days.push({
      key: dateString,

      date: dateString,

      dayNumber: day,

      isWeekend,

      isToday: dateString === todayString,

      status,

      workLogs: workLogs.value[dateString] ?? [],
    });
  }

  return days;
});

/* ============================================================
   SELECTED ACTIVITY & COMPLIANCE
============================================================ */

const selectedDayActivity = computed(() => {
  return workLogs.value[selectedDate.value] ?? [];
});

const selectedDayCompliance = ref<any>(null);

async function fetchDayCompliance(date: string) {
  if (!authStore.user?.id) return;
  try {
    const response = await fetch(
      `http://localhost:3007/api/daily-logs/${authStore.user?.id}/${date}`,
      {
        headers: { Authorization: `Bearer ${authStore.token}` },
      },
    );
    const result = await response.json();
    if (result.success) {
      selectedDayCompliance.value = result.compliance;
    }
  } catch (err) {
    console.error('Error fetching compliance:', err);
  }
}

watch(
  selectedDate,
  (newDate) => {
    fetchDayCompliance(newDate);
  },
  { immediate: true },
);

async function submitDayToPM() {
  if (!authStore.user?.id) return;

  console.log('=== SAVE DAY STATUS ===');
  console.log('User ID:', authStore.user?.id);
  console.log('Selected Date:', selectedDate.value);
  console.log('Selected Status:', selectedDayStatus.value);

  try {
    const response = await fetch('http://localhost:3007/api/daily-logs/submit', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${authStore.token}`,
      },
      body: JSON.stringify({
        user_id: authStore.user?.id,
        log_date: selectedDate.value,
        day_status: selectedDayStatus.value,
      }),
    });
    const result = await response.json();
    console.log('Save status response:', result);
    if (result.success) {
      // Update local state immediately
      dayStatuses.value[selectedDate.value] = selectedDayStatus.value;
      // Refresh to verify database persistence
      await fetchDayStatuses();

      // If status is leave, check for deadline conflicts
      if (selectedDayStatus.value === 'leave') {
        console.log('=== LEAVE STATUS SAVED ===');
        console.log('Selected date:', selectedDate.value);
        await fetchLeaveImpact();
        console.log('Affected tasks count:', affectedTasks.value.length);
        console.log('Affected tasks:', affectedTasks.value);
        // Check if any task deadline falls on this leave date
        for (const task of affectedTasks.value) {
          console.log('Checking task:', task.title, 'deadline:', task.deadline);
          const taskDeadline = new Date(task.deadline);
          const leaveDate = new Date(selectedDate.value);
          // Compare dates (ignore time)
          if (taskDeadline.toDateString() === leaveDate.toDateString()) {
            console.log('DEADLINE CONFLICT FOUND! Opening dialog...');
            selectedAffectedTask.value = task;
            showDeadlineOnLeaveDialog.value = true;
            break;
          }
        }
        console.log('Dialog should be open:', showDeadlineOnLeaveDialog.value);
      }

      showSavedDialog.value = true;
    } else {
      console.error('Save status failed:', result);
    }
  } catch (err) {
    console.error('Error saving day status:', err);
  }
}

/* ============================================================
   SELECTED DATE FORMATTED
============================================================ */

const selectedDateFormatted = computed(() => {
  const date = parseDate(selectedDate.value);

  return date.toLocaleDateString('en-IN', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });
});

/* ============================================================
   MONTHLY STATS
============================================================ */

const monthlyWorkedDays = computed(() => {
  return calendarDays.value.filter((day) => day.date && day.status === 'worked').length;
});

const monthlyTaskCount = computed(() => {
  return calendarDays.value.reduce((total, day) => total + day.workLogs.length, 0);
});

const monthlyHours = computed(() => {
  const hours = calendarDays.value.reduce(
    (total, day) => total + day.workLogs.reduce((sum, log) => sum + Number(log.hours || 0), 0),
    0,
  );

  return hours.toFixed(1);
});

/* ============================================================
   SELECTED STATUS
============================================================ */

const selectedDayStatusComputed = computed<DayStatus>(() => {
  const savedStatus = dayStatuses.value[selectedDate.value];
  if (savedStatus) return savedStatus;

  const date = parseDate(selectedDate.value);

  const day = date.getDay();

  return day === 0 || day === 6 ? 'weekend' : 'worked';
});

/*
  Update selectedDayStatus when date changes (but not when user manually selects)
*/
watch(
  () => selectedDate.value,
  () => {
    selectedDayStatus.value = selectedDayStatusComputed.value;
  },
);

/* ============================================================
   SELECT DAY STATUS
============================================================ */

function selectDayStatus(status: DayStatus) {
  console.log('=== SELECT DAY STATUS ===');
  console.log('New status:', status);
  console.log('Previous status:', selectedDayStatus.value);
  selectedDayStatus.value = status;
}

/* ============================================================
   FORMAT DATE
============================================================ */

function formatDate(date: Date): string {
  const year = date.getFullYear();

  const month = String(date.getMonth() + 1).padStart(2, '0');

  const day = String(date.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}

/* ============================================================
   PARSE DATE
============================================================ */

function parseDate(value: string): Date {
  const [year, month, day] = value.split('-').map(Number);

  if (year === undefined || month === undefined || day === undefined) {
    return new Date();
  }

  return new Date(year, month - 1, day);
}

/* ============================================================
   CALENDAR NAVIGATION
============================================================ */

function previousMonth() {
  if (calendarMonth.value === 0) {
    calendarMonth.value = 11;

    calendarYear.value--;
  } else {
    calendarMonth.value--;
  }
}

function nextMonth() {
  if (calendarMonth.value === 11) {
    calendarMonth.value = 0;

    calendarYear.value++;
  } else {
    calendarMonth.value++;
  }
}

function goCalendarToday() {
  calendarMonth.value = today.getMonth();

  calendarYear.value = today.getFullYear();

  selectedDate.value = todayString;
}

/* ============================================================
   SELECT CALENDAR DAY
============================================================ */

function selectCalendarDay(day: CalendarDay) {
  selectedDate.value = day.date;

  selectedDayStatus.value = day.status;
}

/* ============================================================
   STATUS HELPERS
============================================================ */

function statusLabel(status: DayStatus): string {
  switch (status) {
    case 'worked':
      return 'Worked';

    case 'leave':
      return 'Leave';

    case 'holiday':
      return 'Holiday';

    case 'weekend':
      return 'Weekend';

    default:
      return 'Unknown';
  }
}

function statusIcon(status: DayStatus): string {
  switch (status) {
    case 'worked':
      return 'check_circle';

    case 'leave':
      return 'event_busy';

    case 'holiday':
      return 'celebration';

    case 'weekend':
      return 'weekend';

    default:
      return 'help';
  }
}

function statusClass(status: DayStatus): string {
  return `status-${status}`;
}

/* ============================================================
   WORK LOG HELPERS
============================================================ */

function totalHours(logs: WorkLog[]): string {
  const total = logs.reduce((sum, log) => sum + Number(log.hours || 0), 0);

  return total.toFixed(1);
}

/* ============================================================
   DEADLINE ON LEAVE HANDLERS
============================================================ */

const showSetDeadlineDialog = ref(false);

function openSetDeadlineDialog() {
  showDeadlineOnLeaveDialog.value = false;
  if (selectedAffectedTask.value?.deadline) {
    const d = new Date(selectedAffectedTask.value.deadline);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    newDeadline.value = `${year}-${month}-${day}`;
  } else {
    newDeadline.value = '';
  }
  showSetDeadlineDialog.value = true;
}

async function openLeaveImpactDialog(dateString: string) {
  selectedLeaveDate.value = dateString;
  await fetchLeaveImpact();
  showLeaveImpactDialog.value = true;
}

function handleDeadlineOnLeaveTask() {
  showLeaveImpactDialog.value = false;
  // Find the first task with deadline on leave
  const taskWithDeadlineOnLeave = affectedTasks.value.find(t => t.deadline_on_leave);
  if (taskWithDeadlineOnLeave) {
    selectedAffectedTask.value = taskWithDeadlineOnLeave;
    showDeadlineOnLeaveDialog.value = true;
  }
}

async function saveNewDeadline() {
  if (!selectedAffectedTask.value || !newDeadline.value) return;

  automatingDeadline.value = true;
  try {
    const response = await fetch(
      `http://localhost:3007/api/employee/tasks/${selectedAffectedTask.value.id}`,
      {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
        body: JSON.stringify({
          deadline: newDeadline.value,
          is_leave_conflict: true,
        }),
      },
    );

    const data = await response.json();
    if (data.success) {
      showSetDeadlineDialog.value = false;
      await fetchLeaveImpact(); // Refresh affected tasks
      await fetchTasks(); // Refresh tasks
    }
  } catch (error) {
    console.error('Error saving deadline:', error);
  } finally {
    automatingDeadline.value = false;
  }
}

async function automateDeadline() {
  if (!selectedAffectedTask.value) return;

  automatingDeadline.value = true;
  try {
    const response = await fetch(
      `http://localhost:3007/api/leaves/employee/${authStore.user?.id}/tasks/${selectedAffectedTask.value.id}/automate-deadline`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
      },
    );

    const data = await response.json();
    if (data.success) {
      showDeadlineOnLeaveDialog.value = false;
      await fetchLeaveImpact(); // Refresh affected tasks
      await fetchTasks(); // Refresh tasks
    } else {
      alert(data.error || 'Failed to automate deadline');
    }
  } catch (error) {
    console.error('Error automating deadline:', error);
    alert('Error automating deadline');
  } finally {
    automatingDeadline.value = false;
  }
}
</script>

<style scoped>
.planner-page {
  min-height: 100vh;
  background: #ffffff;
}

.calendar-container {
  background: #ffffff;
}
.planner-header {
  max-width: 1440px;
  margin-inline: auto;
}

.planner-header-icon {
  display: grid;
  width: 46px;
  height: 46px;
  place-items: center;
  color: #6c63ff;
  background: #eeecff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
}

.streak-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: var(--radius-md);
}

.view-toggle {
  border: 1px solid #e5e7eb;
  border-radius: var(--radius-md);
  overflow: hidden;
}

.calendar-card,
.planner-card,
.compact-info-card,
.compact-task-card,
.empty-card {
  background: #ffffff;
  border-color: #e5e7eb;
  border-radius: var(--radius-lg);
}

.calendar-toolbar {
  min-height: 52px;
  border-bottom: 1px solid #edf0f5;
}

.calendar-kicker,
.section-kicker,
.section-title {
  font-size: 9px;
  font-weight: 800;
  letter-spacing: 0.09em;
  color: #64748b;
}

.calendar-month {
  font-size: 18px;
  font-weight: 750;
}

.compact-stats {
  display: flex;
  align-items: center;
  gap: 20px;
  min-height: 48px;
}

.compact-stat {
  display: flex;
  align-items: center;
  gap: 7px;
}

.stat-icon {
  width: 26px;
  height: 26px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 7px;
}

.worked-stat {
  color: #22c55e;
  background: #ecfdf3;
}

.activity-stat {
  color: #7c3aed;
  background: #f3e8ff;
}

.hours-stat {
  color: #3b82f6;
  background: #eff6ff;
}

.stat-value {
  font-size: 13px;
  font-weight: 750;
}

.stat-label {
  font-size: 9px;
  color: #94a3b8;
}

.calendar-legend {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-left: auto;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 9px;
  color: #64748b;
}

.legend-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

.worked-dot {
  background: #22c55e;
}

.leave-dot {
  background: #f59e0b;
}

.holiday-dot {
  background: #3b82f6;
}

.weekend-label {
  padding: 2px 5px;
  border-radius: 3px;
  background: #eeeeef;
}

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  gap: 6px;
}

.calendar-week-header {
  padding-top: 7px;
  padding-bottom: 7px;
  border-top: 1px solid #edf0f5;
  border-bottom: 1px solid #edf0f5;
}

.calendar-weekday {
  text-align: center;
  font-size: 9px;
  font-weight: 800;
  letter-spacing: 0.07em;
  color: #64748b;
}

.weekend-heading {
  color: #aaaab2;
}

.calendar-cell {
  position: relative;
  min-height: 83px;
  padding: 8px 9px;
  border: 1px solid #cfd5df;
  border-radius: 7px;
  background: #ffffff;
  cursor: pointer;
  transition: 0.15s ease;
}

.calendar-cell:hover {
  transform: translateY(-1px);
  border-color: #c9c6f6;
  box-shadow: var(--shadow-sm);
}

.calendar-empty {
  visibility: hidden;
  pointer-events: none;
}

.weekend-cell {
  background: #f5f5f7;
}

.worked-cell {
  background: #fcfff9;
}

.worked-cell::before {
  content: '';
  position: absolute;
  left: 0;
  top: 9px;
  bottom: 9px;
  width: 2px;
  border-radius: 0 3px 3px 0;
  background: #22c55e;
}

.leave-cell {
  background: #fffaf0;
}

.holiday-cell {
  background: #f7f8ff;
}

.today-cell {
  border: 2px solid #7c3aed;
}

.calendar-day-number {
  font-size: 14px;
  font-weight: 750;
}

.today-number {
  color: #7c3aed;
}

.today-pill {
  padding: 2px 4px;
  border-radius: 3px;
  background: #f3e8ff;
  color: #7c3aed;
  font-size: 7px;
  font-weight: 800;
}

.calendar-status {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  margin-top: 7px;
  padding: 3px 5px;
  border-radius: 4px;
  font-size: 8px;
  font-weight: 700;
}

.status-worked {
  color: #22c55e;
  background: #ecfdf3;
}

.status-weekend {
  color: #858691;
  background: #eaeaec;
}

.status-leave {
  color: #f59e0b;
  background: #fffbeb;
}

.status-holiday {
  color: #3b82f6;
  background: #eff6ff;
}

.calendar-work-summary {
  display: flex;
  align-items: center;
  gap: 3px;
  margin-top: 6px;
  font-size: 9px;
  font-weight: 600;
  color: #64748b;
}

.calendar-work-summary span {
  color: #94a3b8;
}

.activity-dots {
  display: flex;
  gap: 2px;
  margin-top: 5px;
}

.activity-dots span {
  width: 11px;
  height: 2px;
  border-radius: 3px;
  background: #7c3aed;
}

.calendar-leave-impact {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  margin-top: 4px;
  padding: 2px 5px;
  border-radius: 4px;
  background: #fef2f2;
  border: 1px solid #fecaca;
}

.calendar-missed-work {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  margin-top: 4px;
  padding: 2px 5px;
  border-radius: 4px;
  background: #fef2f2;
  border: 1px solid #fecaca;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.7;
  }
}

.selected-cell {
  box-shadow: 0 0 0 2px rgba(116, 103, 240, 0.15);
}

.compact-info-card {
  min-height: 135px;
}

.selected-date {
  font-size: 16px;
  font-weight: 750;
}

.compact-status-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 5px;
}

.compact-status-option {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
  min-height: 32px;
  padding: 5px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  font-size: 9px;
  color: #64748b;
  cursor: pointer;
}

.compact-status-active {
  color: #7c3aed;
  background: #f3e8ff;
  border-color: #7c3aed;
  font-weight: 700;
}

.compact-activity-list {
  max-height: 200px;
  overflow-y: auto;
}

.compact-activity-row {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 6px 0;
  border-bottom: 1px solid #edf0f5;
}

.activity-task-icon {
  width: 27px;
  height: 27px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  color: #7c3aed;
  background: #f3e8ff;
}

.compact-task-name {
  font-size: 12px;
  font-weight: 650;
}

.compact-progress {
  width: 75px;
  flex-shrink: 0;
}

.log-note-text {
  max-width: 200px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  font-style: italic;
}

.compact-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  padding-top: 18px;
  color: #94a3b8;
  font-size: 11px;
}

.date-strip {
  display: flex;
  gap: 5px;
}

.date-chip {
  min-width: 58px;
  padding: 6px;
  text-align: center;
  border: 1px solid #e5e7eb;
  border-radius: 7px;
  cursor: pointer;
  color: #64748b;
  background: #ffffff;
}

.date-chip-active {
  color: white;
  background: #6c63ff;
  border-color: #6c63ff;
}

.date-chip-number {
  font-size: 15px;
  font-weight: 750;
}

.reminder-banner {
  color: #111827;
  background: #fffbeb;
  border: 1px solid #f7dda4;
}

.compact-task-card {
  transition: 0.15s ease;
}

.compact-task-card:hover {
  border-color: #d5d2f8;
  box-shadow: var(--shadow-sm);
}

.task-title {
  font-size: 16px;
  font-weight: 750;
}

.progress-label {
  display: flex;
  justify-content: space-between;
  font-size: 10px;
  font-weight: 650;
  color: #64748b;
}

.compact-subtasks {
  display: flex;
  flex-wrap: wrap;
  gap: 2px 12px;
  padding-top: 5px;
  border-top: 1px solid #edf0f5;
}

.empty-card {
  min-height: 180px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
}

.add-work-dialog {
  width: 540px;
  max-width: 94vw;
  border-radius: var(--radius-lg);
}

.field-label {
  font-size: 11px;
  font-weight: 650;
  color: #64748b;
}


/* =========================================================
   DARK MODE — EMPLOYEE PLANNER
   Explicitly override the light calendar palette. The
   component contains many hard-coded light backgrounds,
   so these rules intentionally use !important.
   ========================================================= */

:global(body.body--dark) .planner-page {
  background: #121a1f !important;
  color: #edf2f7 !important;
}

:global(body.body--dark) .calendar-container,
:global(body.body--dark) .calendar-card {
  background: #1d2930 !important;
  color: #edf2f7 !important;
  border-color: #34434c !important;
}

:global(body.body--dark) .calendar-toolbar,
:global(body.body--dark) .calendar-week-header {
  background: #1d2930 !important;
  color: #edf2f7 !important;
  border-color: #34434c !important;
}

:global(body.body--dark) .compact-stats {
  background: #1d2930 !important;
  color: #edf2f7 !important;
}

:global(body.body--dark) .calendar-weekday,
:global(body.body--dark) .calendar-month,
:global(body.body--dark) .stat-value,
:global(body.body--dark) .calendar-day-number,
:global(body.body--dark) .selected-date,
:global(body.body--dark) .section-kicker,
:global(body.body--dark) .section-title {
  color: #edf2f7 !important;
}

:global(body.body--dark) .calendar-weekday {
  color: #b8c7d1 !important;
}

:global(body.body--dark) .weekend-heading {
  color: #91a2ad !important;
}

:global(body.body--dark) .stat-label {
  color: #b8c7d1 !important;
}

:global(body.body--dark) .planner-page .calendar-cell {
  background: #26343c !important;
  background-color: #26343c !important;
  border-color: #465761 !important;
  color: #edf2f7 !important;
}

:global(body.body--dark) .planner-page .calendar-cell.weekend-cell {
  background: #222f36 !important;
  background-color: #222f36 !important;
}

:global(body.body--dark) .planner-page .calendar-cell.worked-cell {
  background: #20372f !important;
  background-color: #20372f !important;
}

:global(body.body--dark) .planner-page .calendar-cell.leave-cell,
:global(body.body--dark) .planner-page .calendar-cell.holiday-cell {
  background: #30343b !important;
  background-color: #30343b !important;
}

:global(body.body--dark) .calendar-cell:hover {
  border-color: #72848f !important;
}

:global(body.body--dark) .today-number {
  color: #bdaeff !important;
}

:global(body.body--dark) .today-pill {
  background: #34305a !important;
  color: #d7d0ff !important;
}

:global(body.body--dark) .status-weekend {
  color: #c1cbd1 !important;
  background: #3a4248 !important;
}

:global(body.body--dark) .status-worked {
  color: #69e59a !important;
  background: #183d2a !important;
}

:global(body.body--dark) .status-leave {
  color: #ffd18a !important;
  background: #463719 !important;
}

:global(body.body--dark) .status-holiday {
  color: #9fd2ff !important;
  background: #1f3548 !important;
}

:global(body.body--dark) .calendar-work-summary,
:global(body.body--dark) .calendar-work-summary span {
  color: #b8c7d1 !important;
}

:global(body.body--dark) .compact-status-option,
:global(body.body--dark) .date-chip {
  background: #26343c !important;
  border-color: #465761 !important;
  color: #edf2f7 !important;
}

:global(body.body--dark) .compact-status-active {
  background: #34305a !important;
  border-color: #9b8cff !important;
  color: #ffffff !important;
}

:global(body.body--dark) .compact-info-card,
:global(body.body--dark) .compact-task-card,
:global(body.body--dark) .empty-card {
  background: #1d2930 !important;
  border-color: #34434c !important;
  color: #edf2f7 !important;
}

:global(body.body--dark) .compact-activity-row {
  border-color: #34434c !important;
}

:global(body.body--dark) .compact-activity-row .text-grey-5,
:global(body.body--dark) .compact-activity-row .text-grey-6,
:global(body.body--dark) .compact-activity-row .text-grey-7,
:global(body.body--dark) .compact-empty,
:global(body.body--dark) .progress-label,
:global(body.body--dark) .field-label {
  color: #b8c7d1 !important;
}

:global(body.body--dark) .planner-page,
:global(body.body--dark) .calendar-container,
:global(body.body--dark) .calendar-card,
:global(body.body--dark) .compact-info-card,
:global(body.body--dark) .streak-card,
:global(body.body--dark) .compact-task-card,
:global(body.body--dark) .empty-card {
  background: #1d2930;
  border-color: #34434c;
  color: #edf2f7;
}

:global(body.body--dark) .calendar-toolbar,
:global(body.body--dark) .calendar-week-header,
:global(body.body--dark) .compact-activity-row {
  border-color: #34434c;
}

:global(body.body--dark) .calendar-cell {
  background: #26343c;
  border-color: #465761;
}

:global(body.body--dark) .calendar-cell.weekend-cell {
  background: #222f36;
}

:global(body.body--dark) .calendar-cell.worked-cell {
  background: #20372f;
}

:global(body.body--dark) .calendar-cell.leave-cell,
:global(body.body--dark) .calendar-cell.holiday-cell {
  background: #30343b;
}

:global(body.body--dark) .calendar-leave-impact,
:global(body.body--dark) .calendar-missed-work {
  background: #45222a;
  border-color: #7f3b47;
}

:global(body.body--dark) .compact-status-option,
:global(body.body--dark) .date-chip {
  background: #26343c;
  border-color: #465761;
  color: #b8c7d1;
}

:global(body.body--dark) .compact-status-active {
  background: #34305a;
  border-color: #9b8cff;
  color: #d7d0ff;
}

@media (max-width: 850px) {
  .calendar-cell {
    min-height: 75px;
    padding: 7px;
  }

  .planner-header {
    align-items: flex-start;
    gap: 14px;
  }

  .planner-header .text-h5 {
    font-size: 1.35rem;
  }

  .calendar-grid {
    gap: 4px;
  }

  .calendar-legend {
    display: none;
  }
}

@media (max-width: 600px) {
  .planner-page {
    padding: 10px !important;
  }

  .streak-card {
    display: none;
  }

  .calendar-cell {
    min-height: 62px;
    padding: 5px;
  }

  .calendar-day-number {
    font-size: 12px;
  }

  .calendar-status {
    font-size: 7px;
  }

  .calendar-work-summary {
    font-size: 7px;
  }

  .activity-dots {
    display: none;
  }

  .compact-status-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
