$(document).on('turbolinks:load', function() {
  $('.edit-question-link').click(function(e) {
    e.preventDefault();

    var current      = $(this);
    var editForm     = $('.edit-question');
    var questionBody = $('.question-body');

    toggleLink(current, 'Edit');
    editForm.toggle();
    questionBody.toggle();
  });
});

function findOrCreateQuestionsList() {
  var questions     = $('.questions');
  var questionsList = questions.find('tbody');
  if (!questionsList.length) {
    questions.html('<table><tbody></tbody></table>');
    questionsList = questions.find('tbody');
  }
  return questionsList;
}
