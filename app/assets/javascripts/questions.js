$(document).on('turbolinks:load', function() {
  $('.edit-question-link').click(function(e) {
    e.preventDefault();

    var current  = $(this);
    var editForm = $('.edit-question');
    var question = $('.question');

    if (!current.hasClass('cancel')) {
      current.addClass('cancel');
      current.text('Cancel');
    } else {
      current.removeClass('cancel');
      current.text('Edit');
    }

    editForm.toggle();
    question.toggle();
  });

  addVoteActionAjaxEvents('.up-vote');
});


function addVoteActionAjaxEvents(selector) {
  $('.question').on('ajax:success', selector, function(event) {
    var detail = event.detail;
    var data = detail[0], status = detail[1], xhr = detail[2];

    // Updating flash
    var message = $('<div>', {
      'class': 'alert success',
      'text':  data.message
    });
    $('.flash').html(message);

    $('.vote-rating').html(data.rating);

    var current = $(this);
    replaceVoteLink(data.resource_id, current);
  });

  $('.question').on('ajax:error', function(event) {
    var detail = event.detail;
    var data = detail[0], status = detail[1], xhr = detail[2];

    // Updating flash
    var message = $('<div>', {
      'class': 'alert danger',
      'text':  xhr.responseText
    });
    $('.flash').html(message);
  });
}

function replaceVoteLink(id, elem) {
  var action, method, text;
  if (elem.hasClass('up-voted')) {
    elem.removeClass('up-voted');
    action = 'up_vote';
    method = 'post';
    text   = 'up vote';
  } else if (elem.hasClass('up-vote')) {
    elem.addClass('up-voted');
    action = 'delete_vote';
    method = 'delete';
    text   = 'delete vote';
  }
  var url = '/questions/' + id + '/' + action;
  console.log(url);
  elem.attr('href', url);
  elem.attr('data-method', method);
  elem.text(text);
}

