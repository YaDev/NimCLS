import ../src/nimcls
import times
import strutils



Class F1:
    method factorial(self: F1, number : int) : int64 {.base.} =
        if number == 1:
            return number
        else:
            return number*self.factorial(number-1)

Class F2:
    method factorial(self: F2, number : int, nextone: F1 = inject(F1)) : int64 {.base.} =
        if number == 1:
            return number
        else:
            return number*nextone.factorial(number-1)

Class F3:
    method factorial(self: F3, number : int, nextone: F2 = inject(F2)) : int64 {.base.} =
        if number == 1:
            return number
        else:
            return number*nextone.factorial(number-1)


Class static S1:
    method factorial(self: S1, number : int) : int64 {.base.} =
        if number == 1:
            return number
        else:
            return number*self.factorial(number-1)

Class static S2:
    method factorial(self: S2, number : int, nextone: S1 = inject(S1)) : int64 {.base.} =
        if number == 1:
            return number
        else:
            return number*nextone.factorial(number-1)

Class static S3:
    method factorial(self: S3, number : int, nextone: S2 = inject(S2)) : int64 {.base.} =
        if number == 1:
            return number
        else:
            return number*nextone.factorial(number-1)


## Variables ##

const value: int = 20
const loops_1: int = 50
const loops_2: int = 1000000
var runTimes: seq[float] = @[]  
var sumTime: float = 0.0



## ref objects ##

addInjector(proc(): F1 = F1())
addInjector(proc(): F2 = F2())

let f1 : F1 = F1()
let f2 : F2 = F2()
let f3 : F3 = F3()


for i in countup(0, loops_1):
    let start = cpuTime()
    for i in countup(1, loops_2):
        discard f1.factorial(value)
        discard f2.factorial(value)
        discard f3.factorial(value)
    let endTime = cpuTime()
    echo "Time: " & (endTime - start).formatFloat(ffDecimal, 5)
    runTimes.add(endTime - start)

for j in runTimes:
    sumTime += j

echo "Ref objects creation and calls"
echo "Mean Time: " & (sumTime/runTimes.len.float).formatFloat(ffDecimal, 5)
echo ""


runTimes.setLen(0)


## objects ##

addInjector(proc(): S1 = S1())
addInjector(proc(): S2 = S2())

let s1 : S1 = S1()
let s2 : S2 = S2()
let s3 : S3 = S3()


for i in countup(0, loops_1):
    let start = cpuTime()
    for i in countup(1, loops_2):
        discard s1.factorial(value)
        discard s2.factorial(value)
        discard s3.factorial(value)
    let endTime = cpuTime()
    echo "Time: " & (endTime - start).formatFloat(ffDecimal, 5)
    runTimes.add(endTime - start)

sumTime = 0.0
for j in runTimes:
    sumTime += j

echo "Objects creation and calls"
echo "Mean Time: " & (sumTime/runTimes.len.float).formatFloat(ffDecimal, 5)
echo ""



