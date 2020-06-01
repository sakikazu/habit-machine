<template>
  <div class="create-doc-form input-group mt-3">
    <input type='text' class='form-control' v-model='newTitle' placeholder='タイトル'>
    <div class='input-group-append'>
      <span class='input-group-text' v-on:click="createData()">作成</span>
    </div>
  </div>
</template>

<script>
import HmAxios from '../../hm_axios.js'
export default {
  // 非prop属性をルート要素に適用したくない場合
  inheritAttrs: false,
  data: function () {
    return {
      newTitle: ''
    }
  },
  methods: {
    createData: function () {
      if (!this.newTitle) {
        return;
      }
      HmAxios.post('/habitodos.json', {
        habitodo: { 'title' : this.newTitle }
      })
      .then(res => {
        console.log(res);
        // NOTE: Promiseのthenの中？のthisは、ちゃんとVueComponentを指していた
        this.newTitle = '';
        this.$emit('created-data', res.data)
      })
      .catch(error => {
        console.log(error)
      })
    }
  }
}
</script>

<style scoped>
</style>
