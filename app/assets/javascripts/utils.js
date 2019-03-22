App.utils = {};

App.utils.basename = function(filename) {
  return filename.replace(/\\/g, '/')
                 .replace(/(^.*\/)|(\.\w*$)/g, '');
};

App.utils.emptyList = function(resources) {
  var listClass = resources + '-list';
  return $('<ul>', { class: listClass });
};

App.utils.emptyTable = function(resources) {
  var tableClass = resources + '-table';
  return $('<table>', { class: tableClass }).append($('<tbody>'));
};

App.utils.filename = function(url) {
  if(!url) return null;
  var result = url.match(/\/([-.\w]+)$/);
  return result && result[1];
};

App.utils.getCSRF = function() {
  return $('meta[name="csrf-token"]').attr('content');
};

App.utils.render = function(template, options) {
  var path = 'templates/' + template;
  return JST[path](options);
};

App.utils.toggleCancelLink = function(link, name) {
  if (link.hasClass('cancel')) {
    link.removeClass('cancel');
    link.text(name);
  } else {
    link.addClass('cancel');
    link.text('Cancel');
  }
};

App.utils.transformKeysToUndescore = function(data) {
  var self = this;
  return Object.keys(data).reduce(function(result, key) {
    var underscoreKey = self.underscore(key);
    result[underscoreKey] = data[key];
    return result;
  }, {})
}

App.utils.underscore = function(camelCaseWord) {
  if (!/[A-Z-]/.test(camelCaseWord)) {
    return camelCaseWord;
  }
  var word = camelCaseWord.replace(/([A-Z\d]+)([A-Z][a-z])/g, '$1_$2');
  word = word.replace(/([a-z\d])([A-Z])/g, '$1_$2');
  word = word.replace(/-/g, '_');
  word = word.toLowerCase();
  return word;
}

App.utils.updateFlash = function(status, text) {
  var message = $('<div>', {
    'class': 'alert ' + status,
    'text':  text
  });
  $('.flash').html(message);
}
