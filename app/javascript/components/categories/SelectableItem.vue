<template>
  <div class="category-item">
    <label>
      <input type="checkbox" :checked="category.selected" @change="$emit('toggle', category.id)" />
      <span>
        {{ category.name }}
        <FamilyBadge v-if="category.shared" />
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
import FamilyBadge from 'components/shared/FamilyBadge'

export default {
  name: "SelectableItem",
  components: {
    FamilyBadge
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

.children
  margin-left: 20px
  border-left: 2px solid #ccc
  padding-left: 10px
</style>
