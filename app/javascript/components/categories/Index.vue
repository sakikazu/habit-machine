<template>
  <div>
    <div class="search-box mb-4">
      <label class="search-label">日記をタイトルで検索</label>
      <input
        v-model="searchQuery"
        type="text"
        class="form-control"
        placeholder="キーワードを入力すると即時検索します"
      />
      <div v-if="searchQuery" class="search-results mt-2">
        <p class="text-muted mb-1">ヒット: {{ filteredResults.length }}件</p>
        <ul class="list-unstyled mb-0">
          <li v-for="result in filteredResults" :key="result.id" class="mb-1">
            <a :href="result.path">{{ result.title_with_date }}</a>
            <small class="text-muted d-block">カテゴリ: {{ result.category_path }}</small>
          </li>
        </ul>
        <p v-if="filteredResults.length === 0" class="text-muted mb-0">該当なし</p>
      </div>
    </div>

    <CategoryNode v-for="category in categories" :key="category.id" :category="category" />
  </div>
</template>

<script>
import CategoryNode from "components/categories/CategoryNode.vue";

export default {
  name: 'Categories',
  props: {
    categories: {
      type: Array,
      required: true,
    },
  },
  components: {
    CategoryNode,
  },
  data() {
    return {
      searchQuery: '',
      diaryIndex: [],
    };
  },
  computed: {
    filteredResults() {
      if (!this.searchQuery) return [];
      const keyword = this.searchQuery.toLowerCase();
      return this.diaryIndex.filter(item => item.title.toLowerCase().includes(keyword));
    },
  },
  watch: {
    categories: {
      handler() {
        this.buildDiaryIndex();
      },
      immediate: true,
      deep: true,
    },
  },
  methods: {
    buildDiaryIndex() {
      const index = [];
      const traverse = (category, parents = []) => {
        const pathNames = [...parents.map(p => p.name), category.name];
        (category.diaries || []).forEach(diary => {
          index.push({
            id: diary.id,
            title: diary.title,
            title_with_date: `${diary.title} [${diary.record_at}]`,
            category_path: pathNames.join(' > '),
            path: `/day/${diary.record_at}/diaries/${diary.id}`,
          });
        });
        (category.children || []).forEach(child => traverse(child, [...parents, category]));
      };
      this.categories.forEach(category => traverse(category));
      this.diaryIndex = index;
    },
  },
};
</script>

<style scoped lang="sass">
.search-box
  padding: 8px 10px
  border: 1px solid #e5e5e5
  border-radius: 6px
  background: #fafafa

.search-label
  font-weight: 600
  display: block
  margin-bottom: 6px

.search-results
  max-height: 280px
  overflow-y: auto
</style>
