root = exports ? this

root.getDisplayName = (user) ->
  (if (user.profile and user.profile.name) then user.profile.name else user.username)

root.getDisplayNameById = (userId) ->
  getDisplayName Meteor.users.findOne(userId)

root.createdAt = (user) ->
  if user.createdAt 
  then moment(user.createdAt).fromNow() 
  else "–"

# getTwitterName = (user) ->
#   try
#     return user.services.twitter.screenName
#   catch e
#     return `undefined`

# getTwitterNameById = (userId) ->
#   getTwitterName Meteor.users.findOne(userId)

# getSignupMethod = (user) ->
#   if user.services and user.services.twitter
#     "twitter"
#   else
#     "regular"

# getEmail = (user) ->
#   if getSignupMethod(user) is "twitter"
#     user.profile.email
#   else if user.emails
#     user.emails[0].address or user.emails[0].email
#   else if user.profile and user.profile.email
#     user.profile.email
#   else
#     ""



# getCurrentUserEmail = ->
#   (if Meteor.user() then getEmail(Meteor.user()) else "")

# userProfileComplete = (user) ->
#   !!getEmail(user)

findLast = (user, collection) ->
	collection.findOne( userId: user._id, sort: createdAt: -1 )

root.timeSinceLast = (user, collection) ->
	now = new Date().getTime()
	last = findLast(user, collection)
	return 999  unless last # if this is the user's first post or comment ever, stop here
	Math.abs Math.floor((now - last.createdAt) / 1000)

root.lastEditedBy = (entry) ->
	if entry? and entry._id
		lastRev = Revisions.findOne({entryId: entry._id},{sort:{ date : -1}})
	else
		return
	if lastRev == undefined
		return
	else
		authorId = lastRev.author
	author = Meteor.users.findOne(authorId)
	author.username

root.sinceLastEdit = (entry) ->
	if entry? and entry._id
		lastRev = Revisions.findOne({entryId: entry._id},{sort:{ date : -1}})
	else
		return
	if lastRev == undefined
		return
	else
		moment(lastRev.date).fromNow()
	
