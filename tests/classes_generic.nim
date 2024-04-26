import nimcls
import ./mock


proc test_generic_classes() =
    ### Setup ###
    let g1 = G1[string]()
    let g2 = G2[int, int]()
    let g3  = G3[int, string, string]()

    ### Test relationships ###
    proc test_classes_relationships() =
        assert g1 is ref ClassObj
        assert g2 is ref ClassObj
        assert g3 is ref ClassObj
        assert g2 is G1[int]
        assert g3 is G2[int, string]

    test_classes_relationships()
    
    ### Test getClassName ###
    proc test_getClassName() =
        assert g1.getClassName == "G1[system.string]"
        assert g2.getClassName == "G2[system.int, system.int]"
        assert g3.getClassName == "G3[system.int, system.string, system.string]"

    test_getClassName()


    ### Test getClassCalls ###
    proc test_getClassCalls() =
        assert g1.getClassCalls.len == 5
        assert g2.getClassCalls.len == 5
        assert g3.getClassCalls.len == 5

        assert "getClassName" in g1.getClassCalls
        assert "getClassCalls" in g2.getClassCalls
        assert "getClassProperties" in g3.getClassCalls

    test_getClassCalls()

    ### Test getClassProperties ###
    proc test_getClassProperties() =
        assert g1.getClassProperties.len == 1
        assert g2.getClassProperties.len == 2
        assert g3.getClassProperties.len == 3

        assert "value" in g1.getClassProperties
        assert "value" in g2.getClassProperties
        assert "next" in g3.getClassProperties

    test_getClassProperties()


    ### Test getParentClassName ###
    proc test_getParentClassName() =
        assert g1.getParentClassName == "ClassObj"
        assert g2.getParentClassName == "G1"
        assert g3.getParentClassName == "G2"
    
    test_getParentClassName()

 
test_generic_classes()
