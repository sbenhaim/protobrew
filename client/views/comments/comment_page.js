Template.comment_page.entry = function(){
  var selectedComment = Comments.findOne(Session.get('selectedCommentId'));
  return selectedComment && Entries.findOne(selectedComment.entry);
};

Template.comment_page.helpers({
	comment: function(){
		var comment = Comments.findOne(Session.get('selectedCommentId'));
		return comment;
	}
});