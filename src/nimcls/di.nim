from locks import Lock, initLock, withLock
import tables
import ./classobj

const 
    DUPLICATE_ERROR_1 : string = "Duplicate injections for "
    DUPLICATE_ERROR_2: string = "Duplicate injections for the class: "
    SUBCLASS_1_ERROR: string = " is not a subclass of "
    SUBCLASS_2_ERROR: string = " and cannot be added to the injection table!!!"
    NOT_FOUND_ERROR_1: string = "Could not find an injection for the class: "

type InjectionError* = object of KeyError

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
    let objPtr = allocShared0(objSize)
    moveMem(objPtr, addr obj, objSize)
    return objPtr

proc addSingleton*[T : ref ClassObj | ClassObj](obj : T) {.raises: [InjectionError, Exception].} =
    ## Adds a singleton object
    ##
    ## Adds a singleton object of type ClassObj
    ## to the injection table and uses its type as key for it.
    ##
    when T is ref ClassObj:
        withLock classRefObjTblLock:
            if injectorsRefTbl.hasKey(T.getTypeSignature):
                raise newException(InjectionError, DUPLICATE_ERROR_1 & $T)
            injectionsRefTblSingleton[T.getTypeSignature] = obj
    else:
        withLock classObjTblLock:
            if injectorsTbl.hasKey(T.getTypeSignature):
                raise newException(InjectionError, DUPLICATE_ERROR_1 & $T)
            if injectionsTblSingleton.hasKey(T.getTypeSignature) :
                dealloc injectionsTblSingleton[T.getTypeSignature] 
            injectionsTblSingleton[T.getTypeSignature] = copyStaticObject(obj)


proc addSingleton*[T, R : ref ClassObj](clsDesc : typedesc[R], obj : T) {.raises: [InjectionError].} =
    ## Adds a singleton object
    ##
    ## Adds a singleton object of type ClassObj 
    ## to the injection table and uses 
    ## its type or its parent's class as key for it.
    ##
    when T is R :
        withLock classRefObjTblLock:
            if injectorsRefTbl.hasKey(R.getTypeSignature):
                raise newException(InjectionError, DUPLICATE_ERROR_1 & $R)
            injectionsRefTblSingleton[R.getTypeSignature] = obj
    else:
        raise newException(InjectionError, $T & SUBCLASS_1_ERROR & $R & SUBCLASS_2_ERROR)


proc addInjector*[T: ref ClassObj | ClassObj](builder : proc(): T) {.raises: [InjectionError].} =
    ## Adds a procedure as an injector
    ##
    ## Adds a procedure that returns an object 
    ## of type ClassObj to the injectors table 
    ## and uses the object's type as key for it. 
    ##
    when T is ref ClassObj:
        withLock classRefObjTblLock:
            if injectionsRefTblSingleton.hasKey(T.getTypeSignature):
                raise newException(InjectionError, DUPLICATE_ERROR_2 & $T)
            injectorsRefTbl[T.getTypeSignature] = proc(): ref ClassObj = result = builder()
    else:
        withLock classObjTblLock:
            if injectionsTblSingleton.hasKey(T.getTypeSignature):
                raise newException(InjectionError, DUPLICATE_ERROR_2 & $T)
            injectorsTbl[T.getTypeSignature] 
                = proc(): pointer =
                    let output = builder()
                    var objPtr: pointer = allocShared0(sizeof(output))
                    moveMem(objPtr, addr output, sizeof(output))
                    return objPtr


proc addInjector*[T, R: ref ClassObj](clsDesc : typedesc[R], builder : proc(): T) {.raises: [InjectionError].} =
    ## Adds a procedure as an injector
    ##
    ## Adds a procedure that returns an object 
    ## of type ref ClassObj to the injectors table 
    ## it the object's type or its parent's class as key for it. 
    ##
    when T is R :
        withLock classRefObjTblLock:
            if injectionsRefTblSingleton.hasKey(R.getTypeSignature):
                raise newException(InjectionError, DUPLICATE_ERROR_2 & $R)
            injectorsRefTbl[R.getTypeSignature] = proc(): ref ClassObj = result = builder()
    else:
        raise newException(InjectionError, $T & SUBCLASS_1_ERROR & $R & SUBCLASS_2_ERROR)



proc inject*[T: ref ClassObj | ClassObj](clsDesc : typedesc[T]) : T {.thread, raises: [InjectionError, Exception].} =
    ## Returns an object 
    ##
    ## Returns an object of type ClassObj 
    ## which exists in the injection tables.
    ##
    {.gcsafe.}:
        when T is ref ClassObj :
            withLock classRefObjTblLock:
                if injectionsRefTblSingleton.hasKey(clsDesc.getTypeSignature):
                    return T(injectionsRefTblSingleton[clsDesc.getTypeSignature])
                elif injectorsRefTbl.hasKey(clsDesc.getTypeSignature) :
                    let callProc = injectorsRefTbl[clsDesc.getTypeSignature]
                    return T(callProc())
                else:
                    raise newException(InjectionError, NOT_FOUND_ERROR_1 & $clsDesc)
        else:
            withLock classObjTblLock:
                if injectionsTblSingleton.hasKey(clsDesc.getTypeSignature):
                    return cast[T](cast[ptr T](injectionsTblSingleton[clsDesc.getTypeSignature])[])
                elif injectorsTbl.hasKey(clsDesc.getTypeSignature) :
                    let callProc = injectorsTbl[clsDesc.getTypeSignature]
                    let objPtr = cast[ptr T](callProc())
                    let output = objPtr[]
                    deallocShared(objPtr)
                    return output
                else:
                    raise newException(InjectionError, NOT_FOUND_ERROR_1 & $clsDesc)

proc isInjectable*[T: ref ClassObj | ClassObj](clsDesc : typedesc[T]) : bool {.thread.} =
    ## Returns true if an object or a procedure of type ClassObj exists in the tables otherwise false.
    ##
    {.gcsafe.}:
        when T is ref ClassObj:
            withLock classRefObjTblLock:
                return injectionsRefTblSingleton.hasKey(clsDesc.getTypeSignature) or injectorsRefTbl.hasKey(clsDesc.getTypeSignature)
        else:
            withLock classObjTblLock:
                return injectionsTblSingleton.hasKey(clsDesc.getTypeSignature) or injectorsTbl.hasKey(clsDesc.getTypeSignature)


proc isSingleton*[T: ref ClassObj | ClassObj](clsDesc : typedesc[T]) : bool {.thread.} =
    ## Returns true if an object of type ClassObj exists in the tables otherwise false.
    ##
    {.gcsafe.}:
        when T is ref ClassObj :
            withLock classRefObjTblLock:
                return injectionsRefTblSingleton.hasKey(clsDesc.getTypeSignature)
        else:
            withLock classObjTblLock:
                return injectionsTblSingleton.hasKey(clsDesc.getTypeSignature)

proc resetInjectTbl*() =
    ## Resets and removes all entries in the injection and injectors tables.
    ##
    withLock classRefObjTblLock:
        injectionsRefTblSingleton.clear
        injectorsRefTbl.clear
    withLock classObjTblLock:
        for key in injectionsTblSingleton.keys:
            deallocShared injectionsTblSingleton[key]
        injectionsTblSingleton.clear
        injectorsTbl.clear
