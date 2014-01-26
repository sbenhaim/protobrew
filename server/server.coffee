throw new Meteor.Error( 500, "No `Domain' defined (need server/_domainer.coffee)" ) unless Domainer?


getClientOrServer = () ->
    if Meteor.isServer
        return "Server"

    if Meteor.isClient
        return "Client"

    return "Unknown"


Meteor.methods

   updateTitle: (entry, context, title, callback) ->

        throw new Meteor.Error(403, "You must be logged in") unless this.userId

        # todo: insert verifyTitle function check 
        # checks for characters that are unencodeable with encodeURIComponent
        # encodeURIComponent() will not encode: ~!*()'"
        # http://stackoverflow.com/questions/4540753/encodeuri-or-encodeuricomponent
        
        existingEntry =  findSingleEntryByTitle(entry.wiki, context, title)
        if existingEntry 
            if existingEntry.title.toLowerCase() == entry.title.toLowerCase()
                return Entries.update( {_id: entry._id}, {$set: {'title': title}} )
            else
                throw new Meteor.Error(403, "page name already exists")
        else
            return Entries.update( {_id: entry._id}, {$set: {'title': title}} )


    deleteEntry:(entry) ->
        # add permission check
        if entry._id is null
            return
        if typeof entry._id is 'undefined'
            return
        id = Entries.remove({_id: entry._id})
        return id

    deleteComments:(entry) ->
        # add permission check
        if entry._id is null
            return
        if typeof entry._id is 'undefined'
            return
        id = Comments.remove(entry: entry._id)
        return id

    # Todo: lock down fields
    saveEntry: (wiki_name, title, entry, context, callback) ->
        # todo: insert verifyTitle function check 

        # Only members can edit
        user = Meteor.user()
        entry = verifySave(wiki_name, title, entry, user, context)
        entry.context = context

        if entry._id
            Entries.update({_id: entry._id}, entry)
            id = entry._id
        else
            id =  Entries.insert(entry)

        full_entry = {
            entryId: id,
            date: new Date(),
            text: entry.text,
            author: user._id,
            wiki_name: wiki_name
        }
        Revisions.insert(full_entry)

        return id

    lockEntry: ( entryId ) ->
        Entries.update( {_id: entryId}, {$set: {"editing": true}}) if entryId

    unlockEntry: ( entryId ) ->
        Entries.update( {_id: entryId}, {$set: {"editing": false}}) if entryId

    updateUser: (value) ->
        throw new Meteor.Error(403, "You must be logged in") unless this.userId

        existing = Meteor.users.find( {"username": value} ).count()
        throw new Meteor.Error(403, "Username exists") if existing > 0

        Meteor.users.update( {_id: this.userId}, {$set: {"username": value}}) if value


    createNewPage: (wikiName) ->
        #ownUnnamedPages = Entries.find( { author : this.userId, title : {$regex: /^unnamed-/ }}, {sort: { title: 1 }}).fetch() # .find(query, projection)
        ownUnnamedPages = Entries.find( {
          context: null,
          title:  {$regex: /^unnamed-/ },
          wiki: wikiName,
        }, {sort: { title: 1 }}).fetch() # .find(query, projection)
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


    createHome: (wiki_name) ->
      entry_name = "home"
    
      _entry = {
        title: "home",
        mode: "public",
        wiki: wiki_name,
        context: null,
      }
      Entries.insert(_entry)
      console.log("Entry created: " + entry_name)
      console.log("All entries: ")
      console.log(Entries.find().fetch())
        

    createWiki: (wiki_name, visibility, owner) =>
        #=======================================================================
        # Create a wiki
        # 
        # If Public:
        #       Make sure the wiki_name is valid and create
        #
        # If private:
        #       Make sure wiki_name is valid and create, also need to
        #       set the current user as the only valid user in the wiki
        #=======================================================================
        already_exists = Wikis.findOne({name: wiki_name})
        if already_exists
            console.log("Wiki already exists - " + wiki_name)
        else
            # TODO: on the server (not simulation), do validation
            Wikis.insert({
                name: wiki_name
                visibility: visibility
                owners: [owner]
                readers: [owner]
                writers: [owner]
                admins: [owner]
                })
            console.log("Wiki created - " + wiki_name)
