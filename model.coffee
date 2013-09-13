root = exports ? this
root.Entries = new Meteor.Collection("entries")
root.Tags = new Meteor.Collection("tags")
root.Revisions = new Meteor.Collection("revisions")

root.escapeRegExp = (str) ->
  str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

Entries.allow
  insert: (userId, entry) -> false

  update: (userId, entries, fields, modifier) -> false

  remove: (userId, entries) -> false

Tags.allow
    insert: (userId, entry) -> true if userId


root.entryLink = ( entry ) ->
    unless entry.context then "/#{entry.title}" else "/u/#{entry.context}/#{entry.title}"



root.findAll = (context) ->
   Entries.find({context: context})

root.findSingleEntryByTitle = ( title, context ) ->
    titleEscaped = escapeRegExp( title )
    titleTerm = new RegExp( "^" + titleEscaped + "$", 'i' )
    Entries.findOne({title: titleTerm, context: context})

root.verifySave = (title, entry, user, context ) ->

    bail = (message, status = 403) ->
        throw new Meteor.Error(status, message)

    # Only members can edit
    if ! user
        bail("You must be logged in")

    if ( entry._id )
        oldEntry = Entries.findOne({_id: entry._id})
        entry._id = null unless oldEntry

    # No dup titles in same context
    other = findSingleEntryByTitle( title, context )
    bail( "Title taken" ) if other && other._id != entry._id
        

    # Admins can do anything
    return entry if user.group == "admin"

    # Non-admins may only edit public entries in root context
    if context == null && oldEntry && oldEntry.mode != "public"
        bail("Can't edit non-public entry")

    # Users may only edit in their own context or group context
    if context != null && context != user.username && context != user.group 
        bail("Only #{context} may edit")

    # Non-admins may only create public entries in root context
    if context == null
        entry.mode = "public"

    entry