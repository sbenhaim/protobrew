root = exports ? this

Meteor.subscribe 'entries', onComplete = ->
  Session.set('entryLoaded', true)

Meteor.subscribe('comments')

Meteor.subscribe('settings', ->
  #runs once on site load
  # analyticsInit()
  Session.set('settingsLoaded',true)
)

Meteor.subscribe('tags')

Meteor.subscribe('revisions')

Meteor.subscribe('allUserData')

Deps.autorun( ->
    Meteor.subscribe("userData")
);

# Deps.autorun(function() {
#   var query = { $or : [ { post : Session.get('selectedPostId') } , { _id : Session.get('selectedCommentId') } ] };
#   Meteor.subscribe('comments', query, function() {
#     Session.set('singleCommentReady', true);
#   });
# });

root.lockEntry = ->
    Meteor.call( 'lockEntry', Session.get('entryId') ) if Session.get('entryId')
    Session.set('entryLocked', true)

root.unlockEntry = ->
    # if Session.get('entryLocked')
        Meteor.call( 'unlockEntry', Session.get('entryId') ) if Session.get('entryId')
        Session.set('editMode', false)
        Session.set('entryLocked', false)


window.onbeforeunload = ->
    unlockEntry()

Session.set('editMode', false)


## Nav

Deps.autorun ->
    # Random user call to force reactivity
    Meteor.user()
    if Meteor.user() && ! Meteor.user().username
        $('#new-user-modal').modal({'backdrop':'static', 'keyboard': false})

# currently the spinner atmosphere package has a bug in it where it does not work
# spinner is clone directly into the project directory
Meteor.Spinner.options = {
    top : '50'
    left : '50'
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


root.getSummaries = (entries) ->
    entries.map (e) ->
        
        text = $('<div>').html( e.text ).text()
        text = text.substring(0,200) + '...' if text.length > 204;
        
        {text: text, title: e.title}


## Global Helpers

Handlebars.registerHelper( 'entryLink', (entry) ->
    entryLink( entry )
)

Handlebars.registerHelper( 'modeIs', (v) ->
    return v == Session.get('entry').mode
)

Handlebars.registerHelper 'locked', ->
    entry = Session.get('entry')
    entry && entry.editing

Handlebars.registerHelper 'editable', ->
    entry = Session.get('entry')
    context = Session.get("context")
    user  = Meteor.user()
    editable( entry, user, context )


Handlebars.registerHelper 'username', ->
    user  = Meteor.user()
    if user
        return user.username

Handlebars.registerHelper 'isStarred', ->
    user  = Meteor.user()
    entryId = Session.get('entryId')
    if user && entryId
        starredPages = user.profile.starredPages
        if entryId in starredPages
            return  true

Handlebars.registerHelper 'adminable', ->
    context = Session.get("context")
    user  = Meteor.user()
    adminable( user, context )

Handlebars.registerHelper 'viewable', ->
    entry = Session.get('entry')
    context = Session.get("context")
    user  = Meteor.user()
    viewable( entry, user, context )

Handlebars.registerHelper 'entryLoaded', ->
    Session.get('entryLoaded')

Handlebars.registerHelper 'editMode', ->
    Session.get('editMode')




## Entry

Template.entry.title = ->
    Session.get('title')

Template.entry.titleHidden = ->
    Session.get('titleHidden')

Template.entry.entryLoaded = ->
    Session.get('entryLoaded')

Template.entry.userContext = ->
    Session.get('context')

Template.entry.lastEditedBy = ->
    title = Session.get('title')
    context = Session.get('context')
    entry = findSingleEntryByTitle( title, context )
    lastEditedBy(entry)

Template.entry.sinceLastEdit = ->
    title = Session.get('title')
    context = Session.get('context')
    entry = findSingleEntryByTitle( title, context )
    sinceLastEdit(entry)

Template.entry.entry = ->
    title = Session.get('title')
    context = Session.get('context')
    if title
        entry = findSingleEntryByTitle( title, context )

        if entry
            Session.set('entry', entry )
            Session.set('entryId', entry._id )

            source = $('<div>').html( entry.text ) #make a div with entry.text as the innerHTML
            headings = stackTitles( filterHeadlines( source.find(":header:first")) )
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

Template.layout.modeIs = (mode) ->
    Session.get('mode') == mode;

Template.layout.loginConfigured = () ->
    if Accounts.loginServicesConfigured()
        return true;
    else
        return false;



Template.editEntry.rendered = ->
    el = $( '#entry-text' )
    el.redactor(
        plugins: ['autoSuggest', 'stickyScrollToolbar']
        imageUpload: '/images'
        linebreaks: true
        buttons: ['html', '|', 'formatting', '|', 'bold', 'italic', 'deleted', '|', 
            'unorderedlist', 'orderedlist', 'outdent', 'indent', '|',
            'image', 'table', 'link', '|',
            'fontcolor', 'backcolor', '|', 'alignment', '|', 'horizontalrule'],
        #    'save', 'cancel', 'delete'],
        # buttonsCustom:
        #     save:
        #         title: 'Save'
        #         callback: saveEntry
        #     cancel:
        #         title: 'Cancel'
        #         callback: ->
        #             Session.set("edit-mode", false)
        #     delete:
        #         title: 'Delete'
        #         callback: deleteEntry

        focus: true
        autoresize: true
        filepicker: (callback) ->

            filepicker.setKey('AjmU2eDdtRDyMpagSeV7rz')

            filepicker.pick({mimetype:"image/*"}, (file) ->
                filepicker.store(file, {location:"S3", path: Meteor.userId() + "/" + file.filename },
                (file) -> callback( filelink: file.url )))
    )

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


deleteEntry = (evt) ->
    entry = Session.get('entry')
    if entry
        Meteor.call('deleteEntry',entry)
        Entries.remove({_id: entry._id})
        Session.set('editMode', false)
        Session.set('editEntry', false)
    else
        Toast.error('Cannot DELETE a page that has not been created!')

root.saveEntry = (evt) ->
    reroute = ( e ) ->
        navigate( '/'+entry.title, Session.get( "context" ) ) unless entry.title == "home"

    title = Session.get('title')

    entry = {
        'title': title
        'text': rewriteLinks( $('#entry-text').val() )
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

    # Meteor.call('saveEntry', title, entry, context, reroute)
    Meteor.call('saveEntry', title, entry, context)
    Entries.update({_id: entry._id}, entry)
    Session.set("editMode", false)


Template.entry.events

    'click a.entry-link': (e) ->
        evtNavigate(e) 

    # for Create It! button on new page
    'click .edit': (evt) ->
        Session.set( 'y-offset', window.pageYOffset )
        evt.preventDefault()
        lockEntry()
        Session.set('editMode', true)

    'click #article-title': (evt) ->

        entry = Session.get('entry')
        context = Session.get("context")
        user  = Meteor.user()
        return unless editable( entry, user, context )

        $el = $(evt.target)
        $in = $("<input class='entry-title-input'/>")
        $in.val( $el.text().trim() )
        $el.replaceWith($in)
        $in.focus()

        updateTitle = (e, force = false) ->
            if force || e.target != $el[0] && e.target != $in[0]
                if $in.val() != $el.text()
                    Meteor.call 'updateTitle', Session.get('entry'), Session.get('context'), $in.val(), (error, result) ->
                        if error
                            Toast.error('Page already exists!')
                        else
                    $el.html($in.val())
                    navigate($in.val())

                $in.replaceWith($el)
                $(document).off('click')

        cancel = (e, force = false) ->
            if force || e.target != $el[0] && e.target != $in[0]
                $in.replaceWith($el)
                $(document).off('click')

        $(document).on('click', updateTitle)

        $in.on("keyup", (e) ->
            updateTitle(e, true) if e.keyCode == 13
            cancel(e, true) if e.keyCode == 27
        )


root.rewriteLinks = ( text ) ->
    $html = $('<div>')
    $html.html( text )

    for el in $html.find( 'a' )
        href = $(el).attr( 'href' )
        if href
            href = href.replace( /https?:\/\/([^\/.]+)$/, '/$1' )
            $(el).attr( 'href', href )
            $(el).addClass( 'entry-link' )

    $html.html()


Meteor.startup ->
    # Backbone.history.start pushState: true
    Session.set('activeTab', 'editedTab')
    Session.set('selectedCommentId', null)
    Session.set('editMode', false)
    # on small screens make sure the login screen is displayed first
    $('#leftNavContainer').toggle(true)
    $("#main").toggleClass('wLeftNav')
  

#builds array of all heading titles
root.stackTitles = (items, cur, counter) ->

    cur = 1 if cur == undefined
    counter ?= 1

    next = cur + 1

    for elem, index in items
        elem = $(elem)
        children  =  filterHeadlines( elem.nextUntil( 'h' + cur, 'h' + next ) )
        d = {};
        d.title = elem.text()
        # d.y  = elem.offset().top
        d.id = counter++
        d.target = "entry-heading-#{d.id}"
        d.style = "top" if cur == 0
        d.children = stackTitles( children, next, counter ) if children.length > 0
        d

root.filterHeadlines = ( $hs ) ->
    _.filter( $hs, ( h ) -> 
        $(h).text().match(/[^\s]/) ) #matches any non-whitespace char

root.buildNav = ( ul, items ) ->
    for child, index in items
        li = $( "<li>" )
        $( ul ).append( li )
        $a = $("<a/>")
        $a.attr( "id", "nav-title-" + child.id )
        $a.addClass( child.style )
        #$a.attr( 'data-target', child.target )
        $a.attr( 'href', '#' + child.target ) #for cursor purposes only
        $a.html( child.title )
        
        li.append( $a )

        if child.children
            subUl = document.createElement( 'ul' )
            li.append( subUl )
            buildNav( subUl, child.children )



root.buildRec = (headingNodes, $elm, lv) ->

    # each time through recursive function pull a piece of the jQuery object off
    node = headingNodes.splice(0,1)

    if node && node.length > 0
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
                    li = $("<li>").appendTo($elm);
                $elm = $("<ul>").appendTo(li);
                cnt++
                break unless cnt < (curLv - lv)
        li = $("<li>").appendTo($elm);
        # li.text(node[0].innerText)
        $a = $("<a/>")
        # $a.attr( "id", "nav-title-" + child.id )
        # $a.addClass( child.style )
        #$a.attr( 'data-target', child.target )
        # $a.html( child.title )
        $a.attr( 'href', '#' + node[0].id ) #for cursor purposes only
        $a.text($(node[0]).text())
        li.append( $a )

        # recursive call
        buildRec headingNodes, $elm, lv + cnt


root.highlightNav = ->

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

# call this after initial code load has run and it will print out all templates that re-render
# logRenders = ->
#   _.each Template, (template, name) ->
#     oldRender = template.rendered
#     counter = 0
#     template.rendered = ->
#       console.log name, "render count: ", ++counter
#       oldRender and oldRender.apply(this, arguments_)


@RedactorPlugins = {}  if typeof RedactorPlugins is "undefined"
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
        #hijack redactor modalClose
        this.selectModalClose = this.modalClose
        this.modalClose = ->
            $("#redactor_wiki_link").select2("close")
            this.selectModalClose()

        $('body').on 'click','.insert_link_btns', ->
            RedactorPlugins.autoSuggest.autoSuggest()
        
        # $('body').on 'click','#redactor_modal_overlay', ->
        #     console.log 'testing'
        #     $('#select2-drop-mask').trigger('click')
        #                 # select2-drop-mask

    autoSuggest: ->
        #.on to catch creation of modal (DNE before dropdown is selected)
        $('body').on 'focus','#redactor_modal', ->
            # evt.preventDefault()
            #remove the event to stop focus from multi-firing
            $('body').off 'focus','#redactor_modal'


            $("#redactor_wiki_link ").on "keyup keypress blur input paste change", (e)->
                linkText = $("#redactor_wiki_link").val()
                displayText = $("#redactor_wiki_link_text").val()
                re = new RegExp('^'+displayText, 'g')

                if not displayText
                    $("#redactor_wiki_link_text").val linkText
                else if displayText is linkText.slice(0,-1) #linkText with the last char stripped off
                    $("#redactor_wiki_link_text").val linkText
                else if re.test(linkText)
                    $("#redactor_wiki_link_text").val linkText 


            $("#redactor_link_url").on "keyup keypress blur input paste change", (e)->
                linkText = $("#redactor_link_url").val()
                displayText = $("#redactor_link_url_text").val()
                re = new RegExp('^'+displayText, 'g')

                if not displayText
                    $("#redactor_link_url_text").val linkText
                else if displayText is linkText.slice(0,-1) #linkText with the last char stripped off
                    $("#redactor_link_url_text").val linkText
                else if re.test(linkText)
                    $("#redactor_link_url_text").val linkText       
            

            listTitles = Entries.find({},title: 1, context: 1).map (e) -> 
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

            console.log 'hit'
            defaultValue = $("#redactor_wiki_link").val()

            #BUG 
            # this whole method is fired twice so check if already applied before applying typeahead
            if $("#redactor_wiki_link").hasClass('tt-query')
                return
            else
                $("#redactor_wiki_link").typeahead
                    local: idarray


