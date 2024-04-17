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


type
    ClassStaticObj*
    = object of RootObj

method getClassName*(self: ClassStaticObj): string {.base.} =
    return $self.type

method getClassMethods*(self: ClassStaticObj): seq[string] {.base.} =
    return @["getClassName", "getClassProperties", "getClassMethods", "getParentClassName", "super"]

method getClassProperties*(self: ClassStaticObj): seq[string] {.base.} =
    return @[]

method getParentClassName*(self: ClassStaticObj): string {.base.} =
    return $RootObj