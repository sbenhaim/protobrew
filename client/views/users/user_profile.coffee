Template.user_profile.user = ->
	Meteor.users.findOne username: selectedUserId  if selectedUserId = Session.get("selectedUserName")

Template.user_profile.createdAtFormatted = ->
	UserLib.createdAt this

Template.user_profile.isCurrentUser = ->
	Meteor.user() and (Session.get("selectedUserName") is Meteor.user().username)
