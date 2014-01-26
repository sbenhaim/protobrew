getEntryFromSession = ->
  title = Session.get("title")
  wiki_name = Session.get("wiki_name")
  context = Session.get("context")
  entry = findSingleEntryByTitle(wiki_name, context, title)
  return entry

getRevisionFromSession = ->
  revisionId = Session.get("rev")
  revision = Revisions.findOne({_id: revisionId})
  return revision

getRevisionsFromSession = ->
  title = Session.get("title")
  return findRevisionsByTitle(title)

# Template Helpers
Template.revision.revision = ->
  getRevisionFromSession()

Template.revision.entry = ->
  getEntryFromSession()

Template.revision.revisionDateAsMoment = ->
  revision = getRevisionFromSession()
  if revision?
    moment(revision.date).fromNow()

Template.revision.revisionAuthorName = ->
  revision = getRevisionFromSession()
  if revision?
    UserLib.getDisplayNameById(revision.author)

# Get the one-based index of this revision in the total collection of revisions
Template.revision.revisionIndexForThisEntry = ->
  # Get ordered list of revisions and then get index of this
  # revision in this list
  revision = getRevisionFromSession()
  if revision?
    revisions = getRevisionsFromSession()
    revisions.reverse()
    for rev, idx in revisions
      if rev._id == revision._id
        return idx + 1

# Get the total number of revisions for this entry
Template.revision.numberOfRevisionsForThisEntry = ->
  getRevisionsFromSession().length

# Get the name of the user that edited this revision
Template.revision.authorName = ->
  revision = getRevisionFromSession()
  if revision?
    return UserLib.getDisplayNameById(revision.author)
