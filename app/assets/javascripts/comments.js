$(document).on('turbolinks:load', function() {
  handleCommentEvents(['.question', '.answers']);
});

function handleCommentEvents(elems) {
  elems.forEach(function(elem) {
    addNewCommentToggleEvent(elem);
    addEditCommentToggleEvent(elem);
    handleNewCommentAjaxEvents(elem);
    handleEditCommentAjaxEvents(elem);
    handleDeleteCommentAjaxEvent(elem);
  });
}

function addNewCommentToggleEvent(elem) {
  $(elem).on('click', '.new-comment-link', function(e) {
    e.preventDefault();

    var current         = $(this);
    var commentableId   = current.data('commentableId');
    var commentableType = current.data('commentableType');
    var commentable     = $('#' + commentableType + '-' + commentableId);
    var newForm         = commentable.find('.new-comment');

    toggleLink(current, 'Add comment');
    newForm.toggle();
  });
}

function addEditCommentToggleEvent(elem) {
  $(elem).on('click', '.edit-comment-link', function(e) {
    e.preventDefault();

    var current     = $(this);
    var commentId   = current.data('commentId');
    var comment     = $('#comment-' + commentId);
    var commentBody = comment.find('.comment-body');
    var editForm    = comment.find('.edit-comment');

    toggleLink(current, 'Edit');
    editForm.toggle();
    commentBody.toggle();
  });
}

function findComment(id) {
  return $('#comment-' + id);
}

function handleNewCommentAjaxEvents(elem) {
  handleNewCommentAjaxSuccessEvent(elem);
  handleFormAjaxErrorEvent(elem, '.new-comment');
}

function handleEditCommentAjaxEvents(elem) {
  handleEditCommentAjaxSuccessEvent(elem);
  handleFormAjaxErrorEvent(elem, '.edit-comment');
}

function handleDeleteCommentAjaxEvent(elem) {
  $(elem).on('ajax:success', '.delete-comment-link', function(event) {
    $('#errors').remove();

    var detail = event.detail;
    var data   = detail[0],
        status = detail[1],
        xhr    = detail[2];

    var commentData = data.comment;
    var comment = $('#comment-' + commentData.id);

    comment.remove();
    updateFlash('success', data.message);
  });
}

function handleNewCommentAjaxSuccessEvent(elem) {
  $(elem).on('ajax:success', '.new-comment', function(event) {
    $('#errors').remove();

    var detail = event.detail;
    var data   = detail[0],
        status = detail[1],
        xhr    = detail[2];

    var commentData     = data.comment;
    var commentableType = commentData.commentable_type.toLowerCase();
    var commentable     = $('#' + commentableType + '-' + commentData.commentable_id);

    var elem = findComment(commentData.id);
    if (!elem.length) {
      addCommentListItem(commentData);
    }
    hideNewCommentForm(commentable);
    updateFlash('success', data.message);
  });
}

function handleEditCommentAjaxSuccessEvent(elem) {
  $(elem).on('ajax:success', '.edit-comment', function(event) {
    $('#errors').remove();

    var detail = event.detail;
    var data   = detail[0],
        status = detail[1],
        xhr    = detail[2];

    var commentData = data.comment;
    var comment     = $('#comment-' + commentData.id);
    var commentText = comment.find('.comment-body span');

    commentText.html(commentData.body);
    hideEditCommentForm(comment);
    updateFlash('success', data.message);
  });
}

function handleFormAjaxErrorEvent(elem, selector) {
  $(elem).on('ajax:error', selector, function(event) {
    var detail   = event.detail;
    var messages = detail[0];

    var errors = App.utils.render("common/errors", { messages: messages });
    var form = $(this);
    form.prepend(errors);
  });
}

function hideNewCommentForm(commentableItem) {
  var newCommentForm  = commentableItem.find('.new-comment');
  var commentTextarea = newCommentForm.find('textarea[name="comment[body]"]');

  commentTextarea.val('');
  newCommentForm.hide();

  var newCommentLink = commentableItem.find('.new-comment-link');
  toggleLink(newCommentLink, 'Add comment');
}

function hideEditCommentForm(commentItem) {
  var commentBody     = commentItem.find('.comment-body');
  var editCommentForm = commentItem.find('.edit-comment');
  var editCommentLink = commentItem.find('.edit-comment-link');

  commentBody.show();
  editCommentForm.hide();
  toggleLink(editCommentLink, 'Edit');
}

function addCommentListItem(commentData) {
  var commentableType = commentData.commentable_type.toLowerCase();
  var commentable     = $('#' + commentableType + '-' + commentData.commentable_id);
  var comments        = commentable.find('.comments-list');
  if (!comments.length) {
    comments = $('<ul>', { 'class': 'comments-list' });
    commentable.find('.comments').html(comments);
  }
  var commentListItem = App.utils.render("comments/comment", commentData);
  comments.append(commentListItem);
}
