class @WikiManager
    constructor: (user_manager) ->
        #=======================================================================
        # WikiManager constructor
        #=======================================================================
        @user_manager = user_manager

    start: () =>
    	#=======================================================================
        # Start
        #=======================================================================
        Meteor.subscribe("browsable-wikis")

        Template.create.events = {
        	"click #login-button": @onCreate
        }

        Template.dashboard.wikis = () ->
            # private wikis must consider the currently logged in user
            private_wikis = Wikis.find({visibility: "private"}).fetch()

            # public wikis any user can view
            public_wikis = Wikis.find({visibility: "public"}).fetch()

            wikis_for_user = {
                private: private_wikis
                public: public_wikis
            }

            return wikis_for_user

        # Template.wiki.currentWiki = () ->
        #     return Session.get("current_wiki")

    onCreate: (event, template) =>
        #=======================================================================
        # Event: onCreate
        #
        # Handle the creation of public and private wikis
        #=======================================================================
        wiki_name = document.getElementById("create-wiki-name").value
        visibility = document.getElementById("create-wiki-visibility").value

        Meteor.call("createWiki", wiki_name, visibility, @user_manager.currentUser())

        Router.go("dashboard")


    hasRights: (wiki_name) =>
        #=======================================================================
        # Called by the router to make sure the user can go to `wiki_name`
        #=======================================================================
        if Wikis.findOne({name: wiki_name})
            return true
        else
            return false


class @UserManager
    constructor: () ->
        #=======================================================================
        # UserManager constructor
        #=======================================================================

    start: () =>
        #=======================================================================
        # Start
        #=======================================================================


    currentUser: () =>
        return Meteor.userId()

    isLoggedIn: () =>
        if Meteor.userId()
            return true
        else
            return false

    addUserToRoles: (uid, roles, wiki_name) =>

    hasWikiRights: (wiki_name) =>
        #=======================================================================
        # Return true if the currentUser has rights to `wiki_name`
        #=======================================================================
