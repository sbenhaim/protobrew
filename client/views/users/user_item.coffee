Template.user_item.rendered = ->

Template.user_item.helpers
  
  createdAtFormatted: ->
    UserLib.createdAt this
    # (if @createdAt then moment(@createdAt).fromNow() else "–")

  displayName: ->
    UserLib.getDisplayName this

  email: ->
    getEmail this

  entries: ->
    Entries.find userId: @_id

  entriesCount: ->
    Entries.find(userId: @_id).count()

  comments: ->
    Comments.find userId: @_id

  commentsCount: ->
    # Posts.find({'user_id':this._id}).forEach(function(post){console.log(post.headline);});
    Comments.find(userId: @_id).count()

  userIsAdmin: ->
    isAdmin this

Template.user_item.events
  # "click .invite-link": (e, instance) ->
  #   e.preventDefault()
  #   user = Meteor.users.findOne(instance.data._id)
  #   Meteor.users.update user._id,
  #     $set:
  #       isInvited: true
  #   ,
  #     multi: false
  #   , (error) ->
  #     if error
  #       throwError()
  #     else
  #       Meteor.call "createNotification", "accountApproved", {}, user


  # "click .uninvite-link": (e, instance) ->
  #   e.preventDefault()
  #   Meteor.users.update instance.data._id,
  #     $set:
  #       isInvited: false


  "click .admin-link": (e, instance) ->
    e.preventDefault()
    Meteor.users.update instance.data._id,
      $set:
        group: "admin"


  "click .unadmin-link": (e, instance) ->
    e.preventDefault()
    Meteor.users.update instance.data._id,
      $set:
        group: "editor"


  # "click .delete-link": (e, instance) ->
    # e.preventDefault()
    # Meteor.users.remove instance.data._id  if confirm("Are you sure you want to delete " + getDisplayName(instance.data) + "?")
