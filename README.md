# AlecrimAsyncKit
Bringing async and await to Swift world with some flavouring.

## Getting Started

Very initial WIP stage.

Docs will be here soon, but you will be able to write something like this:

```swift
do {
    let i = try await { asyncDoSomethingInBackground() }
    print(i)
}
catch let error {
    print(error)
}

// in the Swift world it is better to have `async` as a prefix, not a suffix
func asyncDoSomethingInBackground() -> Task<Int> {
    return async { task in
        var error: ErrorType? = nil
    
        for i in 0..<1_000_000_000 {
           // do something
        }
        
        // ...
        
        if let error = error {
            task.finishWithError(error)
        }
        else {
            task.finishWithValue(i)
        }
    }
}

```

Or:

```swift
let task = asyncDoSomethingNonFailableInBackground()
    
// do other thins while task is running
for o in 0..<1_000_000
    
// now we need the task result
let result = await(task)
print(result)

// in the Swift world it is better to have `async` as a prefix, not a suffix
func asyncDoSomethingNonFailableInBackground() -> Task<Int> {
    return async { task in
        for i in 0..<1_000_000_000 {
           // do something
        }
        
        task.finishWithValue(i)
    }
}

```

---

## Contact

- [Vanderlei Martinelli](https://github.com/vmartinelli)

## License

AlecrimAsyncKit is released under an MIT license. See LICENSE for more information.