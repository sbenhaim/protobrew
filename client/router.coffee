class @WikiRouter
    constructor: (wiki_manager, user_manager) ->
        #=======================================================================
        # Router constructor
        #=======================================================================
        @wiki_manager = wiki_manager
        @user_manager = user_manager

    start: () =>
        #=======================================================================
        # Start
        #=======================================================================

        Router.configure({
            
        })

        @_mapRoutes()

        Hooks.onLoggedIn = () ->
            @_onLoggedIn

        Hooks.onLoggedOut = () ->
            @_onLoggedOut

        Hooks.init()        

    _onLoggedIn: () =>
        Router.go(window.location.pathname)

    _onLoggedOut: () =>
        Router.go(window.location.pathname)

    _mapRoutes: () =>
        #=======================================================================
        # Closure for the router so it has a ref to ``wiki_manager``
        #=======================================================================
        wiki_manager = @wiki_manager
        user_manager = @user_manager
        self = this

        Router.map(() ->
            @route("wiki", {
                template: "entry"
                path: "/wikis/:wiki_name"
                layoutTemplate: "layout"
                loadingTemplate: "loading"
                yieldTemplates:
                    'toolbar': to: 'toolbar'
                action: () ->
                    wiki_name = this.params.wiki_name
                    has_rights = wiki_manager.hasRights(wiki_name)
                    if has_rights
                        console.log this
                        console.log "Welcome to - " + wiki_name
                        this.render("wiki")
                        Session.set("current_wiki", wiki_name)
                    else
                        console.log "Not a valid wiki name - " + wiki_name
                        this.render("landing")
                        Router.go("landing")

                    # # remove this render once render can be inherited from Configure (next iron)
                    # @render
                    #   toolbar:
                    #     to: 'toolbar'

                    # entry = Entries.findOne({_id: 'home'})
                    # if !entry # bang on it a bit
                    #     fn = () -> return @render()
                    #     Meteor.call 'createHome', fn
                    # else
                    #     Session.set('titleHidden', false)
                    #     # Session.set('mode', 'entry')
                    #     Session.set('title', entry.title)
                    #     @render()

                waitOn: () ->
                    Meteor.subscribe("userData")
                    return Meteor.subscribe("wikis")
                })

            @route("create", {
                path: "/create"
                template: "create"
                action: () ->
                    loggedIn = user_manager.isLoggedIn()
                    if loggedIn
                        this.render("create")
                    else
                        Router.go("landing")
                        this.render("landing")
                })

            @route("dashboard", {
                path: "/dashboard"
                template: "dashboard"
                action: () ->
                    if Meteor.userId()
                        this.render("dashboard")
                    else
                        this.render("landing")
                        Router.go("landing")
                })

            @route("landing", {
                path: "/landing"
                template: "landing"
                action: () ->
                    if Meteor.userId()
                        this.render("dashboard")
                        Router.go("dashboard")
                    else
                        this.render("landing")
                })

            @route "search",
                path: "/search/:term"
                before: ->
                  Session.set('search-term', @params.term)
                  Session.set('title', 'search') # forces sidebar to re-render need other session dependency

            @route "tag",
                path: "/tag/:tag"
                before: ->
                  Session.set('tag', @params.tag)
                  Session.set('title', @params.tag)

            #TODO
            # need to determine how to set "title" on special pages
            # maybe want to set page "type" and also name" (which is similar to title)
            # type could be based on url e.g. /s/PageIndex
            @route "pageindex",
                path: "/s/PageIndex"
                before: ->
                  Session.set('title', 'PageIndex')
                waitOn: ->
                  Meteor.subscribe 'userData'
                  Meteor.subscribe 'entries'

            @route "images",
                path: "images"

            @route "user_profile",
                path: "/users/:username"
                action: "sessionSetup"
                before: ->
                  Session.set('title', 'user_profile')
                controller: "User_profileController"

            #TODO ensure /users page can't be created
            @route "users",
                path: "/users"

            @route "history",
                path: "/history/:title"
                template: "history"
                before: ->
                  Session.set('context', null)
                  Session.set('title', @params.title)

            @route "compare",
                path: "/compare/:title/:rev1/:rev2"
                template: "compare"
                before: [
                  ->
                    Session.set('rev1', @params.rev1)
                    Session.set('rev2', @params.rev2)
                    Session.set('title', @params.title)
                ]

            @route "revision",
                path: "/revision/:title/:rev"
                template: "revision"
                before: ->
                  Session.set("context", null)  # TODO: not sure on context thing
                  Session.set("title", @params.title)
                  Session.set("rev", @params.rev)

            @route "entry",
                path: "/:title"
                action: "sessionSetup"
                controller: "EntryController"

            @route("wildcard", {
                path: "*"
                action: () ->
                    this.render("landing")
                    Router.go("landing")
                })
        )

    navigate: (location, context) =>
        location = "/u/#{context}/#{location}" if context
        location = '/'+location if location.indexOf('/') != 0 #prevents calling route directly
        Router.go(location)

    evtNavigate: (evt) =>
        evt.preventDefault()
        if Session.get('editMode')
            Toast.warning('Save or Cancel changes before navigating away')
            return
        window.scrollTo(0,0)
        document.body.style.height = "" # restore bigger document from magicscroll

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


# class @WikiController extends RouteController
#     template: "entry"
#     waitOn: Meteor.subscribe 'userData'

#     constructor: (wiki_manager) ->
#         @wiki_manager = wiki_manager

#     gotoOrCreateHome: ->
#         wiki_name = this.params.wiki_name
#         has_rights = wiki_manager.hasRights(wiki_name)
#         if has_rights
#             console.log "Welcome to - " + wiki_name
#             this.render("wiki")
#             Session.set("current_wiki", wiki_name)
#         else
#             console.log "Not a valid wiki name - " + wiki_name
#             this.render("landing")
#             Router.go("landing")

#         # # remove this render once render can be inherited from Configure (next iron)
#         # @render
#         #   toolbar:
#         #     to: 'toolbar'

#         entry = Entries.findOne({_id: 'home'})
#         if !entry # bang on it a bit
#             fn () -> return @render()
#             Meteor.call 'createHome', fn
#         else
#             Session.set('titleHidden', false)
#             # Session.set('mode', 'entry')
#             Session.set('title', entry.title)
#             @render()


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
    @render()


class @User_profileController extends RouteController
  template: "user_profile"
  waitOn: Meteor.subscribe 'userData'
  sessionSetup: ->
    Session.set('context', null)
    Session.set('selectedUserName', @params.username);
    @render()
