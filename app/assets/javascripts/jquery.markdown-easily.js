//
// esaのChromeエクステンションのソースを変更したもの
// fork from https://github.com/fukayatsu/esarea
//
// KNOWHOW: ソース中にノウハウをメモ
//
// # require
// - jquery.selection.js
//
// # key bindings
// - `Tab` / `Shift + Tab`
//   - indent / unindent
//     - multiline supported
//   - move to next/prev cell in table
// - `Enter` on the end of line
//   - suggest list
//   - suggest table
//     - `| foo | bar |<hit Enter here!>`
// - `Alt + Shift + Space`
//   - toggle tasklist status of current line
//     - tasklist: `- [x] foo`
//

var $, getCurrentLine, getPrevLine, handleEnterKey, handleSpaceKey, handleTabKey, replaceText;

const TAB_KEY = 9;
const ENTER_KEY = 13;
const SPACE_KEY = 32;

jQuery.fn.markdownEasily = function() {
  this.on('keydown', function(e) {
    switch (e.which || e.keyCode) {
      case TAB_KEY:
        handleTabKey(e);
        break;
      case ENTER_KEY:
        handleEnterKey(e);
        break;
      // tasklistのステータスのトグル機能は不要
      // case SPACE_KEY:
      //   handleSpaceKey(e);
    }
  });
}

//
// 元の仕様からの変更は、箇条書きスタイル以外の行の時には
// タブを元の動きのまま（入力フォーム移動）にすること
//
// # original features
// - `Tab` / `Shift + Tab`
//   - indent / unindent
//     - multiline supported
//   - move to next/prev cell in table
//
handleTabKey = function(e) {
  var currentLine, indentedText, newPos, pos, reindentedCount, reindentedText, text;
  currentLine = getCurrentLine(e);
  // 箇条書きスタイル以外の行の時には処理をスルー
  if (!currentLine.text.match(/^ *- /)) {
    return;
  }
  e.preventDefault();
  text = $(e.target).val();
  pos = $(e.target).selection('getPos');
  if (currentLine) {
    $(e.target).selection('setPos', {
      start: currentLine.start,
      end: currentLine.end
    });
  }
  if (e.shiftKey) {
    if (currentLine && currentLine.text.charAt(0) === '|') {
      newPos = text.lastIndexOf('|', pos.start - 1);
      if (newPos > 1) {
        newPos -= 1;
      }
      $(e.target).selection('setPos', {
        start: newPos,
        end: newPos
      });
    } else {
      reindentedText = $(e.target).selection().replace(/^ {1,4}/gm, '');
      reindentedCount = $(e.target).selection().length - reindentedText.length;
      replaceText(e.target, reindentedText);
      if (currentLine) {
        $(e.target).selection('setPos', {
          start: pos.start - reindentedCount,
          end: pos.start - reindentedCount
        });
      } else {
        $(e.target).selection('setPos', {
          start: pos.start,
          end: pos.start + reindentedText.length
        });
      }
    }
  } else {
    if (currentLine && currentLine.text.charAt(0) === '|') {
      newPos = text.indexOf('|', pos.start + 1);
      if ((newPos < 0) || (newPos === text.lastIndexOf('|', currentLine.end - 1))) {
        $(e.target).selection('setPos', {
          start: currentLine.end,
          end: currentLine.end
        });
      } else {
        $(e.target).selection('setPos', {
          start: newPos + 2,
          end: newPos + 2
        });
      }
    } else {
      indentedText = '    ' + $(e.target).selection().split("\n").join("\n    ");
      replaceText(e.target, indentedText);
      if (currentLine) {
        $(e.target).selection('setPos', {
          start: pos.start + 4,
          end: pos.start + 4
        });
      } else {
        $(e.target).selection('setPos', {
          start: pos.start,
          end: pos.start + indentedText.length
        });
      }
    }
  }
  return $(e.target).trigger('input');
};

handleEnterKey = function(e) {
  var caretTo, currentLine, i, indent, len, listMark, listMarkMatch, match, num, prevLine, ref, row;
  if (e.metaKey || e.ctrlKey || e.shiftKey) {
    return;
  }
  if (!(currentLine = getCurrentLine(e))) {
    return;
  }
  if (currentLine.start === currentLine.caret) {
    return;
  }
  if (match = currentLine.text.match(/^(\s*(?:-|\+|\*|\d+\.) (?:\[(?:x| )\] )?)\s*\S/)) {
    if (currentLine.text.match(/^(\s*(?:-|\+|\*|\d+\.) (?:\[(?:x| )\] ))\s*$/)) {
      $(e.target).selection('setPos', {
        start: currentLine.start,
        end: currentLine.end - 1
      });
      return;
    }
    e.preventDefault();
    listMark = match[1].replace(/\[x\]/, '[ ]');
    if (listMarkMatch = listMark.match(/^(\s*)(\d+)\./)) {
      indent = listMarkMatch[1];
      num = parseInt(listMarkMatch[2]);
      if (num !== 1) {
        listMark = listMark.replace(/\s*\d+/, "" + indent + (num + 1));
      }
    }
    replaceText(e.target, "\n" + listMark);
    caretTo = currentLine.caret + listMark.length + 1;
    $(e.target).selection('setPos', {
      start: caretTo,
      end: caretTo
    });
  } else if (currentLine.text.match(/^(\s*(?:-|\+|\*|\d+\.) )/)) {
    $(e.target).selection('setPos', {
      start: currentLine.start,
      end: currentLine.end
    });
  } else if (currentLine.text.match(/^.*\|\s*$/)) {
    if (currentLine.text.match(/^[\|\s]+$/)) {
      $(e.target).selection('setPos', {
        start: currentLine.start,
        end: currentLine.end
      });
      return;
    }
    if (!currentLine.endOfLine) {
      return;
    }
    e.preventDefault();
    row = [];
    ref = currentLine.text.match(/\|/g);
    for (i = 0, len = ref.length; i < len; i++) {
      match = ref[i];
      row.push("|");
    }
    prevLine = getPrevLine(e);
    if (!prevLine || (!currentLine.text.match(/---/) && !prevLine.text.match(/\|/g))) {
      replaceText(e.target, "\n" + row.join(' --- ') + "\n" + row.join('  '));
      $(e.target).selection('setPos', {
        start: currentLine.caret + 6 * row.length - 1,
        end: currentLine.caret + 6 * row.length - 1
      });
    } else {
      replaceText(e.target, "\n" + row.join('  '));
      $(e.target).selection('setPos', {
        start: currentLine.caret + 3,
        end: currentLine.caret + 3
      });
    }
  }
  return $(e.target).trigger('input');
};

//
// Alt + Shift + Space: tasklistのステータスのトグル
//
handleSpaceKey = function(e) {
  var checkMark, currentLine, match, replaceTo;
  if (!(e.shiftKey && e.altKey)) {
    return;
  }
  if (!(currentLine = getCurrentLine(e))) {
    return;
  }
  // KNOWHOW: 任意のマッチ文字列を取得する正規表現が参考になる
  if (match = currentLine.text.match(/^(\s*)(-|\+|\*|\d+\.) (?:\[(x| )\] )(.*)/)) {
    // KNOWHOW: 処理が確定した時のみ、元操作をキャンセルする
    e.preventDefault();
    checkMark = match[3] === ' ' ? 'x' : ' ';
    replaceTo = "" + match[1] + match[2] + " [" + checkMark + "] " + match[4];
    // 置換前に対象文字列を選択状態にする
    $(e.target).selection('setPos', {
      start: currentLine.start,
      end: currentLine.end
    });
    replaceText(e.target, replaceTo);
    // 置換後は選択状態をキャンセルして元のキャレット位置に戻す
    $(e.target).selection('setPos', {
      start: currentLine.caret,
      end: currentLine.caret
    });
    // KNOWHOW: どういう意味がある？
    return $(e.target).trigger('input');
  }
};

getCurrentLine = function(e) {
  var endPos, pos, startPos, text;
  text = $(e.target).val();
  pos = $(e.target).selection('getPos');
  if (!text) {
    return null;
  }
  // 文字列選択状態の時はスルー
  if (pos.start !== pos.end) {
    return null;
  }
  startPos = text.lastIndexOf("\n", pos.start - 1) + 1;
  endPos = text.indexOf("\n", pos.start);
  if (endPos === -1) {
    endPos = text.length;
  }
  return {
    text: text.slice(startPos, endPos),
    start: startPos,
    end: endPos,
    caret: pos.start,
    endOfLine: !$.trim(text.slice(pos.start, endPos))
  };
};

getPrevLine = function(e) {
  var currentLine, endPos, startPos, text;
  currentLine = getCurrentLine(e);
  text = $(e.target).val().slice(0, currentLine.start);
  startPos = text.lastIndexOf("\n", currentLine.start - 2) + 1;
  endPos = currentLine.start;
  return {
    text: text.slice(startPos, endPos),
    start: startPos,
    end: endPos
  };
};

// 置換対象文字列を選択状態にして呼ばれる
replaceText = function(target, str) {
  var e, expectedLen, fromIdx, inserted, pos, toIdx, value;
  pos = $(target).selection('getPos');
  fromIdx = pos.start;
  toIdx = pos.end;
  inserted = false;
  if (str) {
    expectedLen = target.value.length - Math.abs(toIdx - fromIdx) + str.length;
    target.focus();
    target.selectionStart = fromIdx;
    target.selectionEnd = toIdx;
    try {
      // KNOWHOW: このやり方でテキスト入力することで、Undo, Redoを可能にできる
      inserted = document.execCommand('insertText', false, str);
    } catch (_error) {
      e = _error;
      inserted = false;
    }
    if (inserted && (target.value.length !== expectedLen || target.value.substr(fromIdx, str.length) !== str)) {
      inserted = false;
    }
  }
  // KNOWHOW: 例外時にUndoで戻し
  if (!inserted) {
    try {
      document.execCommand('ms-beginUndoUnit');
    } catch (_error) {
      e = _error;
    }
    value = target.value;
    target.value = '' + value.substring(0, fromIdx) + str + value.substring(toIdx);
    try {
      document.execCommand('ms-endUndoUnit');
    } catch (_error) {
      e = _error;
    }
  }
  // KNOWHOW: return時になぜこれをやるのか不明？？
  return $(target).trigger('blur').trigger('focus');
};

