Meteor.subscribe('entries');
Meteor.subscribe('tags')

Session.set('edit-mode', false)

Template.menu.entries = ->
    Entries.find({})

Template.entry.title = ->
    Session.get("title")

Template.entry.entry = ->
    title = Session.get("title")
    if title
        entry = Entries.findOne({'title': Session.get('title')})
        if entry
            Session.set('entry', entry )
            Session.set('entry_id', entry._id )
            entry

Template.entry.edit_mode = ->
    Session.get('edit-mode')

Template.main.index = ->
    return Session.get('index');

Template.index.content = ->
    Entries.findOne({title:"index"})

Template.editEntry.rendered = ->
    el = $( '#entry-text' )
    el.redactor();

    tags = Tags.find({})

    $('#entry-tags').textext({
        plugins : 'autocomplete suggestions tags',
        tagsItems: Session.get('entry').tags
        suggestions: tags.map (t) -> t.name
    });


Template.entry.events({
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
})

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
