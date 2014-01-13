wikisForUser = () ->
  return Wikis.find({
            $or: [
                {
                    visibility: "public"
                },
                {
                    visibility: "private",
                    readers: this.userId
                }
            ]
        })

entriesForUser = () ->
  wikis = wikisForUser().fetch()
  wiki_names = [wiki.name for wiki in wikis][0]  # weird
  return Entries.find({
        wiki: { $in: wiki_names }
    })

Meteor.publish("browsable-wikis", () ->
  return wikisForUser()
)


Meteor.publish("entries", () ->
  console.log("Publishing entries for user")
  entries = entriesForUser()
  console.log entries.fetch()
  return entriesForUser()
)


Meteor.publish("userData", () ->
  return Meteor.users.find({_id: this.userId},
                           {fields: {'username': 1, 'group': 1, 'profile': 1}})
)


Meteor.publish("allUserData", () ->
  user = Meteor.users.findOne({_id: this.userId}) if this.userId
  if user && user.group == "admin"
    return Meteor.users.find();
  else
    return Meteor.users.find({}, {fields: {'username': 1}});
)


Meteor.publish('revisions', () ->
  return Revisions.find({})
)


Meteor.publish('tags', () ->
  return Tags.find({})
)


Meteor.publish('comments', () ->
  return Comments.find({})
)


Meteor.publish('settings', () ->
  return Settings.find({})
)
