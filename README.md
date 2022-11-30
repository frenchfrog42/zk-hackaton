# Todo

Compiled testZKSNARK.scrypt successfully, [1505512 bytes]

## Contribution

I optimized the following functions, so that the resulting scriptcode is a lot smaller and the fees cheaper for the end users.

Here is the list of functions I optimized:

```
bn256:
static function mulFQ12(FQ12 a, FQ12 b) : FQ12
static function squareFQ12(FQ12 a) : FQ12
static function doubleCurvePoint(CurvePoint a) : CurvePoint
static function addCurvePoints(CurvePoint a, CurvePoint b) : CurvePoint

bn256pairing:
static function lineFuncAdd(TwistPoint r, TwistPoint p, CurvePoint q, FQ2 r2) : LineFuncRes
static function lineFuncDouble(TwistPoint r, CurvePoint q) : LineFuncRes
static function mulLine(FQ12 ret, FQ2 a, FQ2 b, FQ2 c) : FQ12
```

And the indicative size[1] I saved for each functions:

|                  | New size | Old size | % improvement |
|------------------|----------|----------|---------------|
| mulFQ12          | 1038     | 11373    | 90.87%        |
| squareFQ12       | 763      | 8459     | 90.98%        |
| doubleCurvePoint | 92       | 648      | 85.8%         |
| addCurvePoints   | 327      | 1409     | 76.79%        |
| lineFuncAdd      | 548      | 4971     | 88.98%        |
| lineFuncDouble   | 484      | 4525     | 89.3%         |
| mulLine          | 580      | 8799     | 93.41%        |

I rewrote it in Baguette because it's more low level and you have more control.  
For instance you don't have to copy every arguments on top of the stack each time you make a function call. Here is an example, the first function does not copy arguments to the top of the stack, but the 2nd function does https://gist.github.com/frenchfrog42/576e0b54f73148dfe965ab935c9c261c  
Another difference, that gives a lot of improvement here, is the fact that Baguette modify the order of variable in the stack when you modify a variable. So modifying a variable has always a fixed cost, and this variable will be at the top of the stack after the modification.

And I also remove the modulus everywhere, and only kept the minimal amount of them. Unfortunatly it's probably longer (CPU time) to verify now, but the scriptcode is smaller, so 🤷

[1]: It's only an indicative size, for the "old size" there are some overhead so it's not the true size.  
For the "old size" there is the modulus everywhere inside, but not the "new size" (I compared properly only mulFQ12 without the modulus everywhere and the gain was approx ~70%)  
And it's also with the debug version, not the release version of these functions!

## How I wrote the code

https://gist.github.com/frenchfrog42/3cc0f669d5bb9e02fcb6ef9d075709c0

todo finish the gist

## How I tested it

First, it passes the main zksnark test that was already available in the boilerplate repo (todo link)

And then, I tested each function against the scrypt function.  
The file `test_subfunctions.py` does that (sorry for the boilerplate code, it's copilot).  
It creates (for instance) random instances of FQ12 objects, call the original FQ12mul function and my function on it, and check results are equal (and they are equal).  
Before checking it's equal, it applies a modulus because my version doesn't do computation modulus the prime used.  
It also has 100% code coverage. The code has very little amount of branches, so it's been easy, but still a nice thing to have. For instance, each `test_addCurvePoints*.scrypt` goes to a give branch in the code.

## How to run the tests

First, install the scrypt vscode extension to compile the code.  
Then, install the scryptlib python library: `pip install scryptlib`.

Now, you need to compile the file `testSubfunctionsZksnark.scrypt`, and then execute `python3 test_subfunctions.py`. Please adjust the parameter `n_test` at the very top of the python script if you wish to run more tests.

## Instruction to generate the scrypt/script code

Clone the Baguette repo: `git clone https://github.com/frenchfrog42/Baguette`  
Install racket: `sudo apt-get install racket`  
If you want a good dev experience, install the racket vscode extension as described in https://github.com/frenchfrog42/Baguette  
Modify and run the file you want, for instance: `racket bn256/line.rkt`  
Copy and paste the result in your scrypt function, and compile your scrypt code :)
