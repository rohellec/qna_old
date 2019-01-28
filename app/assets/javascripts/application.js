// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require rails-ujs
//= require turbolinks
//= require cocoon
//= require pluralize
//= require_tree .
//= require_self

$(document).on('turbolinks:load cocoon:after-insert', function() {
  $('.nested-fields').change(function() {
    var current = $(this);
    var input = current.find('input');
    var label = current.find('label');
    var name  = basename(input.val());
    label.text(name);
  });
});

function basename(filename) {
  return filename.replace(/\\/g, '/')
                 .replace(/(^.*\/)|(\.\w*$)/g, '');
}

function updateFlash(status, text) {
  var message = $('<div>', {
    'class': 'alert ' + status,
    'text':  text
  });
  $('.flash').html(message);
}
