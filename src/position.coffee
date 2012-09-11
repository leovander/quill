#= require underscore
#= require tandem/line

class TandemPosition
  @findLeafNode: (node, offset) ->
    if offset <= node.textContent.length    # We are at right subtree, dive deeper
      if node.firstChild?
        TandemPosition.findLeafNode(node.firstChild, offset)
      else
        node = node.parentNode if node.nodeType == node.TEXT_NODE
        if offset == node.textContent.length && node.nextSibling?
          TandemPosition.findLeafNode(node.nextSibling, 0)
        else
          return [node, offset]
    else if node.nextSibling?               # Not at right subtree, advance to sibling
      offset -= 1 if Tandem.Line.isLineNode(node)
      TandemPosition.findLeafNode(node.nextSibling, offset - node.textContent.length)
    else
      throw new Error('Diving exceeded offset')

  @makePosition: (editor, index) ->
    if _.isNumber(index)
      position = new Tandem.Position(editor, index)
    else if index instanceof Tandem.Range
      position = index.start
      index = position.getIndex()
    else
      position = index
      index = position.getIndex()
    return position


  # constructor: (TandemEditor editor, Object node, Number offset) ->
  # constructor: (TandemEditor editor, Number index) -> 
  constructor: (@editor, @leafNode, @offset) ->
    if _.isNumber(@leafNode)
      @offset = @leafNode
      @index = @leafNode
      @leafNode = @editor.iframeDoc.body.firstChild
    [@leafNode, @offset] = TandemPosition.findLeafNode(@leafNode, @offset)
      
  getIndex: ->
    return @index if @index?
    @index = @offset
    node = @leafNode
    while node.tagName != 'BODY'
      while node.previousSibling?
        node = node.previousSibling
        @index += node.textContent.length + (if Tandem.Line.isLineNode(node) then 1 else 0) # Account for newline char
      node = node.parentNode
    return @index

  getLeaf: ->
    return @leaf if @leaf?
    @leaf = @editor.doc.findLeaf(@leafNode)
    return @leaf



window.Tandem ||= {}
window.Tandem.Position = TandemPosition