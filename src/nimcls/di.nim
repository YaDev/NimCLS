import tables
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

var injectionsTblSingleton {.global.} = initTable[int, ClassObj]()
var injectionsTbl {.global.} = initTable[int, proc(): ClassObj]()
var staticInjectionsTblSingleton {.global.} = initTable[int, pointer]()
var staticInjectionsTbl {.global.} = initTable[int, proc(): pointer]()


proc copyStaticObject[T](obj: T) : pointer =
    let objSize = sizeof(T)
    let objPtr = alloc(objSize)
    copyMem(objPtr, addr obj, objSize)
    return objPtr

proc addSingleton*[T : ClassObj | ClassStaticObj](obj : T) =
    when T is ClassObj and $ClassObj != $T:
        if injectionsTbl.hasKey(T.signature):
            raise newException(InjectionError, DUPLICATE_ERROR_1 & $T)
        injectionsTblSingleton[T.signature] = obj
    elif T is ClassStaticObj and $ClassStaticObj != $T:
        if staticInjectionsTbl.hasKey(T.signature):
            raise newException(InjectionError, DUPLICATE_ERROR_1 & $T)
        if staticInjectionsTblSingleton.hasKey(T.signature) :
            dealloc staticInjectionsTblSingleton[T.signature] 
        staticInjectionsTblSingleton[T.signature] = copyStaticObject(obj)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR)


proc addSingleton*[T, R : ClassObj](clsDesc : typedesc[R], obj : T) =
    when $ClassObj != $T and $ClassObj != $R:
        if T is R :
            if injectionsTbl.hasKey(R.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_1 & $R)
            injectionsTblSingleton[R.signature] = obj
        else:
            raise newException(InjectionError, $T & SUBCLASS_1_ERROR & $R & SUBCLASS_2_ERROR)
    else:
        raise newException(InjectionError, $T & ERRORS_OR & $R & SUBCLASS_ERROR)


proc addInjector*[T: ClassObj | ClassStaticObj](builder : proc(): T) =
    when T is ClassObj and $ClassObj != $T:
        if injectionsTblSingleton.hasKey(T.signature):
            raise newException(InjectionError, DUPLICATE_ERROR_2 & $T)
        injectionsTbl[T.signature] = proc(): ClassObj = result = builder()
    elif T is ClassStaticObj and $ClassStaticObj != $T:
        if staticInjectionsTblSingleton.hasKey(T.signature):
            raise newException(InjectionError, DUPLICATE_ERROR_2 & $T)
        staticInjectionsTbl[T.signature] 
            = proc(): pointer =
                var output = builder()
                return addr(output)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR)


proc addInjector*[T, R: ClassObj](clsDesc : typedesc[R], builder : proc(): T) =
    when $ClassObj != $T and $ClassObj != $R:
        if T is R :
            if injectionsTblSingleton.hasKey(R.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_2 & $R)
            injectionsTbl[R.signature] = proc(): ClassObj = result = builder()
        else:
            raise newException(InjectionError, $T & SUBCLASS_1_ERROR & $R & SUBCLASS_2_ERROR)
    else:
        raise newException(InjectionError, $T & ERRORS_OR & $R & SUBCLASS_ERROR)


proc inject*[T: ClassObj | ClassStaticObj](clsDesc : typedesc[T]) : T =
    when T is ClassObj and $ClassObj != $T:
        if injectionsTblSingleton.hasKey(clsDesc.signature):
            return T(injectionsTblSingleton[clsDesc.signature])
        elif injectionsTbl.hasKey(clsDesc.signature) :
            let callProc = injectionsTbl[clsDesc.signature]
            return T(callProc())
        else:
            raise newException(InjectionError, NOT_FOUND_ERROR_1 & $clsDesc)
    elif T is ClassStaticObj and $ClassStaticObj != $T:
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
    when T is ClassObj and $ClassObj != $T:
        return injectionsTblSingleton.hasKey(clsDesc.signature) or injectionsTbl.hasKey(clsDesc.signature)
    elif T is ClassStaticObj and $ClassStaticObj != $T:
        return staticInjectionsTblSingleton.hasKey(clsDesc.signature) or staticInjectionsTbl.hasKey(clsDesc.signature)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR2)


proc isSingleton*[T: ClassObj | ClassStaticObj](clsDesc : typedesc[T]) : bool =
    when T is ClassObj and $ClassObj != $T:
        return injectionsTblSingleton.hasKey(clsDesc.signature)
    elif T is ClassStaticObj and $ClassStaticObj != $T:
        return staticInjectionsTblSingleton.hasKey(clsDesc.signature)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR2)

proc resetInjectTbl*() =
    injectionsTblSingleton.clear
    injectionsTbl.clear
    staticInjectionsTblSingleton.clear
    staticInjectionsTbl.clear
