import macros, sets
import 
    ./builder,
    ./classobj,
    ./common

proc createInterface*(head, body: NimNode): NimNode {.compileTime.} =
    var
        bodyNodes: seq[NimNode] = @[]
        methodsNames: HashSet[string] = initHashSet[string]()
        callsNames: seq[string] = @[]
        isStatic: bool = false
        isGeneric: bool = false

    if isItStatic(head):
        error("An interface cannot be an object!")
        
    if isGeneric(head):
        error("An interface cannot be a generic object!")

    if head.kind != nnkPrefix and head.kind != nnkIdent:
        error("An interface cannot have a parent!")

    let isExported: bool = isClassExported(head, isStatic, isGeneric)
    filterInterfaceBodyNodes(body, bodyNodes, methodsNames)
    for name in  methodsNames:
        callsNames.add(name)
    let 
        superClass: NimNode = quote do: ClassObj
        className: NimNode = getClassNameNode(head, isExported, isStatic, isGeneric)
        classDef: NimNode = genClassDef(className, superClass, isExported, isStatic)
        props: seq[string] = @[]
    var 
        propsLit: NimNode =  newLit(props)
        methodsNamesLit: NimNode = newLit(callsNames)
    result = buildClass(classDef, superClass, className, methodsNamesLit, propsLit, isGeneric)
    for node in bodyNodes:
        if node.kind == nnkMethodDef:
            if isValidInterfaceMethod(className, node):
                updateInterfaceMethod(node)
                result.add(node)
            else:
                var nameOfProc: string
                if node[0].kind == nnkPostfix:
                    nameOfProc = $node[0][1]
                else:
                    nameOfProc = $node[0]
                error("Invalid or unrelated method was found : '" & nameOfProc & "'. The first parameter of the method must be its object and it cannot be generic.")

proc createClass*(head: NimNode): NimNode {.compileTime.} =
    let 
        isGeneric: bool = isGeneric(head)
        isStatic: bool = isItStatic(head)
        isExported: bool = isClassExported(head, isStatic, isGeneric)
    var superClass: NimNode
    if isStatic:
        superClass = getParentClassStatic(head, isGeneric)
    else:
        superClass = getParentClass(head, isExported, isGeneric)
    let 
        className: NimNode = getClassNameNode(head, isExported, isStatic, isGeneric)
        classDef: NimNode = genClassDef(className, superClass, isExported, isStatic)
    if isGeneric:
        var genParam: NimNode = genGenericParams(head)
        if len(genParam) < 1 :
            error("Invalid class's syntax")
        for i in countup(0, len(classDef[0]) - 1 ):
            if classDef[0][i].kind == nnkEmpty:
                classDef[0][i] = genParam
    let 
        props: seq[string] = @[]
        callsNames: seq[string] = @[]
    var propsLit: NimNode =  newLit(props)
    var methodsNamesLit: NimNode = newLit(callsNames)
    result = buildClass(classDef, superClass, className, methodsNamesLit, propsLit, isGeneric)
    
proc createClass*(head, body: NimNode): NimNode {.compileTime.} =
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

    var recSecList: NimNode
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

        recSecList = classDef[0][2][2]
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

        recSecList = classDef[0][2][0][2]
    var props: seq[string]
    props = buildClassPropertiesSeq(recSecList)

    let whenVarSeq: seq[NimNode] = extractWhenVar(bodyNodes)
    for recWhen in whenVarSeq:
        recSecList.add(recWhen)
    
    let caseVarSeq: seq[NimNode] = extractSwitchVar(bodyNodes)
    for caseStmt in caseVarSeq:
        recSecList.add(caseStmt)

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
        elif node.kind == nnkWhenStmt:
            var validNodes: seq[NimNode] = @[]
            if isValidClassWhen(node, validNodes):
                for nextNode in validNodes:
                    if not isValidFuncOrProcOrMeth(nextNode, className):
                        var nameOfMFP: string
                        if nextNode[0].kind == nnkPostfix:
                            nameOfMFP = $nextNode[0][1]
                        else:
                            nameOfMFP = $nextNode[0]
                        error("Invalid or unrelated method, procedure or function was found : '" & nameOfMFP & "'. The first parameter of the method must be its class's object.")
                result.add(node)
            else:
                error("Cannot process when's body that has a mix of variables and methods.")
        else:
            result.add(node)