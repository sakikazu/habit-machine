const vm = new Vue({
  el: '#habitodo',
  data: {
    habitodos: [],
    mokuji: [],
    newTitle: '',
    searchWord: '',
    searchResult: [],
    searchBtnColor: '',
  },
  created: function () {
    console.log('created');
    this.getData()
      .then(res => {
        // NOTE: この中のthisはVueオブジェクトになっている
        if (res.length > 0) {
          this.habitodos = res.map(ht => {
            ht.markdownedBody = '';
            ht.isCurrent = false;
            ht.unsaved = false;
            return ht;
          });
          this.showDoc(this.habitodos[0].id);
        }
      })
      .catch(e => {
        console.log(e);
      });
  },
  mounted: function () {
    console.log('mounted');

    $('nav.navbar').removeClass('mb20');
    $('footer').css('margin-top', 0);
    this.setMinHeight();
    this.scrollableMokuji();
    this.setConfirmUnsavingEvent();

    // NOTE: Enter押下時の挿入タグをbrに変更したかったが、デフォルトのdivになってしまう。pに変更はできるので、brがダメなんだろう
    //document.execCommand("DefaultParagraphSeparator", false, "br");

    //$(this.$el).find('#editor').markdownEasily();
  },
  updated: function() {
  },
  computed: {
    filteredProjects: function () {
      const reg = new RegExp(this.filterWord);
      return this.projects.filter(p => p.name.match(reg) != null);
    }
  },
  methods: {
    preSearchData: function() {
      if (!this.searchWord) {
        this.searchBtnColor = '';
        return;
      }
      exists = this.habitodos.some(d => {
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
          this.searchResult.push({ 'docId': d.id, 'text': '[' + d.title + ']', 'rows': 0 });
        }
        if (!d.body) {
          // forEach内でcontinueしたい時はreturnを使う
          return;
        }
        // bodyにマッチの場合は、行ごとに検索していく
        if (d.body.match(new RegExp(this.searchWord))) {
          lines = d.body.split(/\r\n|\n|\r/);
          lines.forEach((line, idx) => {
            if (line.match(new RegExp(this.searchWord))) {
              this.searchResult.push({ 'docId': d.id, 'text': '[' + d.title + '] ' + line, 'rows': idx + 1 });
            }
          });
        }
      });
      this.searchBtnColor = '';
    },
    selectFoundData: function(id, rows) {
      this.showDoc(id);
      Vue.nextTick().then(function() {
        // caretを指定行に移動
        const el = document.getElementById(`editor-${id}`);
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
        vm.moveCaret(el.childNodes[nodesCount], 0);

        // Caretの位置にScrollを移動
        // todo まだ位置が不安定
        const rootOffsetTop = $(vm.$el).offset().top;
        console.log(rootOffsetTop);
        // todo なぜこれはundefined？jqueryのoffset().topだと取得できた
        //console.log(document.getSelection().getRangeAt(0).startContainer.offsetTop);
        const offsetTop = $(document.getSelection().getRangeAt(0).startContainer).offset().top + rootOffsetTop;
        console.log(offsetTop);
        scrollTo({ top: offsetTop, behavior: "smooth" });
      });
    },
    buildMokuji: function(id) {
      vm.mokuji = [];
      // htmlタグを評価するのでhtmlを取得する
      text = document.getElementById(`editor-${id}`).innerHTML;
      textArray = text.split(/\r\n|\n|\r/);
      textArray.forEach(t => {
        // 「g」オプションだとマッチしたものが配列になって返却されるが、カッコのキャプチャは使えなくなった
        if (matched = t.match(/\<h\d\ id="(\d+)"\>(.+?)\<\/h\d\>/g)) {
          //console.log(matched);
          if (matched.length > 0) {
            matched.forEach(d => {
              if (matched2 = d.match(/\<h\d\ id="(\d+)"\>(.+?)\<\/h\d\>/)) {
                vm.mokuji.push({ text: matched2[2], anchor: matched2[1] });
              }
            });
          }
        }
      });
    },
    updateMarkdownedBody: function(id) {
      idx = this.habitodos.findIndex(h => h.id == id);
      if (!this.habitodos[idx].body) {
        return;
      }
      textArray = this.habitodos[idx].body.split(/\r\n|\n|\r/);
      newArray = [];
      textArray.forEach((t, idx) => {
        if (t.match(/^#{4}/)) {
          newArray.push('<h4 id="' + idx + '">' + t + '</h4>');
        } else if (t.match(/^#{3}/)) {
          newArray.push('<h3 id="' + idx + '">' + t + '</h3>');
        } else if (t.match(/^#{2}/)) {
          newArray.push('<h2 id="' + idx + '">' + t + '</h2>');
        } else if (t.match(/^#{1}/)) {
          newArray.push('<h1 id="' + idx + '">' + t + '</h1>');
        } else {
          newArray.push(t + '\n');
        }
      });
      newText = this.nl2br(newArray.join(''));
      this.habitodos[idx].markdownedBody = newText;
      //Vue.set(this.habitodos, idx, habitodos[idx]);
    },
    nl2br: function(str) {
      if (!str) { return ''; }
      str = str.replace(/\r\n/g, "<br>");
      str = str.replace(/(\n|\r)/g, "<br>");
      return str;
    },
    showDoc: function(id) {
      this.habitodos = this.habitodos.map(ht => {
        ht.isCurrent = false;
        return ht;
      })
      habitodo = this.habitodos.find(h => h.id == id);
      habitodo.isCurrent = true;
      this.updateMarkdownedBody(id);
      // NOTE: DOMにアクセスする処理はすべてnextTick内で行うこと
      // また、これをやったからといって、この後の処理はDOM構築後というわけではないので、都度、囲む
      Vue.nextTick().then(function() {
        // nextTick内のthisはWindowオブジェクトだった
        vm.buildMokuji(id);
      });
    },
    addHilightOnList: function(event) {
      // NOTE: event.targetにしてしまうと、子要素が対象になりうるので、イベント登録されている要素を取得するためにevent.currentTargetを指定する
      // 通常はthisでそれが取得できるようだが、ここでのthisはVueオブジェクトになってしまっていた
      $(event.currentTarget).addClass('hilight');
    },
    removeHilightOnList: function(event) {
      $(event.currentTarget).removeClass('hilight')
    },
    // コンテンツの最低の高さをWindowに合わせる
    setMinHeight: function() {
      const otherHeight = document.getElementsByTagName('nav')[0].clientHeight
        + document.getElementsByTagName('footer')[0].clientHeight
        + document.getElementById('habitodo-header').clientHeight;
      const editorMinHeight = window.innerHeight - otherHeight;
      // NOTE: heightではなく、minHeightを設定するのがコツ。コンテンツ長が足りないページのみ適用してくれるから。
      //       heightを変更するとコンテンツ長に応じたheightが取得できなくなり、うまくいかなかった
      // NOTE: '#editor'のheightをいじろうとすると、v-ifの要素となっているのでDOMが見つからない。nextTickを入れてもダメだった。間違えやすいので注意
      document.getElementById('habitodo-body').style.minHeight = editorMinHeight + 'px'
    },
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
    handleKeyinput: function(event, id) {
      this.markdownText(event, id);
      this.checkUnsaved(event, id);
    },
    // 自然なのは、editor表示時に、箇条書き部分は<li>に変換すれば、insertUnorderedListだけで済むが、
    // 入れ子のliとかも、判定して変換するのは面倒くさいので、躊躇。あとtabで入れ子部分を制御しなきゃだしで、テキストのままいじる方が楽だな
    markdownText: function(event, id) {
      if (![13, 9].includes(event.keyCode)) { return; }
      if (event.keyCode === 13) {
        // caret位置の行の文字列を取得。startContainerでも基本的には良いだろうけど
        const currentLine = window.getSelection().getRangeAt(0).endContainer.data;
        const caretPosition = window.getSelection().getRangeAt(0).startOffset;
        // Caretが行の先頭の場合は処理せずにそのまま改行
        if (caretPosition > 0 && currentLine && currentLine.match(/^\s*\- /)) {
          // Caretを行の先頭に移動し、formatblockで現在行をpタグで囲む
          // その後、Caretを行の末尾に移動し、insertParagraphで改行して「- 」を挿入する
          Vue.nextTick().then(function() {
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, 0);
            document.execCommand('formatblock', false, 'p');
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, window.getSelection().getRangeAt(0).startContainer.length);

            // これは、現在行のタグ（pやdiv）にならって、次に同じタグを挿入する感じ
            document.execCommand('insertParagraph');
            document.execCommand('insertText', false, '- ');
          });

          // NOTE: contentEditableのdiv挿入が回避できる
          event.preventDefault();
          // NOTE: keydownイベントの時（keyupでは不可）、falseを返すと入力文字をキャンセルできる
          // preventDefaultの方だけでもいいかも・・
          return false;
        }
      // tabキー
      // todo shift+tabも対応
      } else if (event.keyCode === 9) {
        let currentLine = window.getSelection().getRangeAt(0).endContainer.data;
        if (currentLine && currentLine.match(/^\s*\- /)) {
          Vue.nextTick().then(function() {
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, 0);
            document.execCommand('insertText', false, '    ');
            // 行の右端にCaretを移動
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, window.getSelection().getRangeAt(0).startContainer.length);
          });
          event.preventDefault();
        }
      }
    },
    moveCaret: function(baseContainer, offset) {
      const range = document.createRange();
      const sel = window.getSelection();
      range.setStart(baseContainer, offset);
      // これなくてもうまくいく。なんのため？Endを指定せずに範囲をStartにまとめるってこと？
      range.collapse(true);
      sel.removeAllRanges();
      sel.addRange(range);
      // これなくてもちゃんとフォーカスされるが？
      //el.focus();

      // この一行だけでも何とか選択はできるが、文頭だったり文末だったりCaretの位置になるのが理解できてない
      // document.getSelection().collapse(el, nodesCount);
    },
    // 使ってない参考用
    markdownTextAnotherPattern: function() {
      // これはブロック行の場合は「- 」のみ挿入して、そうでなければ改行など自分で挿入するパターン。何かダメだったけ？
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
    checkUnsaved: function(event, id) {
      idx = this.habitodos.findIndex(h => h.id == id);
      habitodo = this.habitodos[idx];
      if (!habitodo.body) {
        if (event.target.textContent) {
          habitodo.unsaved = true;
        } else {
          habitodo.unsaved = false;
        }
      // NOTE: textContentはタグも改行も除去したテキスト
      } else if (habitodo.body.replace(/\n/g, '') !== event.target.textContent) {
        habitodo.unsaved = true;
      } else {
        habitodo.unsaved = false;
      }
      Vue.set(this.habitodos, idx, habitodo);
    },
    // 未使用。changeイベントを発生させるやり方
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
      return this.habitodos.some(d => d.unsaved == true ) ? true : false;
    },
    // 使ってない。参考用
    getPosForContentEditable: function() {
      range = document.getSelection().getRangeAt(0);
      return {
        start: range.startOffset,
        end: range.endOffset
      };
    },
    saveData: function(id) {
      // NOTE: これをやるには、bodyがv-modelである必要があるが、contentEditableとv-modelは特別なことをしなければ併用できないとのエラーが出る
      // data = this.currentData.body
      // NOTE: innerTextは、h1やpなどタグが存在すると、間に改行の行を一つはさむようにして勝手に改行が挿入されたものが取得されてしまう。ので使えない
      // data = document.getElementById(`editor-${id}`).innerText;
      data = document.getElementById(`editor-${id}`).innerHTML
        // hとdivとpの開始タグを除去
        .replace(/\<h\d.*?\>|\<div\>|\<p\>/g, '')
        // spanを除去
        .replace(/\<\/?span.*?\>/g, '')
        // hとdivとpの終了タグと、brタグを改行に変換
        .replace(/\<\/h\d\>|\<\/div\>|\<\/p\>|\<br\>/g, '\n')
      //debugger
      $.ajax({
        type: 'PUT',
        url: '/habitodos/' + id,
        data: { habitodo: { 'body' : data } },
        success: function(res) {
          console.log(res);
          // todo currentDataを変更するだけで配列内も変更されそうだが、Vue.setを使う必要があった。consoleからcurrentDataを変更すると配列も反映されるが、ナゾ
          // todo showDocはこの後に実行しなきゃという制限あるし、良い感じにしたい
          idx = vm.habitodos.findIndex(h => h.id == res.data.id);
          Vue.set(vm.habitodos, idx, res.data);
          vm.showDoc(res.data.id);
        }
      });
    },
    createData: function () {
      if (!this.newTitle) {
        return;
      }
      $.ajax({
        type: 'POST',
        url: '/habitodos',
        data: { habitodo: { 'title' : this.newTitle } },
        success: function(res) {
          console.log(res);
          vm.habitodos.push(res.data);
          vm.newTitle = '';
        }
      });
    },
    deleteData: function(id) {
      if (!confirm('本当に削除してもよろしいですか？')) {
        return;
      }
      $.ajax({
        type: 'DELETE',
        url: '/habitodos/' + id,
        success: function(_res) {
          vm.habitodos = vm.habitodos.filter(d => d.id != id);
        }
      });
    },
    getData: async function() {
      const response = await fetch('/habitodos/get_data');
      if (response.status != 200) {
        throw new Error();
      }
      // TODO: なんでjson()の結果がPromiseオブジェクトになってるんだろう
      const json = await response.json();
      return json.data;
    }
  }
});

