$(document).on('turbolinks:load', function() {
  if (gon.question_id != null) {
    App.channels.questions && App.channels.questions.unsubscribe();
    App.channels.answers   && App.channels.answers.unsubscribe();

    App.channels.answers = App.cable.subscriptions.create(
      { channel: 'AnswersChannel', question_id: gon.question_id },
      {
        received: function(answer) {
          if (!answer) return;
          var elem = App.answers.findAnswer(answer.id);
          if (elem.length) return;

          var answersList = App.answers.findOrCreateList();
          var newAnswer   = App.utils.render('answers/answer', answer);
          answersList.append(newAnswer);
        }
      }
    );
  }
});
