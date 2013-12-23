Template.comment_list.helpers
  has_comments: ->
    entry = Entries.findOne(Session.get("entryId"))
    if entry
      Comments.find(
        entry: entry._id
        parent: null
      ).count() > 0

  child_comments: ->
    entry = Entries.findOne(Session.get("entryId"))
    Comments.find
        entry: entry._id
        parent: null
      ,
        sort:
          submitted: -1