Template.newUserModal.rendered = () ->
    Session.set('selectedUsername', $('#initial-username-input').val() )

usernameTaken = (username) ->
    Meteor.users.find({username: username}).count() > 0

Template.newUserModal.continueDisabled = () ->
    Session.get('selectedUsername')
    username = $('#initial-username-input').val()
    username == '' || usernameTaken( username )

Template.newUserModal.usernameTaken = () ->
    Session.get('selectedUsername')
    username = $('#initial-username-input').val()
    usernameTaken( username )

Template.newUserModal.events =
    'keyup #initial-username-input': () ->
        Session.set('selectedUsername', $('#initial-username-input').val() )

    'click #new-username-button': (e) ->
        if ! $(e.target).hasClass('disabled')
            Meteor.call('updateUser', $("#initial-username-input").val(), (e) -> $("#new-user-modal").modal("hide") )
            navigate( "home", Session.get( "context" ) )
