<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content">
      <h3>カテゴリを編集</h3>
      <div class="category-list">
        <SelectableItem
          v-for="category in categories"
          :key="category.id"
          :category="category"
          @toggle="$emit('toggle', $event)"
        />
      </div>
      <div class="modal-actions">
        <button class="btn btn-primary" @click="$emit('save')">保存</button>
        <button class="btn btn-light" @click="$emit('close')">キャンセル</button>
      </div>
    </div>
  </div>
</template>

<script>
import SelectableItem from "components/categories/SelectableItem"

export default {
  components: { SelectableItem },
  props: {
    categories: Array
  }
};
</script>

<style scoped lang="sass">
.modal-overlay
  position: fixed
  top: 0
  left: 0
  width: 100%
  height: 100%
  background: rgba(0, 0, 0, 0.5)
  display: flex
  justify-content: center
  align-items: center

.modal-content
  background: white
  padding: 20px
  border-radius: 10px
  width: 300px
  text-align: center

.category-list
  text-align: left
  margin-top: 10px

.modal-actions
  margin-top: 15px
  display: flex
  justify-content: space-around
</style>
