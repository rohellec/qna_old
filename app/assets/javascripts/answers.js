$(document).on('turbolinks:load', function() {
  $('.edit-answer-link').click(function(e) {
    e.preventDefault();

    $('#errors').remove();

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
