Scientific calculator with an entrypoint in `bin/`, library code
in `lib/`, and unit test in `test/`.

I have based it on some old compiler code I wrote in C# in the early 2010:s and tried to translate the code concept by concept, learning Dart in the process.
The parser uses a combination of recursive descent and operator-precedence which works quite neat.
I struggled too long to interpret an operand wrapped in a parentheses in conjunction with another expression to the right or left as implicit multiplication, e.g. I'd like `(3)3` or `3(3)` to yield `9`, but that just screwed everything else up and I had to work for my client as well today so I gave up, and frankly most calculators don't seem to handle it anyway. Parentheses override evaluation order as expected so `3*3-1`gives `8` wheras `3*(3-1)` becomes `6`.

It treats the ordinary boolean operators as functions on integers, i.e. `10 < 3` evaluates to `1` whereas `NOT 1` evaluates to `0`; `NOT`, `AND`, `OR` and `XOR` operate on nonzero representing thruths. For convenience, I've also defined constants `TRUE`and `FALSE` as `1` and `0`, respectively.

The weird `LookaheadIterator` wrapper is something that I had to ask ChatGPT to help me craft out as I'm used to C# iterators (and C++) and did not have time to rethink all the logic in the `Parser` class to use Dart iterators directly, but I think I can explain how it works with a one element buffer.

Usage: 

Stand inside `HLF25-2\v01` and type: `dart run`

Keep typing mathematical expressions that will be evaluated and end with `q`. Typing `h` will show it's capabilities.

I've mapped some of the functions and mathematical constants I found in `math.dart` to the evaluator in the class `Calculator`, it's fairly straightfoward once the arguments have been parsed so typing `POW(2,2)` gives `4` and so on.

If I'd had more time; I'd figure out a away of mapping identifiers to lambas to those built-in functions instead of using a switch on their name in Calculator.

`tests\v01_tests.dart` has been developed as I've been hacking along, so I covers most cases even though I must find a much better way of structuring Dart unit tests. Maybe that's for tomorrow's lession.

Ok, I need to explain what a function is in Dart.

I'd say that it is a mapping from domain of inputs to a domain of outputs.

For example, 

In class `Calculator` locatd in `lib\calculator\calculator.dart` I define:
`static num calculate(String expression)`
which effectively checks if the argument `expression` belongs to the language of mathematical expressions that `Calculator` can handle, being a subset of all possible values that `String` can represent, and if so evaluates the expression and returns the result.
However, if the given `String` does NOT belong to the said "class" (set of valid mathematical expressions that the function is capable of evaluating), either `double.Nan` is returned (as the result is not a number), or an exception is thrown that the consumer (caller) may inspect to detect what went wrong. Both indicate that the function is not defined for the given input.
