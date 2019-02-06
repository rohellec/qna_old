App.questionsChannel = App.cable.subscriptions.create({ channel: 'QuestionsChannel' }, {
  received: function(question) {
    if (!question) return;
    var questionsList = findOrCreateQuestionsList();
    var newQuestion   = App.utils.render('question', question);
    questionsList.append(newQuestion);
  }
});
