import ../src/nimcls

Class MyClass:
    var one: int = 12
    var two: string
    method first(self: MyClass) : string {.base.} =
        return ""
    method second(self: MyClass) : float {.base.} =
        return 1.0

let basic = MyClass()
echo basic.getClassName & " methods :"
echo basic.getClassMethods
echo basic.getClassName & " properties :"
echo basic.getClassProperties
echo basic.getClassName & " parent class's name :"
echo basic.getParentClassName