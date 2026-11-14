<template>
  <div class="category-item">
    <label>
      <input type="checkbox" :checked="category.selected" @change="$emit('toggle', category.id)" />
      <span>
        {{ category.name }}
        <Users v-if="category.shared" class="shared-icon" :size="16" aria-label="共有" />
      </span>
    </label>
    <div v-if="category.children && category.children.length" class="children">
      <SelectableItem
        v-for="child in category.children"
        :key="child.id"
        :category="child"
        @toggle="$emit('toggle', $event)"
      />
    </div>
  </div>
</template>

<script>
import { Users } from '@lucide/vue'

export default {
  name: "SelectableItem",
  components: {
    Users
  },
  props: {
    category: Object
  }
};
</script>

<style scoped lang="sass">
.category-item
  margin-left: 10px

label
  display: flex
  align-items: center
  gap: 5px

.shared-icon
  display: inline-block
  margin-left: 0.5rem
  color: orange

.children
  margin-left: 20px
  border-left: 2px solid #ccc
  padding-left: 10px
</style>
