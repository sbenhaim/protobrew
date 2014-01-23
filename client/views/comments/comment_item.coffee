(->
  commentIsNew = (comment) ->
    d = new Date(comment.submitted)
    commentIsNew = d > new Date(Session.get("requestTimestamp"))
    return commentIsNew

  Template.comment_item.helpers
    full_date: ->
      submitted = new Date(@submitted)
      submitted.toString()

    author: ->
      Meteor.users.findOne @userId

    authorName: ->
      getAuthorName this

    user_avatar: ->

    # if(author=Meteor.users.findOne(this.userId))    
    #   return getAvatarUrl(author);

    can_edit: ->
      if @userId and Meteor.userId()
        Meteor.user().isAdmin or (Meteor.userId() is @userId)
      else
        false

    comment_text: ->
      
      if @text        
        source = $("<div>").html(@text)
        source.html()

    showChildComments: ->
      Session.get "showChildComments"

    ago: ->
      moment(@submitted).fromNow()

    upvoted: ->

    # return Meteor.user() && _.include(this.upvoters, Meteor.user()._id);
    downvoted: ->

    # return Meteor.user() && _.include(this.downvoters, Meteor.user()._id);
    
    #GK edits
    editing: ->
      Session.equals "selectedCommentId", @_id

  Template.editComment.rendered = ->
    if @data
      comment = @data
      $comment = $("#" + comment._id)
      comment_editor = $(".comment-text-editor")
    comment_html = @data.text
    if Meteor.user() and not @editor
      window.EntryLib.initRedactor( comment_editor, comment_html, ["autoSuggest"] )

  Template.comment_item.created = ->
    @firstRender = true

  # Template.comment_item.rendered = ->
    
  #   # t("comment_item");
  #   if @data
  #     comment = @data
  #     $comment = $("#" + comment._id)
  #     if not (Meteor.user() && Meteor.user()._id == comment.userId)
  #       openedComments = Session.get("openedComments") or [] 
  #       # if user is logged in, and the comment belongs to the user, then never queue it
  #       debugger;
  #       if commentIsNew(comment) and not $comment.hasClass("comment-queued") and openedComments.indexOf(comment._id) is -1
          
  #         # if comment is new and has not already been previously queued          
  #         # note: testing on the class works because Meteor apparently preserves newly assigned CSS classes          
  #         # across template renderings          
  #         # TODO: save scroll position
  #         if Meteor.users.findOne(comment.userId)
            
  #           # get comment author name
  #           user = Meteor.users.findOne(comment.userId)
  #           author = getDisplayName(user)
  #           imgURL = getAvatarUrl(user)
  #           $container = findQueueContainer($comment)
  #           comment_link = "<li class=\"icon-user\"><a href=\"#" + comment._id + "\" class=\"has-tooltip\" style=\"background-image:url(" + imgURL + ")\"><span class=\"tooltip\"><span>" + author + "</span></span></a></li>"
  #           if @firstRender
              
  #             # TODO: fix re-rendering problem with timer
  #             $(comment_link).appendTo($container.find("ul")).hide().fadeIn "slow"
  #             @firstRender = false
  #           else
  #             $(comment_link).appendTo $container.find("ul")
  #           $comment.removeClass("comment-displayed").addClass "comment-queued"
  #           $comment.data "queue", $container

  
  # TODO: take the user back to their previous scroll position
  Template.comment_item.events =
    "click .queue-comment": (e) ->
      e.preventDefault()
      current_comment_id = $(event.target).closest(".comment").attr("id")
      now = new Date()
      comment_id = Comments.update(current_comment_id,
        $set:
          submitted: new Date().getTime()
      )

    "click .edit-comment": (e) ->
      e.preventDefault()
      Session.set "selectedCommentId", @_id

    "click .save-comment": (e) ->
      e.preventDefault()
      throw "You must be logged in."  unless Meteor.user()
      selectedCommentId = Session.get("selectedCommentId")
      
      # var selectedPostId=Comments.findOne(selectedCommentId).entry;      
      # var content = cleanUp(instance.editor.exportFile());      
      # var text  = $('#comment-text').val();
      commentId = Comments.update(selectedCommentId,
        $set:
          text: rewriteLinks($(".comment-text-editor").val())
      )
      # trackEvent("edit comment", {'entryId': selectedPostId, 'commentId': selectedCommentId});
      Session.set "selectedCommentId", null
      
    "click .cancel-comment": (e) ->
      e.preventDefault()
      Session.set "selectedCommentId", null
)()