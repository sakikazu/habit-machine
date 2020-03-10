setCheckUnsavedEvent = function($form) {
  $form.data('unsaved', false);

  $form.find('input, textarea, select').on('change', function(){
    $form.data('unsaved', true);
  })

  $form.on('submit', function() {
    $form.data('unsaved', false);
  })
}

getUnsavedStatus = function() {
  var unsaved = false;
  $('form').each(function(idx, ele) {
    if ($(ele).data('unsaved')) {
      unsaved = true;
    }
  });
  return unsaved;
}

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

// Diaryのフォームのタグフィールドに選択したタグ名をトグルで追加/削除する
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

