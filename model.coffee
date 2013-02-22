Entries = new Meteor.Collection("entries")
Tags = new Meteor.Collection("tags")

Entries.allow
  insert: (userId, entry) -> false

  update: (userId, entries, fields, modifier) ->
    return false unless _.all( entries, (entry) -> userId == entry.author )
    # Todo: Verify fields
    # return false if _.difference(fields, allowed).length
    true

  remove: (userId, entries) -> _.all( entries, (entry) -> userId == entry.author )

Tags.allow
    insert: (userId, entry) -> true if userId