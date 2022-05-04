Enum arrays

## The Gist

const Axis = enum { X, Y, Z };
const vec3: [Axis]f32 = undefined;
// vec3[Axis.X] == 0.0;
// vec3[.X] == 0.0; // Enum literals
// vec3.len == 3;

Heijsil points out that we should ensure that if someone reorders members of A, then the program doesn't break.

const E = enum {A, B, C }
const x = [E]u8 { 0, 1, 2 }; // Compile error
const e = [E]u8 { .A = 0, .B = 1, .C = 2 }

Tiehuis points out that we should keep the type of capture variable consistent with normal arrays: |item, index_type|.

for (vec3) |val, tag| {
    // @typeOf(val) == f32;
    // @typeOf(tag) == Axis;
}

const a: [E]T = undefined;
const b: [E]U = undefined;
for (a, b) |a_val, b_val, tag| {
    // @typeOf(tag) == Axis
}

## Typed enums

The backing type of an enum can be specified
This enum array has a length of 3 as there are 3 members of the enum:

const Reg = enum(u2) {RAX, RBX, RCX};
const r: [Reg]usize = undefined;
// r.len == 3;

## Wrapping up?

@MageJohn makes a good point regarding enums with explicit values, expected behaviour
becomes a little complex. We could end it here and already have a valuable feature-set.

I think there is more to it though, and this is the simplest approach I was able to come up with.

## Non-exhasutive enums:

const M = enum(u2) { First = 0, Last = 3, _ };

const m: [M]f32 = undefined;
m[.First] = 1;
m[.Last] = 2;

// std.mem.eql(f32, m, [_]{1, undefined, undefined, 2}) == true;

The enum array has a length of 16 - storage for all values of the backing type
It can be cast to a normal array of equal length.
It can only be indexed with an enum member value.

### Introducing: packed enum

A packed enum guarantees that declaration order matches value-order
A packed-enum array would have a guaranteed memory layout in the sense that its elements have a known, explicit ordering
We could even enforce that declaration order match the explicitly declared value
They could therefore be initialised with the array syntax.

const F = packed enum { First = 1, Last = 1000 };
const X = packed enum { First = 1000, Last = 1 }; // Compile error?
// std.mem.eql(f32, &[F]{ 1, 2 }, &[_]{1, 2}) == true;

### Introducing: comptime maps

While runtime values were discussed, I do not think it would be a problem to limit this feature to comptime known values,
since if a runtime cost is acceptable, it can be implemented in userland.

Including this as a language feature should communicate to the user that everything is resolved at comptime.

## Applications

