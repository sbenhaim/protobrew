root = exports ? this

class _UserLib

    getDisplayName: (user) ->
        (if (user.profile and user.profile.name) then user.profile.name else user.username)

    getDisplayNameById: (userId) ->
      @getDisplayName(Meteor.users.findOne(userId))

    createdAt: (user) ->
        if user.createdAt
        then moment(user.createdAt).fromNow()
        else "–"

    findLast: (user, collection) ->
        collection.findOne( userId: user._id, sort: createdAt: -1 )

    timeSinceLast: (user, collection) ->
        now = new Date().getTime()
        last = @findLast(user, collection)
        return 999  unless last # if this is the user's first post or comment ever, stop here
        Math.abs Math.floor((now - last.createdAt) / 1000)

    lastEditedBy: (entry) ->
        if entry? and entry._id
            lastRev = Revisions.findOne({entryId: entry._id},{sort:{ date : -1}})
        else
            return
        if lastRev == undefined
            return
        else
            authorId = lastRev.author
        author = Meteor.users.findOne(authorId)
        if author
            return author.username

    sinceLastEdit: (entry) ->
        if entry? and entry._id
            lastRev = Revisions.findOne({entryId: entry._id},{sort:{ date : -1}})
        else
            return
        if lastRev == undefined
            return
        else
            moment(lastRev.date).fromNow()

@UserLib = new _UserLib()
