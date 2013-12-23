getEntryFromSession = ->
  title = Session.get("title")
  entry = findSingleEntryByTitle(title)
  return entry

getRevisionFromSession = ->
  revisionId = Session.get("rev")
  revision = Revisions.findOne({_id: revisionId})
  return revision

# Template Helpers
Template.revision.revision = ->
  getRevisionFromSession()

Template.revision.entry = ->
  getEntryFromSession()

Template.revision.revisionDateAsMoment = ->
  revision = getRevisionFromSession()
  moment(revision.date).fromNow()

Template.revision.revisionAuthorName = ->
  revision = getRevisionFromSession()
  UserLib.getDisplayNameById(revision.author)
