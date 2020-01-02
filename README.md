# BigNumber

Pure-Swift implementation of a BigNumber library!

This package adds the `UBigNumber` and `BigNumber` structures, as unsigned and signed integer types (respectively) with unlimited size. (maybe that's a bit
optimistic, their real size is just however much RAM you're willing to give them)

## How it works

### The `UBigNumber` type

A `UBigNumber` object is a structure whose only stored properties are an array of unsigned 64 bit integers and a boolean which
tells the `UBigNumber` whether or not it should automatically cleanse itslelf of extraneous leading zeros in order to save memory space.
This boolean is toggled internally and should not be manually changed.

The `UBigNumber` type is in the Little-Endian format, with 64-bit words. For example, the `UBigNumber` representing 
`0xDF72EF369932A988091B380F066CB5A3` would be `[656179807895991715, 16101194635580451208]`.

### The `BigNumber` type

The `BigNumber` type is just the signed version of a `UBigNumber`, with a `sign` property of type `Int` as well as a `magnitude` of
type `UBigNumber`.

## Quick start

BigNumbers (signed and unsigned) can be initilized with integer literals just as you would initialize any other integer type but you
must specify that it is a BigNumber.

```swift
let a: UBigNumber = 0xD5C4E761D36CA206 // creates unsigned BigNumber with a value of 15,403,691,032,858,894,854
let b: UBigNumber = 42 // creates unsigned BigNmber with a value of 42
let c: BigNumer = -32 // creates a signed BigNymber with a value of -32
```

Because standard integer literals are not large enough to represent the kind of numbers a BigNumber is meant to hold, the type
can also be initialized with a hex string literal. **Note: This only works with hexadecimal strings**

```swift
let a: UBN = "0x688375cdfde058451210410aad6f1739"
let b: UBN = "c1f1295b15e46418d0121eb1abba6c4f" // the '0x' is optional in the string, either way will work
```

They can also be initialized with an array literal of the array it will contain.

```swift
let a: UBN = [0, 1] // creates an unsigned BigNumber with a value of 0x10000000000000000
```

**Note: Initializing a `BigNumber` (signed version) with a non-signed specific literal type (array, string) will result in a `BigNumber` that is positive.**


