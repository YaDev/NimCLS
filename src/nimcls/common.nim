import macros, sets

proc buildClassPropertiesSeq*(recList: NimNode): seq[string] {.compileTime.} =
    var properties: seq[string] = @[]
    for node in recList:
        if node[0].kind == nnkPostfix:
            let propName: string = if len(node[0]) > 1:  node[0][1].strVal else: node[0][0].strVal
            properties.add(propName)
        elif node[0].kind == nnkIdent:
            let propName: string = if node[0].strVal == "*" :  node[1].strVal else: node[0].strVal
            properties.add(propName)
    return properties

proc getClassNameNode*(head: NimNode, isExported, isStatic: bool, isGeneric: bool = false): NimNode {.compileTime.} =
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

proc getParentClass*(head: NimNode, isExported: bool, isGeneric: bool = false): NimNode {.compileTime.} =
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

proc getParentClassStatic*(head: NimNode, isGeneric: bool = false): NimNode {.compileTime.} =
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
        

proc genClassDef*(className, superClass: NimNode, isExported, isStatic: bool): NimNode {.compileTime.} =
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

proc genGenericParams*(head: NimNode): NimNode {.compileTime.} =
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

proc isItStatic*(head: NimNode): bool {.compileTime.} =
    if len(head) == 0:
        return false
    else:
        if head.kind == nnkCommand and $head[0] == "static":
            return true
        else:
            return false

proc isClassExported*(head: NimNode, isStatic : bool , isGeneric: bool = false): bool {.compileTime.} =
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

proc isValidFuncOrProcOrMeth*(def, className: NimNode) : bool {.compileTime.} =
    if def.len > 4:
        if def[3].kind == nnkFormalParams and len(def[3]) > 1 :
            if def[3][1].kind == nnkIdentDefs and len(def[3][1]) > 1 :
                if def[3][1][1].kind == nnkIdent:
                    if $def[3][1][1] == $className:
                        return true
                elif (def[3][1][1].kind == nnkVarTy or def[3][1][1].kind == nnkRefTy or def[3][1][1].kind == nnkPtrTy) and len(def[3][1][1]) == 1:
                    if def[3][1][1][0].kind == nnkIdent:
                        if $def[3][1][1][0] == $className:
                            return true
                    elif def[3][1][1][0].kind == nnkBracketExpr:
                        if $def[3][1][1][0][0] == $className:
                            return true
                elif (def[3][1][1].kind == nnkBracketExpr):
                     if def[3][1][1][0].kind == nnkIdent:
                        if $def[3][1][1][0] == $className:
                            return true
                        elif $def[3][1][1][0] == "typedesc":
                            if def[3][1][1][1].kind == nnkIdent:
                                if $def[3][1][1][1] == $className:
                                    return true
                            elif def[3][1][1][1].kind == nnkBracketExpr:
                                if $def[3][1][1][1][0] == $className:
                                    return true

    return false

proc isGeneric*(head : NimNode): bool {.compileTime.} =
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


proc updateInterfaceMethod*(methodNode: NimNode) {.compileTime.} =
    var pragma = nnkPragma.newNimNode
    pragma.add(ident("base"))
    if methodNode[4].kind == nnkPragma:
        var hasBase: bool = false
        for elem in methodNode[4]:
            if elem.kind == nnkIdent:
                if $elem == "base":
                    hasBase = true
        if not hasBase:
            methodNode[4].add(ident("base"))
    elif methodNode[4].kind == nnkEmpty:
        methodNode[4] = pragma
    var stmtList: NimNode = nnkStmtList.newNimNode
    var raiseStmt: NimNode = nnkRaiseStmt.newNimNode
    var callNode: NimNode = nnkCall.newNimNode
    callNode.add(ident("newException"))
    callNode.add(ident("CatchableError"))
    callNode.add(newStrLitNode("Method has not yet been implemented."))
    raiseStmt.add(callNode)
    stmtList.add(raiseStmt)
    methodNode[6] = stmtList

proc isValidInterfaceMethod*(className, methodNode: NimNode): bool {.compileTime.}  =
    if methodNode.len > 4:
        if methodNode[2].kind != nnkGenericParams:
            if methodNode[3].kind == nnkFormalParams and len(methodNode[3]) > 1 :
                if methodNode[3][1].kind == nnkIdentDefs and len(methodNode[3][1]) > 1 :
                    if methodNode[3][1][1].kind == nnkIdent:
                        if $methodNode[3][1][1] == $className:
                            return true
    return false



proc filterBodyNodes*(body: NimNode, bodyNodes: var seq[NimNode], variablesSec: var seq[NimNode], methodsProcFuncNames: var HashSet[string] ) {.compileTime.} =
    for elem in body:
        case elem.kind:
            of nnkVarSection: variablesSec.add(elem)
            of nnkCommentStmt: bodyNodes.add(elem)
            of nnkConstSection: error("'const' cannot be used for classes' properties !!")
            of nnkLetSection: error("'let' cannot be used for classes' properties !!")
            of nnkWhenStmt: bodyNodes.add(elem)
            of nnkCommand:
                if len(elem) == 3 and elem[0].kind == nnkIdent and elem[2].kind == nnkStmtList:
                    if $elem[0] == "switch" :
                        bodyNodes.add(elem)
                    else:
                        error("Only switch statements can be used inside the class body !!")
                else:
                    error("Only switch statements can be used inside the class body !!")
            of nnkMethodDef:
                var methodName: string
                if elem[0].kind == nnkPostfix:
                    methodName = $elem[0][1]
                else:
                    methodName = $elem[0]
                methodsProcFuncNames.incl(methodName)
                bodyNodes.add(elem)
            of nnkFuncDef: 
                var funcName: string
                if elem[0].kind == nnkPostfix:
                    funcName = $elem[0][1]
                else:
                    funcName = $elem[0]
                methodsProcFuncNames.incl(funcName)
                bodyNodes.add(elem)
            of nnkProcDef:
                var procName: string
                if elem[0].kind == nnkPostfix:
                    procName = $elem[0][1]
                else:
                    procName = $elem[0]
                methodsProcFuncNames.incl(procName)
                bodyNodes.add(elem)
            else: error("Only methods, procedures, functions and variables are allowed in classes' body")

proc filterInterfaceBodyNodes*(body: NimNode, bodyNodes: var seq[NimNode], methodsNames: var HashSet[string] ) {.compileTime.} =
    for elem in body:
        case elem.kind:
            of nnkCommentStmt: bodyNodes.add(elem)
            of nnkWhenStmt: bodyNodes.add(elem)
            of nnkMethodDef:
                var methodName: string
                if elem[0].kind == nnkPostfix:
                    methodName = $elem[0][1]
                else:
                    methodName = $elem[0]
                methodsNames.incl(methodName)
                bodyNodes.add(elem)
            else: error("Only methods are allowed in interface's body")

proc isVariablesWhen*(whenNode: NimNode): bool {.compileTime.} =
    for branch in whenNode:
        if branch[len(branch) - 1].kind == nnkStmtList:
            for elem in branch[len(branch) - 1]:
                if elem.kind != nnkVarSection and elem.kind != nnkDiscardStmt:
                    return false
    return true

proc extractWhenVar*(bodyNodes: var seq[NimNode]): seq[NimNode] {.compileTime.} =
    var whenRecList: seq[NimNode] = @[]
    var whenIdx: seq[int] = @[]
    for i in countup(0, len(bodyNodes) - 1):
        if bodyNodes[i].kind == nnkWhenStmt:
            if isVariablesWhen(bodyNodes[i]):
                whenIdx.add(i)
    
    for j in countdown(len(whenIdx) - 1, 0):
        let idx = whenIdx[j]
        var recWhen: NimNode = nnkRecWhen.newNimNode
        for branch in bodyNodes[idx]:
            var newBranch = branch.kind.newNimNode
            for elem in branch:
                var recList = nnkRecList.newNimNode
                if elem.kind == nnkStmtList:
                    if elem[0].kind == nnkDiscardStmt:
                        recList.add(newNilLit())
                    else:
                        for varSec in elem:
                            for variable in varSec:
                                recList.add(variable)
                    newBranch.add(recList)
                else:
                    newBranch.add(elem)
            recWhen.add(newBranch)
        whenRecList.add(recWhen)
        bodyNodes.delete(idx)
        
    return whenRecList

proc isValidClassWhen*(whenNode: NimNode, validNodes: var seq[NimNode]): bool {.compileTime.} =
    for branch in whenNode:
        if branch[len(branch) - 1].kind == nnkStmtList:
            for elem in branch[len(branch) - 1]:
                case elem.kind:
                    of nnkMethodDef: validNodes.add(elem)
                    of nnkFuncDef: validNodes.add(elem)
                    of nnkProcDef: validNodes.add(elem)
                    else: return false
    return true

proc isVariablesSwitch*(switchNode: NimNode): bool {.compileTime.} =
    for branch in switchNode[2][0]:
        if branch.kind == nnkIdent:
            continue
        elif branch[len(branch) - 1].kind == nnkStmtList:
            for elem in branch[len(branch) - 1]:
                if elem.kind != nnkVarSection and elem.kind != nnkDiscardStmt:
                    return false
    return true

proc extractSwitchVar*(bodyNodes: var seq[NimNode]): seq[NimNode] {.compileTime.} =
    var caseRecList: seq[NimNode] = @[]
    var caseIdx: seq[int] = @[]
    for i in countup(0, len(bodyNodes) - 1):
        if bodyNodes[i].kind == nnkCommand:
            echo bodyNodes[i].treeRepr
            if isVariablesSwitch(bodyNodes[i]):
                caseIdx.add(i)
            else:
                error("Invalid switch statement!")
    
    for j in countdown(len(caseIdx) - 1, 0):
        let idx: int = caseIdx[j]
        var recCase: NimNode = nnkRecCase.newNimNode
        var recCaseIdentDef: NimNode = nnkIdentDefs.newNimNode
        if bodyNodes[idx][1].kind == nnkPrefix:
            var postFix = nnkPostfix.newNimNode
            postFix.add(bodyNodes[idx][1][0])
            postFix.add(bodyNodes[idx][1][1])
            recCaseIdentDef.add(postFix)
        elif bodyNodes[idx][1].kind == nnkIdent:
            recCaseIdentDef.add(bodyNodes[idx][1])
        else:
            error("Invalid switch statement!!")
        recCaseIdentDef.add(bodyNodes[idx][2][0][0])
        recCaseIdentDef.add(newEmptyNode())
        recCase.add(recCaseIdentDef)

        for i in 1..(len(bodyNodes[idx][2][0]) - 1):
            var newBranch = bodyNodes[idx][2][0][i].kind.newNimNode
            for elem in bodyNodes[idx][2][0][i]:
                var recList = nnkRecList.newNimNode
                if elem.kind == nnkStmtList:
                    if elem[0].kind == nnkDiscardStmt:
                        recList.add(newNilLit())
                    else:
                        for varSec in elem:
                            for variable in varSec:
                                recList.add(variable)
                    newBranch.add(recList)
                else:
                    newBranch.add(elem)
            recCase.add(newBranch)
        caseRecList.add(recCase)
        bodyNodes.delete(idx)
        
    return caseRecList