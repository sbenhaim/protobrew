Meteor.publish("userData", ->
    Meteor.users.find({_id: this.userId}, {fields: {'username': 1, 'group': 1, 'profile': 1}})
)

Meteor.publish("allUserData", () ->
  user = Meteor.users.findOne({_id: this.userId}) if this.userId
  if user && user.group == "admin"
    return Meteor.users.find();
  else
    Meteor.users.find({}, {fields: {'username': 1}});
)

Meteor.publish('revisions', -> Revisions.find({}))

Meteor.publish('entries', (context) ->

    # Todo: Temporary
    return Entries.find({})

    # Todo: Use when Meteor gets aggregates
    user = Meteor.users.findOne({_id: this.userId}) if this.userId

    # Admins see all!
    if user && user.group == "admin"
        return Entries.find({})

    conditions = [{$ne: ["$entry.mode", "private"]}]

    if user
        conditions.push( {$eq: ["$entry.context": user.username] } ) if user.username
        conditions.push( {$eq: ["$entry.context": user.group] } )    if user.group
    
    visible = {$or: conditions}

    entries = Entries.aggregate
                $project:
                    title: true
                    mode: true
                    context: true
                    tags: {$cond: [visible, "$tags", ""]}
                    text: {$cond: [visible, "$text", ""]}
)


Meteor.publish('tags', -> return Tags.find({}))


######################################################
## telescope integration
##
Meteor.publish('comments', ->
    # Comments.find(query)
    Comments.find({})
)

Meteor.publish('settings', ->
  Settings.find({})
)

##
##
######################################################

# Users

# Meteor.publish('currentUser', function() {
#   return Meteor.users.find(this.userId);
# });
# Meteor.publish('allUsers', function() {
#   if (this.userId && isAdminById(this.userId)) {
#     // if user is admin, publish all fields
#     return Meteor.users.find();
#   }else{
#     // else, filter out sensitive info
#     return Meteor.users.find({}, {fields: {
#       secret_id: false,
#       isAdmin: false,
#       emails: false,
#       notifications: false,
#       'profile.email': false,
#       'services.twitter.accessToken': false,
#       'services.twitter.accessTokenSecret': false,
#       'services.twitter.id': false,
#       'services.password': false,
#       'services.resume': false
#     }});
#   }
# });

# Posts

# a single post, identified by id
# Meteor.publish('singlePost', function(id) {
#   return Posts.find(id);
# });

# Meteor.publish('paginatedPosts', function(find, options, limit) {
#   options = options || {};
#   options.limit = limit;
#   return Posts.find(find || {}, options);
# });

# Meteor.publish('postDigest', function(date) {
#   var mDate = moment(date);
#   return findDigestPosts(mDate);
# });

# Other Publications

# Meteor.publish('comments', function(query) {
#   return Comments.find(query);
# });

# Meteor.publish('settings', function() {
#   return Settings.find();
# });

# Meteor.publish('notifications', function() {
#   // only publish notifications belonging to the current user
#   return Notifications.find({userId:this.userId});
# });

# Meteor.publish('categories', function() {
#   return Categories.find();
# });

