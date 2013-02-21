Meteor.subscribe('entries');
Meteor.subscribe('tags')

Session.set('edit-mode', false)

Template.menu.entries = ->
    Entries.find({})

## MENU

Template.menu.showAllEntries = ->
    Session.get('showAllEntries')

Template.menu.content = ->
    Entries.find({'title': 'menu'})

Template.menu.events =
    'click #show-all-entries': (evt) ->
        Session.set( 'showAllEntries', ! Session.get('showAllEntries') )

## Nav

Template.leftNav.pageIs = (u) ->
    page = Session.get('title')
    return u == "/" if page == undefined
    return u == page

## Entry

Template.entry.title = ->
    Session.get("title")

Template.entry.entry = ->
    title = Session.get("title")
    if title
        entry = Entries.findOne({'title': Session.get('title')})
        if entry
            Session.set('entry', entry )
            Session.set('entry_id', entry._id )

            source = $('<div>').html( entry.text )
            titles = stackTitles( source.find( 'h1' ) )

            if titles.length > 0
                for e, i in source.find('h1,h2,h3,h4,h5')
                    e.id = "entry-title-" + i

            ul = $('<ul>')
            buildNav( ul, titles )

            $("#sidebar").html(ul)

            entry.text = source.html()
            entry

Template.entry.edit_mode = ->
    Session.get('edit-mode')

Template.main.index = ->
    return Session.get('index');

Template.index.content = ->
    entry = Entries.findOne({title:"index"})
    if entry
        Session.set('entry', entry )
        Session.set('entry_id', entry._id )
        entry

Template.editEntry.rendered = ->
    el = $( '#entry-text' )
    el.redactor();

    tags = Tags.find({})

    $('#entry-tags').textext({
        plugins : 'autocomplete suggestions tags',
        tagsItems: Session.get('entry').tags
        suggestions: tags.map (t) -> t.name
    });


Template.entry.events

    'click #edit': (evt) ->
        evt.preventDefault()
        Session.set('edit-mode', true )

    'click #save': (evt) ->

        evt.preventDefault()

        reroute = ( e ) ->
            Router.setTitle( entry.title ) unless entry.title == "home"

        title = Session.get('title') || ''

        entry = {
            'title': title
            'text': rewriteLinks( $('#entry-text').val() )
        }

        tags = $('#entry-tags').nextAll('input[type=hidden]').val()

        if tags
            tags = JSON.parse(tags)
            entry.tags = tags;
            Tags.insert({'name':tag}) for tag in tags

        entry._id = Session.get('entry_id')

        Meteor.call('saveEntry', entry, reroute)

        Session.set("edit-mode", false)

    'click #cancel': (evt) ->

        evt.preventDefault()
        Session.set("edit-mode", false)


Template.user.info = ->
    user = Meteor.user()
    console.log( "user: ", user );
    user

rewriteLinks = ( text ) ->
    $html = $('<div>')
    $html.html( text )

    for el in $html.find( 'a' )
        href = $(el).attr( 'href' )
        if href
            href = href.replace( /https?:\/\/([^\/.]+)$/, '/$1' )
            $(el).attr( 'href', href )

    $html.html()



EntryRouter = Backbone.Router.extend({
    routes: {
        ":title": "main",
        "": "index"
    },
    index: ->
        Session.set("index", 'true')
    main: (title) ->
        Session.set("index", false)
        Session.set("title", decodeURIComponent( title ))
    setTitle: (title) ->
        this.navigate(title, true)
})

Router = new EntryRouter

Meteor.startup(-> Backbone.history.start({pushState: true}))


##################################
## NAV

Template.sidebar.navItems = ->
    Session.get('sidebar')

stackTitles = (items, cur, counter) ->

    cur = 1 if cur == undefined
    counter = { n: 0 } if counter == undefined

    next = cur + 1

    for elem, index in items
        elem = $(elem)
        children  =  elem.nextUntil( 'h' + cur, 'h' + next )

        d = {};
        d.title = elem.html()
        # d.y  = elem.offset().top
        d.id = counter.n++

        d.style = "top" if cur == 0

        d.children = stackTitles( children, next, counter ) if children.length > 0

        d


buildNav = ( ul, items ) ->
    for child, index in items

        li = $( "<li>" )
        $( ul ).append( li )
        $a = $("<a/>")
        $a.attr( "id", "nav-title-" + child.id )
        $a.addClass( child.style )

        $a.on( "click", ->
            id = this.id
            target_id = id.replace( /nav/, 'entry' )
            offset = $('#' + target_id).offset()
            $( 'html,body' ).animate( { scrollTop: offset.top }, 500 )
        )

        $a.attr( 'href', 'javscript:void(0)' )
        $a.html( child.title )
        
        li.append( $a )

        if child.children
            subUl = document.createElement( 'ul' )
            li.append( subUl )
            buildNav( subUl, child.children )

highlightNav = ->

    pos = $(window).scrollTop( )
    headlines = $('h1, h2, h3, h4, h5')

    # id = null

    for headline in headlines
        if $(headline).offset().top + 20 > pos
            id = headline.id.replace( /entry/, "nav" )
            break

    el = $("#" + id)

    # todo: remove
    el.parents( 'ul' ).find( 'a' ).css( 'color', 'black' )
    el.parents( 'ul' ).find( 'a' ).removeClass( 'selected' )
    # el.parents( 'li' ).last().addClass( 'selected' )
    el.addClass( 'selected' )
    # todo: remove
    el.css( 'color', 'red' )

scrollLast = +new Date()


$(window).scroll ->
    if +new Date() - scrollLast > 50
        scrollLast = +new Date();
        highlightNav()

