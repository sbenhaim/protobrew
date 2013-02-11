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

Meteor.methods

    # Todo: lock down fields
    saveEntry: (entry, callback) ->
        throw new Meteor.Error(403, "You must be logged in") unless this.userId

        entry.author = this.userId
        entry.visibility = "public"

        return Entries.insert(entry, callback) unless entry._id
        return Entries.update({_id: entry._id}, entry, callback)

        
