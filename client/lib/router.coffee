root = exports ? this

# Todo: reloadEntry = true
@navigate = (location, context) ->
  location = "/u/#{context}/#{location}" if context
  location = '/' + location if location.indexOf('/') != 0 #prevents calling route directly
  Router.go(location)

@evtNavigate = (evt) ->
  evt.preventDefault()
  if Session.get('editMode')
    Toast.warning('Save or Cancel changes before navigating away')
    return
  window.scrollTo(0, 0)
  document.body.style.height = "" # restore bigger document from magicscroll

  $a = $(evt.target).closest('a')
  href = $a.attr('href')
  localhost = document.location.host
  linkhost = $a[0].host
  if localhost == linkhost
    # support for full local URLs (e.g. http://www.yourwiki.com/page <-- won't refresh)
    relHref = $('<a/>').attr('href', href)[0].pathname
    navigate(relHref)
  else
    window.open(href, '_blank')

Hooks.onLoggedIn = () ->
  #=======================================================================
  # Maybe do something here eventually?
  #=======================================================================
  console.log("User logged out")

Hooks.onLoggedOut = () ->
  #=======================================================================
  # If a user suddenly logs out, we need to make sure they still have
  # permissions to be on the page they are
  # 
  # TODO:
  #=======================================================================
  Router.go(window.location.pathname)
  console.log("User logged in")

Hooks.init()

hasWikiRights = (wiki) ->
  #=======================================================================
  # Determine if the current user has the rights to a given wiki
  #=======================================================================


Router.map ->
  #=======================================================================
  # Global Routes (No Wiki Context)
  #=======================================================================
  @route("landing", {
    path: "/landing"
    template: "landing"
    layoutTemplate: "global"
    action: () ->
      if Meteor.userId()
        this.render("dashboard")
        Router.go("dashboard")
      else
        this.render("landing")
    })

  @route("create", {
    path: "/create"
    template: "create"
    layoutTemplate: "global"
    action: () ->
      console.log("sup")
      if Meteor.userId()
        this.render("create")
      else
        Router.go("landing")
        this.render("landing")
    })

  @route("dashboard", {
    path: "/dashboard"
    template: "dashboard"
    layoutTemplate: "global"
    action: () ->
        if Meteor.userId()
            this.render("dashboard")
        else
            this.render("landing")
            Router.go("landing")
    })

  #=======================================================================
  # Wiki Routes (All prefixed with /wikis/<name>/)
  #=======================================================================
  @route "wiki",
    path: "/wikis/:wiki_name"
    layoutTemplate: "layout"
    yieldTemplates:
      'toolbar':
        to: 'toolbar'
    action: "routeToWiki"
    controller: "WikiController"

   @route "entry",
    path: "/wikis/:wiki_name/entry/:entry_name"
    layoutTemplate: "layout"
    yieldTemplates:
      'toolbar':
        to: 'toolbar'
    template: "entry"
    waitOn: () ->
      Meteor.subscribe("userData")
      Meteor.subscribe("entries")
    action: () ->
      entry_name = this.params.entry_name
      wiki_name = this.params.wiki_name

      entry_found = Entries.find({name: entry_name})
      if entry_found
        Session.set('context', null)
        Session.set('title', entry_name)
        Session.set("wiki_name", wiki_name)

        this.render()
      else
        Router.go("landing")

  @route "search",
    path: "/search/:term"
    layoutTemplate: "layout"
    yieldTemplates:
      'toolbar':
        to: 'toolbar'
    before: ->
      Session.set('search-term', @params.term)
      Session.set('title', 'search') # forces sidebar to re-render need other session dependency

  @route "tag",
    path: "/tag/:tag"
    layoutTemplate: "layout"
    yieldTemplates:
      'toolbar':
        to: 'toolbar'
    before: ->
      Session.set('tag', @params.tag)
      Session.set('title', @params.tag)

  #TODO
  # need to determine how to set "title" on special pages
  # maybe want to set page "type" and also name" (which is similar to title)
  # type could be based on url e.g. /s/PageIndex
  @route "pageindex",
    path: "/s/PageIndex"
    layoutTemplate: "layout"
    yieldTemplates:
      'toolbar':
        to: 'toolbar'
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
    layoutTemplate: "layout"
    yieldTemplates:
      'toolbar':
        to: 'toolbar'
    before: [
      ->
        Session.set('rev1', @params.rev1)
        Session.set('rev2', @params.rev2)
        Session.set('title', @params.title)
    ]

  @route "revision",
    path: "/revision/:title/:rev"
    template: "revision"
    layoutTemplate: "layout"
    yieldTemplates:
      'toolbar':
        to: 'toolbar'
    before: ->
      Session.set("context", null)  # TODO: not sure on context thing
      Session.set("title", @params.title)
      Session.set("rev", @params.rev)

  @route "wildcard",
    path: "/*"
    layoutTemplate: "global"
    action: () ->
      this.render("landing")
      Router.go("landing")


class @WikiController extends RouteController
  template: "entry"
      
  waitOn: -> [
    Meteor.subscribe("userData"),
    Meteor.subscribe("entries") ]

  findHome: (wiki_name) ->
    home = Entries.findOne({
        title: "home",
        wiki: wiki_name
      })
    return home

  routeToWiki: () ->
    #=======================================================================
    # Routing controller to handle the main Wiki page
    #
    # (1) Whenever trying to navigate to a wiki page we must verify that the
    # the currently logged in user has read/write permissions for this wiki
    #
    #=======================================================================
    wiki_name = this.params.wiki_name
      
    console.log("Attempting to access wiki: " + wiki_name)

    wiki = Wikis.findOne({name: wiki_name})
    if wiki
      home = @findHome(wiki_name)

      Session.set('titleHidden', false)
      Session.set('title', home.title)
      Session.set("wiki_name", wiki_name)
      Router.go(EntryLib.getEntryPath(wiki_name, "home"))
    else
      this.render("landing")
      Router.go("landing")

class @User_profileController extends RouteController
  template: "user_profile"
  waitOn: Meteor.subscribe 'userData'
  sessionSetup: ->
    Session.set('context', null)
    Session.set('selectedUserName', @params.username);
    @render()
