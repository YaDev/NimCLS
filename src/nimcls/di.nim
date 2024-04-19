import tables, locks
import ./classobj

const 
    DUPLICATE_ERROR_1 : string = "Duplicate injections for "
    SUBCLASS_ERROR: string = " is not a subclass of ClassObj or ClassStaticObj and cannot be added as an injection!!!"
    SUBCLASS_1_ERROR: string = " is not a subclass of "
    SUBCLASS_2_ERROR: string = " and cannot be added to the injection table!!!"
    DUPLICATE_ERROR_2: string = "Duplicate injections for the class: "
    NOT_FOUND_ERROR_1: string = "Could not find an injection for the class: "
    SUBCLASS_ERROR2: string = " is not a subclass of ClassObj and cannot be injected!!!"
    ERRORS_OR: string = " or "


type InjectionError* = object of ValueError

## Injection & injectors tables
var
    injectionsTblSingleton {.global.} = initTable[int, ClassObj]()
    injectionsTbl {.global.} = initTable[int, proc(): ClassObj]()
    staticInjectionsTblSingleton {.global.} = initTable[int, pointer]()
    staticInjectionsTbl {.global.} = initTable[int, proc(): pointer]()
    classObjTblLock {.global.}: Lock
    classStaticObjTblLock {.global.}: Lock
    
classObjTblLock.initLock
classStaticObjTblLock.initLock


proc copyStaticObject[T](obj: T) : pointer =
    ## Copy object
    ##
    let objSize = sizeof(T)
    let objPtr = alloc(objSize)
    copyMem(objPtr, addr obj, objSize)
    return objPtr

proc addSingleton*[T : ClassObj | ClassStaticObj](obj : T) =
    ## Adds a singleton object
    ##
    ## Adds a singleton object of type ClassObj or ClassStaticObj
    ## to the injection table and uses its type as key for it.
    ##
    when T is ClassObj and $ClassObj != $T:
        withLock classObjTblLock:
            if injectionsTbl.hasKey(T.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_1 & $T)
            injectionsTblSingleton[T.signature] = obj
    elif T is ClassStaticObj and $ClassStaticObj != $T:
        withLock classStaticObjTblLock:
            if staticInjectionsTbl.hasKey(T.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_1 & $T)
            if staticInjectionsTblSingleton.hasKey(T.signature) :
                dealloc staticInjectionsTblSingleton[T.signature] 
            staticInjectionsTblSingleton[T.signature] = copyStaticObject(obj)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR)


proc addSingleton*[T, R : ClassObj](clsDesc : typedesc[R], obj : T) =
    ## Adds a singleton object
    ##
    ## Adds a singleton object of type ClassObj 
    ## to the injection table and uses 
    ## its type or its parent's class as key for it.
    ##
    when $ClassObj != $T and $ClassObj != $R:
        if T is R :
            withLock classObjTblLock:
                if injectionsTbl.hasKey(R.signature):
                    raise newException(InjectionError, DUPLICATE_ERROR_1 & $R)
                injectionsTblSingleton[R.signature] = obj
        else:
            raise newException(InjectionError, $T & SUBCLASS_1_ERROR & $R & SUBCLASS_2_ERROR)
    else:
        raise newException(InjectionError, $T & ERRORS_OR & $R & SUBCLASS_ERROR)


proc addInjector*[T: ClassObj | ClassStaticObj](builder : proc(): T) =
    ## Adds a procedure as an injector
    ##
    ## Adds a procedure that returns an object 
    ## of type ClassObj or ClassStaticObj to the injectors table 
    ## and uses the object's type as key for it. 
    ##
    when T is ClassObj and $ClassObj != $T:
        withLock classObjTblLock:
            if injectionsTblSingleton.hasKey(T.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_2 & $T)
            injectionsTbl[T.signature] = proc(): ClassObj = result = builder()
    elif T is ClassStaticObj and $ClassStaticObj != $T:
        withLock classStaticObjTblLock:
            if staticInjectionsTblSingleton.hasKey(T.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_2 & $T)
            staticInjectionsTbl[T.signature] 
                = proc(): pointer =
                    var output = builder()
                    return addr(output)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR)


proc addInjector*[T, R: ClassObj](clsDesc : typedesc[R], builder : proc(): T) =
    ## Adds a procedure as an injector
    ##
    ## Adds a procedure that returns an object 
    ## of type ClassObj to the injectors table 
    ## it the object's type or its parent's class as key for it. 
    ##
    when $ClassObj != $T and $ClassObj != $R:
        if T is R :
            withLock classObjTblLock:
                if injectionsTblSingleton.hasKey(R.signature):
                    raise newException(InjectionError, DUPLICATE_ERROR_2 & $R)
                injectionsTbl[R.signature] = proc(): ClassObj = result = builder()
        else:
            raise newException(InjectionError, $T & SUBCLASS_1_ERROR & $R & SUBCLASS_2_ERROR)
    else:
        raise newException(InjectionError, $T & ERRORS_OR & $R & SUBCLASS_ERROR)


proc inject*[T: ClassObj | ClassStaticObj](clsDesc : typedesc[T]) : T =
    ## Returns an object 
    ##
    ## Returns an object of type ClassObj or ClassStaticObj 
    ## which exists in the injection tables.
    ##
    when T is ClassObj and $ClassObj != $T:
        withLock classObjTblLock:
            if injectionsTblSingleton.hasKey(clsDesc.signature):
                return T(injectionsTblSingleton[clsDesc.signature])
            elif injectionsTbl.hasKey(clsDesc.signature) :
                let callProc = injectionsTbl[clsDesc.signature]
                return T(callProc())
            else:
                raise newException(InjectionError, NOT_FOUND_ERROR_1 & $clsDesc)
    elif T is ClassStaticObj and $ClassStaticObj != $T:
        withLock classStaticObjTblLock:
            if staticInjectionsTblSingleton.hasKey(clsDesc.signature):
                return cast[T](cast[ptr T](staticInjectionsTblSingleton[clsDesc.signature])[])
            elif staticInjectionsTbl.hasKey(clsDesc.signature) :
                let callProc = staticInjectionsTbl[clsDesc.signature]
                return cast[T](cast[ptr T](callProc())[])
            else:
                raise newException(InjectionError, NOT_FOUND_ERROR_1 & $clsDesc)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR2)

proc isInjectable*[T: ClassObj | ClassStaticObj](clsDesc : typedesc[T]) : bool =
    ## Returns true if an object or a procedure of type ClassObj or ClassStaticObj exists in the tables otherwise false.
    ##
    when T is ClassObj and $ClassObj != $T:
        withLock classObjTblLock:
            return injectionsTblSingleton.hasKey(clsDesc.signature) or injectionsTbl.hasKey(clsDesc.signature)
    elif T is ClassStaticObj and $ClassStaticObj != $T:
        withLock classStaticObjTblLock:
            return staticInjectionsTblSingleton.hasKey(clsDesc.signature) or staticInjectionsTbl.hasKey(clsDesc.signature)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR2)


proc isSingleton*[T: ClassObj | ClassStaticObj](clsDesc : typedesc[T]) : bool =
    ## Returns true if an object of type ClassObj or ClassStaticObj exists in the tables otherwise false.
    ##
    when T is ClassObj and $ClassObj != $T:
        withLock classObjTblLock:
            return injectionsTblSingleton.hasKey(clsDesc.signature)
    elif T is ClassStaticObj and $ClassStaticObj != $T:
        withLock classStaticObjTblLock:
            return staticInjectionsTblSingleton.hasKey(clsDesc.signature)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR2)

proc resetInjectTbl*() =
    ## Resets and removes all entries in the injection and injectors tables.
    ##
    withLock classObjTblLock:
        injectionsTblSingleton.clear
        injectionsTbl.clear
    withLock classStaticObjTblLock:
        for key in staticInjectionsTblSingleton.keys:
            dealloc staticInjectionsTblSingleton[key]
        staticInjectionsTblSingleton.clear
        staticInjectionsTbl.clear
