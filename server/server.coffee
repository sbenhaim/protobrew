class @Server
    constructor: () ->
        #=======================================================================
        # Server constructor
        #=======================================================================
        @reqHeaders = null

    start: () =>
        #=======================================================================
        # Start
        #=======================================================================
        if (typeof WebApp != "undefined")
            app = WebApp.connectHandlers
        else
            app = __meteor_bootstrap__.app
        app.use (request, response, next) =>
            @_onClientConnect request, response, next

        Meteor.methods({
            getReqHeaders: @getReqHeaders
            getReqHeader: @getReqHeader
            createWiki: @createWiki
        })

        @_publish()

    _onClientConnect: (request, response, next) =>
        #=======================================================================
        # Called on client connect
        #=======================================================================
        @reqHeaders = request.headers
        return next()

    _publish: () =>
        # Make a publication for all available wikis we can route the current
        # user to, i.e. all public wikis and all private wikis with `read` rights
        Meteor.publish("browsable-wikis", () ->
            return Wikis.find({
                    $or: [
                        {
                            visibility: "public"
                        },
                        {
                            visibility: "private",
                            readers: this.userId
                        }
                    ]
                })
            )

    getReqHeaders: () =>
        #=======================================================================
        # Get all headers
        #=======================================================================
        return @reqHeaders

    getReqHeader: (header) =>
        #=======================================================================
        # Get specific header
        #=======================================================================
        return @reqHeaders[header]

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
            Wikis.insert({
                name: wiki_name
                visibility: visibility
                owners: [owner]
                readers: [owner]
                writers: [owner]
                admins: [owner]
                })
            console.log("Wiki created -" + wiki_name)
