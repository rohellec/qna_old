$(document).on('turbolinks:load', function() {
  if (gon.question_id != null) {
    App.channels.questions && App.channels.questions.unsubscribe();
    App.channels.comments  && App.channels.comments.unsubscribe();

    App.channels.comments = App.cable.subscriptions.create(
      { channel: 'CommentsChannel', question_id: gon.question_id },
      {
        received: function(comment) {
          if (!comment) return;
          var elem = App.comments.findComment(comment.id);
          if (elem.length) return;

          var commentsList = App.comments.findOrCreateList(comment.commentable_type, comment.commentable_id);
          var newComment   = App.utils.render("comments/comment", comment)
          commentsList.append(newComment);
        }
      }
    );
  }
});
