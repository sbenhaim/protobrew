Template.comment_form.rendered = ->
  if Meteor.user() and not @editor
    el = $("#comment")
    console.log "rendered"
    el.redactor
      plugins: ["autoSuggest"]
      imageUpload: "/images"
      buttons: ["html", "|", "formatting", "|", "bold", "italic", "deleted", "|", "unorderedlist", "orderedlist", "outdent", "indent", "|", "image", "table", "link", "|", "fontcolor", "backcolor", "|", "alignment", "|", "horizontalrule"]
      focus: true
      autoresize: true
      filepicker: (callback) ->
        filepicker.setKey "AjmU2eDdtRDyMpagSeV7rz"
        filepicker.pick
          mimetype: "image/*"
        , (file) ->
          filepicker.store file,
            location: "S3"
            path: Meteor.userId() + "/" + file.filename
          , (file) ->
            callback filelink: file.url

     # @editor = new EpicEditor(EpicEditorOptions).load()
     # $(@editor.editor).bind "keydown", "meta+return", ->
     #   $(window.editor).closest("form").find("input[type=\"submit\"]").click()


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
