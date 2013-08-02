class Node
   constructor: (@url, @name, @parent) ->
      @children = []

class Tree
   root: null
   constructor: (@root) ->
      @ulElem = null
      @textOut = ""
      @nameArray = []

   # simple linear search. improve to binary for performance
   findNameArray: (name) ->
      for n in @nameArray
         if n == name
            return true
      return false
   insertNode : (newChild) ->
      parent = newChild.parent
      for child in parent.children
         if child.url == newChild.url
            #console.log("multi child detected")
            return false

      while (parent) # check for loops
         if parent.url == newChild.url
            #console.log("loop detected "+newChild.url)
            return false
         parent = parent.parent
      newChild.parent.children.push newChild
      @nameArray.push newChild.name
      return true

   displayNames: () ->
      for n in @nameArray
         console.log("name: #{n}")

   traverseTree: (ulElem, node) ->
#      console.log("url: #{node.url} name: #{node.name}")
      li = $("<li>")
      $(ulElem).append(li)
      $a = $("<a/>")
      $a.attr('href', node.url ) 
      $a.html(node.name)
      li.append($a)
      child_stack = []
      for child in node.children
         child_stack.push child
      newUlElem = $("<ul>").appendTo(li)
      @traverseTree(newUlElem, child) for child in child_stack

buildLinks = (context, tree, rootNode) ->
   #entry = findSingleEntryByTitle(rootNode.name, context)

   entry = Entries.findOne({_id: 'home'})

   #console.log("building #{rootNode.name}")
   if ! entry
      return

   for el in $("<div>"+entry.text+"</div>").find('a')
      href = $(el).attr('href')
      if ! href.match(/^\w+:\/\//) #detect internal link
         if (href.indexOf "/") == 0
            name = href.slice(1)
         else
            name = href
         tree.insertNode(new Node href, name, rootNode)
      else   
         #console.log("what kind of #{href}")
   for child in rootNode.children
      buildLinks(context, tree, child)

Template.pageindex.test = ->
    tree = new Tree
    entry = Entries.findOne({_id: 'home'})
    tree.root = new Node "/"+entry.title,entry.title, null

    context = Session.get('context')
    buildLinks context, tree, tree.root
            
    ul = $('<ul>')
    tree.traverseTree(ul, tree.root)
    #console.log(ul.html())
    tree.displayNames()      

    ul2 = $('<ul>')      

    for entry in findAll().fetch()
      console.log(entry)
      if ! tree.findNameArray(entry.title)
         li = $("<li>")
         $(ul2).append(li)
         $a = $("<a/>")
         $a.attr('href', "/"+entry.title ) 
         $a.html(entry.title)
         li.append($a)

    html_out = ul.html() + "<h2>Orphan Pages</h2>" + ul2.html()
    html_out
   