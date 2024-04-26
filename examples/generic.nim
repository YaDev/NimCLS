import ../src/nimcls

Class *Node[K, V]:
    var key : K
    var value: V
    var leftNode: Node[K, V]
    var rightNode: Node[K, V]

Class *BTree[K,V]:
    var root: Node[K, V]
    proc printTreeTypes[K, V](self: BTree[K,V]) =
        echo "key's type is: " & $K & ", value's type is: " & $V


var binaryTree : BTree[string, int] = BTree[string, int]()

binaryTree.root =  Node[string, int](key: "one", value: 1)
binaryTree.root.leftNode = Node[string, int](key: "left two", value: 2)
binaryTree.root.rightNode = Node[string, int](key: "right three", value: 3)

binaryTree.printTreeTypes
echo "Root key: " & binaryTree.root.key & " , value: " & $binaryTree.root.value
echo "Left key: " & binaryTree.root.leftNode.key & " , value: " & $binaryTree.root.leftNode.value
echo "Right key: " & binaryTree.root.rightNode.key & " , value: " & $binaryTree.root.rightNode.value