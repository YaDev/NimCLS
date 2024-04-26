from locks import Lock, initLock, withLock
import tables
import ./classobj

const 
    DUPLICATE_ERROR_1 : string = "Duplicate injections for "
    DUPLICATE_ERROR_2: string = "Duplicate injections for the class: "
    SUBCLASS_1_ERROR: string = " is not a subclass of "
    SUBCLASS_2_ERROR: string = " and cannot be added to the injection table!!!"
    NOT_FOUND_ERROR_1: string = "Could not find an injection for the class: "

type InjectionError* = object of ValueError

## Injection & injectors tables
var
    injectionsRefTblSingleton {.global.} = initTable[int, ref ClassObj]()
    injectorsRefTbl {.global.} = initTable[int, proc(): ref ClassObj]()
    injectionsTblSingleton {.global.} = initTable[int, pointer]()
    injectorsTbl {.global.} = initTable[int, proc(): pointer]()
    classRefObjTblLock {.global.}: Lock
    classObjTblLock {.global.}: Lock
    
classRefObjTblLock.initLock
classObjTblLock.initLock


proc copyStaticObject[T](obj: T) : pointer =
    ## Copy object
    ##
    let objSize = sizeof(T)
    let objPtr = alloc(objSize)
    copyMem(objPtr, addr obj, objSize)
    return objPtr

proc addSingleton*[T : ref ClassObj | ClassObj](obj : T) =
    ## Adds a singleton object
    ##
    ## Adds a singleton object of type ClassObj
    ## to the injection table and uses its type as key for it.
    ##
    when T is ref ClassObj:
        withLock classRefObjTblLock:
            if injectorsRefTbl.hasKey(T.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_1 & $T)
            injectionsRefTblSingleton[T.signature] = obj
    else:
        withLock classObjTblLock:
            if injectorsTbl.hasKey(T.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_1 & $T)
            if injectionsTblSingleton.hasKey(T.signature) :
                dealloc injectionsTblSingleton[T.signature] 
            injectionsTblSingleton[T.signature] = copyStaticObject(obj)


proc addSingleton*[T, R : ref ClassObj](clsDesc : typedesc[R], obj : T) =
    ## Adds a singleton object
    ##
    ## Adds a singleton object of type ClassObj 
    ## to the injection table and uses 
    ## its type or its parent's class as key for it.
    ##
    when T is R :
        withLock classRefObjTblLock:
            if injectorsRefTbl.hasKey(R.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_1 & $R)
            injectionsRefTblSingleton[R.signature] = obj
    else:
        raise newException(InjectionError, $T & SUBCLASS_1_ERROR & $R & SUBCLASS_2_ERROR)


proc addInjector*[T: ref ClassObj | ClassObj](builder : proc(): T) =
    ## Adds a procedure as an injector
    ##
    ## Adds a procedure that returns an object 
    ## of type ClassObj to the injectors table 
    ## and uses the object's type as key for it. 
    ##
    when T is ref ClassObj:
        withLock classRefObjTblLock:
            if injectionsRefTblSingleton.hasKey(T.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_2 & $T)
            injectorsRefTbl[T.signature] = proc(): ref ClassObj = result = builder()
    else:
        withLock classObjTblLock:
            if injectionsTblSingleton.hasKey(T.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_2 & $T)
            injectorsTbl[T.signature] 
                = proc(): pointer =
                    var output = builder()
                    return addr(output)


proc addInjector*[T, R: ref ClassObj](clsDesc : typedesc[R], builder : proc(): T) =
    ## Adds a procedure as an injector
    ##
    ## Adds a procedure that returns an object 
    ## of type ref ClassObj to the injectors table 
    ## it the object's type or its parent's class as key for it. 
    ##
    when T is R :
        withLock classRefObjTblLock:
            if injectionsRefTblSingleton.hasKey(R.signature):
                raise newException(InjectionError, DUPLICATE_ERROR_2 & $R)
            injectorsRefTbl[R.signature] = proc(): ref ClassObj = result = builder()
    else:
        raise newException(InjectionError, $T & SUBCLASS_1_ERROR & $R & SUBCLASS_2_ERROR)



proc inject*[T: ref ClassObj | ClassObj](clsDesc : typedesc[T]) : T =
    ## Returns an object 
    ##
    ## Returns an object of type ClassObj 
    ## which exists in the injection tables.
    ##
    when T is ref ClassObj :
        withLock classRefObjTblLock:
            if injectionsRefTblSingleton.hasKey(clsDesc.signature):
                return T(injectionsRefTblSingleton[clsDesc.signature])
            elif injectorsRefTbl.hasKey(clsDesc.signature) :
                let callProc = injectorsRefTbl[clsDesc.signature]
                return T(callProc())
            else:
                raise newException(InjectionError, NOT_FOUND_ERROR_1 & $clsDesc)
    else:
        withLock classObjTblLock:
            if injectionsTblSingleton.hasKey(clsDesc.signature):
                return cast[T](cast[ptr T](injectionsTblSingleton[clsDesc.signature])[])
            elif injectorsTbl.hasKey(clsDesc.signature) :
                let callProc = injectorsTbl[clsDesc.signature]
                return cast[T](cast[ptr T](callProc())[])
            else:
                raise newException(InjectionError, NOT_FOUND_ERROR_1 & $clsDesc)

proc isInjectable*[T: ref ClassObj | ClassObj](clsDesc : typedesc[T]) : bool =
    ## Returns true if an object or a procedure of type ClassObj exists in the tables otherwise false.
    ##
    when T is ref ClassObj:
        withLock classRefObjTblLock:
            return injectionsRefTblSingleton.hasKey(clsDesc.signature) or injectorsRefTbl.hasKey(clsDesc.signature)
    else:
        withLock classObjTblLock:
            return injectionsTblSingleton.hasKey(clsDesc.signature) or injectorsTbl.hasKey(clsDesc.signature)


proc isSingleton*[T: ref ClassObj | ClassObj](clsDesc : typedesc[T]) : bool =
    ## Returns true if an object of type ClassObj exists in the tables otherwise false.
    ##
    when T is ref ClassObj :
        withLock classRefObjTblLock:
            return injectionsRefTblSingleton.hasKey(clsDesc.signature)
    else:
        withLock classObjTblLock:
            return injectionsTblSingleton.hasKey(clsDesc.signature)

proc resetInjectTbl*() =
    ## Resets and removes all entries in the injection and injectors tables.
    ##
    withLock classRefObjTblLock:
        injectionsRefTblSingleton.clear
        injectorsRefTbl.clear
    withLock classObjTblLock:
        for key in injectionsTblSingleton.keys:
            dealloc injectionsTblSingleton[key]
        injectionsTblSingleton.clear
        injectorsTbl.clear
