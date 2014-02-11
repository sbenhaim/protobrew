root = exports ? this

Meteor.subscribe('comments')

Meteor.subscribe('settings', ->
  #runs once on site load
  # analyticsInit()
  Session.set('settingsLoaded', true)
)

Meteor.subscribe('tags')

Meteor.subscribe('revisions')

Meteor.subscribe('allUserData')

Deps.autorun(() ->
  # userData
  Meteor.subscribe("userData")

  # entries
  Meteor.subscribe("entries", () -> Session.set("entryLoaded", true))

  # wikis
  Meteor.subscribe("browsable-wikis")

)


Handlebars.registerHelper('session', (input) ->
    return Session.get(input)
)

highlightNav = ->
  headerHeight = $("header")[0].clientHeight
  pos = $(window).scrollTop()
  headlines = _.filter $('h1, h2, h3, h4, h5'), ($headline) ->
    $headline.id != "article-title"

  for headline in headlines
    if $(headline).offset().top - 10 >= pos
      id = headline.id.replace(/entry/, "nav")
      break

  $el = $("#" + id)
  $el.parents('ul').find('a').removeClass('selected')
  $el.addClass('selected')

@lockEntry = ->
  Meteor.call('lockEntry', Session.get('entryId')) if Session.get('entryId')
  Session.set('entryLocked', true)

@unlockEntry = ->
  # if Session.get('entryLocked')
  Meteor.call('unlockEntry', Session.get('entryId')) if Session.get('entryId')
  Session.set('editMode', false)
  Session.set('entryLocked', false)


window.onbeforeunload = ->
  unlockEntry()

Session.set('editMode', false)


## Nav

Deps.autorun ->
  # Random user call to force reactivity
  Meteor.user()
  if Meteor.user() && !Meteor.user().username
    $('#new-user-modal').modal({'backdrop': 'static', 'keyboard': false})

# currently the spinner atmosphere package has a bug in it where it does not work
# spinner is clone directly into the project directory
Meteor.Spinner.options = {
  top: '50'
  left: '50'
}

Template.deleteConfirmModal.events =
  'click #delete-confirm-button': (e) ->
    deleteInput = $('#delete-confirm-input').val()
    if deleteInput == "DELETE"
      deleteEntry()
      $('#delete-confirm-modal').modal('hide')
    else
      Toast.error('Must type in "DELETE" in all caps to delete')

  'click #delete-cancel-button': (e) ->
    $('#delete-confirm-modal').modal('hide')
    

## Global Helpers

Handlebars.registerHelper('entryLink', (entry) ->
  entryLink(entry)
)

Handlebars.registerHelper('modeIs', (v) ->
  return v == Session.get('entry').mode
)

Handlebars.registerHelper 'locked', ->
  entry = Session.get('entry')
  entry && entry.editing

Handlebars.registerHelper 'editable', ->
  entry = Session.get('entry')
  context = Session.get("context")
  user = Meteor.user()
  editable(entry, user, context)


Handlebars.registerHelper 'username', ->
  user = Meteor.user()
  if user
    return user.username

Handlebars.registerHelper 'isStarred', ->
  user = Meteor.user()
  entryId = Session.get('entryId')
  if user && entryId
    starredPages = user.profile.starredPages
    if entryId in starredPages
      return  true

Handlebars.registerHelper 'adminable', ->
  context = Session.get("context")
  user = Meteor.user()
  adminable(user, context)

Handlebars.registerHelper 'viewable', ->
  entry = Session.get('entry')
  context = Session.get("context")
  user = Meteor.user()
  viewable(entry, user, context)

Handlebars.registerHelper 'entryLoaded', ->
  Session.get('entryLoaded')

Handlebars.registerHelper 'editMode', ->
  Session.get('editMode')


Template.layout.modeIs = (mode) ->
  Session.get('mode') == mode;

Template.layout.loginConfigured = () ->
  if Accounts.loginServicesConfigured()
    return true;
  else
    return false;

# rewriteLinks(html) -> html
#
# This function takes some html and finds all links and
# replaces them with relative paths.  This function is not safe
# to use on text that may contain external links (currently).
#
# The class .entry-link is also added
@rewriteLinks = (text) ->
  $html = $('<div>')
  $html.html(text)

  for el in $html.find('a')
    href = $(el).attr('href')
    if href
      href = href.replace(/https?:\/\/([^\/.]+)$/, '/$1')
      $(el).attr('href', href)
      $(el).addClass('entry-link')
  $html.html()


Meteor.startup ->
  # Backbone.history.start pushState: true
  Session.set('activeTab', 'editedTab')
  Session.set('selectedCommentId', null)
  Session.set('editMode', false)
  # on small screens make sure the login screen is displayed first
  $('#leftNavContainer').toggle(true)
  $("#main").toggleClass('wLeftNav')


scrollLast = +new Date()
$(window).scroll ->
  if +new Date() - scrollLast > 30  # milliseconds
    scrollLast = +new Date();
    highlightNav()


Meteor.saveFile = (blob, name, path, type, callback) ->
  fileReader = new FileReader()
  encoding = 'binary'
  type = type || 'binary'

  switch type
    when 'text'
      method = 'readAsText'
      encoding = 'utf8'
    when 'binary'
      method = 'readAsBinaryString'
      encoding = 'binary'
    else
      method = 'readAsBinaryString'
      encoding = 'binary'

  fileReader.onload = (file) ->
    result = Meteor.call('saveFile', file.srcElement.result, name, path, encoding, (e) ->
      callback({ filelink: "/user-images/#{Meteor.userId()}/#{name}" })
    )

  fileReader[method](blob)

@RedactorPlugins = {} unless RedactorPlugins?
@RedactorPlugins.stickyScrollToolbar =
  init: ->
    toolbarOffsetFromTop = $("#entry .redactor_toolbar").offset().top
    headerHeight = $("#entry").offset().top

    stickyToolbar = ->
      scrollTop = $(window).scrollTop()
      if scrollTop > toolbarOffsetFromTop - headerHeight
        $("#entry .redactor_toolbar").addClass "sticky-toolbar-onscroll"
      else
        $("#entry .redactor_toolbar").removeClass "sticky-toolbar-onscroll"
    stickyToolbar()
    $(window).scroll ->
      stickyToolbar()

@RedactorPlugins.autoSuggest =
  init: ->
    #hijack redactor modalClose - if need to clean-up before closing
    # this.selectModalClose = this.modalClose
    # this.modalClose = ->
    #     this.selectModalClose()
    $('body').on 'click', '.redactor_dropdown_link', ->
      RedactorPlugins.autoSuggest.autoSuggest()

# $('body').on 'click','#redactor_modal_overlay', ->
#     console.log 'testing'
#     $('#select2-drop-mask').trigger('click')
#                 # select2-drop-mask

  autoSuggest: ->
    #.on to catch creation of modal (DNE before dropdown is selected)
    $('body').on 'focus', '#redactor_modal', ->
      # evt.preventDefault()
      #remove the event to stop focus from multi-firing
      $('body').off 'focus', '#redactor_modal'


      # $("#redactor_wiki_link").on "keyup keypress blur input paste change", (e)->
      #     linkText = $("#redactor_wiki_link").val()
      #     displayText = $("#redactor_wiki_link_text").val()
      #     re = new RegExp('^'+displayText, 'g')

      #     if not displayText
      #         $("#redactor_wiki_link_text").val linkText
      #     else if displayText is linkText.slice(0,-1) #linkText with the last char stripped off
      #         $("#redactor_wiki_link_text").val linkText
      #     else if re.test(linkText)
      #         $("#redactor_wiki_link_text").val linkText


      # $("#redactor_link_url").on "keyup keypress blur input paste change", (e)->
      #     linkText = $("#redactor_link_url").val()
      #     displayText = $("#redactor_link_url_text").val()
      #     re = new RegExp('^'+displayText, 'g')

      #     if not displayText
      #         $("#redactor_link_url_text").val linkText
      #     else if displayText is linkText.slice(0,-1) #linkText with the last char stripped off
      #         $("#redactor_link_url_text").val linkText
      #     else if re.test(linkText)
      #         $("#redactor_link_url_text").val linkText


      $("#redactor_link_url").on "keyup keypress blur input paste change", (e)->
        linkText = $("#redactor_link_url").val()
        displayText = $("#redactor_link_url_text").val()
        re = new RegExp('^' + displayText, 'g')

        if not displayText
          $("#redactor_link_url_text").val linkText
        else if displayText is linkText.slice(0, -1) #linkText with the last char stripped off
          $("#redactor_link_url_text").val linkText
        else if re.test(linkText)
          $("#redactor_link_url_text").val linkText


      listTitles = Entries.find({}, title: 1, context: 1).map (e) ->
        wSlash = entryLink e
        wSlash.replace(/^\//, "")

      # $("#redactor_wiki_link").textext
      #     plugins: "autocomplete suggestions"
      #     suggestions: listTitles

      idarray = []
      for i in listTitles
        idarray.push(i)

      # case where 0 length put some junk in there
      if idarray.length == 0
        idarray.push("")

      #defaultValue = $("#redactor_wiki_link").val()

      #BUG
      # this whole method is fired twice so check if already applied before applying typeahead
      if $("#redactor_link_url").hasClass('tt-query')
        return
      else
        $("#redactor_link_url").typeahead
          local: idarray
