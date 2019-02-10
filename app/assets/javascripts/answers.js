$(document).on('turbolinks:load', function() {
  $('.answers').on('click', '.edit-answer-link', function(e) {
    e.preventDefault();

    var current  = $(this);
    var answerId = current.data('answerId');
    var answer   = $('#answer-' + answerId);
    var editForm = answer.find('.edit-answer');
    var content  = answer.find('.answer-text');

    toggleLink(current, 'Edit');
    editForm.toggle();
    content.toggle();
  });
});

function findAnswer(id) {
  return $('#answer-' + id);
}

function findOrCreateAnswersList() {
  var answers     = $('.answers');
  var answersList = answers.find('tbody');
  if (!answersList.length) {
    answers.html('<table><tbody></tbody></table>');
    answersList = answers.find('tbody');
  }
  return answersList;
}

