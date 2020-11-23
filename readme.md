Lift
================================================================================

With Lua coroutines you can:

- Resume a coroutine (go down one level)
- Yield to the calling coroutine (go up one level)

Lift adds another option: yield up to a specific coroutine, no matter how far up
in the stack it is.

Usage is simple: the `lift` module mimics the `coroutine` module, and in fact
many of its functions are just copied over from it. However, it adds the
`lift.yieldto(target, ...)` function. Internally, lift passes extra parameters
around when yielding/resuming coroutines, so it is incompatible with the
original `coroutine` module.
