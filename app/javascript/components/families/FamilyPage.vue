<template>
  <div>
    <FamilyOverview :overview="overview" />
    <FamilyDashboard :current-year="currentYear" :current-month="currentMonth" />
  </div>
</template>

<script>
import FamilyOverview from './FamilyOverview.vue'
import FamilyDashboard from './FamilyDashboard.vue'

export default {
  name: 'FamilyPage',
  components: {
    FamilyOverview,
    FamilyDashboard
  },
  props: {
    overview: {
      type: Object,
      required: true
    },
    currentYear: {
      type: Number,
      required: true
    },
    currentMonth: {
      type: Number,
      required: true
    }
  }
}
</script>
