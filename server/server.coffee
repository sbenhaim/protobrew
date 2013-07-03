throw new Meteor.Error( 500, "No `Settings' defined (need server/_settings.coffee)" ) unless Settings?

Accounts.onCreateUser( (options, user) ->
    if Settings.DOMAIN? && ! user.services.google.email.match( Settings.DOMAIN )
        throw new Meteor.Error(403, "Unauthorized")

    users = Meteor.users.find({})
    if ( users.count() == 0 )
        user.group = 'admin'

    user.profile = {starredPages: []}

    user
)

Meteor.publish("userData", ->
    Meteor.users.find({_id: this.userId}, {fields: {'username': 1, 'group': 1, 'profile': 1}})
)

Meteor.publish("allUserData", () ->
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

Meteor.methods

    updateTitle: (entry, context, title, callback) ->
        throw new Meteor.Error(403, "You must be logged in") unless this.userId
        if findSingleEntryByTitle( title, context )
            throw new Meteor.Error(403, "page name already exists")
        else
            return Entries.update( {_id: entry._id}, {$set: {'title': title}} )

    # Todo: lock down fields
    saveEntry: (title, entry, context, callback) ->
        # Only members can edit
        user = Meteor.user()
        entry = verifySave(title, entry, user, context )
        entry.context = context

        if entry._id
            Entries.update({_id: entry._id}, entry)
            id = entry._id
        else
            id =  Entries.insert(entry)

        Revisions.insert( { entryId: id, date: new Date(), text: entry.text, author: user._id } )

        return id

    createHome: () ->
        bail = (message, status = 403) ->
            throw new Meteor.Error(status, message)

        entry = Entries.findOne({_id: "home"})
        if ! entry
            id =  Entries.insert({_id: "home", title: "home"})

    lockEntry: ( entryId ) ->
        Entries.update( {_id: entryId}, {$set: {"editing": true}}) if entryId

    unlockEntry: ( entryId ) ->
        Entries.update( {_id: entryId}, {$set: {"editing": false}}) if entryId

    updateUser: (value) ->
        throw new Meteor.Error(403, "You must be logged in") unless this.userId

        existing = Meteor.users.find( {"username": value} ).count()
        throw new Meteor.Error(403, "Username exists") if existing > 0

        Meteor.users.update( {_id: this.userId}, {$set: {"username": value}}) if value


    createNewPage: () ->
        #ownUnnamedPages = Entries.find( { author : this.userId, title : {$regex: /^unnamed-/ }}, {sort: { title: 1 }}).fetch() # .find(query, projection)
        ownUnnamedPages = Entries.find( { context: null, title : {$regex: /^unnamed-/ }}, {sort: { title: 1 }}).fetch() # .find(query, projection)
        if ownUnnamedPages.length == 0
            console.log('1')
            return 'unnamed-1'
        else
            seq = 1
            posted = false
            for page in ownUnnamedPages
                in_array = false
                for array_slice, i in ownUnnamedPages
                    if array_slice[i] == 'unnamed-'+seq
                        in_array = true
                        break
                    seq = seq + 1
                if in_array
                    seq = 0
                    continue
                else
                    return 'unnamed-'+seq
            next_seq = ownUnnamedPages.length + 1     
            return 'unnamed-'+next_seq   

    saveFile: (blob, name, path, encoding) ->
        throw new Meteor.Error(403, "You must be logged in") unless this.userId

        cleanPath = (str) ->
          if str
            str.replace(/\.\./g,'').replace(/\/+/g,'').replace(/^\/+/,'').replace(/\/+$/,'')

        cleanName = (str) ->
          str.replace(/\.\./g,'').replace(/\//g,'')

        path = cleanPath(path)
        fs = __meteor_bootstrap__.require('fs')
        name = cleanName(name || 'file')
        encoding = encoding || 'binary'
        chroot = 'public'

        path = chroot + (if path then '/' + path + '/' else '/')

        path = "public/user-images/#{this.userId}/"

        fs.mkdirSync( path ) if ! fs.existsSync( path )

        fs.writeFile(path + name, blob, encoding, (err) ->
          if err
            console.log( "err" );
          else
            console.log('The file ' + name + ' (' + encoding + ') was saved to ' + path)
        );

        return {filelink: path + name}