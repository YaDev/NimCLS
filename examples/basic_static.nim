import ../src/nimcls

Class static MyClass:
    var one: int = 12
    var two: string
    method first(self: MyClass) : string {.base.} =
        return ""
    method second(self: MyClass) : float {.base.} =
        return 1.0

let basic = MyClass(two: "a string")
echo "one value: " & $basic.one
echo "two value: " & basic.two
echo basic.getClassName & " methods :"
echo basic.getClassCalls
echo basic.getClassName & " propearties :"
echo basic.getClassProperties
echo basic.getClassName & " parent class's name :"
echo basic.getParentClassName
echo "Calling method `second`: " & $basic.second