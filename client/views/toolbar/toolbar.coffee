Template.toolbar.entry = ->
    Template.entry.entry()

Template.toolbar.hide_toolbar = ->
    editingComment = Session.get('selectedCommentId')
    addingComment = Session.get('addingComment')
    if editingComment or addingComment
        return true
    else
        return false


Template.toolbar.events
    'click #new_page': (evt) ->
        evt.preventDefault()
        Meteor.call('createNewPage', 
           (error, pageName) ->
                console.log(error, pageName);
                #TODO: fix non-editable navigate
                window.scrollTo(0,0) # fix for positio being screwed up
                navigate('/'+pageName)
        )

    'click #toggle_star': (evt) ->
        evt.preventDefault()
        user  = Meteor.user()
        starredPages = user.profile.starredPages
        entryId = Session.get('entryId')
        context = Session.get('context')
        title = Session.get("title")
        entry = findSingleEntryByTitle( title, context )

        if not entry
            Toast.error('Cannot star a blank page!')
        else if entryId in starredPages
            console.log('match pulling')
            Meteor.users.update(Meteor.userId(), {
                $pull: {'profile.starredPages': entryId}
            })
        else
            console.log('no match pushing')
            Meteor.users.update(Meteor.userId(), {
                $push: {'profile.starredPages': entryId}
            })

    'click .edit': (evt) ->
        Session.set( 'y-offset', window.pageYOffset )
        evt.preventDefault()
        lockEntry()
        Session.set('editMode', true)

    'click .save': (evt) ->
        evt.preventDefault()
        unlockEntry()
        saveEntry( evt )

    'click .cancel': (evt) ->
        evt.preventDefault()
        unlockEntry()
        Session.set('editMode', false)

    'click .delete': (evt) ->
        evt.preventDefault()
        $('#delete-confirm-input').val('')
        $('#delete-confirm-modal').modal('show')
        # deleteEntry(evt)