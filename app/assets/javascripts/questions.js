$('.edit-question-link').click(function(e) {
  e.preventDefault();

  var editLink = $(this);
  var editForm = $('.edit-question');
  var question = $('.question');

  if (!current.hasClass('cancel')) {
    current.addClass('cancel');
    current.text('Cancel');
  } else {
    current.removeClass('cancel');
    current.text('Edit');
  }

  editForm.toggle();
  question.toggle();
}
