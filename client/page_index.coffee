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
            console.log("loop detected")
            return false
         parent = parent.parent
      newChild.parent.children.push newChild
      return true

   createul: ->
      @ulElem = $('<ul>')

   traverseTree: (ulElem, node) ->
      console.log("traverse tree")
      console.log("url: #{node.url} name: #{node.name}")
      li = $("<li>")
      $(ulElem).append(li)
      $a = $("<a/>")
      $a.attr( "id", "nav-title-" + node.name )
      $a.addClass( "top" )
      $a.attr('href', node.url ) #for cursor purposes only
      $a.html(node.name)
      li.append($a)
      @textOut = @textOut + node.name + '<br>'  
      child_stack = []
      for child in node.children
         child_stack.push child

      @traverseTree(ulElem, child) for child in child_stack

Template.pageindex.test = ->
    tree = new Tree
    tree.root = new Node "/Articles","Articles", null

    context = Session.get('context')
    entry = findSingleEntryByTitle('Articles', context)
    
    for el in $("<div>"+entry.text+"</div>").find( 'a')
         href = $(el).attr('href')
         if (href.indexOf "/") == 0
              tree.insertNode(new Node href, href, tree.root)
    ul = $('<ul>')
    tree.traverseTree(ul, tree.root)
    ul.html()
