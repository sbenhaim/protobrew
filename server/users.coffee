Accounts.onCreateUser( (options, user) ->
  #if Settings.DOMAIN? && ! user.services.google.email.match( Settings.DOMAIN )
  if Domainer.DOMAIN? && ! user.services.google.email.match( Domainer.DOMAIN )
      throw new Meteor.Error(403, "Unauthorized")

  user.profile = options.profile or {}
  user.profile.name = user.username  unless user.profile.name
  user.profile.email = options.email  if options.email
  # user.email_hash = CryptoJS.MD5(user.profile.email.trim().toLowerCase()).toString()  if user.profile.email
  user.profile = {starredPages: []}

  users = Meteor.users.find({})
  if ( users.count() == 0 )
    user.group = 'admin'
  else
    user.group = 'editor'

  # trackEvent "new user",
  #   username: user.username
  #   email: user.profile.email

  user
)