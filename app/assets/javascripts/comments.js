$(document).on('turbolinks:load', function() {
  App.comments.eventsHandler
    .handleNewFormToggleEvent()
    .handleEditFormToggleEvent()
    .handleAjaxCreateEvents()
    .handleAjaxUpdateEvents()
    .handleAjaxDeleteEvent();
});

App.comments || (App.comments = {});

App.comments.eventsHandler = new ResourceEventsHandler({
  resource:      'comment',
  parent:        'commentable',
  polymorphic:   true,
  containers:    ['.question', '.answers'],
  containerType: 'list'
});

App.comments.findComment = function(id) {
  return $('#comment-' + id);
};

App.comments.findOrCreateList = function(commentableType, commentableId) {
  var commentable  = $('#' + commentableType.toLowerCase() + '-' + commentableId);
  var commentsList = commentable.find('.comments-list');

  if (!commentsList.length) {
    commentsList = App.utils.emptyList('comments');
    commentable.find('.comments').prepend(commentsList);
  }
  return commentsList;
}
