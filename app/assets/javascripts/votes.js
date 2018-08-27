$(document).on('turbolinks:load', function() {
  addVoteActionAjaxEvents('.question');
});

function addVoteActionAjaxEvents(selector) {
  $(selector).on('ajax:success', '.vote', function(event) {
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
    replaceVoteLink(data.resource_id, data.type, current);
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

function replaceVoteLink(id, type, elem) {
  var link;
  if (elem.hasClass('up-vote') || elem.hasClass('down-vote')) {
    link = createDeleteVoteLink(id, type, elem);
  } else if (elem.hasClass('down-voted')) {
    link = createDownVoteLink(id, type);
  } else if (elem.hasClass('up-voted')) {
    link = createUpVoteLink(id, type);
  }
  elem.replaceWith(link);
}

function createDeleteVoteLink(id, type, elem) {
  var href = type + '/' + id + '/delete_vote';
  var css_class = elem.hasClass('up-vote') ? 'up-voted' : 'down-voted';
  var link = $('<a>', {
    'href':  href,
    'class': css_class,
    'text':  'delete vote',
    'data-method': 'delete',
    'data-remote': true,
  });
  return link;
}

function createDownVoteLink(id, type) {
  var href = type + '/' + id + '/down_vote';
  var link = $('<a>', {
    'class': 'down-vote',
    'text':  'down vote',
    'href':  href,
    'data-method': 'post',
    'data-remote': true,
  });
  return link;
}

function createUpVoteLink(id, type) {
  var href = type + '/' + id + '/up_vote';
  var link = $('<a>', {
    'class': 'up-vote',
    'text':  'up vote',
    'href':  href,
    'data-method': 'post',
    'data-remote': true,
  });
  return link;
}
