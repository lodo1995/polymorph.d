
# polymorph.d: struct polymorphism

This module provides mixins to create wrappers to transform structures into
polymorphic, refcounted reference types. In practice, this module builds refcounted
classes from structs.

### What's inside the module?

* `@PolymorphicWrapper("MyWonderfulName")`: a UDA to use on structs; it specifies the name of the wrapper;
* `mixin BaseClass;`: the containing struct will be the base of a struct hierarchy;
* `mixin DerivedOf!(T);`: the containing struct will be part of a hierarchy and will derive from `T`;
* `mixin hasDerived!(A, B, C);`: the containing struct will be part of a hierarchy and `A`, `B` and `C` will derive from it;
* `mixin MakePolymorphicRefCountedHierarchy!("A", _A, "B", _B, "C", _C);`: builds wrappers around structs
`_A`, `_B` and `_C`; the wrappers' names will be `A`, `B` and `C`;
* `mixin MakePolymorphicRefCountedHierarchy!(A, B, C);`: builds wrappers around structs `A`, `B` and `C`; the wrappers' names
will be the ones specified via `@PolymorphicWrapper`;
* `mixin MakePolymorphicRefCountedHierarchy!(mymodule);`: builds wrappers around all structs in `mymodule` marked with `@PolymorphicWrapper`;
* function `assertAbstract`, to mark functions as abstract and get a nice error message if they are used (`abstract` can't be used on structs).

### An example

```d

mixin MakePolymorphicRefCountedHierarchy!(_Foo, _Bar);

@PolymorphicWrapper("Foo")
struct _Foo
{
    mixin BaseClass;
    mixin HasDerived!(_Bar);
    
    int foo;
    Bar child;
    string virtualCall(int x)
    {
        return "_Foo";
    }
    @property int prop() { return assertAbstract!int; }
}

@PolymorphicWrapper("Bar")
struct _Bar
{
    mixin DerivedOf!(_Foo);
    
    Foo parent;
    Bar sibling;
    int bar;
    string virtualCall(int x)
    {
        return "_Bar";
    }
    @property int prop() { return 4; }
}

void main()
{
    auto foobar = Foo(_Bar());
    assert(!foobar.isNull);
    assert(foobar);
    assert(foobar.virtualCall(1) == "_Bar");
    assert(foobar.prop == 4);
    assert(foobar.foo == 0);
    
    {
        auto bar = cast(Bar)foobar;
        //assert(bar.virtualCall(1) == "_Bar"); <-- ERROR: bar is const, while virtualCall is not.
        assert(bar.prop == 4);
        assert(bar.bar == bar.foo);
    }
    
    import std.stdio: writeln;
    writeln("Everything works!");
}

```