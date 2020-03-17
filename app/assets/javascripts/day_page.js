// フォームデータの変更ステータスをフォームに記録しておく
setCheckUnsavedEvent = function($form) {
  $form.data('unsaved', false);

  $form.find('input, textarea, select').on('change', function(){
    $form.data('unsaved', true);
  })

  $form.on('submit', function() {
    $form.data('unsaved', false);
  })
}

// ページ内のすべてのフォームからデータ変更をチェック
getUnsavedStatus = function() {
  var unsaved = false;
  $('form').each(function(idx, ele) {
    if ($(ele).data('unsaved')) {
      unsaved = true;
    }
  });
  return unsaved;
}

// フォームが複数表示している場合、tabindexがかぶらないようにインクリメントする
// タイトルにフォーカスする
setTabIndexAndFocus = function($form) {
  tabidx += 1;
  $form.find("input[name='diary[title]']").attr("tabindex", tabidx);
  tabidx += 1;
  $form.find("textarea[name='diary[content]']").attr("tabindex", tabidx);
  tabidx += 1;
  $form.find("input[name='diary[tag_list]']").attr("tabindex", tabidx);
  tabidx += 1;
  $form.find("input[name='commit']").attr("tabindex", tabidx);

  $form.find("input[name='diary[title]']").focus();
}

// 編集をキャンセルするボタン押下時、
// そのフォームデータが変更されていれば確認メッセージを表示する
cancelEdit = function(event, diaryId) {
  $form = $(event.target).parents('.diary-wrapper').find('form');
  if ($form.data('unsaved')) {
    if(confirm(formWarningMessage) == false) {
      return;
    }
  }

  if (diaryId) {
    var wrapperId = $(event.target).parents('.diary-wrapper').attr('id');
    $.get('/diaries/' + diaryId + '/cancel?wrapperId=' + wrapperId);
  } else {
    $(event.target).parents('.diary-wrapper').remove();
  }
}

// Diaryのフォームのタグフィールドに、選択したタグ名をトグルで追加/削除する
toggleTag = function(event, tagname) {
  var $tag_input = $(event.target).parents('.diary-form').find('input[name="diary[tag_list]"]');
  var inputted_tags_string = $tag_input.val();
  if (inputted_tags_string.length == 0) {
    $tag_input.val(tagname);
    return
  }
  var inputted_tags = inputted_tags_string.split(/\s*,\s*/);
  var find_idx = inputted_tags.indexOf(tagname);
  if (find_idx > -1) {
    inputted_tags.splice(find_idx, 1);
  } else {
    inputted_tags.push(tagname);
  }
  $tag_input.val(inputted_tags.join(', '));
}

// ショートカットキー
// shift + < : 日戻し / shift + > : 日送り
const PREV_KEY = 188;
const NEXT_KEY = 190;
shortcutOfPagingLink = function(prev_class, next_class) {
  $(document).on('keydown', function(e) {
    if (!e.shiftKey) { return; }
    if (['INPUT', 'TEXTAREA', 'SELECT'].includes(e.target.tagName)) { return; }
    switch (e.which || e.keyCode) {
      case PREV_KEY:
        // NOTE: これが2019年版のクリックのさせ方らしい
        $('a.' + prev_class)[0].click();
        break;
      case NEXT_KEY:
        $('a.' + next_class)[0].click();
        break;
    }
  });
}

