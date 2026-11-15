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
        <button class="modal-button modal-button--primary" @click="$emit('save')">保存</button>
        <button class="modal-button" @click="$emit('close')">キャンセル</button>
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
  z-index: 3000 // 既存のフローティング要素より前面に出す

.modal-content
  background: white
  width: min(360px, calc(100vw - 20px))
  padding: 16px
  border-radius: 10px
  text-align: center
  position: relative
  z-index: 3100

.category-list
  text-align: left
  margin-top: 8px

.modal-actions
  margin-top: 15px
  display: flex
  justify-content: space-around

.modal-button
  padding: 7px 13px
  border: 1px solid #d1d5db
  border-radius: 5px
  background: #f8f9fa
  color: #343a40
  cursor: pointer
  font-weight: 600

.modal-button--primary
  border-color: #2563eb
  background: #2563eb
  color: #fff
</style>
