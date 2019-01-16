$(document).on('turbolinks:load', function() {
  addToggleEditFormEvent();
  addToggleNewFormEvent();
  addCommentAjaxEvents(['.question', '.answers']);
});

function addToggleEditFormEvent() {
  $('.comments').on('click', '.edit-comment-link', function(e) {
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

function addToggleNewFormEvent() {
  $('.add-comment').on('click', '.new-comment-link', function(e) {
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

function toggleLink(link, name) {
  if (link.hasClass('cancel')) {
    link.removeClass('cancel');
    link.text(name);
  } else {
    link.addClass('cancel');
    link.text('Cancel');
  }
}

function addCommentAjaxEvents(selectors) {
  selectors.forEach(function(selector) {
    $(selector).on('ajax:success', '.edit-comment', function(event) {
      $('#errors').remove();

      var detail = event.detail;
      var data   = detail[0],
          status = detail[1],
          xhr    = detail[2];

      var commentData = data.commentData;
      var comment     = $('#comment-' + commentData.id);
      var commentBody = comment.find('.comment-body');
      commentBody.html(comment.body);

      // Update flash
      var message = $('<div>', {
        'class': 'alert success',
        'text':  data.message
      });
      $('.flash').html(message);

      // Fill form with new defalt input and hide
      var form = $(this);
      // var input = form.find('name="comment[body]"');
      // input.html(comment.body);
      form.hide();
      commentBody.show();
    });

    $(selector).on('ajax:error', '.edit-comment', function(event) {
      //$('#errors').remove();

      var detail = event.detail;
      var data   = detail[0],
          status = detail[1],
          xhr    = detail[2];

      var commentData = data.commentData;
      var comment     = $('#comment-' + commentData.id);
      var commentBody = comment.find('.comment-body');
      commentBody.html(comment.body);

      // Update flash
      var message = $('<div>', {
        'class': 'alert success',
        'text':  data.message
      });
      $('.flash').html(message);

      // Fill form with new defalt input and hide
      var form = $(this);
      // var input = form.find('name="comment[body]"');
      // input.html(comment.body);
      form.hide();
      commentBody.show();
    });

    $(selector).on('ajax:success', '.delete-comment-link', function(event) {
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
  });
}
