
module example;

import polymorph;

// Choose only one of the following three equivalent lines:

//mixin MakePolymorphicRefCountedHierarchy!("Foo", _Foo, "Bar", _Bar);
mixin MakePolymorphicRefCountedHierarchy!(_Foo, _Bar);
//mixin MakePolymorphicRefCountedHierarchy!(example);

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
    @property int prop() const { return assertAbstract!int; }
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
    @property int prop() const { return 4; }
    
    auto myFun() inout { return bar; }
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
        auto bar = cast(const Bar)foobar;
        // assert(bar.virtualCall(1) == "_Bar"); <-- ERROR: virtualCall can't be called on const Bar
        assert(bar.prop == 4);
        assert(bar.bar == bar.foo);
    }
    
    import std.stdio: writeln;
    writeln("Everything works!");
}