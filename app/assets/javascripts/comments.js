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

    // Update flash
    var message = $('<div>', {
      'class': 'alert success',
      'text':  data.message
    });
    $('.flash').html(message);
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

    addCommentListItem(commentData);
    hideNewCommentForm(commentable);

    var flash = $('<div>', {
      'class': 'alert success',
      'text':  data.message
    });
    $('.flash').html(flash);
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

    // Update flash
    var message = $('<div>', {
      'class': 'alert success',
      'text':  data.message
    });
    $('.flash').html(message);

  });
}

function handleFormAjaxErrorEvent(elem, selector) {
  $(elem).on('ajax:error', selector, function(event) {
    var detail   = event.detail;
    var messages = detail[0];

    var errors = buildErrorsContainer(messages);
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
    comments = $('<ul>', { 'class': '.comments-list' });
    commentable.find('.comments').html(comments);
  }
  var commentListItem = buildCommentListItem(commentData);
  comments.append(commentListItem);
}

function buildErrorsContainer(messages) {
  $('#errors').remove();
  var errorMessage = pluralize('error', messages.length, true) +
                     ' prohibited this resource from being saved:';
  var errors = $('<div>', {
    'id':    'errors',
    'class': 'alert',
    'text':  errorMessage
  });

  var errorsList = $('<ul>');
  messages.forEach(function(message) {
    errorsList.append(
      $('<li>', { 'text': message })
    );
  });
  errors.append(errorsList);
  return errors;
}

function buildCommentListItem(commentData) {
  var listItem = $('<li>', {
    'id': 'comment-' + commentData.id
  });

  var commentBody = $('<p>', {
    'class': 'comment-body'
  }).append(
    $('<span>', {
      'text': commentData.body
    })
  );

  var form  = buildEditCommentForm(commentData);
  var links = buildCommentItemLinks(commentData);

  listItem.append(commentBody, form, links);
  return listItem;
}

function buildEditCommentForm(commentData) {
  var form = $('<form>', {
    'class':  'edit-comment',
    'action': '/comments/' + commentData.id,
    'accept-charset': 'UTF-8',
    'data-remote':    true,
    'method': 'post',
  });

  var hiddenUTF = $('<input>', {
    'name':  'utf8',
    'type':  'hidden',
    'value': '\u2713'
  });

  var csrfToken = App.utils.getCSRF();
  var hiddenAuthenticityToken = $('<input>', {
    'type':  'hidden',
    'name':  'authenticity-token',
    'value': csrfToken
  });

  var hiddenMethod = $('<input>', {
    'type':  'hidden',
    'name':  '_method',
    'value': 'patch'
  });

  var bodyField = $('<div>', {
    'class': 'field',
  }).append(
    $('<textarea>', {
      'name':  'comment[body]',
      'text':  commentData.body
    })
  );

  var action = $('<div>', {
    'class': 'actions'
  }).append(
    $('<input>', {
      'type': 'submit',
      'name': 'commit',
      'value': 'Update Comment',
      'data-disable-with': 'Update Comment'
    })
  );

  form.append(hiddenUTF, hiddenMethod, hiddenAuthenticityToken, bodyField, action);
  return form;
}

function buildCommentItemLinks(commentData) {
  var links = $('<p>', {
    'text': ' | '
  });

  var editLink = $('<a>', {
    'class': 'edit-comment-link',
    'text':  'Edit',
    'data-comment-id': commentData.id,
    'href':  ''
  });

  var deleteLink = $('<a>', {
    'class': 'delete-comment-link',
    'data-remote': 'true',
    'rel':   'nofollow',
    'text':  'Delete',
    'data-method': 'delete',
    'href':  '/comments/' + commentData.id
  });

  links.prepend(editLink).append(deleteLink);
  return links;
}
