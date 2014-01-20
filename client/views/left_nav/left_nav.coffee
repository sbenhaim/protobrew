Template.left_nav.events =
    'click a.left-nav': evtNavigate

    'submit form': (evt) ->
        evt.preventDefault()
        term = $("#search-input").val()
        window.scrollTo(0,0) # fix for position being screwed up (also in tags click, and new page)
        navigate( '/search/' + term ) if term

    'change #search-input': (evt) ->
        term = $(evt.target).val()
        window.scrollTo(0,0) # fix for position being screwed up (also in tags click, and new page)
        navigate( '/search/' + term ) if term

    'click #usernav a': evtNavigate

    'click #userTabs > li' : (evt) ->
        $el = $(evt.currentTarget)
        Session.set( 'activeTab' , $el.attr('id'))

Template.left_nav.isActiveTab = (tab, options)->
    Session.equals "activeTab", tab 

Template.left_nav.isActivePanel = (panel, options)->
    Session.equals "activePanel", panel

Template.left_nav.term = -> 
    Session.get( 'search-term' )

Template.left_nav.pageIs = (u) ->
    page = Session.get('title')
    entry = Entries.findOne({_id: 'home'})
    if entry
        if entry.title == page
            return u == "/"
    return u == page

Template.left_nav.edited = () ->
    revisions = Revisions.find({author: Meteor.userId()}, {entryId: true}).fetch()
    ids = _.map( revisions, (r) -> r.entryId )
    entries = Entries.find({_id: {$in: ids}}).fetch()
    _.sortBy( entries, (e) -> e.date ).reverse()


Template.left_nav.starred = () ->
    user = Meteor.user()
    if ! user 
        return
    else
        starredPages = user.profile.starredPages
        if ! starredPages
            return
        starred =  Entries.find({ _id :{$in: starredPages}}).fetch()
        if ! starred or starred.length == 0
          return # starred = {starred:["nothing"]} #would need to make this not a link
        return starred

Template.left_nav.rendered = ->
    _handleResizeable = ->
        $("#divider.resizeable").mousedown (e) ->
            e.preventDefault()
            divider_width = $("#divider").width()
            $(document).mousemove (e) ->
                if (e.pageX + divider_width) > 100
                    sidebar_width = e.pageX + divider_width
                    Session.set('sidebar_width', sidebar_width)
                else
                    sidebar_width = 100
                    Session.set('sidebar_width', sidebar_width)
                setSidebarWidth()    
        setSidebarWidth = ->
            divider_width = $("#divider").width()
            sidebar_width = Session.get('sidebar_width')
            if sidebar_width <= 300 and sidebar_width >= (divider_width * 2 - 3)
                if sidebar_width >= 240 and sidebar_width <= 260
                    $("#sidebar").css "width", 250
                    $("#sidebar").css "min-width", 100
                    $("#sidebar-content").css "width", 250
                    $("#content").css "margin-left", 250
                    $("#divider").css "margin-left", 250
                else
                    $("#sidebar").css "width", sidebar_width
                    $("#sidebar").css "min-width", 100
                    $("#sidebar-content").css "width", sidebar_width
                    $("#content").css "margin-left", sidebar_width
                    $("#divider").css "margin-left", sidebar_width
        setSidebarWidth()

  

        $(document).mouseup (e) ->
            $(document).unbind "mousemove"
    _handleResizeable()