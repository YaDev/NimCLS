# NimCLS - Nim Classes & Dependency Injection Library
Classes' macro and a lightweight dependency injection library for the Nim programming language, designed to help easily create and manage dependency injection by using classes.

## Features
- **Classes**: Create Nim objects using a simple syntax, similar to Python.
- **Debugging and Inspection Methods**: Make development easier with methods that help debug and inspect class objects.
- **Superclass Invocation**: Effortlessly call the super class's methods of an object.
- **Dependency Injection**: Easily inject dependencies into your code and reduce boilerplate code.
- **Singleton Management**: Manage and create singleton instances of classes.
- **Custom Injectors**: Create custom injectors to manage dependencies just the way you need.
- **Pass Injection**: Pass dependencies through procedures, functions and methods parameters.
- **Minimal Overhead**: Keep your application lightweight with NimCLS's minimal overhead (Zero Dependencies).

## Usage

### Installing NimCLS

You can install NimCLS via Nim's package manager, Nimble:

```bash
nimble install nimcls
```

### Basic Usage

1. Define your classes:

```nim
import nimcls

Class MyClass:
    var number: int = 12
    var config: string
    method call(self: MyClass) : string {.base.} =
        return "Class"
```
2. Set up an instance of the class and register it:

```nim

let myClassObj = MyClass()
addSingleton(myClassObj)

```
3. Retrieve the created instance with injected dependencies:

```nim

proc run(myClass : MyClass = inject(MyClass)) =
    myClassObj.call

run()
```
### Example

```nim
import nimcls

Class Parent:
    var value: int = 10
    method hello(self: Parent) {.base.} =
        echo "Hello!! Parent"

Class Child(Parent):
    method hello(self: Child)  =
        echo "Hello!! Child"

proc callHello(classObject: Parent = inject(Parent))
    classObject.hello

let createChild = proc(): Child = Child()
addInjector(Parent, createChild)

## prints "Hello!! Child"
callHello

```
### Injection Usage

There are two ways to register an injection:

1. Create an instance of the class and register it using `addSingleton` procedure.
2. Create a procedure which returns a class object and register it using `addInjector` procedure.

After registering an injection, call `inject` and pass the type of the object to get the object.

#### Examples

1. Adding a singleton:

```nim
## only this instance of the class "MyClass" will be used.
let myClassObj = MyClass()
addSingleton(myClassObj)
```

```nim
## only this instance of the class "ChildClass" will be used
## but it will be registered as "ParentClass".
## "ChildClass" must be a subclass of  "ParentClass".
let myClassObj = MyClass()
addSingleton(ParentClass, child)
```


2. Adding a procedure:


```nim
## A procedure that builds an instance of "ChildClass"
proc createChild() : ChildClass =
    let child = ChildClass()
    child.init("configuration")
    return child
## Each time "ChildClass" is injected, "createChild" will be called
## and a new instance will be created
addInjector(createChild)
```


```nim
## A procedure that builds an instance of "ChildClass"
proc createChild() : ChildClass =
    let child = ChildClass()
    child.init("configuration")
    return child
## Each time "ParentClass" is injected, "createChild" will be called
## and a new instance will be created
## "ChildClass" must be a subclass of  "ParentClass".
addInjector(ParentClass , createChild)
```


3. Injecting:

```nim
## A procedure that has a "ChildClass" parameter
proc runChild(child: ChildClass = inject(ChildClass) ) =
    child.run

```

```nim
## A procedure that makes inject call
proc runChild() =
    let child = inject(ChildClass)
    child.run

```

## Limitations

1. **Constants**: Nim programming language does not support constants properties for objects. So, `let` and `const` cannot be used for **classes' properties**.

2. **Export class with no parent**: Although, it is easy to export any class (public class) using the star mark `*`. Nim's compiler does not allow the following:
 ```nim
 # causes a Syntax error !?!? 
Class MyClass*:
    var me: string
```

However, you can solve this issue in two ways:

  ```nim
 # Exported and Runs!
Class *MyClass:
    var me: string
```

OR

 ```nim
 # All classes are subclasses of "ClassObj"
Class MyClass*(ClassObj):
    var me: string
```

3. **Super class calls**: Calling a super class's methods is easy using the class's method `super` but `procCall` must be used to make the call.
 ```nim
 # it will call the child object 'init' method 
 child.super.init
 # Works
 procCall child.super.init
```

4. **Procedures and functions**: The classes's macro does not allow procedures and functions inside the class's body. Keeping procedures and functions outside of classes ensures that they remain relevant and focused solely on their intended functionality. Placing them within a class could introduce unnecessary complexity, leading to code that is harder to understand and maintain.

## Classes built-in methods
Each class created has the following methods :

| Name                   | Arguments | Output        | Description                                                   |
|------------------------|-----------|---------------|---------------------------------------------------------------|
| `getClassName`         | None      | `string`      | Returns the class's name as a `string`.                       |
| `getClassMethods`      | None      | `seq[string]` | Returns the class's methods in a sequence of `string`.        |
| `getClassProperties`   | None      | `seq[string]` | Returns the class's properties in a sequence of `string`.     |
| `getParentClassName`   | None      | `string`      | Returns the class's parent's class name as a `string`.        |
| `super`                | None      | `ClassObj`    | Upcast the object and returns it.                             |


## Injection procedures

| Name                | Argument 1           | Argument 2         | Output     | Description                                                                                             |
|---------------------|----------------------|--------------------|------------|---------------------------------------------------------------------------------------------------------|
| `addSingleton[T]`   | `ClassObj`           | None               | Void       | Adds a singleton object of type `T` to the injection table and uses `T` as key for it.                  |
| `addSingleton[R,T]` | `typedesc[ClassObj]` | `ClassObj`         | Void       | Adds a singleton object of type `T` to the injection table and uses `R` as key for it.                  |
| `addInjector[T]`    | `proc(): ClassObj`   | None               | Void       | Adds a procedure that returns an object of type `T` to the injectors table and uses `T` as key for it.  |
| `addInjector[R,T]`  | `typedesc[ClassObj]` | `proc(): ClassObj` | Void       | Adds a procedure that returns an object of type `T` to the injectors table and uses `R` as key for it.  |
| `inject[T]`         | `typedesc[ClassObj]` | None               | `ClassObj` | Returns an object of type `T` which exists in the injection.                                            |
| `isInjectable[T]`   | `typedesc[ClassObj]` | None               | `bool`     | Returns `true` if an object or a procedure of type `T` exists in the tables otherwise `false`.          |
| `isSingleton[T]`    | `typedesc[ClassObj]` | None               | `bool`     | Returns `true` if an object of type `T` exists in the injection table otherwise `false`.                |
| `resetInjectTbl`    | None                 | None               | Void       | Rests and removes all entries in the injection and injectors tables.                                    |
