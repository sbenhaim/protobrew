Meteor.users.allow
  insert: (userId, doc) ->
    isAdminById(userId)

  update: (userId, doc, fields, modifier) ->
    isAdminById(userId) 

  remove: (userId, doc) ->
    isAdminById(userId)