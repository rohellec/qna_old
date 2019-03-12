var voteEventsMixin = {
  handleAjaxVoteEvents: function(container) {
    this.handleEvents({
      eventsNames: ['_ajaxVoteSuccessEvent', '_ajaxVoteErrorEvent'],
      container:   container
    });
    return this;
  },

  _ajaxVoteSuccessEvent: function(container) {
    var self = this;
    $(container).on('ajax:success', '.vote', function(event) {
      var detail = event.detail;
      var data = detail[0], status = detail[1], xhr = detail[2];

      var votable    = $('#' + data.votable_type + '-' + data.votable_id);
      var voteRating = votable.find('.vote-rating');
      voteRating.html(data.rating);

      var current = $(this);
      self._replaceVoteLink(data.votable_id, data.votable_type, current);
      App.utils.updateFlash('success', data.message);
    });
  },

  _ajaxVoteErrorEvent: function(container) {
    $(container).on('ajax:error', '.vote', function(event) {
      var detail = event.detail;
      var data = detail[0], status = detail[1], xhr = detail[2];
      App.utils.updateFlash('danger', xhr.responseText)
    });
  },

  _replaceVoteLink: function(votable_id, votable_type, elem) {
    var link;
    if (elem.hasClass('up-vote') || elem.hasClass('down-vote')) {
      link = App.utils.render('votes/delete_vote_link', {
        votable_id:   votable_id,
        votable_type: votable_type,
        type: elem.hasClass('up-vote') ? 'up' : 'down'
      });
    } else {
      link = App.utils.render('votes/vote_link', {
        votable_id:   votable_id,
        votable_type: votable_type,
        type: elem.hasClass('up-voted') ? 'up' : 'down'
      });
    }
    elem.replaceWith(link);
  }
};
