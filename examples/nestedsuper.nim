import ../src/nimcls

Class One:
    method sayHi(self: One) {.base.} =
        echo "Hi, this is One"

    proc sayName(self: One) =
        echo "This is One"
Class Two(One):
    method sayHi(self: Two) =
        procCall self.super.sayHi
        echo "Hi, this is Two"

    proc sayName(self: Two) =
        procCall self.super.sayName
        echo "This is Two"

Class Three(Two):
    method sayHi(self: Three) =
        procCall self.super.sayHi
        echo "Hi, this is Three"
    proc sayName(self: Three) =
        procCall self.super.sayName
        echo "This is Three"

Class Four(Three):
    method sayHi(self: Four) =
        procCall self.super.sayHi
        echo "Hi, this is Four"
    proc sayName(self: Four) =
        procCall self.super.sayName
        echo "This is Four"

let four = Four()

echo "=== Calling One sayHi ==="
procCall four.super.super.super.sayHi

echo "=== Calling One sayName ==="
procCall four.super.super.super.sayName

echo "=== Calling sayHi ==="
four.sayHi

echo "=== Calling sayName ==="
four.sayName

