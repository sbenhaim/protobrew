Meteor.subscribe("browsable-wikis")


Template.dashboard.wikis = () ->
  # private wikis must consider the currently logged in user
  private_wikis = Wikis.find({visibility: "private"}).fetch()

  # public wikis any user can view
  public_wikis = Wikis.find({visibility: "public"}).fetch()

  wikis_for_user = {
    private: private_wikis
    public: public_wikis
  }

Template.create.events = {
  "click #login-button": (event, template) ->
    wiki_name = document.getElementById("create-wiki-name").value
    visibility = document.getElementById("create-wiki-visibility").value

    Meteor.call("createWiki", wiki_name, visibility, Meteor.userId())

    Router.go("dashboard")
}
