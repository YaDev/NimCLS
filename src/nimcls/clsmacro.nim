import macros, sets
import 
    ./builder,
    ./classobj

proc buildClassPropertiesSeq(recList: NimNode): seq[string] {.compileTime.} =
    var properties: seq[string] = @[]
    for node in recList:
        if node[0].kind == nnkPostfix:
            let propName: string = if len(node[0]) > 1:  node[0][1].strVal else: node[0][0].strVal
            properties.add(propName)
        elif node[0].kind == nnkIdent:
            let propName: string = if node[0].strVal == "*" :  node[1].strVal else: node[0].strVal
            properties.add(propName)
    return properties

proc getClassNameNode(head: NimNode, isExported, isStatic: bool, isGeneric: bool = false): NimNode {.compileTime.} =
    if isGeneric:
        if head.kind == nnkBracketExpr:
            return head[0]
        elif head.kind == nnkPrefix and len(head) > 1:
            if head[1].kind == nnkBracketExpr:
                return head[1][0]
        elif head.kind == nnkCall and len(head) > 1:
            if head[0].kind == nnkBracketExpr:
                return head[0][0]
        elif head.kind == nnkInfix and len(head) > 2:
            if head[1].kind == nnkIdent:
                return head[1]
        elif isStatic:
            if head[1].kind == nnkPrefix and len(head[1]) > 1:
                if head[1][1].kind == nnkBracketExpr:
                    return head[1][1][0]
            elif head[1].kind == nnkCall and len(head[1]) > 1:
                if head[1][0].kind == nnkBracketExpr:
                    return head[1][0][0]
            elif head[1].kind == nnkBracketExpr and len(head[1]) > 1:
                if head[1][0].kind == nnkIdent:
                    return head[1][0]
            elif head[1].kind == nnkInfix and len(head[1]) > 1:
                if head[1][1].kind == nnkIdent:
                    return head[1][1]
    elif isStatic:
        if head.len == 2:
            if head[1].kind == nnkPrefix:
                return head[1][len(head[1]) - 1]
            elif head[1].kind == nnkCall:
                return head[1][0]
            elif head[1].kind == nnkIdent:
                return head[1]
            elif head[1].kind == nnkInfix:
                if head[1][len(head[1]) - 1].kind == nnkPar:
                    return head[1][len(head[1]) - 2]
    else:
        if len(head) == 0:
            return head
        elif isExported:
            return head[1]
        else:
            return head[0]
    error("Invalid class's definition sytanx")

proc getParentClass(head: NimNode, isExported: bool, isGeneric: bool = false): NimNode {.compileTime.} =
    if isGeneric:
        if head.kind == nnkCall and len(head) > 1:
            if head[1].kind == nnkIdent or head[1].kind == nnkBracketExpr:
                return head[1]
        elif head.kind == nnkInfix and len(head) > 2:
            if head[2].kind == nnkCall and len(head[2]) > 1:
                if head[2][1].kind == nnkIdent or head[2][1].kind == nnkBracketExpr:
                    return head[2][1]
            elif head[2].kind == nnkBracket and len(head[2]) > 0:
                return quote do: ClassObj
        elif head.kind == nnkBracketExpr or head.kind == nnkPrefix:
            return quote do: ClassObj
        else:
            error("Invalid class's definition sytanx")
    elif len(head) > 1:
        if (isExported and len(head) > 2) or (not isExported):
            if head[len(head) - 1].kind != nnkTupleConstr:
                if head[len(head) - 1].kind == nnkPar:
                    if  head[len(head) - 1][0].kind == nnkObjectTy:
                        error("Cannot use object as a parent class")
                    if head[len(head) - 1][0].kind == nnkIdent:
                        return head[len(head) - 1][0]
                    else:
                        error("Invalid parent class")
                if head[len(head) - 1].kind == nnkIdent:
                    return head[len(head) - 1]
            else:
                error("Invalid class's definition sytanx")
    return quote do: ClassObj

proc getParentClassStatic(head: NimNode, isGeneric: bool = false): NimNode {.compileTime.} =
    if len(head) == 2:
        if head[1].kind == nnkPrefix:
            return quote do: ClassObj
        elif head[1].kind == nnkIdent:
            return quote do: ClassObj
        else:
            if isGeneric:
                if head[1].kind == nnkBracketExpr:
                    return quote do: ClassObj
                elif head[1].kind == nnkCall and len(head[1]) > 1 :
                    if head[1][1].kind == nnkIdent or head[1][1].kind == nnkBracketExpr:
                        return head[1][1]
                elif head[1].kind == nnkInfix:
                    if head[1][len(head[1]) - 1].kind == nnkCall and len(head[1][len(head[1]) - 1]) > 1:
                        if head[1][len(head[1]) - 1][1].kind == nnkIdent or head[1][len(head[1]) - 1][1].kind == nnkBracket:
                            return head[1][len(head[1]) - 1][1]
                        elif head[1][len(head[1]) - 1][1].kind == nnkBracketExpr:
                            return head[1][len(head[1]) - 1][1]
                    elif head[1][len(head[1]) - 1].kind == nnkBracket:
                        return quote do: ClassObj
            else:
                if head[1].kind == nnkInfix:
                    if head[1][len(head[1]) - 1].kind == nnkPar:
                        return head[1][len(head[1]) - 1][0]
                elif head[1].kind == nnkCall and head[1].len > 1:
                    if head[1][len(head[1]) - 1].kind == nnkIdent:
                        return head[1][len(head[1]) - 1]
    error("Invalid class's definition sytanx")
        

proc genClassDef(className, superClass: NimNode, isExported, isStatic: bool): NimNode {.compileTime.} =
    if isExported:
        if isStatic:
            result = quote do:
                type `className`* 
                    = object of `superClass`
        else:
            result = quote do:
                type `className`* 
                    = ref object of `superClass`
    else:
        if isStatic:
            result = quote do:
                type `className` 
                    = object of `superClass`
        else:
            result = quote do:
                type `className` 
                    = ref object of `superClass`

proc genGenericParams(head: NimNode): NimNode {.compileTime.} =
    var searchNode: NimNode = head 
    var genParam: NimNode

    if head.kind == nnkPrefix:
        searchNode = head[1]
    elif head.kind == nnkCall:
        searchNode = head[0]
    elif head.kind == nnkInfix:
        if head[2].kind == nnkBracket:
            searchNode = head[2]
        else:
            searchNode = head[2][0]
    elif head.kind == nnkCommand:
        if head[1].kind == nnkCall:
            searchNode = head[1]
            if head[1].len > 1:
                if head[1][0].kind == nnkBracketExpr and head[1][1].kind == nnkBracketExpr:
                    searchNode = head[1][0]
        elif head[1].kind == nnkInfix:
            if head[1][2].kind == nnkBracket:
                searchNode = head[1][2]
            else:    
                searchNode = head[1][2][0]
        elif head[1].kind == nnkBracketExpr:
            searchNode = head[1]
        elif head[1].kind == nnkPrefix:
            searchNode = head[1][1]
    var loop: int = 0
    if searchNode.kind == nnkBracketExpr:
        loop += 1

    genParam = nnkGenericParams.newNimNode
    var idDef = nnkIdentDefs.newNimNode
    for i in countup(loop, len(searchNode)-1):
        if searchNode[i].kind == nnkIdent:
            idDef.add(searchNode[i])
            if i == (len(searchNode) - 1):
                idDef.add(newEmptyNode())
                idDef.add(newEmptyNode())
                genParam.add(idDef)
            elif (i + 1) <= (len(searchNode) - 1):
                if searchNode[i + 1].kind != nnkIdent: 
                    idDef.add(newEmptyNode())
                    idDef.add(newEmptyNode())
                    genParam.add(idDef)
        elif searchNode[i].kind == nnkExprColonExpr:
            idDef = nnkIdentDefs.newNimNode
            searchNode[i].copyChildrenTo(idDef)
            idDef.add(newEmptyNode())
            genParam.add(idDef)
            idDef = nnkIdentDefs.newNimNode
    return genParam

proc isItStatic(head: NimNode): bool {.compileTime.} =
    if len(head) == 0:
        return false
    else:
        if head.kind == nnkCommand and $head[0] == "static":
            return true
        else:
            return false

proc isClassExported(head: NimNode, isStatic : bool , isGeneric: bool = false): bool {.compileTime.} =
    if isGeneric:
        if head.kind == nnkPrefix and len(head) > 1:
            if head[0].kind == nnkIdent and $head[0] == "*":
                return true
        elif head[1].kind == nnkInfix and len(head[1]) > 2:
            if head[1][0].kind == nnkIdent and $head[1][0] == "*":
                return true
        elif head.kind == nnkInfix and len(head) > 2:
            if head[0].kind == nnkIdent and $head[0] == "*":
                return true
        elif isStatic:
            if head[1].kind == nnkPrefix and len(head[1]) > 1:
                if head[1][0].kind == nnkIdent and $head[1][0] == "*":
                    return true
            elif head[1].kind == nnkInfix and len(head[1]) > 1:
                 if head[1][0].kind == nnkIdent and $head[1][0] == "*":
                    return true
    elif isStatic:
        if head.len == 2:
            if head[1].kind == nnkPrefix:
                if $head[1][0] == "*":
                    return true
            elif head[1].kind == nnkInfix:
                if $head[1][0] == "*":
                    return true
    else:
        if len(head) > 1:    
            if $head[0] == "*":
                return true
    return false

proc isValidFuncOrProcOrMeth(def, className: NimNode) : bool {.compileTime.} =
    if def.len > 4:
        if def[3].kind == nnkFormalParams and len(def[3]) > 1 :
            if def[3][1].kind == nnkIdentDefs and len(def[3][1]) > 1 :
                if def[3][1][1].kind == nnkIdent:
                    if $def[3][1][1] == $className:
                        return true
                elif (def[3][1][1].kind == nnkVarTy or def[3][1][1].kind == nnkRefTy) and len(def[3][1][1]) == 1:
                    if def[3][1][1][0].kind == nnkIdent:
                        if $def[3][1][1][0] == $className:
                            return true
                    elif def[3][1][1][0].kind == nnkBracketExpr:
                        if $def[3][1][1][0][0] == $className:
                            return true
                elif (def[3][1][1].kind == nnkBracketExpr) :
                     if def[3][1][1][0].kind == nnkIdent:
                        if $def[3][1][1][0] == $className:
                            return true
    return false

proc isGeneric(head : NimNode): bool {.compileTime.} =
    if head.kind == nnkBracketExpr:
        return true
    elif head.kind == nnkCommand and len(head) > 1:
        if head[1].kind == nnkBracketExpr:
            return true
        elif head[1].kind == nnkCall and len(head[1]) > 0:
            if head[1][0].kind == nnkBracketExpr:
                return true
        elif head[1].kind == nnkInfix and len(head[1]) > 2:
            if head[1][2].kind == nnkCall and len(head[1][2]) > 0:
                if head[1][2][0].kind == nnkBracket:
                    return true
            elif head[1][2].kind == nnkBracket and len(head[1][2]) > 0:
                return true
        elif head[1].kind == nnkPrefix and len(head[1]) > 1:
            if head[1][1].kind == nnkBracketExpr :
                return true
    elif head.kind == nnkPrefix and len(head) > 1:
        if head[1].kind == nnkBracketExpr:
            return true
    elif head.kind == nnkCall and len(head) > 0:
        if head[0].kind == nnkBracketExpr:
            return true
    elif head.kind == nnkInfix and len(head) > 2:
        if head[2].kind == nnkCall and len(head[2]) > 0:
            if head[2][0].kind == nnkCall or head[2][0].kind == nnkBracket:
                return true
        elif head[2].kind == nnkBracket and len(head[2]) > 0:
            return true
    else:
        return false

proc processMacro*(head: NimNode): NimNode =
    if isGeneric(head):
        error("Incomplete generic class's definition!")
    let isStatic: bool = isItStatic(head)
    let isExported: bool = isClassExported(head, isStatic)
    var superClass: NimNode
    if isStatic:
        superClass = getParentClassStatic(head)
    else:
        superClass = getParentClass(head, isExported)
    let 
        className: NimNode = getClassNameNode(head, isExported, isStatic)
        classDef: NimNode = genClassDef(className, superClass, isExported, isStatic)
    let 
        props: seq[string] = @[]
        callsNames: seq[string] = @[]
    var propsLit: NimNode =  newLit(props)
    var methodsNamesLit: NimNode = newLit(callsNames)
    result = buildClass(classDef, superClass, className, methodsNamesLit, propsLit)

proc filterBodyNodes(body: NimNode, bodyNodes: var seq[NimNode], variablesSec: var seq[NimNode], methodsProcFuncNames: var HashSet[string] ) {.compileTime.} =
    for elem in body:
        case elem.kind:
            of nnkVarSection: variablesSec.add(elem)
            of nnkCommentStmt: bodyNodes.add(elem)
            of nnkConstSection: error("'const' cannot be used for classes' properties !!")
            of nnkLetSection: error("'let' cannot be used for classes' properties !!")
            of nnkMethodDef:
                let namesCount: int =  methodsProcFuncNames.len
                var methodName: string
                if elem[0].kind == nnkPostfix:
                    methodName = $elem[0][1]
                else:
                    methodName = $elem[0]
                methodsProcFuncNames.incl(methodName)
                if namesCount == methodsProcFuncNames.len:
                    error("A duplicate name for a method, procedure or function: '" & methodName  & "'")
                bodyNodes.add(elem)
            of nnkFuncDef: 
                let namesCount: int =  methodsProcFuncNames.len
                var funcName: string
                if elem[0].kind == nnkPostfix:
                    funcName = $elem[0][1]
                else:
                    funcName = $elem[0]
                methodsProcFuncNames.incl(funcName)
                if namesCount == methodsProcFuncNames.len:
                    error("A duplicate name for a method, procedure or function: '" & funcName & "'")
                bodyNodes.add(elem)
            of nnkProcDef:
                let namesCount: int =  methodsProcFuncNames.len
                var procName: string
                if elem[0].kind == nnkPostfix:
                    procName = $elem[0][1]
                else:
                    procName = $elem[0]
                methodsProcFuncNames.incl(procName)
                if namesCount == methodsProcFuncNames.len:
                    error("A duplicate name for a method, procedure or function: '" & procName & "'")
                bodyNodes.add(elem)
            else: error("Only methods, procedures, functions and variables are allowed in classes' body")


proc processMacro*(head, body: NimNode): NimNode =
    var
        bodyNodes: seq[NimNode] = @[]
        variablesSec: seq[NimNode] = @[]
        methodsProcFuncNames: HashSet[string] = initHashSet[string]()
        callsNames: seq[string] = @[]
        scratchRecList = newNimNode(nnkRecList)

    let 
        isStatic: bool = isItStatic(head)
        isGeneric: bool = isGeneric(head)
        isExported: bool = isClassExported(head, isStatic, isGeneric)
        
    filterBodyNodes(body, bodyNodes, variablesSec, methodsProcFuncNames) 
    for name in methodsProcFuncNames:
        callsNames.add(name)
    var superClass: NimNode
    if isStatic:
        superClass = getParentClassStatic(head, isGeneric)
    else:
        superClass = getParentClass(head, isExported, isGeneric)

    let className: NimNode = getClassNameNode(head, isExported, isStatic, isGeneric)
    var classDef: NimNode = genClassDef(className, superClass, isExported, isStatic)
    if isGeneric:
        var genParam: NimNode = genGenericParams(head)
        if len(genParam) < 1 :
            error("Invalid syntax")
        for i in countup(0, len(classDef[0]) - 1 ):
            if classDef[0][i].kind == nnkEmpty:
                classDef[0][i] = genParam

    if isStatic:
        if classDef[0][2][2].kind == nnkEmpty:
            for sec in variablesSec:
                for variable in sec:
                    scratchRecList.add(variable)
            classDef[0][2][2] = scratchRecList
        elif classDef[0][2][2].kind == nnkRecList:
            for sec in variablesSec:
                for variable in sec:
                    classDef[0][2][2].add(variable)
    else:
        if classDef[0][2][0][2].kind == nnkEmpty:
            for sec in variablesSec:
                for variable in sec:
                    scratchRecList.add(variable)
            classDef[0][2][0][2] = scratchRecList
        elif classDef[0][2][0][2].kind == nnkRecList:
            for sec in variablesSec:
                for variable in sec:
                    classDef[0][2][0][2].add(variable)
    var props: seq[string]
    if isStatic:
        props = buildClassPropertiesSeq(classDef[0][2][2])
    else:
        props = buildClassPropertiesSeq(classDef[0][2][0][2])
    var propsLit: NimNode =  newLit(props)
    var methodsNamesLit: NimNode = newLit(callsNames)
    result = buildClass(classDef, superClass, className, methodsNamesLit, propsLit, isGeneric)
    for node in bodyNodes:
        if node.kind == nnkFuncDef:
            if isValidFuncOrProcOrMeth(node, className):
                result.add(node)
            else:
                var nameOfFunc: string
                if node[0].kind == nnkPostfix:
                    nameOfFunc = $node[0][1]
                else:
                    nameOfFunc = $node[0]
                error("Invalid or unrelated function was found : '" & nameOfFunc & "'. The first parameter of the function must be its class's object.")
        elif node.kind == nnkProcDef:
            if isValidFuncOrProcOrMeth(node, className):
                result.add(node)
            else:
                var nameOfProc: string
                if node[0].kind == nnkPostfix:
                    nameOfProc = $node[0][1]
                else:
                    nameOfProc = $node[0]
                error("Invalid or unrelated procedure was found : '" & nameOfProc & "'. The first parameter of the procedure must be its class's object.")
        elif node.kind == nnkMethodDef:
            if isValidFuncOrProcOrMeth(node, className):
                result.add(node)
            else:
                var nameOfProc: string
                if node[0].kind == nnkPostfix:
                    nameOfProc = $node[0][1]
                else:
                    nameOfProc = $node[0]
                error("Invalid or unrelated method was found : '" & nameOfProc & "'. The first parameter of the method must be its class's object.")
        else:
            result.add(node)