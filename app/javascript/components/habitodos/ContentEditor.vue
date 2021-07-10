<comment>
  updateMarkdownedBody()の実行タイミングとか、もっとうまくできそう
</comment>

<template lang="pug">
  // NOTE: min-height:100%にしておくと、contentEditableの要素に値がなくても、領域全部がクリッカブルになって編集可能
  .editor.min-h100(contentEditable=true :id="`editor-${habitodo.uuid}`" @keydown="handleKeyinput($event)" v-html="markdownedBody")
</template>

<script>
import Vue from 'vue'
import { debounce, moveCaret, nl2br } from 'helper.js'

export default {
  props: {
    habitodo: {
      type: Object,
      required: true,
    },
  },
  data () {
    return {
      checkUnsavedFunc: undefined,
      markdownedBody: '',
      originalTextContent: '',
    }
  },
  watch: {
    // TODO: switchDocの度に2回実行されているので修正する
    habitodo: {
      handler(newVal) {
        this.updateMarkdownedBody()
      },
      deep: true
    },
    // saveDataされた後はその内容でthis.originalTextContentを置き換えたいので、body変更時にそれを空にしておく
    'habitodo.body': function(newVal) {
      this.originalTextContent = ''
      this.updateMarkdownedBody()
    },
  },
  created () {
    this.checkUnsavedFunc = debounce(this.checkUnsaved, 1000)
  },
  mounted () {
    if (this.habitodo.isCurrent) {
      this.updateMarkdownedBody()
    }
  },
  methods: {
    moveCaret,
    handleKeyinput (event) {
      this.makeMarkdownableEditor(event)
      this.checkUnsavedFunc(event)
    },
    // 自然なのは、editor描画時に、箇条書き部分は<li>に変換すれば、insertUnorderedListだけで済むが、
    // 入れ子のliとかも、判定して変換するのは面倒くさいので、躊躇。あとtabで入れ子部分を制御しなきゃだしで、テキストのままいじる方が楽だな
    // NOTE: ここでnode.removeChild()すると、Undoで戻せないので使わないこと
    makeMarkdownableEditor (event) {
      if (![13, 9].includes(event.keyCode)) { return; }

      // caret位置の行の文字列を取得。startContainerでも基本的には良いだろうけど
      const currentLine = window.getSelection().getRangeAt(0).endContainer.data;
      const caretPosition = window.getSelection().getRangeAt(0).startOffset;

      if (!currentLine) { return; }

      // Enter押下時
      if (event.keyCode === 13) {
        // Caretが行末でなければ、<br>を挿入し、元々の改行時の動作であるパラグラフの追加は抑制する
        // パラグラフの追加は改行のコントロールがしづらいため、極力避ける
        if (caretPosition !== window.getSelection().getRangeAt(0).startContainer.length) {
          document.execCommand('insertHTML', false, '<br>');
          event.preventDefault();
          return;
        }

        // リストのテキストが空の場合は、そのリストを削除して改行
        if (currentLine.match(/^\s*\-\s*$/)) {
          // todo removeChildが使えなくなったので頓挫した
          //Vue.nextTick().then(function() {
            //let currentNode = window.getSelection().getRangeAt(0).startContainer;
            //const el = document.getElementById(`editor-${uuid}`);
            //// ブロックタグで囲まれていないtextの場合は、parentNodeがeditorになるので、そのままtextとして削除
            //if (currentNode.parentNode == el) {
            //  currentNode.parentNode.removeChild(currentNode);
            //} else {
            //  // todo ここのCaretの制御とか難しい・・hタグ直前でここが実行されると、hタグがなぜかコピーされてしまうし・・
            //  currentNode.parentNode.parentNode.removeChild(currentNode.parentNode);
            //  document.execCommand('insertParagraph');
            //}
            //event.preventDefault();
          //});
        } else if (currentLine.match(/^\s*\-\s/)) {
          // Caretを行の先頭に移動し、formatblockで現在行をpタグで囲む
          // その後、Caretを行の末尾に移動し、insertParagraphで改行して「- 」を挿入する
          Vue.nextTick().then(() => {
            this.moveCaret(window.getSelection().getRangeAt(0).startContainer, 0);
            document.execCommand('formatblock', false, 'p');
            this.moveCaret(window.getSelection().getRangeAt(0).startContainer, window.getSelection().getRangeAt(0).startContainer.length);

            // これは、現在行のタグ（pやdiv）にならって、次に同じタグを挿入する感じ
            document.execCommand('insertParagraph');
            document.execCommand('insertText', false, '- ');
          });

          // NOTE: contentEditableのdiv挿入が回避できる
          // リストの時は「- 」挿入タイミングを制御したいため、自動div挿入をキャンセルして、insertParagraphで明示的にブロックを入れている
          event.preventDefault();
          // NOTE: keydownイベントの時（keyupでは不可）、falseを返すと入力文字をキャンセルできる
          // preventDefaultの方だけでもいいかも・・
//          return false;
        } else if (currentLine.match(/^(#{1,5})\s/)) {
          // TODO: 条件式の中でconstつけて変数代入が怒られるようになったけど、こういうケースのうまい書き方は？
          const matched = currentLine.match(/^(#{1,5})\s/)
          Vue.nextTick().then(() => {
            const hTag = 'h' + matched[1].length;
            this.moveCaret(window.getSelection().getRangeAt(0).startContainer, 0);
            document.execCommand('formatblock', false, hTag);
            this.moveCaret(window.getSelection().getRangeAt(0).startContainer, window.getSelection().getRangeAt(0).startContainer.length);
          });

        } else {
          Vue.nextTick().then(() => {
            this.moveCaret(window.getSelection().getRangeAt(0).startContainer, 0);
            document.execCommand('formatblock', false, 'p');
            this.moveCaret(window.getSelection().getRangeAt(0).startContainer, window.getSelection().getRangeAt(0).startContainer.length);
            document.execCommand('insertParagraph');
            event.preventDefault();
          });
        }
      // tabキー
      } else if (!event.shiftKey && event.keyCode === 9) {
        if (currentLine.match(/^\s*\-\s/)) {
          Vue.nextTick().then(() => {
            this.moveCaret(window.getSelection().getRangeAt(0).startContainer, 0);
            document.execCommand('insertText', false, '    ');
            // 行の右端にCaretを移動
            this.moveCaret(window.getSelection().getRangeAt(0).startContainer, window.getSelection().getRangeAt(0).startContainer.length);
          });
          // タブの動作である次要素へのフォーカスをキャンセル
          event.preventDefault();
        }
      // shift+tabー、逆インデント
      } else if (event.shiftKey && event.keyCode === 9) {
        // ハイフン以前にスペースが4つ以上ある場合、その4つ分を削除する
        if (currentLine.match(/^\s{4,}\-\s/)) {
          // todo removeChildが使えなくなったため
          // Vue.nextTick().then(function() {
            // let currentNode = window.getSelection().getRangeAt(0).startContainer;
            // const replaceText = currentNode.data.replace(/^\s{4}/, '');
            // currentNode.parentNode.removeChild(currentNode);
            // document.execCommand('insertText', false, replaceText);
          // });
          event.preventDefault();
        }
      }
    },
    // 内容変更されたらフラグを立て、その変更がUndoなどでキャンセルされたらフラグを戻す
    // todo: 改行の変更の無視するのでどうにかしたいなー。それか、ただ変更されたかどうかの表示用途のみにして、保存ボタンは常時表示すればこのチェックでもいいな
    checkUnsaved: function(event) {
      if (!this.habitodo.body) {
        this.habitodo.unsaved = !!event.target.textContent
      // NOTE: textContentはDOMのテキストからタグも改行も除去したテキスト
      // this.habitodo.bodyの方は、他からのコピペなどでaタグとか入っている可能性があるので、そのタグをすべて除去しなければ比較はできない
      // スペースを入力したらなぜかnbspになって挿入されるのでスペースに変換する
      // 変換が煩雑なので、変更前のtextContentを保持しておき、それを比較するようにした
      //} else if (this.habitodo.body.replace(/\n/g, '').replace(/&nbsp;/g, ' ') !== event.target.textContent) {
      } else if (event.target.textContent !== this.originalTextContent) {
        this.habitodo.unsaved = true;
      } else {
        this.habitodo.unsaved = false;
      }
      this.$emit('updated', this.habitodo)
    },
    // todo computedでできれば良いんだけど、あれは引数が取れないのでやるならcurrentDataをまた使用するやり方になりそう
    // でもそれだと、切り替える度にデータが変更になってレンダリングされるのは変わらないので、パフォーマンスも変更ないか
    updateMarkdownedBody () {
      if (!this.habitodo.body) { return }

      const textArray = this.habitodo.body.split(/\r\n|\n|\r/);
      let newArray = [];
      textArray.forEach((t, idx) => {
        const matched = t.match(/^(#{1,5})/)
        if (matched) {
          const hTag = 'h' + matched[1].length;
          newArray.push(`<${hTag} id="${this.habitodo.uuid}-${idx}">${t}</${hTag}>`);
        } else {
          newArray.push(t + '\n');
        }
      });
      // 最後に無駄な改行コードが追加されてしまうので除去
      if (newArray[newArray.length - 1] === '\n') {
        newArray.pop();
      }
      const newText = nl2br(newArray.join(''));
      // todo ここで不思議なのは、一度contentEditableのテキストを変更後、switchDocで切り替えて戻ってきたときに、
      // 元のデータに置き換わってしまいそう（実際にnewTextは元のデータを示している）だが、実際には変更されたテキストがそのまま表示されている
      // v-htmlだからかcontentEditableだからか、明らかにしておきたい
      this.markdownedBody = newText

      Vue.nextTick().then(() => {
        // contentEditableで内容変更したときに、それとDB保存されている内容を比較するため、originalTextContentにDB保存されている内容でレンダリングしたtextContentを保持している
        // そうしないと、contentEditableで内容変更して、switchDocで切り替えて戻ったら変更した内容でtextContentが格納されてしまう
        if (!this.originalTextContent) {
          this.originalTextContent = this.$el.textContent
        }
      })
    },
  },
}
</script>

<style scoped lang="sass">
</style>
