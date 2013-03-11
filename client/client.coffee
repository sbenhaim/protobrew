Meteor.subscribe('entries');
Meteor.subscribe('tags')

Session.set('edit-mode', false)

navigate = (location) ->
    Router.navigate(location, true)

evtNavigate = (evt) ->
    evt.preventDefault()
    $a = $(evt.target).closest('a')
    href = $a.attr('href')
    localhost = document.location.host
    linkhost = $a[0].host

    if localhost == linkhost
        navigate(href)
    else
        window.open( href, '_blank')

## Nav

Template.leftNav.events =
    'click a.left-nav': evtNavigate

    'change #search-input': (evt) ->
        term = $(evt.target).val()
        navigate( '/search/' + term ) if term

getSummaries = (entries) ->
    entries.map (e) ->
        
        text = $('<div>').html( e.text ).text()
        text = text.substring(0,200) + '...' if text.length > 204;
        
        {text: text, title: e.title}

Template.search.term = -> Session.get( 'search-term' )

Template.search.results = ->
    term = Session.get('search-term')

    return unless term
    
    entries = Entries.find( {text: new RegExp( term, "i" )} )
    getSummaries( entries )

Template.search.events
    'click a': evtNavigate

Template.tag.events
    'click a': evtNavigate


Template.tag.tag = ->
    Session.get( 'tag' )

Template.tag.results = ->
    tag = Session.get('tag')

    return unless tag
    
    entries = Entries.find( { tags: tag } )
    console.log( "tag: ", tag );
    console.log( "entries: ", entries );
    getSummaries( entries )

Template.leftNav.term = -> Session.get( 'search-term' )

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
        else
            Session.set( 'entry', null )
            Session.set( 'entry_id', null )

Template.entry.edit_mode = ->
    Session.get('edit-mode')

Template.main.modeIs = (mode) ->
    Session.get('mode') == mode;

Template.index.content = ->
    entry = Entries.findOne({title:"index"})
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

        entry

Template.index.events
    'click a.entry-link': evtNavigate

Template.editEntry.events
    'focus #entry-tags': (evt) ->
        console.log( "hello" );
        $("#tag-init").show()

Template.editEntry.rendered = ->
    el = $( '#entry-text' )
    el.redactor(
        imageUpload: '/images'
        buttons: ['html', '|', 'formatting', '|', 'bold', 'italic', 'deleted', '|', 
            'unorderedlist', 'orderedlist', 'outdent', 'indent', '|',
            'image', 'table', 'link', '|',
            'fontcolor', 'backcolor', '|', 'alignment', '|', 'horizontalrule', '|',
            'save', 'cancel', 'delete'],
        buttonsCustom:
            save:
                title: 'Save'
                callback: saveEntry
            cancel:
                title: 'Cancel'
                callback: ->
                    Session.set("edit-mode", false)
            delete:
                title: 'Delete'
                callback: deleteEntry
        focus: true
        autoresize: true
        filepicker: (callback) ->

            filepicker.setKey('AjmU2eDdtRDyMpagSeV7rz')

            filepicker.pick({mimetype:"image/*"}, (file) ->
                filepicker.store(file, {location:"S3", path: Meteor.userId() + "/" + file.filename },
                (file) -> callback( filelink: file.url )))
    )

    tags = Tags.find({})
    entry = Session.get('entry')

    $('#entry-tags').textext({
        plugins : 'autocomplete suggestions tags',
        tagsItems: if entry then entry.tags else []
        suggestions: tags.map (t) -> t.name
    });

deleteEntry = (evt) ->
    entry = Session.get('entry')
    if entry && confirm( "Are you sure you want to delete #{entry.title}?")
        Entries.remove({_id: entry._id})
        Session.set('edit-mode', false)

saveEntry = (evt) ->
    reroute = ( e ) ->
        Router.setTitle( entry.title ) unless entry.title == "home"

    title = Session.get('title')

    entry = {
        'title': title
        'text': rewriteLinks( $('#entry-text').val() )
    }

    tags = $('#entry-tags').nextAll('input[type=hidden]').val()

    if tags
        tags = JSON.parse(tags)
        entry.tags = tags;
        Tags.insert({'name':tag}) for tag in tags

    eid = Session.get('entry_id')
    entry._id = eid if eid

    Meteor.call('saveEntry', entry, reroute)

    Session.set("edit-mode", false)


Template.entry.events

    'click li.article-tag a': (evt) ->
        evt.preventDefault()
        tag = $(evt.target).text()
        navigate( '/tag/' + tag ) if tag

    'click a.entry-link': (e) ->
        evtNavigate(e) unless Session.get('edit-mode')

    'click #edit': (evt) ->
        evt.preventDefault()
        Session.set('edit-mode', true )

    'click #save': (evt) ->
        evt.preventDefault()
        saveEntry( evt )

    'click #cancel': (evt) ->
        evt.preventDefault()
        Session.set("edit-mode", false)

    'click #delete': (evt) ->
        evt.preventDefault()
        deleteEntry(evt)

    'click #article-title': (evt) ->
        return unless Meteor.userId() && Session.get('entry')

        $el = $(evt.target)
        $in = $("<input class='entry-title-input'/>")
        console.log( "$el.text(): ", $el.text().trim() );
        $in.val( $el.text().trim() )
        $el.replaceWith($in)
        $in.focus()

        updateTitle = (e, force = false) ->
            if force || e.target != $el[0] && e.target != $in[0]
                if $in.val() != $el.text()
                    Meteor.call('updateTitle', Session.get('entry'), $in.val())
                    $el.html($in.val())
                    navigate($in.val())

                $in.replaceWith($el)
                $(document).off('click')

        cancel = (e, force = false) ->
            if force || e.target != $el[0] && e.target != $in[0]
                $in.replaceWith($el)
                $(document).off('click')

        $(document).on('click', cancel)

        $in.on("keyup", (e) ->
            updateTitle(e, true) if e.keyCode == 13
            cancel(e, true) if e.keyCode == 27
        )


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
            $(el).addClass( 'entry-link' )

    $html.html()


EntryRouter = Backbone.Router.extend({
    routes: {
        "search/:term": "search"
        "tag/:tag": "tag",
        "images": "images",
        ":title": "main",
        "": "index"
    },
    index: ->
        Session.set("mode", 'index')
        Session.set("title", undefined)
    search: (term) ->
        Session.set( 'mode', 'search' )
        Session.set( 'search-term', decodeURIComponent( term ) )
    tag: (tag) ->
        Session.set( 'mode', 'tag' )
        Session.set( 'tag', decodeURIComponent( tag ) )
    main: (title) ->
        Session.set("mode", 'entry')
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
            adjust = if Session.get( 'edit-mode' ) then 70 else 20
            $( 'html,body' ).animate( { scrollTop: offset.top - adjust }, 500 )
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

    el.parents( 'ul' ).find( 'a' ).removeClass( 'selected' )
    # el.parents( 'li' ).last().addClass( 'selected' )
    el.addClass( 'selected' )


scrollLast = +new Date()


$(window).scroll ->
    if +new Date() - scrollLast > 50
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
        callback( { filelink: "/user-images/#{Meteor.userId()}/#{name}" } )
    )

  fileReader[method](blob)
