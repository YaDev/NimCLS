import nimcls
import ./mock


proc test_static_classes() =
    ### Setup ###
    let loader: Loader = Loader()
    let loaderA = ChildLoaderA()
    let loaderB = ChildLoaderB()

    ### Test relationships ###
    proc test_classes_relationships() =
        assert loader is ClassStaticObj
        assert loaderA is ClassStaticObj
        assert loaderB is ClassStaticObj
        assert loaderA is Loader
        assert loaderB is Loader

    test_classes_relationships()
    
    ### Test getClassName ###
    proc test_getClassName() =
        assert loader.getClassName == "Loader"
        assert loaderA.getClassName == "ChildLoaderA"
        assert loaderB.getClassName == "ChildLoaderB"

    test_getClassName()


    ### Test getClassCalls ###
    proc test_getClassCalls() =
        assert loader.getClassCalls.len == 6
        assert loaderA.getClassCalls.len == 6
        assert loaderB.getClassCalls.len == 6

        assert "load" in loader.getClassCalls
        assert "load" in loaderA.getClassCalls
        assert "load" in loaderB.getClassCalls

    test_getClassCalls()

    ### Test getClassProperties ###
    proc test_getClassProperties() =
        assert loader.getClassProperties.len == 2
        assert loaderA.getClassProperties.len == 3
        assert loaderB.getClassProperties.len == 2

        assert "path" in loader.getClassProperties
        assert "more" in loaderA.getClassProperties
        assert "code" in loaderB.getClassProperties

    test_getClassProperties()


    ### Test getParentClassName ###
    proc test_getParentClassName() =
        assert loader.getParentClassName == "ClassStaticObj"
        assert loaderA.getParentClassName == "Loader"
        assert loaderB.getParentClassName == "Loader"
    
    test_getParentClassName()


    ### Test override and super calls ###
    proc test_override_super_calls() =
        assert loader.code == 22
        assert loaderA.code == 22
        assert loaderB.code == 22
        assert loader.load == "LoaderCall"
        assert loaderA.load == "ChildLoaderACall"
        assert loaderB.load == "ChildLoaderBCall"
        let callOutput: string = procCall loaderB.super.load
        assert  callOutput == "LoaderCall"

    test_override_super_calls()

 
test_static_classes()
