<template>
  <span class="family-shared-badge" aria-label="家族で共有">
    <Users :size="14" aria-hidden="true" />
    <span>家族</span>
  </span>
</template>

<script>
import { Users } from '@lucide/vue'

export default {
  components: { Users },
}
</script>

<style scoped lang="sass">
.family-shared-badge
  display: inline-flex
  align-items: center
  gap: 3px
  margin-left: 8px
  padding: 2px 6px
  border: 1px solid #f59e0b
  border-radius: 999px
  background: #fff7ed
  color: #9a3412
  font-size: 0.75rem
  font-weight: 600
  line-height: 1.2
  vertical-align: middle
</style>
