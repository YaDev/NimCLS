type
    ClassObj*
    = object of RootObj

## ClassObj ##
method getClassName*(self: ClassObj): string {.base.} =
    return $self.type

method getClassCalls*(self: ClassObj): seq[string] {.base.} =
    return @["getClassName", "getClassProperties", "getClassCalls", "getParentClassName", "super"]

method getClassProperties*(self: ClassObj): seq[string] {.base.} =
    return @[]

method getParentClassName*(self: ClassObj): string {.base.} =
    return $RootObj


## Ref ClassObj ##
method getClassName*(self: ref ClassObj): string {.base.} =
    return $self.type

method getClassCalls*(self: ref ClassObj): seq[string] {.base.} =
    return @["getClassName", "getClassProperties", "getClassCalls", "getParentClassName", "super"]

method getClassProperties*(self: ref ClassObj): seq[string] {.base.} =
    return @[]

method getParentClassName*(self: ref ClassObj): string {.base.} =
    return $RootObj