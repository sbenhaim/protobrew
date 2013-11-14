root = exports ? this

# Todo: reloadEntry = true
root.navigate = (location, context) ->
    location = "/u/#{context}/#{location}" if context
    location = '/'+location if location.indexOf('/') != 0 #prevents calling route directly
    Router.go(location)

root.evtNavigate = (evt) ->
    evt.preventDefault()
    window.scrollTo(0,0)
    $a = $(evt.target).closest('a')
    href = $a.attr('href')
    localhost = document.location.host
    linkhost = $a[0].host
    if localhost == linkhost
        # support for full local URLs (e.g. http://www.yourwiki.com/page <-- won't refresh)
        relHref = $('<a/>').attr( 'href', href )[0].pathname
        navigate(relHref)
    else
        window.open( href, '_blank')


Router.configure
    layout: "layout"
    # notFoundTemplate: "notFound"
    loadingTemplate: "loading"
    renderTemplates: 
        'toolbar': 
            to: 'toolbar'
            data: ->
                title = Session.get("title")
                context = Session.get('context')
                if title #toolbar may render before entry is ready
                    entry = findSingleEntryByTitle( title, context )

Router.map ->
    @route "home", 
        path: "/"
        action: "gotoOrCreateHome"
        controller: "HomeController"
    @route "search",
        path: "/search/:term"
        onBeforeRun: ->
            Session.set('search-term',@params.term)
    @route "tag",
        path: "/tag/:tag"
    @route "profile",
        path: "/profile"
    @route "pageindex",
        path: "/PageIndex"
        waitOn: ->
            Meteor.subscribe 'userData'
            Meteor.subscribe 'entries'
    @route "images",
        path: "images"
    @route "user_profile",
        path: "/users/:username"
        action: "sessionSetup"
        controller: "User_profileController"
    @route "users",
        path: "/users"
    @route "entry",
        path: "/:title"
        action: "sessionSetup"
        controller: "EntryController"

class @HomeController extends RouteController
    template: "entry"
    waitOn: Meteor.subscribe 'userData'
    gotoOrCreateHome: ->
        # remove this render once render can be inherited from Configure (next iron)
        @render     
            toolbar: 
                to: 'toolbar'
                data: ->
                    return entry: true

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
    waitOn: ->
        Meteor.subscribe 'userData'
        Meteor.subscribe 'entries'
    sessionSetup: ->
        Session.set('context', null)
        Session.set('title', @params.title)
        # remove this render once render can be inherited from Configure (next iron)
        @render     
            toolbar: 
                to: 'toolbar'
                data: ->
                    return entry: true
        @render()

class @User_profileController extends RouteController
    template: "user_profile"
    waitOn: Meteor.subscribe 'userData'
    sessionSetup: ->
        Session.set('context', null)
        Session.set('selectedUserName', @params.username);
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