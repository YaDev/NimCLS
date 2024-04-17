import ../src/nimcls
import times
import strutils


proc factorial_1(number : int) : int64 =
    if number == 1:
        return number
    else:
        return number*factorial_1(number-1)

proc factorial_2(number : int) : int64 =
    if number == 1:
        return number
    else:
        return number*factorial_1(number-1)

proc factorial_3(number : int) : int64 =
    if number == 1:
        return number
    else:
        return number*factorial_2(number-1)



Class static F1:
    proc factorial(self: F1, number : int) : int64 =
        if number == 1:
            return number
        else:
            return number*self.factorial(number-1)

Class static F2:
    var nextone: F1
    proc factorial(self: F2, number : int) : int64 =
        if number == 1:
            return number
        else:
            return number*self.nextone.factorial(number-1)

Class static F3:
    var nextone: F2
    proc factorial(self: F3, number : int) : int64 =
        if number == 1:
            return number
        else:
            return number*self.nextone.factorial(number-1)


## Variables ##


const value: int = 20
const loops_1: int = 50
const loops_2: int = 1000000
var runTimes: seq[float] = @[]  
var sumTime: float = 0.0



## Classes' procedures calls ##

let f1 : F1 = F1()
addSingleton(f1)
let f2 : F2 = F2(nextone: inject(F1))
addSingleton(f2)
let f3 : F3 = F3(nextone: inject(F2))

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

echo "Classes' procedures calls"
echo "Mean Time: " & (sumTime/runTimes.len.float).formatFloat(ffDecimal, 5)
echo ""




## Independent procedures calls ##


runTimes.setLen(0)

for i in countup(0, loops_1):
    let start = cpuTime()
    for i in countup(1, loops_2):
        discard factorial_1(value)
        discard factorial_2(value)
        discard factorial_3(value)
    let endTime = cpuTime()
    echo "Time: " & (endTime - start).formatFloat(ffDecimal, 5)
    runTimes.add(endTime - start)

sumTime = 0.0
for j in runTimes:
    sumTime += j

echo "Independent procedures calls"
echo "Mean Time: " & (sumTime/runTimes.len.float).formatFloat(ffDecimal, 5)
echo ""