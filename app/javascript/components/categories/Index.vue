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
