import 
    macros,
    intsets,
    sequtils,
    random,
    strutils

import ./classobj

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

proc buildGenericParams(classDef: NimNode): NimNode {.compileTime.} =
    var originalParam: NimNode
    for i in countup(0, len(classDef[0]) - 1 ):
            if classDef[0][i].kind == nnkGenericParams:
                originalParam = classDef[0][i]
                break
    var idDef: NimNode = nnkIdentDefs.newNimNode
    for param in originalParam:
        if len(param) == 3:
            idDef.add(param[0])
        else:
            for elem in param:
                if elem.kind == nnkIdent:
                    idDef.add(elem)
    idDef.add(newEmptyNode())
    idDef.add(newEmptyNode())
    var output: NimNode = nnkGenericParams.newNimNode
    output.add(idDef)
    return output

proc buildBracketExpr(genericParams, className: NimNode): NimNode {.compileTime.} =
    var bracketExpr: NimNode = nnkBracketExpr.newNimNode
    bracketExpr.add(className)
    for i in countup(0, len(genericParams[0]) - 1):
        if genericParams[0][i].kind == nnkIdent:
            bracketExpr.add(genericParams[0][i])
    return bracketExpr

proc buildClass*(classDef, superClass, className, methodsNamesLit, propsLit: NimNode, isGeneric: bool = false): NimNode {.compileTime.} =
    var superClassIdent: NimNode
    if superClass.kind == nnkBracketExpr:
        superClassIdent = superClass[0]
    else:
        superClassIdent = superClass
    let
        signature: int =  genSignature()
        signatureLit: NimNode = newLit(signature)
        isGenericLit: NimNode = newLit(isGeneric)
        superClassError: NimNode = newLit(superClassIdent.strVal & " cannot be used as a parent class. Types mismatch error class!")
        superClassNameLit: NimNode = newLit(superClassIdent.strVal)
    result = quote("@") do:
        @classDef

        proc getTypeSignature*(classType: typedesc[@className]): int =
            return @signatureLit
    
        when (@superClassIdent is ref ClassObj) or (@superClassIdent is ClassObj) or (@isGenericLit):

            method getClassName*(self: @className): string =
                return $self.type

            method getClassCalls*(self: @className): seq[string] =
                when not @superClass is ClassObj or not @superClass is ref ClassObj:
                    raise newException(ValueError, @superClassError)
                else:
                    var superMethods: seq[string]
                    when self is ref ClassObj and @superClass is ClassObj:
                        superMethods = procCall @superClass((self)[]).getClassCalls()
                    elif self is ClassObj and @superClass is ref ClassObj:
                        var selfRef= new(ref self.type)
                        selfRef[] = self
                        superMethods = procCall @superClass(selfRef).getClassCalls()
                    else:
                        superMethods = procCall @superClass(self).getClassCalls()
                    return deduplicate( superMethods & @methodsNamesLit )

            method getClassProperties*(self: @className): seq[string] =
                when not @superClass is ClassObj or not @superClass is ref ClassObj:
                    raise newException(ValueError, @superClassError)
                else:
                    var superProp: seq[string]
                    when self is ref ClassObj and @superClass is ClassObj:
                        superProp = procCall @superClass((self)[]).getClassProperties()
                    elif self is ClassObj and @superClass is ref ClassObj:
                        var selfRef= new(ref self.type)
                        selfRef[] = self
                        superProp = procCall @superClass(selfRef).getClassProperties()
                    else:
                        superProp = procCall @superClass(self).getClassProperties() 
                return superProp & @propsLit
            
            method getParentClassName*(self: @className): string  =
                return @superClassNameLit

            method super*(self: @className): @superClass {.base.}  =
                when not @superClass is ClassObj or not @superClass is ref ClassObj:
                    raise newException(ValueError, @superClassError)
                else:
                    when self is ref ClassObj and @superClass is ClassObj:
                        return @superClass((self)[])
                    elif self is ClassObj and @superClass is ref ClassObj:
                        var selfRef= new(ref self.type)
                        selfRef[] = self
                        return @superClass(selfRef)
                    else:
                        return @superClass(self)

    if isGeneric:
        var genericParam: NimNode = buildGenericParams(classDef)
        var bracketExpr: NimNode = buildBracketExpr(genericParam, className)
        result[1][2] = genericParam
        var newnnkBracketExpr = nnkBracketExpr.newNimNode
        newnnkBracketExpr.add(ident("typedesc"))
        newnnkBracketExpr.add(bracketExpr)
        result[1][3][1][1] = newnnkBracketExpr
        for i in countup(0, len(result[2][0][1]) - 1):
            var elem = result[2][0][1][i]
            if elem.kind == nnkMethodDef :
                elem[2] = genericParam
                elem[3][1][1] = bracketExpr
                elem[4] = newEmptyNode()
                var procNode: NimNode = nnkProcDef.newNimNode
                elem.copyChildrenTo(procNode)
                result[2][0][1][i] = procNode
