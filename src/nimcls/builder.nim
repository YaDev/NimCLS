import 
    macros,
    intsets,
    sequtils,
    random,
    strutils

import ./classobj

macro ClassErrorMacro(msg: string): untyped =
    error(msg.strVal)

var signaturesSet {.compileTime.} : IntSet = initIntSet()

proc genSignature() : int =
    var
        timeStamp: string = CompileTime
        timeSplit: seq[string] = ("1" & timeStamp).split(":")
        value: int = parseInt(timeSplit.join) 
        rState: Rand = initRand(value)
        signature: int = rState.rand(999_999 .. 999_999_999)
        signaturesCount: int = signaturesSet.len
    signaturesSet.incl(signature)
    while signaturesCount == signaturesSet.len:
        signature = rState.rand(999_999 .. 999_999_999)
        signaturesSet.incl(signature)
    return signature

proc buildClass*(classDef, superClass, className, methodsNamesLit, propsLit: NimNode): NimNode {.compileTime.} =
    let
        signature: int =  genSignature()
        signatureLit: NimNode = newLit(signature)
        superClassError: NimNode = newLit(superClass.strVal & " cannot be used as a parent class. Types mismatch error!")
        superClassNameLit: NimNode = newLit(superClass.strVal)
    result = quote("@") do:
        @classDef
        when (@superClass is ClassObj and @className is ref RootObj) or (@superClass is ClassStaticObj and @className is RootObj) :

            method getClassName*(self: @className): string =
                return $self.type

            method getClassMethods*(self: @className): seq[string]  =
                var superMethods = procCall @superClass(self).getClassMethods()
                return deduplicate( superMethods & @methodsNamesLit )

            method getClassProperties*(self: @className): seq[string]  =
                var superProp = procCall @superClass(self).getClassProperties() 
                return superProp & @propsLit
            
            method getParentClassName*(self: @className): string =
                return @superClassNameLit

            method super*(self: @className): @superClass {.base.} =
                return @superClass(self)

            proc signature*(classType: typedesc[@className]): int =
                return @signatureLit

        else:
            ClassErrorMacro(@superClassError)