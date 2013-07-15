class Node
   constructor: (@url, @name, @parent) ->
      @children = []

class Tree
   root: null
   constructor: (@root) ->
   
   insertNode : (newChild) ->
      parent = newChild.parent
      while (parent) # check for loops
         if parent.url == newChild.url
            console.log("loop detected")
            return false
         parent = parent.parent
      newChild.parent.children.push newChild
      return true

   traverseTree: (node) ->
      console.log("traverse tree")
      console.log("url: #{node.url} name: #{node.name}")
      for child in node.children
         @traverseTree(child)

Template.pageindex.test = ->
    tree = new Tree
    tree.root = new Node "/Articles","Articles", null
#    n1 = new Node "www.cheese.biz", "cheeze biz", tree.root
#    n2 = new Node "muffins.com", "muffin hat", tree.root 
#    n3 = new Node "www.hello.com", "looper", tree.root
#    n4 = new Node "www.hello2.com", "looper2", n1
#    tree.insertNode(n1)
#    tree.insertNode(n2)
#    tree.insertNode(n3)
#    tree.insertNode(n4)
#    tree.traverseTree(tree.root)

    context = Session.get('context')
    entry = findSingleEntryByTitle('Articles', context)
    
    
#    x = $('<div>')
#    x.html(entry.text)
#    console.log(entry.text)
    for el in $("<div>"+entry.text+"</div>").find( 'a')
         href = $(el).attr('href')
         if (href.indexOf "/") == 0
              tree.insertNode(new Node href, href, tree.root)
 #            console.log("hey"+href)
#             console.log("hey"+href)

    "hello"