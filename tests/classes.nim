import nimcls
import ./mock

proc test_classes() =
    ### Setup ###
    let sevice: Service = Service()
    let childA = ChildServiceA()
    let childB = ChildServiceB()
    let childC = ChildServiceC()
    sevice.init()
    childA.init(80)
    childB.init(443, "3yFSx01R")

    ### Test relationships ###
    proc test_classes_relationships() =
        assert sevice is ClassObj
        assert childA is ClassObj
        assert childB is ClassObj
        assert childC is ClassObj
        assert childA is Service
        assert childB is Service
        assert childC is Service
        assert childC is ChildServiceB

    test_classes_relationships()
    
    ### Test getClassName ###
    proc test_getClassName() =
        assert sevice.getClassName == "Service"
        assert childA.getClassName == "ChildServiceA"
        assert childB.getClassName == "ChildServiceB"
        assert childC.getClassName == "ChildServiceC"

    test_getClassName()

    ### Test getClassCalls ###
    proc test_getClassCalls() =
        assert sevice.getClassCalls.len == 7
        assert childA.getClassCalls.len == 9
        assert childB.getClassCalls.len == 10
        assert childC.getClassCalls.len == 13

        assert "init" in sevice.getClassCalls
        assert "connect" in childA.getClassCalls
        assert "getPort" in childB.getClassCalls
        assert "callParentURL" in childC.getClassCalls
        assert "runService" in childC.getClassCalls
        assert "calcNumber" in childC.getClassCalls
    
    test_getClassCalls()

    ### Test getClassProperties ###
    proc test_getClassProperties() =
        assert sevice.getClassProperties.len == 1
        assert childA.getClassProperties.len == 2
        assert childB.getClassProperties.len == 3
        assert childC.getClassProperties.len == 3

        assert "url" in sevice.getClassProperties
        assert "port" in childA.getClassProperties
        assert "key" in childB.getClassProperties
        assert "url" in childc.getClassProperties

    test_getClassProperties()

    ### Test getParentClassName ###
    proc test_getParentClassName() =
        assert sevice.getParentClassName == "ClassObj"
        assert childA.getParentClassName == "Service"
        assert childB.getParentClassName == "Service"
        assert childC.getParentClassName == "ChildServiceB"
    
    test_getParentClassName()

    ### Test override and super calls ###
    proc test_override_super_calls() =
        assert sevice.getURL == url1
        assert childA.getURL == url2
        assert childB.getURL == url4
        assert childA.getPort == 80
        assert childB.getPort == 443
        assert childB.callParentURL == url3
        childB.callParentInit()
        assert childB.callParentURL == url2
        assert childC.getURL == url1

    test_override_super_calls()

test_classes()