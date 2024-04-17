import ../src/nimcls

Class static Parent:
    var value: int = 10
    method hello(self: Parent) {.base.} =
        echo "Hello!! Parent"

Class static Child(Parent):
    method hello(self: Child)  =
        echo "Hello!! Child"

let parent: Parent = Parent(value: 55)
parent.hello

let child: Child = Child()
child.hello

echo "---- Superclass call ----"
### Call Parent class hello ###
procCall child.super.hello

echo "---- Parent & Child variable  ----"
echo "Parent 'value': " & $parent.value
echo "Child  'value': " & $child.value