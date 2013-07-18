class Node
   constructor: (@url, @name, @parent) ->
      @children = []

class Tree
   root: null
   constructor: (@root) ->
      @ulElem = null
      @textOut = ""

   insertNode : (newChild) ->
      parent = newChild.parent
      for child in parent.children
         if child.url == newChild.url
            console.log("multi child detected")
            return false

      while (parent) # check for loops
         if parent.url == newChild.url
            console.log("loop detected "+newChild.url)
            return false
         parent = parent.parent
      newChild.parent.children.push newChild
      return true

   createul: ->
      @ulElem = $('<ul>')

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
   entry = findSingleEntryByTitle(rootNode.name, context)
   console.log("building #{rootNode.name}")
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
         console.log("what kind of #{href}")
   for child in rootNode.children
      buildLinks(context, tree, child)

Template.pageindex.test = ->
    tree = new Tree
    tree.root = new Node "/Articles","Articles", null

    context = Session.get('context')
    buildLinks context, tree, tree.root
            
    ul = $('<ul>')
    tree.traverseTree(ul, tree.root)
    console.log(ul.html())
    ul.html()
   