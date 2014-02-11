class Node
  constructor: (@url, @name, @parent) ->
    @children = []

  addChild: (childNode) ->
    @children.push(childNode)

  addToDOM: (ul) ->
    li = $("<li>")
    $(ul).append(li)
    $a = $("<a/>")
    $a.attr('href', "/" + @url)
    $a.html(@name)
    li.append($a)
    if @children.length > 0
      newUlElem = $("<ul>").appendTo(li)
      for child in @children
        child.addToDOM(newUlElem)


class Tree

  constructor: () ->
    @root = null
    @ulElem = null
    @textOut = ""
    @names = {}

  insertName: (name) =>
    @names[name] = {}

  # constant time, forget that linear or logarithmic bs
  containsName: (name) =>
    return @names.hasOwnProperty(name)

  # Insert a new node into the tree
  insertNode: (newChild) =>
    parent = newChild.parent

    if !@root?
      @root = newChild

    # do not insert the node if it is already inserted
    if parent?
      for sibling in parent.children
        if sibling.url == newChild.url
          return false

    # Make sure we are not creating a cylce
    node = parent
    while (node)
      if node.url == newChild.url
        return false
      node = node.parent

    # All clear, do it!
    if parent?
      parent.addChild(newChild)
    @names[newChild.name] = newChild
    return true

  displayNames: () =>
    for n in @names
      console.log("name: #{n}")

  toDom: () =>
    ul = $("<ul>")
    @root.addToDOM(ul)
    return ul

isInternalLink = (theHref) ->
  return (!theHref.match(/^\w+:\/\//))

buildTree = (context, tree, rootNode) ->
  wiki_name = Session.get("wiki_name")

  if !parent
    entry = Entries.findOne({title: 'home'})
  else
    entry = findSingleEntryByTitle(wiki_name, context, rootNode.name)

  if !entry
    return

  for el in $("<div>" + entry.text + "</div>").find('a')
    href = $(el).attr('href')
    if isInternalLink(href)
      if (href.indexOf "/") == 0
        name = href.slice(1)
      else
        name = href
      tree.insertNode(new Node(href, name, rootNode))

  for child in rootNode.children
    buildTree(context, tree, child)

Template.pageindex.events =
  'click #pageindex a': evtNavigate

Template.pageindex.pageindex = ->
  tree = new Tree()
  entry = Entries.findOne({title: 'home'})
  if !entry?
    return "No Wiki Pages Exist. You should make one!"

  root = new Node(entry.title, entry.title, null)
  tree.insertNode(root)

  context = Session.get('context')
  buildTree(context, tree, tree.root)

  # build unordered list of unorphaned entries
  ul = tree.toDom()

  # build unordered list of orphaned entries
  ul2 = $('<ul>')
  entry_cnt = 0
  for entry in findAll().fetch()
    if !tree.containsName(entry.title)
      entry_cnt += 1
      li = $("<li>")
      $(ul2).append(li)
      $a = $("<a/>")
      $a.attr('href', "/entry/" + entry.title)
      $a.html(entry.title)
      li.append($a)

  if !entry_cnt
    html_out = ul.html()
  else
    html_out = ul.html() + "<h2>Orphaned Pages</h2>" + ul2.html()
  html_out
