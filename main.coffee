if Meteor.isServer
    #=======================================================================
    # Construct server-side components, injecting needed dependencies.
    #=======================================================================

    # core logic
    server = new Server

    # start
    server.start()

    # log completion of setup
    console.log "Server initialization complete."

if Meteor.isClient
    #=======================================================================
    # Construct client-side components, injecting needed dependencies.
    #=======================================================================

    # core logic
    user_manager = new UserManager
    wiki_manager = new WikiManager(user_manager)
    router = new WikiRouter(wiki_manager, user_manager)

    # template helpers
    entry = new Entry(router)
    left_nav = new LeftNav(router)
    entry_sidebar = new EntrySidebar(router, entry) 
    page_index = new PageIndex(router)
    search = new Searching(router)

    # debug only
    debug = new DebugPage(wiki_manager)

    # start all!
    debug.start()
    wiki_manager.start()
    router.start()
    entry.start()
    left_nav.start()
    entry_sidebar.start()
    page_index.start()
    search.start()

    # log completion of setup
    console.log "Client initialization complete."
