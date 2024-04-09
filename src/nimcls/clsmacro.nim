import macros
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

proc getClassNameNode(head: NimNode, isExported: bool): NimNode {.compileTime.} =
    if isExported:
        return head[1]
    else:
        if len(head) == 0:
            return head
        else:
            return head[0]

proc getParentClass(head: NimNode, isExported: bool): NimNode {.compileTime.} =
    var output: NimNode = quote do: ClassObj
    if len(head) > 1:
        if (isExported and len(head) > 2) or (not isExported):
            if head[len(head) - 1].kind != nnkTupleConstr:
                if head[len(head) - 1].kind == nnkPar:
                    if  head[len(head) - 1][0].kind == nnkObjectTy:
                        error("Cannot use object as a parent class")
                    if head[len(head) - 1][0].kind == nnkIdent:
                        output = head[len(head) - 1][0]
                    else:
                        error("Invalid parent class")
                if head[len(head) - 1].kind == nnkIdent:
                    output = head[len(head) - 1]
            else:
                error("Invalid class definition sytanx")
    return output

proc genClassDef(className, superClass: NimNode, isExported: bool): NimNode {.compileTime.} =
    if isExported:
        result = quote do:
            type `className`* 
                = ref object of `superClass`
    else:
        result = quote do:
            type `className` 
                = ref object of `superClass`

proc processMacro*(head, body: NimNode): NimNode =
    var
        isExported = false 
        methods: seq[NimNode] = @[]
        variablesSec: seq[NimNode] = @[]
        methodsNames: seq[string] = @[]
        scratchRecList = newNimNode(nnkRecList)

    if len(head) > 1:
        if head[0].strVal == "*":
            isExported = true
    
    for elem in body:
        case elem.kind:
            of nnkMethodDef:
                if elem[0].kind == nnkPostfix:
                    methodsNames.add(elem[0][1].strVal)
                else:
                    methodsNames.add(elem[0].strVal)
                methods.add(elem)
            of nnkVarSection: variablesSec.add(elem)
            of nnkCommentStmt: continue
            else: error("Not allowed in classes' body")
    let 
        className: NimNode = getClassNameNode(head, isExported)
        superClass: NimNode = getParentClass(head, isExported)
        classDef: NimNode = genClassDef(className, superClass, isExported)
    if classDef[0][2][0][2].kind == nnkEmpty:
        for sec in variablesSec:
            for variable in sec:
                scratchRecList.add(variable)
        classDef[0][2][0][2] = scratchRecList
    elif classDef[0][2][0][2].kind == nnkRecList:
        for sec in variablesSec:
            for variable in sec:
                classDef[0][2][0][2].add(variable)
    var props: seq[string] = buildClassPropertiesSeq(classDef[0][2][0][2])
    var propsLit: NimNode =  newLit(props)
    var methodsNamesLit: NimNode = newLit(methodsNames)
    result = buildClass(classDef, superClass, className, methodsNamesLit, propsLit)
    for m in methods:
        result.add(m)