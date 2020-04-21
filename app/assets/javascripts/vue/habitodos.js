const vm = new Vue({
  el: '#habitodo',
  data: {
    habitodos: [],
    mokuji: [],
    newTitle: '',
    searchWord: '',
    searchResult: [],
    searchBtnColor: '',
    checkUnsavedFunc: undefined,
  },
  created: function () {
    console.log('created');

    this.checkUnsavedFunc = this.debounce(this.checkUnsaved, 1000);
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
          this.showDoc(this.habitodos[0].uuid);
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
  // Vue: methodsでやる場合と違い、引数が取れないが、キャッシュしてくれるので、ReadOnlyならこっち使う
  computed: {
    // todo 削除
    filteredProjects: function () {
      const reg = new RegExp(this.filterWord);
      return this.projects.filter(p => p.name.match(reg) != null);
    }
  },
  methods: {
    findData: function(uuid) {
      const idx = this.habitodos.findIndex(h => h.uuid === uuid);
      return { idx: idx, data: this.habitodos[idx] };
    },
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
          this.searchResult.push({ 'docId': d.uuid, 'text': '[' + d.title + ']', 'rows': 0 });
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
              this.searchResult.push({ 'docId': d.uuid, 'text': '[' + d.title + '] ' + line, 'rows': idx + 1 });
            }
          });
        }
      });
      this.searchBtnColor = '';
    },
    selectFoundData: function(uuid, rows) {
      this.showDoc(uuid);
      Vue.nextTick().then(function() {
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
    // hタグは目次として抽出
    // todo これもcurrentData運用すればcomputedにできるなあ
    // todo htmlで見なくとも、文字列で「#」を見れば、nextTickなしにいける、けどbodyは双方向じゃないので、最新のデータをどう取得するか
    buildMokuji: function(uuid) {
      // NOTE: DOMにアクセスする処理はすべてnextTick内で行うこと
      // また、これをやったからといって、この後の処理はDOM構築後というわけではないので、都度、囲む
      Vue.nextTick().then(function() {
        // nextTick内のthisはWindowオブジェクトだった
        vm.mokuji = [];
        // htmlタグを評価するのでhtmlを取得する。改行は含まず1行で取得されるので注意
        text = document.getElementById(`editor-${uuid}`).innerHTML;
        // まずはすべてのhタグ要素を取得して、それぞれからidとtextを取得する
        // 「g」オプションだとマッチしたものが配列になって返却されるが、カッコのキャプチャは使えなくなった
        if (matched = text.match(/\<h\d\ id="(\d+)"\>(.+?)\<\/h\d\>/g)) {
          //console.log(matched);
          matched.forEach(d => {
            if (matched2 = d.match(/\<h\d\ id="(\d+)"\>(.+?)\<\/h\d\>/)) {
              vm.mokuji.push({ text: matched2[2], anchor: matched2[1] });
            }
          });
        }
      });
    },
    // todo computedでできれば良いんだけど、あれは引数が取れないのでやるならcurrentDataをまた使用するやり方になりそう
    // でもそれだと、切り替える度にデータが変更になってレンダリングされるのは変わらないので、パフォーマンスも変更ないか
    updateMarkdownedBody: function(uuid) {
      const found = this.findData(uuid);
      if (!found.data.body) {
        return;
      }
      textArray = found.data.body.split(/\r\n|\n|\r/);
      newArray = [];
      textArray.forEach((t, idx) => {
        if (matched = t.match(/^(#{1,5})/)) {
          const hTag = 'h' + matched[1].length;
          newArray.push('<' + hTag + ' id="' + idx + '">' + t + '</' + hTag + '>');
        } else {
          newArray.push(t + '\n');
        }
      });
      // 最後に無駄な改行コードが追加されてしまうので除去
      if (newArray[newArray.length - 1] === '\n') {
        newArray.pop();
      }
      newText = this.nl2br(newArray.join(''));
      // todo ここで不思議なのは、一度contentEditableのテキストを変更後、showDocで切り替えて戻ってきたときに、
      // 元のデータに置き換わってしまいそう（実際にnewTextは元のデータを示している）だが、実際には変更されたテキストがそのまま表示されている
      // v-htmlだからかcontentEditableだからか、明らかにしておきたい
      found.data.markdownedBody = newText;

      Vue.nextTick().then(function() {
        // DB保存されている内容でレンダリングしたtextContentを保持しておきたいので、最初だけ格納する
        // そうしないと、contentEditableで内容変更して、showDocで切り替えて戻ったら変更した内容でtextContentが格納されてしまうのでOriginalにはならない
        if (!found.data.originalTextContent) {
          found.data.originalTextContent = document.getElementById(`editor-${uuid}`).textContent;
          Vue.set(vm.habitodos, found.idx, found.data);
        }
      });
    },
    nl2br: function(str) {
      if (!str) { return ''; }
      str = str.replace(/\r\n/g, "<br>");
      str = str.replace(/(\n|\r)/g, "<br>");
      return str;
    },
    showDoc: function(uuid) {
      this.habitodos = this.habitodos.map(ht => {
        ht.isCurrent = false;
        return ht;
      })
      const found = this.findData(uuid);
      found.data.isCurrent = true;
      this.updateMarkdownedBody(uuid);
      this.buildMokuji(uuid);
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
    handleKeyinput: function(event, uuid) {
      this.makeMarkdownableEditor(event, uuid);
      this.checkUnsavedFunc(event, uuid);
    },
    // 自然なのは、editor描画時に、箇条書き部分は<li>に変換すれば、insertUnorderedListだけで済むが、
    // 入れ子のliとかも、判定して変換するのは面倒くさいので、躊躇。あとtabで入れ子部分を制御しなきゃだしで、テキストのままいじる方が楽だな
    // NOTE: ここでnode.removeChild()すると、Undoで戻せないので使わないこと
    makeMarkdownableEditor: function(event, uuid) {
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
          Vue.nextTick().then(function() {
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, 0);
            document.execCommand('formatblock', false, 'p');
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, window.getSelection().getRangeAt(0).startContainer.length);

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
        } else if (matched = currentLine.match(/^(#{1,5})\s/)) {
          Vue.nextTick().then(function() {
            const hTag = 'h' + matched[1].length;
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, 0);
            document.execCommand('formatblock', false, hTag);
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, window.getSelection().getRangeAt(0).startContainer.length);
          });

        } else {
          Vue.nextTick().then(function() {
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, 0);
            document.execCommand('formatblock', false, 'p');
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, window.getSelection().getRangeAt(0).startContainer.length);
            document.execCommand('insertParagraph');
            event.preventDefault();
          });
        }
      // tabキー
      } else if (!event.shiftKey && event.keyCode === 9) {
        if (currentLine.match(/^\s*\-\s/)) {
          Vue.nextTick().then(function() {
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, 0);
            document.execCommand('insertText', false, '    ');
            // 行の右端にCaretを移動
            vm.moveCaret(window.getSelection().getRangeAt(0).startContainer, window.getSelection().getRangeAt(0).startContainer.length);
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
    // 内容変更されたらフラグを立て、その変更がUndoなどでキャンセルされたらフラグを戻す
    // todo: 改行の変更の無視するのでどうにかしたいなー。それか、ただ変更されたかどうかの表示用途のみにして、保存ボタンは常時表示すればこのチェックでもいいな
    checkUnsaved: function(event, uuid) {
      const found = this.findData(uuid);
      if (!found.data.body) {
        found.data.unsaved = event.target.textContent ? true : false;
      // NOTE: textContentはタグも改行も除去したテキスト
      // found.data.bodyの方は、他からのコピペなどでaタグとか入っている可能性があるので、そのタグをすべて除去しなければ比較はできない
      // スペースを入力したらなぜかnbspになって挿入されるのでスペースに変換する
      // 変換が煩雑なので、変更前のtextContentを保持しておき、それを比較するようにした
      //} else if (found.data.body.replace(/\n/g, '').replace(/&nbsp;/g, ' ') !== event.target.textContent) {
      } else if (event.target.textContent !== found.data.originalTextContent) {
        found.data.unsaved = true;
      } else {
        found.data.unsaved = false;
      }
      Vue.set(this.habitodos, found.idx, found.data);
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
    saveData: function(uuid) {
      // NOTE: これをやるには、bodyがv-modelである必要があるが、contentEditableとv-modelは特別なことをしなければ併用できないとのエラーが出る
      // data = this.currentData.body
      // NOTE: innerTextは、h1やpなどタグが存在すると、間に改行の行を一つはさむようにして勝手に改行が挿入されたものが取得されてしまう。ので使えない
      // data = document.getElementById(`editor-${id}`).innerText;
      // Nodeでいじった方が楽という可能性はある
      data = document.getElementById(`editor-${uuid}`).innerHTML
        // contentEditableによってdivで囲まれたbrが入るので、先にそれを改行に変換
        .replace(/\<div\>\<br\>\<\/div\>/g, '\n')
        // hとdivとpの開始タグを除去
        .replace(/\<h\d.*?\>|\<div\>|\<p\>/g, '')
        // spanを除去
        .replace(/\<\/?span.*?\>/g, '')
        // hとdivとpの終了タグと、brタグを改行に変換
        .replace(/\<\/h\d\>|\<\/div\>|\<\/p\>|\<br\>/g, '\n')
      $.ajax({
        type: 'PUT',
        url: '/habitodos/' + uuid,
        data: { habitodo: { 'body' : data } },
        success: function(res) {
          console.log(res);
          // todo currentDataを変更するだけで配列内も変更されそうだが、Vue.setを使う必要があった。consoleからcurrentDataを変更すると配列も反映されるが、ナゾ
          // todo showDocはこの後に実行しなきゃという制限あるし、良い感じにしたい
          const found = vm.findData(res.data.uuid);
          Vue.set(vm.habitodos, found.idx, res.data);
          vm.showDoc(res.data.uuid);
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
    deleteData: function(uuid) {
      if (!confirm('本当に削除してもよろしいですか？')) {
        return;
      }
      $.ajax({
        type: 'DELETE',
        url: '/habitodos/' + uuid,
        success: function(_res) {
          vm.habitodos = vm.habitodos.filter(d => d.uuid != uuid);
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
    },
    // todo mixinに移動する。lodashのメソッドの再現。そのものではないので動作の違いに注意
    // イベントを呼び出し後、指定した時間が経過するまでは次のイベントを発生させない
    // keydownやscrollなど頻発するイベントによって実行したい処理は、コストが高いので一定間隔で行うようにthrottleを使う
    throttle: function(fn, interval) {
      const context = this;
      // クロージャ(Closure)の例。lastTimeが固定されている
      let lastTime = Date.now() - interval;
      return function() {
        const args = arguments;
        if ((lastTime + interval) < Date.now()) {
          lastTime = Date.now();
          fn.apply(context, args);
        }
      }
    },
    // todo mixinに移動する。lodashのメソッドの再現。そのものではないので動作の違いに注意
    // イベントを呼び出し後、次のイベントまで指定した時間が経過するまではイベントを発生させない
    // 待機中に再度イベント発生して実行されたら、タイマーをリセットしてまたそこから指定時間を待機する
    // throttleと違って、イベントが頻発している最中は実行せず、それが落ち着いたときに実行するためのもの
    debounce: function(fn, interval) {
      // todo ここのthisはVueだけど、それでいいのか？thisを渡す理由を理解しないとわからんな
      const context = this;
      let timer;
      return function() {
        clearTimeout(timer);
        const args = arguments;
        timer = setTimeout(function() {
          // todo bind, call, applyのどれを使えばいいかとかthisの意味とかアロー関数についてしっかり理解しなければ
          fn.apply(context, args);
        }, interval);
      };
    }
  }
});

