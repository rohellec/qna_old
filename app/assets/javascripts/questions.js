$(document).on('turbolinks:load', function() {
  $('.edit-question-link').click(function(e) {
    e.preventDefault();

    var current      = $(this);
    var editForm     = $('.edit-question');
    var questionBody = $('.question-body');

    if (!current.hasClass('cancel')) {
      current.addClass('cancel');
      current.text('Cancel');
    } else {
      current.removeClass('cancel');
      current.text('Edit');
    }

    editForm.toggle();
    questionBody.toggle();
  });
});
