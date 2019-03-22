$(document).on('turbolinks:load', function() {
  if (!gon.question_id) {
    App.channels.answers  && App.channels.answers.unsubscribe();
    App.channels.comments && App.channels.comments.unsubscribe();

    App.channels.questions = App.cable.subscriptions.create(
      { channel: 'QuestionsChannel' },
      {
        received: function(question) {
          if (!question) return;
          var elem = App.questions.findQuestion(question.id);
          if (elem.length) return;

          var questionsList = App.questions.findOrCreateList();
          var newQuestion   = App.utils.render('questions/question', question);
          questionsList.append(newQuestion);
        }
      }
    );
  }
});
