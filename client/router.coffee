Router.configure
    layout: "layout"
    # notFoundTemplate: "notFound"
    loadingTemplate: "loading"

Router.map ->
    @route "home", 
        path: "/"
        action: "gotoOrCreateHome"
        controller: "HomeController"
    @route "search",
        path: "/search/:term"
    @route "tag",
        path: "/tag/:tag"
    @route "profile",
        path: "profile"
    @route "pageindex",
        path: "/PageIndex"
    @route "images",
        path: "images"
    @route "userSpace",
        path: "/users/:user"
    @route "users",
        path: "users"
    @route "entry",
        path: "/:title"
        action: "sessionSetup"
        controller: "EntryController"

class @HomeController extends RouteController
    template: "entry"
    waitOn: Meteor.subscribe 'userData'
    gotoOrCreateHome: ->
        entry = Entries.findOne({_id: 'home'})
        if ! entry # bang on it a bit
           Meteor.call 'createHome', render_home
        else
           Session.set('titleHidden', false)
           # Session.set('mode', 'entry')
           Session.set('title', entry.title)
           @render()
        render_home = () ->
            @render()
            

class @EntryController extends RouteController
    template: "entry"
    waitOn: Meteor.subscribe 'userData'
    sessionSetup: ->
        Session.set('context', null)
        Session.set('title', @params.title)
        @render()



    # redirectHome: ->
    #     this.navigate( "", true )
    # home: ->
    #     unlockEntry()

    # profile: (term) ->
    #     unlockEntry()
    #     Session.set( 'mode', 'profile' )

    # userSpace: (username) ->
    #     unlockEntry()
    #     Session.set('titleHidden', false)
    #     Session.set('mode', 'entry')
    #     Session.set('context', username)

    # main: (title) ->
    #     unlockEntry()
    #     Session.set('titleHidden', false)
    #     Session.set('mode', 'entry')
    #     Session.set('context', null)
    #     Session.set('title', decodeURIComponent( title ))