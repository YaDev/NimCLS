import nimcls/[clsmacro, classobj, di]

export 
    ClassObj,
    ClassStaticObj,
    InjectionError,
    addSingleton,
    addInjector,
    inject,
    isInjectable,
    isSingleton,
    resetInjectTbl

macro Class*(head, body: untyped): untyped =
    result = processMacro(head, body)