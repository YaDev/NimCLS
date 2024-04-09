type
    ClassObj*
    = ref object of RootObj

method getClassName*(self: ClassObj): string {.base.} =
    return $self.type

method getClassMethods*(self: ClassObj): seq[string] {.base.} =
    return @["getClassName", "getClassProperties", "getClassMethods", "getParentClassName", "super"]

method getClassProperties*(self: ClassObj): seq[string] {.base.} =
    return @[]

method getParentClassName*(self: ClassObj): string {.base.} =
    return $RootObj

method super*(self: ClassObj): ClassObj {.base.} =
    return self