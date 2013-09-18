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

# getAvatarUrl = (user) ->
#   if getSignupMethod(user) is "twitter"
#     "http://twitter.com/api/users/profile_image/" + user.services.twitter.screenName
#   else
#     Gravatar.getGravatar user,
#       d: "http://demo.telesc.pe/img/default_avatar.png"
#       s: 30


# getCurrentUserEmail = ->
#   (if Meteor.user() then getEmail(Meteor.user()) else "")

# userProfileComplete = (user) ->
#   !!getEmail(user)

# findLast = (user, collection) ->
#   collection.findOne
#     userId: user._id
#   ,
#     sort:
#       createdAt: -1


# timeSinceLast = (user, collection) ->
#   now = new Date().getTime()
#   last = findLast(user, collection)
#   return 999  unless last # if this is the user's first post or comment ever, stop here
#   Math.abs Math.floor((now - last.createdAt) / 1000)

# numberOfItemsInPast24Hours = (user, collection) ->
#   mDate = moment(new Date())
#   items = collection.find(
#     userId: user._id
#     createdAt:
#       $gte: mDate.subtract("hours", 24).valueOf()
#   )
#   items.count()