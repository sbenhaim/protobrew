root = exports ? this

@Entries = new Meteor.Collection("entries")
@Tags = new Meteor.Collection("tags")
@Revisions = new Meteor.Collection("revisions")
@Wikis = new Meteor.Collection("wikis")


root.escapeRegExp = (str) ->
  str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

Entries.allow
  insert: (userId, entry) ->
    false

  update: (userId, entries, fields, modifier) ->
    false

  remove: (userId, entries) ->
    false

Tags.allow
  insert: (userId, entry) ->
    true if userId

@entryLink = (entry) ->
  encodedTitle = encodeURIComponent(entry.title)
  if entry.context?
    encodedContext = encodeURIComponent(entry.context)
    return "/u/#{encodedContext}/#{encodedTitle}"
  else
    return "/#{encodedTitle}"

@historyLink = (entry) ->
  encodedTitle = encodeURIComponent(entry.title)
  return "/history/#{encodedTitle}"

@findAll = (context) ->
  Entries.find({context: context})

@findSingleEntryByTitle = (wiki_name, context, title) ->
  titleEscaped = escapeRegExp(title)
  titleTerm = new RegExp("^" + titleEscaped + "$", 'i')
  Entries.findOne({
          title: titleTerm
          context: context
          wiki: wiki_name
              })

@findRevisionsByTitle = (title) ->
    titleEscaped = escapeRegExp( title )
    titleTerm = new RegExp( "^" + titleEscaped + "$", 'i' )
    entry = Entries.findOne({title: titleTerm})
    if entry
      revs = Revisions.find({entryId: entry._id}, {sort: {date: -1}}).fetch()
      console.log(revs)
      _.each revs, (rev) ->
        rev.moment = moment(rev.date).fromNow()
      revs
    else
      []

@findRevisionById = (id) ->
  Revisions.findOne({"_id": id})

@verifySave = (wiki_name, title, entry, user, context) ->
  bail = (message, status = 403) ->
    throw new Meteor.Error(status, message)

  # Only members can edit
  if !user
    bail("You must be logged in")

  if ( entry._id )
    oldEntry = Entries.findOne({_id: entry._id})
    entry._id = null unless oldEntry

  # No dup titles in same context
  other = findSingleEntryByTitle(wiki_name, context, title)
  bail("Title taken") if other && other._id != entry._id


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
