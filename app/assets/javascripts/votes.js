$(document).on('turbolinks:load', function() {
  addVoteActionAjaxEvents(['.question', '.answers']);
});

function addVoteActionAjaxEvents(selectors) {
  selectors.forEach(function(selector) {
    $(selector).on('ajax:success', '.vote', function(event) {
      var detail = event.detail;
      var data = detail[0], status = detail[1], xhr = detail[2];

      // Updating flash
      var message = $('<div>', {
        'class': 'alert success',
        'text':  data.message
      });
      $('.flash').html(message);

      var voteRating = $('#' + data.resource + '-' + data.votable_id).find('.vote-rating');
      voteRating.html(data.rating);

      var current = $(this);
      replaceVoteLink(data.votable_id, data.resource, current);
    });

    $(selector).on('ajax:error', '.vote', function(event) {
      var detail = event.detail;
      var data = detail[0], status = detail[1], xhr = detail[2];

      updateFlash('danger', xhr.responseText)
    });
  });
}

function replaceVoteLink(id, resource, elem) {
  var link;
  if (elem.hasClass('up-vote') || elem.hasClass('down-vote')) {
    link = createDeleteVoteLink(id, resource, elem);
  } else {
    link = createVoteLink(id, resource, elem);
  }
  elem.replaceWith(link);
}

function createDeleteVoteLink(id, resource, elem) {
  var href  = '/' + resource + '/' + id + '/delete_vote';
  var voted = elem.hasClass('up-vote') ? 'up-voted' : 'down-voted';
  var css_class = 'vote ' + voted;
  var link = $('<a>', {
    'href':  href,
    'class': css_class,
    'text':  'delete vote',
    'data-method': 'delete',
    'data-remote': true,
  });
  return link;
}

function createVoteLink(id, resource, elem) {
  var vote = elem.hasClass('up-voted') ? 'up' : 'down';
  var css_class = 'vote ' + vote + '-vote';
  var href = '/' + resource + '/' + id + '/' + vote + '_vote';
  var link = $('<a>', {
    'class': css_class,
    'text':  vote + ' vote',
    'href':  href,
    'data-method': 'post',
    'data-remote': true,
  });
  return link;
}
