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

macro Class*(head, body: untyped): untyped =
    result = processMacro(head, body)

macro Class*(head): untyped =
    result = processMacro(head)