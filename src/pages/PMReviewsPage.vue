<template>
  <q-page class="q-pa-md">
    <div class="text-h5 text-weight-bold q-mb-md">Reviews</div>

    <q-tabs
      v-model="activeTab"
      dense
      class="text-grey-7 q-mb-md"
      active-color="primary"
      indicator-color="primary"
      align="left"
    >
      <q-tab name="pending" label="Pending Finalization" />
      <q-tab name="finalized" label="Finalized" />
    </q-tabs>

    <q-tab-panels v-model="activeTab" animated class="transparent">
      <!-- Pending Finalization (review-done) -->
      <q-tab-panel name="pending">
        <q-card>
          <q-card-section>
            <div class="text-h6">Pending Finalization</div>
            <div class="text-caption text-grey-7">Tasks peer-reviewed and awaiting PM finalization</div>
          </q-card-section>
          <q-card-section>
            <q-list separator v-if="pendingTasks.length > 0">
              <q-item v-for="review in pendingTasks" :key="review.id" class="q-py-md">
                <q-item-section avatar>
                  <q-icon name="rate_review" color="purple" size="32px" />
                </q-item-section>
                <q-item-section>
                  <q-item-label class="text-weight-bold">{{ review.title }}</q-item-label>
                  <q-item-label caption>Project: {{ review.project_name }}</q-item-label>
                  <q-item-label caption>Reviewed by: {{ review.reviewer_first_name }} {{ review.reviewer_last_name }}</q-item-label>
                  <q-item-label caption>Task Owner: {{ review.task_owner_first_name }} {{ review.task_owner_last_name }}</q-item-label>
                  <q-item-label caption v-if="review.review_comment" class="text-grey-8 q-mt-xs">
                    Reviewer: "{{ review.review_comment }}"
                  </q-item-label>
                </q-item-section>
                <q-item-section side>
                  <q-btn color="primary" label="Finalize" size="sm" @click="openFinalizeDialog(review)" />
                </q-item-section>
              </q-item>
            </q-list>
            <div v-else class="text-center q-pa-xl text-grey-6">
              <q-icon name="check_circle" size="48px" class="q-mb-sm text-green-4" />
              <div class="text-h6">No tasks pending finalization</div>
            </div>
          </q-card-section>
        </q-card>
      </q-tab-panel>

      <!-- Finalized -->
      <q-tab-panel name="finalized">
        <q-card>
          <q-card-section>
            <div class="text-h6">Finalized Tasks</div>
            <div class="text-caption text-grey-7">Tasks fully completed and finalized</div>
          </q-card-section>
          <q-card-section>
            <q-list separator v-if="finalizedTasks.length > 0">
              <q-item v-for="review in finalizedTasks" :key="review.id" class="q-py-md">
                <q-item-section avatar>
                  <q-icon name="check_circle" color="green" size="32px" />
                </q-item-section>
                <q-item-section>
                  <q-item-label class="text-weight-bold">{{ review.title }}</q-item-label>
                  <q-item-label caption>Project: {{ review.project_name }}</q-item-label>
                  <q-item-label caption>Reviewed by: {{ review.reviewer_first_name }} {{ review.reviewer_last_name }}</q-item-label>
                  <q-item-label caption>Task Owner: {{ review.task_owner_first_name }} {{ review.task_owner_last_name }}</q-item-label>
                  <q-item-label caption v-if="review.review_comment" class="text-grey-8 q-mt-xs">
                    Reviewer: "{{ review.review_comment }}"
                  </q-item-label>
                  <q-item-label caption v-if="review.pm_final_comment" class="text-blue-8 q-mt-xs">
                    PM: "{{ review.pm_final_comment }}"
                  </q-item-label>
                  <q-item-label caption v-if="review.task_owner_points" class="text-amber-8 q-mt-xs">
                    Points Awarded: {{ review.task_owner_points }} to owner, {{ review.reviewer_points }} to reviewer
                  </q-item-label>
                </q-item-section>
                <q-item-section side>
                  <div class="column items-end">
                    <q-badge color="green" label="Finalized" />
                    <div class="text-caption text-grey-6 q-mt-xs">{{ formatDate(review.finalized_at) }}</div>
                  </div>
                </q-item-section>
              </q-item>
            </q-list>
            <div v-else class="text-center q-pa-xl text-grey-6">
              <q-icon name="check_circle" size="48px" class="q-mb-sm text-green-4" />
              <div class="text-h6">No finalized tasks yet</div>
            </div>
          </q-card-section>
        </q-card>
      </q-tab-panel>
    </q-tab-panels>

    <!-- Finalize Dialog -->
    <q-dialog v-model="showFinalizeDialog">
      <q-card style="min-width: 450px">
        <q-card-section>
          <div class="text-h6">Finalize Review</div>
        </q-card-section>
        <q-card-section v-if="selectedReview">
          <div class="q-mb-sm"><strong>Task:</strong> {{ selectedReview.title }}</div>
          <div class="q-mb-sm"><strong>Reviewer Comment:</strong> {{ selectedReview.review_comment || 'N/A' }}</div>
          <q-input
            v-model="pmFinalComment"
            label="PM Final Comment (optional)"
            type="textarea"
            outlined
            rows="3"
            class="q-mt-md"
          />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn color="primary" label="Finalize" @click="finalizeReview" :loading="finalizing" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { Notify } from 'quasar';

const allReviews = ref<any[]>([]);
const activeTab = ref('pending');
const showFinalizeDialog = ref(false);
const selectedReview = ref<any>(null);
const pmFinalComment = ref('');
const finalizing = ref(false);

const pendingTasks = computed(() =>
  allReviews.value.filter((r: any) => r.review_status === 'review-done')
);

const finalizedTasks = computed(() =>
  allReviews.value.filter((r: any) => r.review_status === 'finalized')
);

onMounted(async () => {
  await fetchReviews();
});

async function fetchReviews() {
  try {
    const response = await fetch('http://localhost:3001/api/pm/reviews/all');
    const data = await response.json();
    if (data.success) {
      allReviews.value = data.reviews;
    }
  } catch (error) {
    console.error('Error fetching reviews:', error);
  }
}

function openFinalizeDialog(review: any) {
  selectedReview.value = review;
  pmFinalComment.value = '';
  showFinalizeDialog.value = true;
}

async function finalizeReview() {
  if (!selectedReview.value) return;
  finalizing.value = true;
  try {
    const response = await fetch(
      `http://localhost:3001/api/pm/reviews/${selectedReview.value.id}/finalize`,
      {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ pm_final_comment: pmFinalComment.value }),
      }
    );
    const data = await response.json();
    if (data.success) {
      showFinalizeDialog.value = false;
      Notify.create({ type: 'positive', message: 'Task finalized successfully' });
      await fetchReviews();
    } else {
      Notify.create({ type: 'negative', message: data.error || 'Failed to finalize' });
    }
  } catch (error) {
    console.error('Error finalizing review:', error);
    Notify.create({ type: 'negative', message: 'Server error' });
  } finally {
    finalizing.value = false;
  }
}

function formatDate(date: string) {
  if (!date) return 'N/A';
  const d = new Date(date);
  if (isNaN(d.getTime())) return 'Invalid Date';
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}
</script>
