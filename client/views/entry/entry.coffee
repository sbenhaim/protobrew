# Recursively build tree of headings starting with the first one provided
#
# Example Return Value
# [{
#   "title": "title",
#   "id": 0,
#   "target": "entry-heading-0",
#   "style": "top",
#   "children": [
#     {...},
#     {...}
#   ]
# }]
#
@buildHeadingTree = (items, cur=1, counter=1) ->
    next = cur + 1
    nodes = []
    for elem, index in items
        $elem = $(elem)
        children = onlyNonEmpty($elem.nextUntil('h' + cur, 'h' + next))
        d = {}
        d.title = $elem.text()
        d.id = counter++
        d.target = "entry-heading-#{d.id}"
        d.style = "top" if cur == 0
        d.children = buildHeadingTree(children, next, counter) if children.length > 0
        nodes.push(d)
    return nodes

# Given a collection of headlines, return only those that include
# non-whitespace characters
@onlyNonEmpty = ($hs) ->
    _.filter $hs, (h) ->
      $(h).text().match(/[^\s]/) #matches any non-whitespace char


Template.entry.title = ->
    Session.get('title')

Template.entry.titleHidden = ->
    Session.get('titleHidden')

Template.entry.entryLoaded = ->
    Session.get('entryLoaded')

Template.entry.changingTitle = ->
    Session.get('changingTitle')

Template.entry.userContext = ->
    Session.get('context')

Template.entry.lastEditedBy = ->
    title = Session.get('title')
    context = Session.get('context')
    entry = findSingleEntryByTitle( title, context )
    UserLib.lastEditedBy(entry)

Template.entry.sinceLastEdit = ->
    title = Session.get('title')
    context = Session.get('context')
    entry = findSingleEntryByTitle( title, context )
    UserLib.sinceLastEdit(entry)

Template.entry.entry = ->
    title = Session.get('title')
    context = Session.get('context')
    if title
        entry = findSingleEntryByTitle(title, context)

        if entry
            Session.set('entry', entry )
            Session.set('entryId', entry._id )

            source = $('<div>').html( entry.text ) #make a div with entry.text as the innerHTML
            headings = buildHeadingTree( onlyNonEmpty( source.find(":header:first")) )
            headings.unshift( {id: 0, target: "article-title", title: Session.get('title') } )
            if headings.length > 0
                for e, i in source.find('h1,h2,h3,h4,h5')
                    e.id = "entry-heading-" + (i + 1)

            entry.text = source.html()
            entry
        else
            Session.set( 'entry', {} )
            Session.set( 'entryId', null )
            Session.get('entryLoaded')

Template.entry.events

    'click a.entry-link': (evt) ->
        if Session.get('editMode')
            evt.preventDefault()
        else
            evtNavigate(evt)

    # for Create It! button on new page
    'click .edit': (evt) ->
        Session.set( 'y-offset', window.pageYOffset )
        evt.preventDefault()
        lockEntry()
        Session.set('editMode', true)

    'click #article-title': (evt) ->
        editTitleMode(evt)

    'click #article-title-edit': (evt) ->
        editTitleMode(evt)

    'click #article-title-save': (evt) ->
        saveTitleChange()

    'click #article-title-cancel': (evt) ->
        cancelTitleChange()
    
    'keyup #article-title-input': (evt) ->
        if evt.keyCode == 13
            saveTitleChange()

        if evt.keyCode == 27
            cancelTitleChange()

@editTitleMode = (evt) ->
    entry = Session.get('entry')
    context = Session.get('context')
    user  = Meteor.user()
    if not editable( entry, user, context )
        return
    Session.set('changingTitle', true)
    evt.stopPropagation()
    $(document).on 'click', (evt)->
        if evt.target.getAttribute("id") isnt "article-title-input"
            cancelTitleChange()

@saveTitleChange = (evt) ->
    titleInput = $('#article-title-input').val().trim()
    Meteor.call 'updateTitle', Session.get('entry'), Session.get('context'), titleInput, (error, result) ->
        if error
            Toast.error('Page already exists!')
            Session.set('changingTitle', false)
        else
            navigate(titleInput)
            Session.set('changingTitle', false)

@cancelTitleChange = (evt) ->
    Session.set('changingTitle', false)
    $(document).off('click')

Template.entry.rendered = ->
    $('#article-title-input').focus()

Template.editEntry.rendered = ->
    el = $( '#entry-text' )
    html = Template.entry.entry().text
    window.EntryLib.initRedactor( el, html, ['autoSuggest', 'stickyScrollToolbar'] )
    window.scrollTo(0,Session.get('y-offset'))

    minHeight = $(window).height() - 190 #   top toolbar = 50px,  title = 90px wmargin,  redactor toolbar = 30 px,  bottom margin = 20px
    if( $('.redactor_').height() < minHeight )
        $('.redactor_').css('min-height', minHeight)

    tags = Tags.find({})
    entry = Session.get('entry')

    $('#entry-tags').textext({
        plugins : 'autocomplete suggestions tags',
        tagsItems: if entry then entry.tags else []
        suggestions: tags.map (t) -> t.name
    });


@deleteEntry = (evt) ->
    entry = Session.get('entry')
    if entry
        # delete associated comments
        if Comments.find(entry: entry._id).count() > 0
            Meteor.call('deleteComments',entry)

        #delete entry
        Meteor.call('deleteEntry',entry)
        Entries.remove(_id: entry._id)
        Session.set('editMode', false)
        Session.set('editEntry', false)
    else
        Toast.error('Cannot DELETE a page that has not been created!')

@saveEntry = (evt) ->
    reroute = ( e ) ->
        navigate( '/'+entry.title, Session.get( "context" ) ) unless entry.title == "home"

    title = Session.get('title')
    wiki_name = Session.get("wiki_name")

    console.log("Saving entry (" + title + ") for wiki (" + wiki_name + ")")


    text = rewriteLinks( $('#entry-text').redactor('get') )
    entry = {
        'title': title
        'text': text
        'mode': $('#mode').val()
    }

    tags = $('#entry-tags').nextAll('input[type=hidden]').val()

    if tags
        tags = JSON.parse(tags)
        entry.tags = tags;
        Tags.insert({'name':tag}) for tag in tags

    eid = Session.get('entryId')
    entry._id = eid if eid

    context = Session.get('context')
    # TODO should call verifySave from here and the server saveEntry function
    # rather than just the server saveEntry function?

    wiki_name = Session.get("wiki_name")
    Meteor.call('saveEntry', wiki_name, title, entry, context)
    Entries.update({_id: entry._id}, entry)
    Session.set("editMode", false)
