<template>
  <div>
    <div v-for="(category, index) in categories" :key="index" class="category">
      {{ category.name }}
      <span v-if="category.articles.length" class="article-link" @click.stop="toggleArticles(category)">
        ({{ category.articles.length }}件)
      </span>
    </div>
    <ul v-for="(category, index) in categories" :key="'list-' + index" class="category-list">
      <li v-for="(subCategory, subIndex) in category.subCategories" :key="subIndex" class="indent">
        <div class="category">
          {{ subCategory.name }}
          <span v-if="subCategory.articles.length" class="article-link" @click.stop="toggleArticles(subCategory)">
            ({{ subCategory.articles.length }}件)
          </span>
        </div>
        <ul v-if="subCategory.showArticles" class="article-list">
          <li v-for="(article, articleIndex) in subCategory.articles" :key="articleIndex">
            {{ article }}
          </li>
        </ul>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      categories: [
        {
          name: '親カテゴリA',
          articles: ['記事1', '記事2'],
          showArticles: false,
          subCategories: [
            {
              name: '子カテゴリA-1',
              articles: ['記事1', '記事2'],
              showArticles: false,
            },
          ],
        },
        {
          name: '親カテゴリB',
          articles: ['記事1', '記事2'],
          showArticles: false,
          subCategories: [
            {
              name: '子カテゴリB-1',
              articles: ['記事3', '記事4'],
              showArticles: false,
            },
          ],
        },
      ],
    };
  },
  methods: {
    toggleArticles(category) {
      category.showArticles = !category.showArticles;
    },
  },
};
</script>

<style>
.category {
  background: #fff;
  padding: 12px;
  margin: 8px 0;
  border-radius: 8px;
  display: flex;
  justify-content: space-between;
  font-weight: bold;
}
.article-link {
  color: blue;
  cursor: pointer;
  text-decoration: underline;
}
.category-list {
  list-style: none;
  padding-left: 15px;
}
.indent {
  margin-left: 30px;
}
.article-list {
  padding-left: 20px;
}
</style>

