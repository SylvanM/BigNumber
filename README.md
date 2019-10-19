# BigNumber

Pure-Swift implementation of a BigNumber library!

This package adds the `BigNumber` structure, which is an array representation of an unsigned integer.

Swift arrays have dynamically-allocated memory, meaning that an object of type `BigNumber` can represent an unsigned integer of unlimited size
(although of course larger numbers will have a greater performance impact).

## How it works

A `BigNumber` object (which will be known from now on as its typealias, `BN`) is represented using the [Little-Endian](https://en.wikipedia.org/wiki/Endianness) 
format.

