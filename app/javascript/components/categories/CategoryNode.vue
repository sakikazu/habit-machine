<template>
  <div class="category-node">
    <div :class="['category-header', { 'shared-category': category.shared }]" @click="toggleOpen">
      <span class="toggle-icon">{{ isOpen ? "▼" : "▶" }}</span>
      <span class="category-name">{{ category.name }}</span>
      <i v-if="category.shared" class="fa fa-users ml-2" style="color:orange"></i>
    </div>

    <transition name="fade">
      <div v-if="isOpen" class="category-content">
        <ul v-if="category.diaries" class="article-list">
          <li v-for="diary in category.diaries" :key="diary.id">
            <a :href="`/day/${diary.record_at}/diaries/${diary.id}`">
              {{ `${diary.record_at}${diary.title}` }}
            </a>
          </li>
        </ul>

        <div v-if="category.children">
          <CategoryNode
            v-for="child in category.children"
            :key="child.id"
            :category="child"
          />
        </div>
      </div>
    </transition>
  </div>
</template>

<script>
export default {
  name: 'CategoryNode',
  props: {
    category: Object,
  },
  data() {
    return {
      isOpen: true,
    };
  },
  methods: {
    toggleOpen() {
      this.isOpen = !this.isOpen;
    },
  },
};
</script>

<style scoped>
/* カテゴリのコンテナ */
.category-node {
  margin-top: 7px;
  margin-left: 12px;
  border-left: 2px solid #ddd;
  padding-left: 10px;
}

/* クリック部分 */
.category-header {
  display: flex;
  align-items: center;
  padding: 10px;
  background: #f9f9f9;
  border-radius: 8px;
  cursor: pointer;
  transition: background 0.3s;
}

.category-header:hover {
  background: #ececec;
}

.shared-category {
  background: #e0f2ff;
  border-left: 4px solid #2196f3;
  padding-left: 16px;
}

/* 開閉アイコン */
.toggle-icon {
  margin-right: 8px;
  font-size: 14px;
}

/* カテゴリ名 */
.category-name {
  font-size: 16px;
  font-weight: bold;
}

/* 記事リスト */
.article-list {
  padding-left: 20px;
  margin-top: 5px;
}

.article-list li {
  list-style: none;
  padding: 5px 0;
  font-size: 14px;
  color: #333;
}

/* アニメーション */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.1s ease-out;
}
.fade-enter, .fade-leave-to {
  opacity: 0;
}
</style>
