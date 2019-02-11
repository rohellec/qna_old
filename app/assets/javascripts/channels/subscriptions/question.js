$(document).on('turbolinks:load', function() {
  if (!gon.question_id) {
    App.answersChannel && App.answersChannel.unsubscribe();
    App.questionsChannel = App.cable.subscriptions.create({ channel: 'QuestionsChannel' }, {
      received: function(question) {
        if (!question) return;
        var questionsList = findOrCreateQuestionsList();
        var newQuestion   = App.utils.render('questions/question', question);
        questionsList.append(newQuestion);
      }
    });
  }
});
