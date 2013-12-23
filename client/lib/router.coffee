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


Router.configure
  layoutTemplate: "layout"
# notFoundTemplate: "notFound"
  loadingTemplate: "loading"
  yieldTemplates:
    'toolbar':
      to: 'toolbar'


# TODO
# each page should have a editing permission based on
# 

Router.map ->
  @route "home",
    path: "/"
    action: "gotoOrCreateHome"
    controller: "HomeController"

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



class @HomeController extends RouteController
  template: "entry"
  waitOn: Meteor.subscribe 'userData'
  gotoOrCreateHome: ->
    # remove this render once render can be inherited from Configure (next iron)
    @render
      toolbar:
        to: 'toolbar'

    entry = Entries.findOne({_id: 'home'})
    if !entry # bang on it a bit
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
    @render()

class @User_profileController extends RouteController
  template: "user_profile"
  waitOn: Meteor.subscribe 'userData'
  sessionSetup: ->
    Session.set('context', null)
    Session.set('selectedUserName', @params.username);
    @render()
