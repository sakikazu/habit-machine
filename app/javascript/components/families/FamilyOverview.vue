<template>
  <section class="family-overview">
    <header class="family-overview__header">
      <div class="family-overview__title-row">
        <h3 class="family-overview__title">家族の一覧</h3>
        <button type="button" class="family-overview__toggle" @click="toggleMembers">
          <i :class="membersOpen ? 'fa fa-chevron-up' : 'fa fa-chevron-down'"></i>
        </button>
      </div>
      <a :href="overview.settings_path" :class="['family-overview__settings', { 'is-open': membersOpen }]">
        <i class="fa fa-cog"></i>
        設定
      </a>
    </header>

    <div v-if="!membersOpen" class="family-overview__avatars">
      <img
        v-for="member in avatarMembers"
        :key="`avatar-${member.type}-${member.id}`"
        :src="member.image_url"
        alt=""
        class="family-overview__avatar family-overview__avatar--small"
      >
    </div>

    <div class="family-overview__section">
      <div class="family-overview__grid" :class="{ 'is-open': membersOpen }">
        <article
          v-for="member in overview.members"
          :key="`${member.type}-${member.id}`"
          class="family-overview__card"
        >
          <img
            v-if="member.image_url"
            :src="member.image_url"
            alt=""
            class="family-overview__avatar"
          >
          <div class="family-overview__meta">
            <p class="family-overview__name">
              <span v-if="member.type === 'Child'" class="family-overview__child-icon">
                <i class="fa fa-child"></i>
              </span>
              {{ member.name }}
            </p>
            <p v-if="member.age_label" class="family-overview__age">{{ member.age_label }}</p>
            <a
              v-if="member.legacy_path"
              :href="member.legacy_path"
              class="family-overview__legacy"
            >
              年ページ
            </a>
          </div>
          <a v-if="member.graph_path" :href="member.graph_path" class="family-overview__graph">
            <i class="fa fa-line-chart"></i>
          </a>
        </article>
        <p v-if="overview.members.length === 0" class="family-overview__empty">登録された家族がいません。</p>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  props: {
    overview: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      membersOpen: true
    }
  },
  computed: {
    avatarMembers () {
      if (!this.overview?.members) return []
      return this.overview.members.filter((member) => !!member.image_url)
    }
  },
  mounted () {
    this.membersOpen = !(window.matchMedia && window.matchMedia('(max-width: 768px)').matches)
  },
  methods: {
    toggleMembers () {
      this.membersOpen = !this.membersOpen
    }
  }
}
</script>
