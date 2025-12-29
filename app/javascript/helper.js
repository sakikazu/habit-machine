// bootstrapがビューポート幅で表示を切り替えているので、それに合わせUserAgentではなくメディアクエリ関数でスマホを判別する
export function isSmartPhone() {
  if (window.matchMedia && window.matchMedia('(max-device-width: 640px)').matches) {
    return true;
  } else {
    return false;
  }
}

export function nl2br(str) {
  if (!str) { return ''; }
  str = str.replace(/\r\n/g, "<br>");
  str = str.replace(/(\n|\r)/g, "<br>");
  return str;
}

// lodashのメソッドの再現。そのものではないので動作の違いに注意
// イベントを呼び出し後、指定した時間が経過するまでは次のイベントを発生させない
// keydownやscrollなど頻発するイベントによって実行したい処理は、コストが高いので一定間隔で行うようにthrottleを使う
export function throttle(fn, interval) {
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
}

// lodashのメソッドの再現。そのものではないので動作の違いに注意
// イベントを呼び出し後、次のイベントまで指定した時間が経過するまではイベントを発生させない
// 待機中に再度イベント発生して実行されたら、タイマーをリセットしてまたそこから指定時間を待機する
// throttleと違って、イベントが頻発している最中は実行せず、それが落ち着いたときに実行するためのもの
export function debounce(fn, interval) {
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

// todo windowオブジェクトを扱うものは別のクラスにするとかしたい
export function moveCaret(baseContainer, offset) {
  const range = document.createRange();
  const sel = window.getSelection();
  range.setStart(baseContainer, offset);
  // これなくてもうまくいく。なんのため？Endを指定せずに範囲をStartにまとめるってこと？
  range.collapse(true);
  sel.removeAllRanges();
  sel.addRange(range);
  // これなくてもちゃんとフォーカスされるが？
  //el.focus();

  // todo これでもいける？
  // oContent = document.createRange();
  // oContent.selectNodeContents(oDoc.firstChild);

  // この一行だけでも何とか選択はできるが、文頭だったり文末だったりCaretの位置になるのが理解できてない
  // document.getSelection().collapse(el, nodesCount);
}

export function truncate(text, length) {
  if (!text || typeof text !== 'string') { return '' }
  if (text.length <= length) { return text }
  return text.substring(0, length) + '...'
}
