class @DebugPage
    constructor: (wiki_manager) ->
        #=======================================================================
        # DebugPage constructor
        #=======================================================================
        @wiki_manager = wiki_manager

    start: () =>
        #=======================================================================
        # Start
        #=======================================================================
        Meteor.setInterval(@debugLoop, 3000)

        Router.map () ->
            this.route "debug", {
                path: "/debug"
                template: "debug"
            }

        @setupTemplates()

    debugLoop: () =>


    setupTemplates: () =>
        Template.debug.wikis = () =>
            

        Template.debug.users = () =>
            return Meteor.users.find({}).fetch()           
