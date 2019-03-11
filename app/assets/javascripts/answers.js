$(document).on('turbolinks:load', function() {
  App.answers.eventsHandler.handleAnswerEvents();
});

App.answers || (App.answers = {});

App.answers.eventsHandler = new AnswersEventsHandler();

App.answers.findAnswer = function(id) {
  return $('#answer-' + id);
};

App.answers.findOrCreateList = function () {
  var answers = $('.answers');
  var answersList = answers.find('.answers-table > tbody');
  if (!answersList.length) {
    var emptyTable = App.utils.emptyTable('answers');
    answers.find('.answers-placeholder').replaceWith(emptyTable);
    answersList = answers.find('.answers-table > tbody');
  }
  return answersList;
}
