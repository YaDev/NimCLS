import ../src/nimcls

Class One:
    method sayHi(self: One) {.base.} =
        echo "Hi, this is One"
Class Two(One):
    method sayHi(self: Two) =
        procCall self.super.sayHi
        echo "Hi, this is Two"
Class Three(Two):
    method sayHi(self: Three) =
        procCall self.super.sayHi
        echo "Hi, this is Three"
Class Four(Three):
    method sayHi(self: Four) =
        procCall self.super.sayHi
        echo "Hi, this is Four"

let four = Four()
four.sayHi

echo "=== Calling One ==="
procCall four.super.super.super.sayHi