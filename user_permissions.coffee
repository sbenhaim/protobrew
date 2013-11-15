root = exports ? this

# Admins can admin anywhere, others can only admin in context
root.adminable = ( user, context ) ->
    user &&
    ( user.group == "admin" ||
      user.group == context ||
      user.username == context )

# View all in context, view public and read-only otherwise
root.viewable = ( entry, user, context ) ->
    adminable( user, context ) ||
    ( context == null && (entry == null || !(entry._id?))) ||
    ( entry && entry.mode != "private" )

# Edit in context or public entries
# TODO: add ability to restrict public editing priveledges from
# users who do not belog to group = 'editor'

# TODO: editable should only return true if the page is editable 
# e.g. editable special pages, and editable entires, but not non-editable special pages
# or special pages that are editable but only by the admin
root.editable = ( entry, user, context ) ->
    user && 
    ( adminable( user, context ) ||
      ( context == null && (entry == null || !(entry._id?))) ||
      ( entry && entry.mode == "public" ) )



# from telescope
root.isAdminById = (userId) ->
  user = Meteor.users.findOne(userId)
  user and isAdmin(user)

root.isAdmin = (user) ->
  return false  if not user or typeof user is "undefined"
  return true if user.group == "admin"

root.adminUsers = ->
  Meteor.users.find(group: "admin").fetch()