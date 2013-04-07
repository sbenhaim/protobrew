root = exports ? this
root.Entries = new Meteor.Collection("entries")
root.Tags = new Meteor.Collection("tags")
    

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


# Admins can admin anywhere, others can only admin in context
root.adminable = ( user, context ) ->
    user &&
    ( user.profile.group == "admin" ||
      user.profile.group == context ||
      user.profile.username == context )

# View all in context, view public and read-only otherwise
root.viewable = ( entry, user, context ) ->
    adminable( user, context ) ||
    ( context == null && entry == null ) ||
    ( entry && entry.mode != "private" )

# Edit in context or public entries
root.editable = ( entry, user, context ) ->
    user && 
    ( adminable( user, context ) ||
      ( context == null && entry == null ) ||
      ( entry && entry.mode == "public" ) )


root.verifySave = ( entry, user, context ) ->

    bail = (message, status = 403) ->
        throw new Meteor.Error(status, message)

    # Only members can edit
    if ! user
        bail("You must be logged in")

    if ( entry._id )
        oldEntry = Entries.findOne({_id: entry._id})
        entry._id = null unless oldEntry

    # No dup titles in same context
    for other in Entries.find({context: context, _id: {$not: entry._id}})
        if other.title == entry.title
            bail( "Title taken" )

    # Admins can do anything
    return entry if user.profile.group == "admin"

    # Non-admins may only edit public entries in root context
    if context == null && oldEntry && oldEntry.mode != "public"
        bail("Can't edit non-public entry")

    # Users may only edit in their own context or group context
    if context != null && context != user.profile.username && context != user.profile.group 
        bail("Only #{context} may edit")

    # Non-admins may only create public entries in root context
    if context == null
        entry.mode = "public"

    entry
>>>>>>> c3cfb04... new scoping on model.coffee
