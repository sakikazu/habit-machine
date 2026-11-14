<template>
  <div class="diary-categories">
    <button v-if="showEditButton" class="category-button" style="min-width: 105px" @click="$emit('edit-category')">カテゴリ ✎</button>
    <div class="category-list">
      <a v-for="category in savedCategories" :key="category.id" href="/categories" class="category-link">
        <Users v-if="category.shared" class="shared-icon" :size="16" aria-label="共有" />
        {{ category.path.join(' > ') }}
      </a>
    </div>
  </div>
</template>

<script>
import { Users } from '@lucide/vue'

export default {
  components: {
    Users
  },
  props: {
    categories: Array,
    savedCategoryIds: Array,
    showEditButton: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    savedCategories() {
      const findCategoryPath = (categories, targetId, path = []) => {
        for (const category of categories) {
          const newPath = [...path, category.name];
          if (category.id === targetId) {
            return { path: newPath, id: category.id, shared: category.shared };
          }
          if (category.children) {
            const found = findCategoryPath(category.children, targetId, newPath);
            if (found) return found;
          }
        }
        return null;
      };

      return this.savedCategoryIds
        .map(id => findCategoryPath(this.categories, id))
        .filter(Boolean);
    }
  }
};
</script>

<style scoped lang="sass">
.diary-categories
  margin-top: 6px
  padding: 0
  display: flex
  align-items: center
  gap: 8px

.category-list
  display: flex
  flex-wrap: wrap
  gap: 8px

.category-link
  display: inline-flex
  align-items: center
  gap: 0.5rem
  text-decoration: none
  color: #4338ca
  font-weight: 700
  background: #eef2ff
  padding: 4px 10px
  border-radius: 999px
  border: 1px solid #e0e7ff

  &:hover
    background: #e0e7ff

.shared-icon
  color: orange

.category-button
  background-color: #eef2ff
  border: 1px solid #c7d2fe
  padding: 6px 12px
  border-radius: 10px
  cursor: pointer
  font-weight: 700
  display: flex
  align-items: center
  transition: transform 0.12s ease, box-shadow 0.12s ease

  &:hover
    background-color: #e0e7ff
    transform: translateY(-1px)
    box-shadow: 0 6px 14px rgba(67, 56, 202, 0.2)
</style>
