Template.users.users = ->
  users = Meteor.users.find({},
    sort:
      createdAt: -1
  )
  users