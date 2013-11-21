Comments = new Meteor.Collection('comments');

Comments.allow({
    insert: canCommentById
  , update: canEditById
  , remove: canEditById
});

// Comments.deny({
//   update: function(userId, post, fieldNames) {
//     if(isAdminById(userId))
//       return false;
//     // may only edit the following fields:
//     return (_.without(fieldNames, 'text').length > 0);
//   }
// });

// Meteor.methods
//   comment: (entryId, parentCommentId, text)
//   user = Meteor.user()
//   entry = Entrsies.findOne(entryId)
//   properties = {
//                 'commentAuthorId' : user._id
//                 'entryId' : entryId
//                 }

Meteor.methods({
  comment: function(entryId, parentCommentId, text){
    var user = Meteor.user(),
        entry=Entries.findOne(entryId),
        // postUser=Meteor.users.findOne(post.userId),
        timeSinceLastComment=UserLib.timeSinceLast(user, Comments),

        //TODO: cleanup text
        cleanText= text,
        commentInterval = Math.abs(parseInt(getSetting('commentInterval',15))),
        properties={
          'commentAuthorId': user._id,
          'commentAuthorName': UserLib.getDisplayName(user),
          'entryId': entryId
        };
    // check that user can comment
    if (!user || !canComment(user))
      throw new Meteor.Error('You need to login or be invited to post new comments.');
    
    // check that user waits more than 15 seconds between comments
    if(!this.isSimulation && (timeSinceLastComment < commentInterval))
      throw new Meteor.Error(704, 'Please wait '+(commentInterval-timeSinceLastComment)+' seconds before commenting again');

    // Don't allow empty comments
    if (!cleanText)
      throw new Meteor.Error(704,'Your comment is empty.');
          
    var comment = {
        entry: entryId,
        text: cleanText,
        userId: user._id,
        submitted: new Date().getTime(),
        author: UserLib.getDisplayName(user)
    };
    
    if(parentCommentId)
      comment.parent = parentCommentId;

    var newCommentId=Comments.insert(comment);

    Entries.update(entryId, {$inc: {comments: 1}});

    // Meteor.call('upvoteComment', newCommentId);

    properties.commentId = newCommentId;

    if(!this.isSimulation){
      if(parentCommentId){
        // child comment
        var parentComment=Comments.findOne(parentCommentId);
        var parentUser=Meteor.users.findOne(parentComment.userId);

        properties.parentCommentId = parentCommentId;
        properties.parentAuthorId = parentComment.userId;
        properties.parentAuthorName = UserLib.getDisplayName(parentUser);

        // do not notify users of their own actions (i.e. they're replying to themselves)
        // if(parentUser._id != user._id)
        //   Meteor.call('createNotification','newReply', properties, parentUser, user);

        // // if the original poster is different from the author of the parent comment, notify them too
        // if(postUser._id != user._id && parentComment.userId != post.userId)
        //   Meteor.call('createNotification','newComment', properties, postUser, user);

      }
      // else{
      //   // root comment
      //   // don't notify users of their own comments
      //   if(postUser._id != user._id)
      //     Meteor.call('createNotification','newComment', properties, postUser, Meteor.user());
      // }
    }
    return properties;
  },
  removeComment: function(commentId){
    var comment=Comments.findOne(commentId);
    // decrement post comment count
    Entries.update(comment.post, {$inc: {comments: -1}});
    // note: should we also decrease user's comment karma ?
    Comments.remove(commentId);
  }
});
