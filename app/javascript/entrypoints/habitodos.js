//
// Vue.jsに不慣れな頃に作ったもので、もっと良い作り方できそうなのでリファクタリングしたい
// リファクタリング前に書いていたコメントが古くなっている可能性があるのでチェックしたい
//
// 内容の保存時、DOMの内容を保存していることから、想定しない内容を保存するリスクは普通の仕組みよりも高い。そこをうまい処理にしたいし、適切なコメントを書きたい
//

import Vue from 'vue/dist/vue.esm'
import HmAxios from 'hm_axios.js'
import ContentEditor from 'components/habitodos/ContentEditor.vue'
import CreateForm from 'components/habitodos/CreateForm.vue'
import { isSmartPhone, moveCaret } from 'helper.js'

document.addEventListener('turbolinks:load', () => {
const vm = new Vue({
  el: '#habitodo',
  components: {
    ContentEditor,
    CreateForm,
  },
  // TODO: ライフサイクルの共通処理があれば。ログインチェック処理とかに適しているかな？
  mixins: [],
  data: {
    habitodos: [],
    mokuji: [],
    searchWord: '',
    searchResult: [],
    searchBtnColor: '',
  },
  created: function () {
    this.fetchData()
  },
  mounted: function () {
    $('footer').css('margin-top', 0);
    this.setHeightForScroll()
    this.setConfirmUnsavingEvent()
    this.setShortcutOfSave()
    this.setFontSizeInEditor()

    // NOTE: Enter押下時の挿入タグをbrに変更したかったが、デフォルトのdivになってしまう。pに変更はできるので、brがダメなんだろう
    //document.execCommand("DefaultParagraphSeparator", false, "br");

    //$(this.$el).find('#editor').markdownEasily();
  },
  updated: function() {
  },
  // Vue: methodsでやる場合と違い、引数が取れないが、キャッシュしてくれるので、ReadOnlyならこっち使う
  computed: {
    // todo: ここでsliceしてコピーしてるようなのに、フォームでv-modelでこの要素を指定しているのに、habitodosにうまく反映されているのが謎・・
    // sliceはリアクティブだったけかな
    // computedで並び替えのデータを作ってるのに、そのキーをv-forの中のv-modelで変更できるってのは、何か怪しくて、どうにかしたい。正しいデータが対象となっているか不安になる
    sortedHabitodos: function() {
      // todo: 何度も呼ばれてる。キャッシュしてたら呼ばれないんじゃないのかな -> habitodosが更新されれば呼ばれるか
      console.log('sorting')
      // sliceしとかないと、データが重複する問題があった。this.habitodos自体を変更した時になにか問題が起きてるのかな・・
      return this.habitodos.slice().sort((x, y) => x.order_number < y.order_number ? 1 : -1)
    },
  },
  methods: {
    moveCaret,
    onCreatedData: function(e) {
      this.habitodos.push(e)
    },
    // 保存ボタンのショートカット。Macはcmd + s, Winはctrl + s
    setShortcutOfSave: function() {
      const S_KEY = 83
      // TODO: Vue.jsではこういう全体のイベントハンドリングはどうするのがセオリー？
      $(document).on('keydown', function(e) {
        // Macのcmdはe.metaKey、Winのctrlはe.ctrlKey（でもこれはMacのcontrolも含むだろうからMacではそっちでもいける）
        if ((e.ctrlKey || e.metaKey) && e.keyCode === S_KEY) {
          // ブラウザの「ページを別名で保存」を抑制
          e.preventDefault()
          const current = vm.findCurrentData()
          if (current.unsaved) {
            vm.saveBody(current.uuid)
          }
        }
      });
    },
    // todo media queryでやれそう
    // BodyのFontSize基準を設定：スマホではBodyのテキストは相対的に小さくしたかったので、remで一律設定はできなかった
    setFontSizeInEditor: function() {
      if (isSmartPhone()) {
        document.getElementById('middle-area').style.fontSize = '13px'
      }
    },
    findIndex (uuid) {
      return this.habitodos.findIndex(h => h.uuid === uuid)
    },
    findCurrentData: function() {
      return this.habitodos.find(h => h.isCurrent === true)
    },

    // 検索機能
    preSearchData: function() {
      if (!this.searchWord) {
        this.searchBtnColor = '';
        return;
      }
      const exists = this.habitodos.some(d => {
        // RegExpは//と違って（？）文字列を指定できるので、変数を使いたい場合に必要になる感じかなー
        return d.title.match(new RegExp(this.searchWord)) || (d.body && d.body.match(new RegExp(this.searchWord)))
      });
      this.searchBtnColor = exists ? 'red' : '';
    },
    searchData: function() {
      this.searchResult = [];
      if (!this.searchWord || !this.searchBtnColor) {
        return;
      }
      this.habitodos.forEach(d => {
        // titleにマッチ
        if (d.title.match(new RegExp(this.searchWord))) {
          this.searchResult.push({ 'docId': d.uuid, 'text': '[' + d.title + ']', 'rows': 0 });
        }
        if (!d.body) {
          // forEach内でcontinueしたい時はreturnを使う
          return;
        }
        // bodyにマッチの場合は、行ごとに検索していく
        if (d.body.match(new RegExp(this.searchWord))) {
          const lines = d.body.split(/\r\n|\n|\r/);
          lines.forEach((line, idx) => {
            if (line.match(new RegExp(this.searchWord))) {
              this.searchResult.push({ 'docId': d.uuid, 'text': '[' + d.title + '] ' + line, 'rows': idx + 1 });
            }
          });
        }
      });
      this.searchBtnColor = '';
    },
    // todo caretが適切に移動しないが、まあ重要ではないか
    selectFoundData: function(uuid, rows) {
      this.switchDoc(uuid);
      Vue.nextTick().then(() => {
        // caretを指定行に移動
        const el = document.getElementById(`editor-${uuid}`);
        let kaigyoCount = 1;
        let nodesCount;
        // rowsは検索結果で見つかった行数を示すが、
        // range.setStartではNode数を指定する必要があるので、
        // 改行されるタイプのNodeの数がrowsと同じになる所のNodeの値を出す
        for (let i = 0, len = el.childNodes.length; i < len; i++) {
          if (kaigyoCount == rows) {
            nodesCount = i;
            break;
          }
          // NOTE: 改行されるNodeであるbrやh1は、nodeTypeが1だったので改行された判定として使用
          if (el.childNodes[i].nodeType == 1) {
            kaigyoCount ++;
          }
        };
        this.moveCaret(el.childNodes[nodesCount], 0);

        // Caretの位置にScrollを移動
        // todo まだ位置が不安定
        const rootOffsetTop = $(this.$el).offset().top;
        console.log(rootOffsetTop);
        // todo なぜこれはundefined？jqueryのoffset().topだと取得できた
        //console.log(document.getSelection().getRangeAt(0).startContainer.offsetTop);
        const offsetTop = $(document.getSelection().getRangeAt(0).startContainer).offset().top + rootOffsetTop;
        console.log(offsetTop);
        scrollTo({ top: offsetTop, behavior: "smooth" });
      });
    },
    // todo 目次をComponentにして移動したい
    // hタグは目次として抽出
    // todo これもcurrentData運用すればcomputedにできるなあ
    // todo htmlで見なくとも、文字列で「#」を見れば、nextTickなしにいける、けどbodyは双方向じゃないので、最新のデータをどう取得するか
    buildMokuji: function(uuid) {
      // NOTE: DOMにアクセスする処理はすべてnextTick内で行うこと
      // また、これをやったからといって、この後の処理はDOM構築後というわけではないので、都度、囲む
      Vue.nextTick().then(() => {
        this.mokuji = [];
        // htmlタグを評価するのでhtmlを取得する。改行は含まず1行で取得されるので注意
        const text = document.getElementById(`editor-${uuid}`).innerHTML;
        // まずはすべてのhタグ要素を取得して、それぞれからidとtextを取得する
        // 「g」オプションだとマッチしたものが配列になって返却されるが、カッコのキャプチャは使えなくなった
        const matched = text.match(/\<h\d\ id="([a-z0-9-]+)"\>(.+?)\<\/h\d\>/g)
        if (matched) {
          //console.log(matched);
          matched.forEach(d => {
            const matched2 = d.match(/\<h(\d)\ id="([a-z0-9-]+)"\>#+(.+?)\<\/h\d\>/)
            if (matched2) {
              this.mokuji.push({ text: matched2[3], anchor: matched2[2], style_class: `mokuji-h${matched2[1]}` });
            }
          });
        }
      });
    },
    switchDoc: function(uuid) {
      this.habitodos.forEach(ht => {
        ht.isCurrent = false
      })
      const idx = this.findIndex(uuid)
      const habitodo = this.habitodos[idx]
      habitodo.isCurrent = true
      Vue.set(this.habitodos, idx, habitodo)
      // todo updateMarkdownedBodyの後に実行する必要があるが、現状はbuildMokujiのnextTick内で処理しているから順序がうまくできてるだけ
      this.buildMokuji(uuid);
    },
    updateHabitodo (habitodo) {
      const idx = this.findIndex(habitodo.uuid)
      Vue.set(this.habitodos, idx, habitodo)
    },
    // 長いコンテンツの場合はスクロールさせるようにする（overflow-y:scroll 適用済みであること）
    setHeightForScroll: function() {
      if (isSmartPhone()) {
        document.getElementById('middle-area').style.maxHeight = '600px'
        document.getElementById('sidebar-left').style.maxHeight = '140px'
        document.getElementById('sidebar-right').style.maxHeight = '140px'
      } else {
        document.getElementById('middle-area').style.height = this.getContentAreaHeight() + 'px'
      }
    },
    getContentAreaHeight: function() {
      const otherHeight = document.getElementsByTagName('nav')[0].clientHeight
        // + document.getElementsByTagName('footer')[0].clientHeight
        + document.getElementById('habitodo-header').clientHeight;
      return window.innerHeight - otherHeight;
    },
    setConfirmUnsavingEvent: function() {
      const formWarningMessage = "未保存の内容が破棄されますがよろしいですか？";
      $('a').on('click', function(e) {
        const unsaved = vm.isAnyUnsaved();
        if (!unsaved) { return; }
        if (!confirm(formWarningMessage)) {
          e.preventDefault();
        }
      });

      // ブラウザのタブを閉じようとした時、またはturbolinks以外のリンクをクリックした時の警告
      $(window).on('beforeunload', function() {
        const unsaved = vm.isAnyUnsaved();
        if (unsaved) {
          return formWarningMessage;
        }
      });
    },
    isAnyUnsaved: function() {
      return this.habitodos.some(d => d.unsaved == true )
    },
    saveAttrs: function(uuid) {
      const idx = this.findIndex(uuid)
      const habitodo = {
        'title' : this.habitodos[idx].title,
        'order_number' : this.habitodos[idx].order_number,
      }
      this.saveData(uuid, habitodo)
    },
    // DOM参照していてVue.jsらしくない
    // 渡されたuuidをキーとして、そのDOMのデータで更新しているので、他のデータを誤って上書きするリスクはなさそう
    saveBody: function(uuid) {
      // NOTE: これをやるには、bodyがv-modelである必要があるが、contentEditableとv-modelは特別なことをしなければ併用できないとのエラーが出る
      // data = this.currentData.body
      // NOTE: innerTextは、h1やpなどタグが存在すると、間に改行の行を一つはさむようにして勝手に改行が挿入されたものが取得されてしまう。ので使えない
      // data = document.getElementById(`editor-${id}`).innerText;
      // Nodeでいじった方が楽という可能性はある
      const data = document.getElementById(`editor-${uuid}`).innerHTML
        // contentEditableによってdivで囲まれたbrが入るので、先にそれを改行に変換
        .replace(/\<div\>\<br\>\<\/div\>/g, '\n')
        // hとdivとpの開始タグを除去
        .replace(/\<h\d.*?\>|\<div\>|\<p\>/g, '')
        // spanを除去
        .replace(/\<\/?span.*?\>/g, '')
        // hとdivとpの終了タグと、brタグを改行に変換
        .replace(/\<\/h\d\>|\<\/div\>|\<\/p\>|\<br\>/g, '\n')
      const habitodo = { 'body' : data }
      this.saveData(uuid, habitodo)
    },
    saveData: function(uuid, habitodo) {
      HmAxios.put(`/habitodos/${uuid}.json`, {
        habitodo: habitodo
      })
      .then(res => {
        // todo currentDataを変更するだけで配列内も変更されそうだが、Vue.setを使う必要があった。consoleからcurrentDataを変更すると配列も反映されるが、ナゾ
        // todo switchDocはこの後に実行しなきゃという制限あるし、良い感じにしたい
        const idx = this.findIndex(res.data.uuid)
        Vue.set(this.habitodos, idx, res.data)
        this.switchDoc(res.data.uuid);
      })
      .catch(error => {
        console.log(error)
        alert(error.response.data.message)
      })
    },
    deleteData: function(uuid) {
      if (!confirm('本当に削除してもよろしいですか？')) {
        return;
      }
      HmAxios.delete(`/habitodos/${uuid}.json`)
        .then(_res => {
          this.habitodos = this.habitodos.filter(d => d.uuid != uuid);
        })
        .catch(error => {
          console.log(error)
        })
    },
    fetchData () {
      HmAxios.get('/habitodos/get_data.json')
        .then(res => {
          if (res.data.habitodos.length > 0) {
            this.habitodos = res.data.habitodos.map(ht => {
              // todo この2つをhabitodoオブジェクトの中に入れないようにしたい
              ht.isCurrent = false
              ht.unsaved = false
              return ht
            });
            this.switchDoc(this.habitodos[0].uuid)
          }
        })
        .catch(error => {
          console.log(error)
        });
    },

    //
    // これ以降使っていない。参考用
    //

    // 要素をスクロールに追従させる
    scrollableMokuji: function() {
      const headerHeight = document.getElementsByTagName('nav')[0].clientHeight
        + document.getElementById('habitodo-header').clientHeight;
      $(window).on('scroll', function() {
        if (window.scrollY > headerHeight) {
          $('#mokujis').css('top', window.scrollY - headerHeight);
        } else {
          $('#mokujis').css('top', 0);
        }
      });
    },
    // event.currentTargetのメモのため
    addHilightOnList: function(event) {
      // NOTE: event.targetにしてしまうと、子要素が対象になりうるので、イベント登録されている要素を取得するためにevent.currentTargetを指定する
      // 通常はthisでそれが取得できるようだが、ここでのthisはVueオブジェクトになってしまっていた
      $(event.currentTarget).addClass('hilight')
    },
    markdownTextAnotherPattern: function() {
      // これはブロック行の場合は「- 」のみ挿入して、そうでなければ改行など自分で挿入するパターン
      // このやり方だと「- 」が現在行に追加されてしまって下に空白行ができるだけになるはず
      if (window.getSelection().getRangeAt(0).endContainer.nodeType == 1) {
        document.execCommand('insertText', false, '- ');
      } else {
        // formatblockやinsertParagraphだと制御ができなさそうで、単純なタグ、文字の挿入で行うようにした
        // この後、Caretをひとつ上に戻す制御が必要
        document.execCommand('insertHTML', false, '<br>');
        document.execCommand('insertText', false, '- ');
        document.execCommand('insertHTML', false, '<br>');
      }

      // liを挿入するが、現在行をどうにかしたいので使えない
      //document.execCommand('insertUnorderedList');
      // これだと次の行からがpで囲まれるようになる。現在行をどうにかしたい
      //document.execCommand('formatblock', false, 'p');

      // 左キーを挿入したかったが動かず。Caret操作をやるしかない
      // const KEvent = new KeyboardEvent( "keydown", { keyCode: 37 });
      // document.getElementById(`editor-${id}`).dispatchEvent( KEvent );
    },
    // changeイベントを発生させるやり方
    setContentEditableChangeEvent: function() {
      $(".editor").each(function () {
        const $this = $(this);
        // NOTE: こういう変数って、ちゃんとイベント発生時にそれぞれ保持して比較できるんだな。クロージャか？
        const htmlOld = $this.html();
        // remove: blur,mouseup
        $this.on('keyup paste copy cut', function(e) {
          const htmlNew = $this.html();
          if (htmlOld !== htmlNew) {
            $this.trigger('change');
            htmlOld = htmlNew;
            vm.currentData.unsaved = true;
          }
        })
      });
    },
    getPosForContentEditable: function() {
      range = document.getSelection().getRangeAt(0);
      return {
        start: range.startOffset,
        end: range.endOffset
      };
    },
    // async, awaitをよく理解してないからか、とりあえずaxiosを使っておく
    // fetchの例として、Axiosに置き換えずに置いておこう
    getData_fetchVer: async function() {
      const response = await fetch('/habitodos/get_data');
      if (response.status != 200) {
        throw new Error();
      }
      // TODO: なんでjson()の結果がPromiseオブジェクトになってるんだろう
      const json = await response.json();
      return json.data;
    },
  }
})

})
