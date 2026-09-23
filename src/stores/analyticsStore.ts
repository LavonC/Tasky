import { defineStore } from 'pinia';

export const useAnalyticsStore = defineStore('analytics', {
  state: () => ({
    overview: null as any,
    projectProgress: [] as any[],
    taskDistribution: null as any,
    completionTrend: [] as any[],
    resourceWorkload: [] as any[],
    deadlineRisks: [] as any[],
    projectPerformance: [] as any[],
    dailyLogCompliance: [] as any[],
    loading: false,
    error: null as string | null,
  }),

  actions: {
    getHeaders() {
      const token = sessionStorage.getItem('tasky_token');
      return {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      };
    },

    async fetchOverview(period = 'this_month') {
      try {
        const response = await fetch(
          `http://localhost:3001/api/pm/analytics/overview?period=${encodeURIComponent(period)}`,
          {
          headers: this.getHeaders(),
          },
        );
        const data = await response.json();
        if (data.success) this.overview = data.overview;
      } catch (err: any) {
        this.error = err.message;
      } 
    },

    async fetchProjectProgress(period = 'this_month') {
      try {
        const response = await fetch(
          `http://localhost:3001/api/pm/analytics/project-progress?period=${encodeURIComponent(period)}`,
          {
            headers: this.getHeaders(),
          },
        );
        const data = await response.json();
        if (data.success) this.projectProgress = data.projects;
      } catch (err: any) {
        this.error = err.message;
      }
    },

    async fetchTaskDistribution() {
      try {
        const response = await fetch('http://localhost:3001/api/pm/analytics/task-distribution', {
          headers: this.getHeaders(),
        });
        const data = await response.json();
        if (data.success) {
          // Convert array format to object format for easier iteration
          const statusObj: Record<string, number> = {};
          data.statusDistribution.forEach((item: any) => {
            statusObj[item.status] = item.count;
          });

          const priorityObj: Record<string, number> = {};
          data.priorityDistribution.forEach((item: any) => {
            priorityObj[item.priority] = item.count;
          });

          this.taskDistribution = {
            status: statusObj,
            priority: priorityObj,
            total: data.total,
          };
        }
      } catch (err: any) {
        this.error = err.message;
      }
    },

    async fetchCompletionTrend() {
      try {
        const response = await fetch('http://localhost:3001/api/pm/analytics/completion-trend', {
          headers: this.getHeaders(),
        });
        const data = await response.json();
        if (data.success) this.completionTrend = data.trend;
      } catch (err: any) {
        this.error = err.message;
      }
    },

    async fetchResourceWorkload() {
      try {
        const response = await fetch('http://localhost:3001/api/pm/analytics/resource-workload', {
          headers: this.getHeaders(),
        });
        const data = await response.json();
        if (data.success) this.resourceWorkload = data.byProject;
      } catch (err: any) {
        this.error = err.message;
      }
    },

    async fetchDeadlineRisks() {
      try {
        const response = await fetch('http://localhost:3001/api/pm/analytics/deadline-risks', {
          headers: this.getHeaders(),
        });
        const data = await response.json();
        if (data.success) this.deadlineRisks = data.risks;
      } catch (err: any) {
        this.error = err.message;
      }
    },

    async fetchProjectPerformance() {
      try {
        const response = await fetch('http://localhost:3001/api/pm/analytics/project-performance', {
          headers: this.getHeaders(),
        });
        const data = await response.json();
        if (data.success) {
          this.projectPerformance = data.projects.map((project: any) => {
            const total_tasks = Number(project.total_tasks) || 0;
            const completed_tasks = Number(project.completed_tasks) || 0;
            const completion_rate = total_tasks > 0 ? Math.round((completed_tasks / total_tasks) * 100) : 0;

            return {
              ...project,
              progress: Number(project.progress) || 0,
              total_tasks,
              completed_tasks,
              completion_rate,
              overdue_tasks: Number(project.overdue_tasks) || 0,
              at_risk_tasks: Number(project.at_risk_tasks) || 0,
              team_size: Number(project.team_size) || 0,
              total_hours_logged: Number(project.total_hours_logged) || 0,
              total_estimated_hours: Number(project.total_estimated_hours) || 0,
              days_remaining: Number(project.days_remaining) || 0,
            };
          });
        }
      } catch (err: any) {
        this.error = err.message;
      }
    },

    async fetchDailyLogCompliance() {
      try {
        const response = await fetch(
          'http://localhost:3001/api/pm/analytics/daily-log-compliance',
          {
            headers: this.getHeaders(),
          },
        );
        const data = await response.json();
        if (data.success) this.dailyLogCompliance = data.compliance;
      } catch (err: any) {
        this.error = err.message;
      }
    },

    async loadAll(period = 'this_month') {
      this.loading = true;
      await Promise.all([
        this.fetchOverview(period),
        this.fetchProjectProgress(period),
        this.fetchTaskDistribution(),
        this.fetchCompletionTrend(),
        this.fetchResourceWorkload(),
        this.fetchDeadlineRisks(),
        this.fetchProjectPerformance(),
        this.fetchDailyLogCompliance(),
      ]);
      this.loading = false;
    },
  },
});
