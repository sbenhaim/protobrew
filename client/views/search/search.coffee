class @Searching
    constructor: (router) ->
        #=======================================================================
        # Search constructor
        #=======================================================================
        @router = router

    start: () =>
        #=======================================================================
        # Start
        #=======================================================================
        Template.search.events = {
            'click a': @router.evtNavigate
        }

        Template.search.term = -> Session.get( 'search-term' )

        Template.search.results = ->
            term = Session.get('search-term')

            return unless term

            entries = Entries.find( {text: new RegExp( term, "i" )} )
            EntryLib.getSummaries( entries )
