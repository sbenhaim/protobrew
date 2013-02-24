Meteor.publish('entries', (title) ->
    terms = {$or: [{'visibility': "public"}, {author: this.userId}]}
    term['$or'].push( { 'title': title } ) if title

    Entries.find(terms)
)


Meteor.publish('tags', -> return Tags.find({}))



Meteor.methods

    updateTitle: (entry, title, callback) ->
        throw new Meteor.Error(403, "You must be logged in") unless this.userId
        return Entries.update( {_id: entry._id}, {$set: {'title': title}} )

    # Todo: lock down fields
    saveEntry: (entry, callback) ->
        throw new Meteor.Error(403, "You must be logged in") unless this.userId

        entry.author = this.userId
        entry.visibility = "public"

        return Entries.insert(entry, callback) unless entry._id
        return Entries.update({_id: entry._id}, entry, callback)

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


# __meteor_bootstrap__.app.stack.splice (0, 0, {
#     route: '/images',
#     handle: function (req,res, next) {
#         //handle upload
#     }.future ()
# });