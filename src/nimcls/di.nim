import tables
import ./classobj


type InjectionError* = object of ValueError

var injectionsTblSingleton {.global.} = initTable[int, ClassObj]()
var injectionsTbl {.global.} = initTable[int, proc(): ClassObj]()


proc addSingleton*[T : ClassObj](obj : T) =
    when $ClassObj != $T:
        let signature: int = T.signature
        if injectionsTbl.hasKey(signature):
            raise newException(InjectionError, "Duplicate injections for " & $T)
        injectionsTblSingleton[signature] = obj
    else:
        raise newException(InjectionError, $T & " is not a subclass of ClassObj and cannot be added as an injection!!!")


proc addSingleton*[T, R : ClassObj](clsDesc : typedesc[R], obj : T) =
    when $ClassObj != $T and $ClassObj != $R and T is R:
        if T is R :
            let signature: int = R.signature
            if injectionsTbl.hasKey(signature):
                raise newException(InjectionError, "Duplicate injections for " & $R)
            injectionsTblSingleton[signature] = obj
        else:
            raise newException(InjectionError, $T & " is not a subclass of " & $R & " and cannot be added to the injection table!!!")
    else:
        raise newException(InjectionError, $T & " or " & $R & " is not a subclass of ClassObj and cannot be added as an injection!!!")


proc addInjector*[T: ClassObj](builder : proc(): T) =
    when $ClassObj != $T:
        let signature: int = T.signature
        if injectionsTblSingleton.hasKey(signature):
            raise newException(InjectionError, "Duplicate injections for the class: " & $T)
        injectionsTbl[signature] = proc(): ClassObj = builder()
    else:
        raise newException(InjectionError, $T & " is not a subclass of ClassObj and cannot be added as an injection!!!")


proc addInjector*[T, R: ClassObj](clsDesc : typedesc[R], builder : proc(): T) =
    when $ClassObj != $T and $ClassObj != $R and T is R:
        if T is R :
            let signature: int = R.signature
            if injectionsTblSingleton.hasKey(signature):
                raise newException(InjectionError, "Duplicate injections for the class: " & $R)
            injectionsTbl[signature] = proc(): ClassObj = builder()
        else:
            raise newException(InjectionError, $T & " is not a subclass of " & $R & " and cannot be added to the injection table!!!")
    else:
        raise newException(InjectionError, $T & " or " & $R & " is not a subclass of ClassObj and cannot be added as an injection!!!")


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
            raise newException(InjectionError, "Could not find the injection for the class: " & $clsDesc)
    else:
        raise newException(InjectionError, $T & " is not a subclass of ClassObj and cannot be injected!!!")


proc isInjectable*[T: ClassObj](clsDesc : typedesc[T]) : bool =
    when $ClassObj != $T:
        let signature: int = clsDesc.signature
        return injectionsTblSingleton.hasKey(signature) or injectionsTbl.hasKey(signature)
    else:
        raise newException(InjectionError, $T & " is not a subclass of ClassObj and cannot be injected!!!")


proc isSingleton*[T: ClassObj](clsDesc : typedesc[T]) : bool =
    when $ClassObj != $T:
        let signature: int = clsDesc.signature
        return injectionsTblSingleton.hasKey(signature)
    else:
        raise newException(InjectionError, $T & " is not a subclass of ClassObj and cannot be injected!!!")


proc resetInjectTbl*() =
    injectionsTblSingleton = initTable[int, ClassObj]()
    injectionsTbl = initTable[int, proc(): ClassObj]()