function AnswersEventsHandler() {
  ResourceEventsHandler.call(this, {
    resource:      'answer',
    container:     '.answers',
    containerType: 'table',
    attachable:    true,
    placeholder:   'Nobody has given any answer yet!'
  });

  this._acceptLink = '.accept-answer-link';
  this._removeAcceptLink = '.remove-accept-answer-link';
}

AnswersEventsHandler.prototype = Object.create(ResourceEventsHandler.prototype);
AnswersEventsHandler.prototype.constructor = AnswersEventsHandler;

for (var key in voteEventsMixin) {
  AnswersEventsHandler.prototype[key] = voteEventsMixin[key];
}

AnswersEventsHandler.prototype.handleAnswerEvents = function() {
  this
    .handleEditFormToggleEvent()
    .handleAjaxCreateEvents()
    .handleAjaxUpdateEvents()
    .handleAjaxDeleteEvent()
    .handleAjaxVoteEvents()
    .handleAcceptEvent()
    .handleRemoveAcceptEvent();
};


AnswersEventsHandler.prototype.handleAcceptEvent = function(container) {
  this.handleEvent({
    eventName: '_ajaxAcceptEvent',
    container: container
  })
  return this;
};

AnswersEventsHandler.prototype.handleRemoveAcceptEvent = function(container) {
  this.handleEvent({
    eventName: '_ajaxRemoveAcceptEvent',
    container: container
  })
  return this;
};

AnswersEventsHandler.prototype._ajaxAcceptEvent = function(container) {
  $(container).on('ajax:success', this._acceptLink, function(event) {
    var detail = event.detail;
    var data   = detail[0],
        status = detail[1],
        xhr    = detail[2];

    var acceptedAnswer = $('.accepted');
    acceptedAnswer.removeClass('accepted');

    var answer = $('#answer-' + data.id);
    answer.addClass('accepted');

    var question = $('.question');
    question.addClass('answered');

    var answers = $('.answers tbody');
    answers.prepend(answer);
  });
  return this;
};

AnswersEventsHandler.prototype._ajaxRemoveAcceptEvent = function(container) {
  var self = this;
  $(container).on('ajax:success', this._removeAcceptLink, function(event) {
    var detail = event.detail;
    var data   = detail[0],
        status = detail[1],
        xhr    = detail[2];

    var answer  = $('#answer-' + data.id);
    answer.removeClass('accepted');

    var question = $('.question');
    question.removeClass('answered');

    var answersList = $('.answers tbody');
    var createdAt   = answer.data('createdAt');
    var foundAnswer = self._findAnswerToInsertBefore(answer);

    if (foundAnswer) {
      $(foundAnswer).before(answer);
    } else {
      answersList.append(answer);
    }
  });
  return this;
};

AnswersEventsHandler.prototype._findAnswerToInsertBefore = function(answer) {
  var createdAt  = answer.data('createdAt');
  var voteRating = +answer.find('.vote-rating').text();

  var lowRatedAnswers = $('.answer').filter(function(index, elem) {
    var currentAnswer = $(elem);
    var currentRating = +currentAnswer.find('.vote-rating').text();
    return voteRating >= currentRating;
  });

  if (lowRatedAnswers.length === 0) {
    lowRatedAnswers = $('.answer');
  }

  var answersByDate = lowRatedAnswers.filter(function(index, elem) {
    var currentAnswer = $(elem);
    var currentCreatedAt = currentAnswer.data('createdAt');
    return createdAt < currentCreatedAt;
  });
  return answersByDate[0];
};

