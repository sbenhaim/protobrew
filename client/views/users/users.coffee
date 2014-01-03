Template.users.users = ->
    return Meteor.users.find({},
        sort:
          createdAt: -1
    )
