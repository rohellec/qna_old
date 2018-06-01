$(document).on('turbolinks:load', function() {
  $('.answers').on('click', '.edit-answer-link', function(e) {
    e.preventDefault();

    var current = $(this);
    var answerId = current.data('answerId');
    var answer = $('#answer-' + answerId);
    var editForm = answer.find('form');
    var content = answer.find('p');

    if (!current.hasClass('cancel')) {
      current.addClass('cancel');
      current.text('Cancel');
    } else {
      current.removeClass('cancel');
      current.text('Edit');
    }

    editForm.toggle();
    content.toggle();
  });
});
