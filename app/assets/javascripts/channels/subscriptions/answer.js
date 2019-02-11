$(document).on('turbolinks:load', function() {
  if (gon.question_id != null) {
    App.questionsChannel && App.questionsChannel.unsubscribe();
    App.answersChannel   && App.answersChannel.unsubscribe();

    App.answersChannel = App.cable.subscriptions.create(
      { channel: 'AnswersChannel', question_id: gon.question_id },
      {
        received: function(data) {
          if (!data.answer) return;
          var answer = findAnswer(data.answer.id);
          if (answer.length) return;

          var answersList = findOrCreateAnswersList();
          var newAnswer   = App.utils.render('answers/answer', data);
          answersList.append(newAnswer);
        }
      }
    );
  }
});
