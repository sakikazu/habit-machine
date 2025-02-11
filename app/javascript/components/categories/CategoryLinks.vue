<template>
  <div class="diary-categories">
    <span>カテゴリ:</span>
    <div class="category-list">
      <a v-for="category in savedCategories" :key="category.id" href="/categories" class="category-link">
        <i v-if="category.shared" class="fa fa-users mr-2" style="color:orange"></i>
        {{ category.path.join(' > ') }}
      </a>
    </div>
    <button class="btn btn-light" style="min-width: 70px" @click="$emit('edit-category')">編集</button>
  </div>
</template>

<script>
export default {
  props: {
    categories: Array,
    savedCategoryIds: Array
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
  margin-top: 10px
  padding: 8px
  background: #f8f9fa
  border-radius: 5px
  display: flex
  align-items: center
  gap: 10px

.category-list
  display: flex
  flex-wrap: wrap
  gap: 10px

.category-link
  text-decoration: none
  color: #007bff
  font-weight: bold
  background: #e9ecef
  padding: 3px 8px
  border-radius: 3px

  &:hover
    text-decoration: underline

.edit-category
  background: #007bff
  color: white
  border: none
  padding: 5px 10px
  border-radius: 5px
  cursor: pointer
  font-size: 14px

  &:hover
    background: #0056b3
</style>
