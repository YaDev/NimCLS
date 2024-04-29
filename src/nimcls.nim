import nimcls/[clsmacro, classobj, di]

export 
    ClassObj,
    InjectionError,
    addSingleton,
    addInjector,
    inject,
    isInjectable,
    isSingleton,
    resetInjectTbl

macro Interface*(head, body: untyped): untyped =
    result = createInterface(head, body)

macro Class*(head, body: untyped): untyped =
    result = createClass(head, body)

macro Class*(head): untyped =
    result = createClass(head)