import tables
import ./classobj

const 
    DUPLICATE_ERROR: string = "Duplicate injections for "
    SUBCLASS_ERROR: string = " is not a subclass of ClassObj and cannot be added as an injection!!!"
    SUBCLASS_1_ERROR: string = " is not a subclass of "
    SUBCLASS_2_ERROR: string = " and cannot be added to the injection table!!!"
    DUPLICATE_ERROR2: string = "Duplicate injections for the class: "
    NOT_FOUND_ERROR: string = "Could not find the injection for the class: "
    SUBCLASS_ERROR2: string = " is not a subclass of ClassObj and cannot be injected!!!"
    ERRORS_OR: string = " or "


type InjectionError* = object of ValueError

var injectionsTblSingleton {.global.} = initTable[int, ClassObj]()
var injectionsTbl {.global.} = initTable[int, proc(): ClassObj]()


proc addSingleton*[T : ClassObj](obj : T) =
    when $ClassObj != $T:
        let signature: int = T.signature
        if injectionsTbl.hasKey(signature):
            raise newException(InjectionError, DUPLICATE_ERROR & $T)
        injectionsTblSingleton[signature] = obj
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR)


proc addSingleton*[T, R : ClassObj](clsDesc : typedesc[R], obj : T) =
    when $ClassObj != $T and $ClassObj != $R and T is R:
        if T is R :
            let signature: int = R.signature
            if injectionsTbl.hasKey(signature):
                raise newException(InjectionError, DUPLICATE_ERROR & $R)
            injectionsTblSingleton[signature] = obj
        else:
            raise newException(InjectionError, $T & SUBCLASS_1_ERROR & $R & SUBCLASS_2_ERROR)
    else:
        raise newException(InjectionError, $T & ERRORS_OR & $R & SUBCLASS_ERROR)


proc addInjector*[T: ClassObj](builder : proc(): T) =
    when $ClassObj != $T:
        let signature: int = T.signature
        if injectionsTblSingleton.hasKey(signature):
            raise newException(InjectionError, DUPLICATE_ERROR2 & $T)
        injectionsTbl[signature] = proc(): ClassObj = builder()
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR)


proc addInjector*[T, R: ClassObj](clsDesc : typedesc[R], builder : proc(): T) =
    when $ClassObj != $T and $ClassObj != $R and T is R:
        if T is R :
            let signature: int = R.signature
            if injectionsTblSingleton.hasKey(signature):
                raise newException(InjectionError, DUPLICATE_ERROR2 & $R)
            injectionsTbl[signature] = proc(): ClassObj = builder()
        else:
            raise newException(InjectionError, $T & SUBCLASS_1_ERROR & $R & SUBCLASS_2_ERROR)
    else:
        raise newException(InjectionError, $T & ERRORS_OR & $R & SUBCLASS_ERROR)


proc inject*[T: ClassObj](clsDesc : typedesc[T]) : T =
    when $ClassObj != $T:
        if isInjectable(clsDesc):
            let signature: int = clsDesc.signature
            if injectionsTbl.hasKey(signature) :
                let callProc = injectionsTbl[signature]
                return T(callProc())
            else:
                return T(injectionsTblSingleton[signature])
        else:
            raise newException(InjectionError, NOT_FOUND_ERROR & $clsDesc)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR2)


proc isInjectable*[T: ClassObj](clsDesc : typedesc[T]) : bool =
    when $ClassObj != $T:
        let signature: int = clsDesc.signature
        return injectionsTblSingleton.hasKey(signature) or injectionsTbl.hasKey(signature)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR2)


proc isSingleton*[T: ClassObj](clsDesc : typedesc[T]) : bool =
    when $ClassObj != $T:
        let signature: int = clsDesc.signature
        return injectionsTblSingleton.hasKey(signature)
    else:
        raise newException(InjectionError, $T & SUBCLASS_ERROR2)


proc resetInjectTbl*() =
    injectionsTblSingleton = initTable[int, ClassObj]()
    injectionsTbl = initTable[int, proc(): ClassObj]()