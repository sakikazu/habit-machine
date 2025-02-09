<template>
  <div>
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
    };
  },
};
</script>

<style>
.category {
  background: #fff;
  padding: 12px;
  margin: 8px 0;
  border-radius: 8px;
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
