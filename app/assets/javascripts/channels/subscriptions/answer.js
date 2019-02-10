$(document).on('turbolinks:load', function() {
  if (gon.question_id != null) {
    App.questionsChannel && App.questionsChannel.unsubscribe();
    App.answersChannel   && App.answersChannel.unsubscribe();

    App.answersChannel = App.cable.subscriptions.create(
      { channel: 'AnswersChannel', question_id: gon.question_id },
      {
        connected: function() {
          App.questionsChannel && App.questionsChannel.unsubscribe();
        },

        received: function(data) {
          if (!data.answer) return;
          var answer = $('#answer-' + data.answer.id);
          if (answer.length) return;

          var answersList = findOrCreateAnswersList();
          var newAnswer   = App.utils.render('answer', data);
          answersList.append(newAnswer);
        },
      }
    );
  }
});
