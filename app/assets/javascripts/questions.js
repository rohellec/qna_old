$(document).on('turbolinks:load', function() {
  App.questions.eventsHandler
    .handleEditFormToggleEvent()
    .handleAjaxUpdateEvents()
    .handleAjaxDeleteEvent()
    .handleAjaxVoteEvents();
});

App.questions || (App.questions = {});

App.questions.eventsHandler = new ResourceEventsHandler({
  resource:    'question',
  attachable:  true,
  placeholder: 'Nobody has asked anything yet!'
});

for (var key in voteEventsMixin) {
  App.questions.eventsHandler[key] = voteEventsMixin[key];
}

App.questions.findQuestion = function(id) {
  return $('#question-' + id);
}

App.questions.findOrCreateList = function() {
  var questions = $('.questions');
  var questionsList = questions.find('.questions-table > tbody');
  if (!questionsList.length) {
    var emptyTable = App.utils.emptyTable('questions');
    questions.find('.questions-placeholder').replaceWith(emptyTable);
    questionsList = questions.find('.questions-table > tbody');
  }
  return questionsList;
}
