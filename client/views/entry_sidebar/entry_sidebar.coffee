Template.entry_sidebar.entry = ->
    Template.entry.entry()


# Template.editEntry.events
#     'focus #entry-tags': (evt) ->
#         $("#tag-init").show()

Template.entry_sidebar.navItems = ->
    title = Session.get("title")
    context = Session.get('context')
    if title
        entry = findSingleEntryByTitle( title, context )
        if entry
            source = $('<div>').html( entry.text ) #make a div with entry.text as the innerHTML

            # TODO: replace wtih function and user here and Template.entry.entry
            headings = stackTitles( filterHeadlines( source.find(":header:first")) )
            headings.unshift( {id: 0, target: "article-title", title: Session.get('title') } )
            if headings.length > 0
                for e, i in source.find('h1,h2,h3,h4,h5')
                    e.id = "entry-heading-" + (i + 1)
            entry.text = source.html()
            # endTODO

            textWithTitle = '<h1 id="article-title" class="article-title">'+title+'</h2>'+entry.text
            $headingNodes = $(textWithTitle).filter(":header")
            result = $('<ul>')
            buildRec($headingNodes,result,1)
            result.html()
    else
    	return false


Template.entry_sidebar.events
    'click #entry-sidebar-outline a': (evt) ->
        evt.preventDefault()
        $el = $(evt.currentTarget)
        #dataTarget = $el.attr('data-target')
        dataTarget = $el.attr('href')
        offset = $(dataTarget).offset()
        adjust = if Session.get( 'editMode' ) then 80 else 50
        
        # ensures the document has enough height so that the heading can be scrolled fully to the top left
        if ( offset.top - adjust + $(window).height() ) > $(document).height()
            document.body.style.height = ( offset.top - adjust + $(window).height() ) + "px" #reset in the evtNavigate function

        $( 'html,body' ).animate( { scrollTop: offset.top - adjust }, 350 )
    
    'click #entry-sidebar-tags a': (evt) ->
        evt.preventDefault()
        tag = $(evt.target).text()
        window.scrollTo(0,0) # fix for position 
        navigate( '/tag/' + tag ) if tag