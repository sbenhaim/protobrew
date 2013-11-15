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