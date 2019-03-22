$(document).on('turbolinks:load cocoon:after-insert', function() {
  $('.nested-fields').change(function() {
    var current = $(this);
    App.attachments.changeFileFieldLabel(current);
  });
});

App.attachments || (App.attachments = {});

App.attachments.changeFileFieldLabel = function(nestedFields) {
  var input = nestedFields.find('input');
  var label = nestedFields.find('label');
  var name  = App.utils.basename(input.val());
  label.text(name);
}
