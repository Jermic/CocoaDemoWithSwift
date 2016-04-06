//
//  MainWindowController.swift
//  Outline
//
//  Created by Jason Zheng on 4/6/16.
//  Copyright © 2016 Jason Zheng. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController,
    NSOutlineViewDataSource, NSOutlineViewDelegate {
  
  @IBOutlet weak var outlineView: NSOutlineView!
  
  var nodes = [Node]()
  
  override var windowNibName: String? {
    return "MainWindowController"
  }
  
  func initNodes() {
    let node = Node(title: "Node")
    let group = Node(title: "Group")
    let nodeA = Node(title: "Node A")
    let nodeB = Node(title: "Node B")
    
    group.isGroup = true
    nodeA.parent = group
    nodeB.parent = group
    group.children = [nodeA, nodeB]
    
    nodes = [node, group]
  }
  
  // MARK: - lifecycle
  
  override func windowWillLoad() {
    initNodes()
  }
  
  override func windowDidLoad() {
    super.windowDidLoad()    
    
    let index = 0
    outlineView.scrollRowToVisible(index)
    outlineView.expandItem(nil, expandChildren: true)
  }
  
  // MARK: - Helper Functions
  
  func appendItem(item: Node, afterItem: Node?, inout inItems items: [Node]) {
    
    if let parent = afterItem?.parent {
      item.parent = parent
    }
    
    if let afterItem = afterItem {
      if let index = items.indexOf(afterItem) {
        items.insert(item, atIndex: index + 1)
        
        return
      }
    }
    
    items.append(item)
  }
  
  func insertItemInOutlineView(item: Node, outlineView: NSOutlineView) {
    
    var index = 0
    var parent: Node? = nil
    
    if let itemParent = item.parent {
      index = itemParent.children.indexOf(item) ?? 0
      
      parent = itemParent
      
    } else {
      index = nodes.indexOf(item) ?? 0
    }
    
    outlineView.insertItemsAtIndexes(NSIndexSet(index: index),
                                     inParent: parent, withAnimation: .EffectFade)
  }
  
  func selectItem(item: Node, outlineView: NSOutlineView) {
    let index = outlineView.rowForItem(item)
    outlineView.scrollRowToVisible(index)
    outlineView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
  }
  
  func editSelectedItemInOutlineView(outlineView: NSOutlineView) {
    let row = outlineView.selectedRow
    if row != -1 {
      outlineView.editColumn(0, row: row, withEvent: nil, select: true)
    }
  }
  
  // MARK: - Actions
  
  @IBAction func addNode(sender: NSObject) {
    let item = Node()
    
    if let selectedItem = outlineView.itemAtRow(outlineView.selectedRow) as? Node {
      
      // For root item or group
      if selectedItem.parent == nil || selectedItem.isGroup {
        
        appendItem(item, afterItem: selectedItem, inItems: &nodes)
        
      } else { // For child item
        
        if let parent = selectedItem.parent {
          
          appendItem(item, afterItem: selectedItem, inItems: &parent.children)
          
        } else {
          print("Error")
        }
      }
      
    } else { // Currently now item selected. Insert in the end.
      nodes.append(item)
    }
    
    insertItemInOutlineView(item, outlineView: outlineView)
    selectItem(item, outlineView: outlineView)
    editSelectedItemInOutlineView(outlineView)
  }
  
  @IBAction func addGroup(sender: NSObject) {
    let item = Node()
    
    item.title = "Group"
    item.isGroup = true
    
    if let selectedItem = outlineView.itemAtRow(outlineView.selectedRow) as? Node {
      
      // For root item or group
      if selectedItem.parent == nil || selectedItem.isGroup {
        
        appendItem(item, afterItem: selectedItem, inItems: &nodes)
        
      } else { // For child item
        appendItem(item, afterItem: selectedItem.parent, inItems: &nodes)
      }
      
    } else {
      appendItem(item, afterItem: nil, inItems: &nodes)
    }
    
    // Insert a sub item
    let subItem = Node()
    subItem.parent = item
    
    appendItem(subItem, afterItem: nil, inItems: &item.children)
    
    // Update in outline view.
    insertItemInOutlineView(item, outlineView: outlineView)
    insertItemInOutlineView(subItem, outlineView: outlineView)
    
    // Must expand parent item before select sub item.
    outlineView.expandItem(item)
    selectItem(subItem, outlineView: outlineView)
    editSelectedItemInOutlineView(outlineView)
  }
  
  // MARK: - NSOutlineViewDataSource
  
  func outlineView(outlineView: NSOutlineView,
                   child index: Int, ofItem item: AnyObject?) -> AnyObject {
    
    if item == nil { // Case of virtual root
      return nodes[index]
      
    } else if let node = item as? Node {
      return node.children[index]
      
    } else {
      // TODO: Use better object
      print("Error: invalid object.")
      return ""
    }
  }
  
  func outlineView(outlineView: NSOutlineView,
                   isItemExpandable item: AnyObject) -> Bool {
    guard let node = item as? Node else {
      print("Error: invalid object.")
      return false
    }
    
    return node.children.count > 0
  }
  
  func outlineView(outlineView: NSOutlineView,
                   numberOfChildrenOfItem item: AnyObject?) -> Int {
    
    if item == nil { // Case of virtual root
      return nodes.count
      
    } else if let node = item as? Node {
      return node.children.count
      
    } else {
      print("Error: invalid object.")
      return 0
    }
  }
  
  func outlineView(outlineView: NSOutlineView,
                   objectValueForTableColumn tableColumn: NSTableColumn?,
                                             byItem item: AnyObject?) -> AnyObject? {
    guard let node = item as? Node else {
      print("Error: invalid object.")
      return nil
    }
    
    return node
  }
  
  // MARK: - NSOutlineViewDelegate
  
  func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
    
    guard let node = item as? Node else {
      return false
    }
    
    return node.isGroup
  }
  
  func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?,
                   item: AnyObject) -> NSView? {
    // For a group row, the tableColumn == nil.
    // In this case use get the column by outlineView.tableColumns[0]
    let identifier = tableColumn?.identifier ?? outlineView.tableColumns[0].identifier
    return outlineView.makeViewWithIdentifier(identifier, owner: self)
  }
}