$(document).on('turbolinks:load', function() {
  if (gon.question_id != null) {
    App.commentsChannel && App.commentsChannel.unsubscribe();
    App.commentsChannel = App.cable.subscriptions.create(
      { channel: 'CommentsChannel', question_id: gon.question_id },
      {
        received: function(comment) {
          if (!comment) return;
          var elem = findComment(comment.id);
          if (elem.length) return;

          addCommentListItem(comment);
        }
      }
    );
  }
});
