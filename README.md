# NimCLS - Nim Classes & Dependency Injection Library

Classes' macro, interfaces' macro and a lightweight dependency injection library for the Nim programming language, designed to help easily create and manage dependency injection by using classes and interfaces.

## Features

- **Classes**: Create Nim objects using a simple syntax, similar to Python.
- **Interfaces**: Define interfaces using a concise syntax.
- **Debugging and Inspection Methods**: Make development easier with methods that help debug and inspect class objects.
- **Superclass Invocation**: Effortlessly call the super class's methods, procedures and functions of an object.
- **Dependency Injection**: Easily inject dependencies into your code and reduce boilerplate code.
- **Singleton Management**: Manage and create singleton instances of classes.
- **Custom Injectors**: Create custom injectors to manage dependencies just the way you need.
- **Pass Injection**: Pass dependencies through constructors, procedures, functions and methods parameters.
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

proc run(obj : MyClass = inject(MyClass)) =
    obj.call

```

### Example

```nim
import nimcls

Class Parent:
    var value: int = 10
    proc getValue(self: Parent): int =
        return self.value
    method hello(self: Parent) {.base.} =
        echo "Hello!! Parent"

Class Child(Parent):
    proc getNewValue(self: Child): int =
        return self.value + 10
    method hello(self: Child)  =
        echo "Hello!! Child"

proc callHello(classObject: Parent = inject(Parent)) =
    classObject.hello

let createChild = proc(): Child = Child()
addInjector(Parent, createChild)

## prints "Hello!! Child"
callHello()

```

### Classes Usage

#### Overview

```nim
import nimcls

# ClassObj is RootObj
Class MyClass ## type MyClass = ref object of ClassObj
Class static NextClass ## type NextClass = object of ClassObj
Class OtherClass(MyClass) ## type MyClass = ref object of MyClass
Class static OtherNextClass(NextClass) ## type OtherNextClass = object of NextClass
Class TryGeneric[K,V] ## type TryGeneric[K,V] = ref object of ClassObj


Class GenericClass[T]:
    var value: T
##
## Translated to:
## type GenericClass[T] 
##    = ref object of ClassObj
##        value: T
```


There are two types of classes that can be used:

1- Regular Class (Nim's `ref object`)

```nim
import nimcls

Class Person:
    var name: string
    method hello(self: Person) {.base.} =
        echo "Hello!! my name is " & self.name

let person = Person()
person.name = "Nim Dev"
```

2- Static Class (Nim's `object`)

```nim
import nimcls

Class static Person:
    var name: string = ""
    proc hello(self: Person) =
        echo "Hello!! my name is " & self.name

let person = Person(name: "Other Name")
# Error: properties cannot be updated
# person.name = "Nim Dev"
```

**What are the differences:**

1. ***ref object***:

- A ref object is a reference type. When you assign a ref object to another variable or pass it as a parameter to a procedure, you're passing a reference to the same object.
- ref object types are typically used for larger, mutable data structures where you want reference semantics, such as classes in other programming languages.
- They are allocated on the heap, and their memory is managed by the garbage collector. They are automatically deallocated when there are no more references to them.

2. ***object***:

- An object is a value type. When you assign an object to another variable or pass it as a parameter to a procedure, a copy of the object is made.
- object types are typically used for small, immutable data structures where you want value semantics, such as structs in other programming languages.
- They are allocated on the stack, and their memory is automatically deallocated when they go out of scope.

### Conditional Statements 

```nim
import nimcls

# When statement example
Class TryGeneric[T]:
    var value: T
    when T is string:
        var length: int
        var user: string
    when T is int:
        discard
    else:
        var name: string
        

# Case statement example
Class Next:
    var input: string
    switch myChar: char :
    of 'A':
        var aVal: int
    of 'Z':
        var zVal: string
    else:
        var val: float

```

### Interface Usage

```nim
import nimcls

Interface IRunner:
    method run(self: IRunner)
    method getFilePath(self: IRunner): string
    method isRunning(self: IRunner): bool
```

#### Interface Macro Rules:
1. An interface cannot have a parent class/object.
2. An interface cannot be a generic object.
2. An interface must have at least one method.
3. Only ***methods*** can be added to the interface.

### Injection Usage

There are two ways to register an injection:

1. Create an instance of the class and register it using `addSingleton` procedure.
2. Create a procedure which returns a class object and register it using `addInjector` procedure.

After registering an injection, call `inject` and pass the registered type to get the object.

#### Examples

1. Adding a singleton:

- *addSingleton[T]*

```nim
## only this instance of the class "MyClass" will be used.
let myClassObj = MyClass()
addSingleton(myClassObj)
```

- *addSingleton[R,T]*

```nim
## only this instance of the class "ChildClass" will be used
## but it will be registered as "ParentClass".
## "ChildClass" must be a subclass of  "ParentClass".
let myClassObj = MyClass()
addSingleton(ParentClass, myClassObj)
```

2. Adding a procedure:

- *addInjector[T]*

```nim
## A procedure that builds an instance of "ChildClass"
proc createChild() : ChildClass =
    let child = ChildClass()
    child.init("configurations")
    return child
## Each time "ChildClass" is injected, "createChild" will be called
## and a new instance will be created
addInjector(createChild)
```

- *addInjector[R,T]*

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

- *Passing it as a parameter*

```nim
## A procedure that has a parameter of type "ChildClass" 
proc runChild(child: ChildClass = inject(ChildClass) ) =
    child.run

```

- *Passing it to a constructor*

```nim
Class static User:
    var tools : Tools

let user = User(tools: inject(Tools))
```

- *Getting it through a call*

```nim
## A procedure that makes inject call
proc runChild() =
    let child = inject(ChildClass)
    child.run

```

## Limitations

1. **Constructors**: In the Nim programming language, objects cannot be created with a custom constructor.
2. **Constants**: Nim programming language does not support constant properties for objects. So, `let` and `const` cannot be used for **classes' properties**.
3. **Exporting classes with no parent**: While it is simple to export any class using the asterisk (`*`) symbol, Nim's compiler doesn't permit the following:

```nim
# causes a syntax error !?!? 
Class MyClass*:
   var me: string
```

However, you can solve this issue in **two ways**:

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

4. **Super class calls**: Calling a super class's methods is easy using the class's method `super` but `procCall` must be used to make the call.

```nim
# Not working, it will call the child object 'init' method 
child.super.init

# Works, it will call the super class method
procCall child.super.init
```

5. **Methods, Procedures and functions**: The class's macro only allows methods, procedures, and functions that utilize the class's object as their **first parameter** within the class's body. By keeping unrelated methods, procedures, and functions outside of classes, we ensure their focus remains on their intended functionality. Placing them within a class may introduce unnecessary complexity, making the code harder to understand and maintain.

6. **Objects casting**: Nim's limitations regarding **non-ref objects** casting, introduce challenges for dependency injection. These limitations elevate the risk of data loss, raise concerns about type safety, complicate debugging, and may result in unexpected output and errors when accessing object fields post-downcasting due to the possibility of encountering invalid addresses.

## Methods and Procedures

- Each class's object has the following methods or procedures :


| Name                 | Arguments | Returns                        | Description                                                                        |
|----------------------|-----------|--------------------------------|------------------------------------------------------------------------------------|
| `getClassName`       | ─         | `string`                       | Returns the class's name as a`string`.                                             |
| `getClassCalls`      | ─         | `seq[string]`                  | Returns the class's procedures, functions and methods in a sequence of`string`.    |
| `getClassProperties` | ─         | `seq[string]`                  | Returns the class's properties in a sequence of`string`.                           |
| `getParentClassName` | ─         | `string`                       | Returns the class's parent's class name as a`string`.                              |
| `super`              | ─         | `ClassObj`                     | Upcasts the object and returns it.                                                 |

- Dependency injection's procedures :


| Name                | Argument 1                                       | Argument 2             | Returns | Description                                                                                           |
|---------------------|--------------------------------------------------|------------------------|---------|-------------------------------------------------------------------------------------------------------|
| `addSingleton[T]`   | `ClassObj` or `ref ClassObj`                     | ─                      | ─       | Adds a singleton object of type`T` to the injection table and uses `T` as key for it.                 |
| `addSingleton[R,T]` | `typedesc[ref ClassObj]`                         | `ref ClassObj`         | ─       | Adds a singleton object of type`T` to the injection table and uses `R` as key for it.                 |
| `addInjector[T]`    | `proc(): ClassObj` or `proc(): ref ClassObj`     | ─                      | ─       | Adds a procedure that returns an object of type`T` to the injectors table and uses `T` as key for it. |
| `addInjector[R,T]`  | `typedesc[ref ClassObj]`                         | `proc(): ref ClassObj` | ─       | Adds a procedure that returns an object of type`T` to the injectors table and uses `R` as key for it. |
| `inject[T]`         | `typedesc[ClassObj]` or `typedesc[ref ClassObj]` | ─                      | `T`     | Returns an object of type`T` which exists in the injection tables.                                    |
| `isInjectable[T]`   | `typedesc[ClassObj]` or `typedesc[ref ClassObj]` | ─                      | `bool`  | Returns`true` if an object or a procedure of type `T` exists in the tables otherwise `false`.         |
| `isSingleton[T]`    | `typedesc[ClassObj]` or `typedesc[ref ClassObj]` | ─                      | `bool`  | Returns`true` if an object of type `T` exists in the injection table otherwise `false`.               |
| `resetInjectTbl`    | ─                                                | ─                      | ─       | Resets and removes all entries in the injection and injectors tables.                                 |
