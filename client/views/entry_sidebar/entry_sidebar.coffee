# Recursively build navigation tree from nodes, appending to element
buildNavTree = (headingNodes, $elm, lv) ->
    # each time through recursive function pull a piece of the jQuery object off
    node = headingNodes.splice(0,1)

    if node? and node.length > 0
        curLv = parseInt(node[0].tagName.substring(1))
        if curLv is lv # same level append an il
            cnt = 0
        else if curLv < lv # walk up then append il
            cnt = 0
            loop
                $elm = $elm.parent().parent()
                cnt--
                break unless cnt > (curLv - lv)
        else if curLv > lv # create children then append li
            cnt = 0
            loop
                li = $elm.children().last() # if there are already li's at this level
                if ($elm.children().last().length == 0)
                    li = $("<li>").appendTo($elm)
                $elm = $("<ul>").appendTo(li)
                cnt++
                break unless cnt < (curLv - lv)
        li = $("<li>").appendTo($elm)
        $a = $("<a/>")
        $a.attr('href', '#' + node[0].id) #for cursor purposes only
        $a.attr('id', node[0].id.replace(/entry/, "nav"))
        $a.text($(node[0]).text())
        li.append( $a )

        # recursive call
        buildNavTree(headingNodes, $elm, lv + cnt)


Template.entry_sidebar.entry = ->
    Template.entry.entry()

Template.entry_sidebar.navItems = ->
    title = Session.get("title")
    context = Session.get('context')
    if title
        entry = findSingleEntryByTitle(title, context)
        if entry
            source = $('<div>').html(entry.text) #make a div with entry.text as the innerHTML
            headings = _.filter buildHeadingTree(onlyNonEmpty(source.find(":header:first"))), (heading) ->
              heading.id != 0
            if headings.length > 0
                for e, i in source.find('h1,h2,h3,h4,h5')
                    e.id = "entry-heading-" + (i + 1)
            entry.text = source.html()

            textWithTitle = entry.text
            $headingNodes = $(textWithTitle).filter(":header")
            $result = $('<ul>')
            buildNavTree($headingNodes, $result, 1)
            $result.html()
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
