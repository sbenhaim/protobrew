Template.comment_form.rendered = ->
  if Meteor.user() and not @editor
    el = $("#comment")
    window.EntryLib.initRedactor( el, ["autoSuggest"] )


Template.comment_form.helpers addingComment: ->
  Session.equals "addingComment", true

Template.comment_form.events =
  "click .comment-add": (e) ->
    e.preventDefault()
    Session.set('addingComment', true)

  "click .comment-cancel": (e) ->
    e.preventDefault()
    Session.set('addingComment', false)

  "click .comment-save": (e) ->
    e.preventDefault()
    content = $("#comment").val()
    parentCommentId = null
    entryId = Session.get("entryId")
    Meteor.call "comment", entryId, parentCommentId, content, (error, commentProperties) ->
      if error
        console.log error
        Toast.error error.reason
      else
      # trackEvent("newComment", commentProperties);
        Session.set('scrollToCommentId', commentProperties.commentId)
    Session.set('addingComment', false)
