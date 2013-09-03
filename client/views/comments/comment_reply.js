Template.comment_reply.entry = function(){
  var selectedComment = Comments.findOne(Session.get('selectedCommentId'));
  return selectedComment && Posts.findOne(selectedComment.entry);
};

Template.comment_reply.helpers({
	comment: function(){
		var comment = Comments.findOne(Session.get('selectedCommentId'));
		return comment;
	}
});