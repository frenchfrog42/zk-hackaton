# My submission to the ZK bsv hackaton

Compiled testZKSNARK.scrypt successfully, [1270054 bytes]  
(Instead of 5MB! Use my files to save lot of fees for your users).

If you want to use my code, just replace your `bn256.scrypt` and `bn256pairing.scrypt` files with my files and enjoy the lower size (and faster compilation time) of your contract.

## Contribution

I optimized the following functions, so that the resulting scriptcode is a lot smaller and the fees cheaper for the end users. The diff between my code and the original code can be read here: https://github.com/frenchfrog42/zk-hackaton/commit/4e8deff409832e641362289719b9332a6cb0e4e5

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

You can find my implems in the following racket files:

In line.rkt you have:
+ `(contract->opcodes contract-linefuncadd)`
+ `(contract->opcodes contract-linefuncdouble)`

In curve.rkt you have:
+ `(contract->opcodes contract-doubleCurvePoint)`
+ `(contract->opcodes contract-addCurvePoint)`

In fq12.rkt you have:
+ `(contract->opcodes contract-mulFQ12)`
+ `(contract->opcodes contract-squareFQ12)`
+ `(contract->opcodes contract-mulLine)`


I rewrote it in Baguette because it's more low level and you have more control.  
For instance you don't have to copy every arguments on top of the stack each time you make a function call. Here is an example, the first function does not copy arguments to the top of the stack, but the 2nd function does https://gist.github.com/frenchfrog42/576e0b54f73148dfe965ab935c9c261c  
Another difference, that gives a lot of improvement here, is the fact that Baguette modify the order of variable in the stack when you modify a variable. So modifying a variable has always a fixed cost, and this variable will be at the top of the stack after the modification.

And I also remove the modulus everywhere, and only kept the minimal amount of them. Unfortunatly it's probably longer (CPU time) to verify now, but the scriptcode is smaller, so 🤷

To remove the modulus I used the file `abstract-interpretation.rkt` which takes source code and estimate the maximum value variable can possibly have. So if you do `c=a+b`, the maximum value `c` can have is the sum of the maximum value. It's however a bit tricky because numbers are very large so I do these estimates with their log256. So `a*b` is the easy to estimate, but not `a+b`.  
This approach is feasible and somewhat "easy" because it's lisp. It's easy to parse source code and compute information about it.  
The result of this approach is however depressing. In the worst case you NEED to keep a lot of modulus to not cross the 750.000 bytes limit. You can play yourself with the file if you want, but key take aways are:
+ You need a modulus each 3 iteration of the loop in `mulCurvePoint`
+ You need a modulus each 5 instruction of either `linefuncdouble` or `linefuncadd`  
I applied these in the source code as you can check yourself. Without this script I'd have intuitively put far less modulus, and therefore wrote an incorrect code!

[1]: It's only an indicative size, for the "old size" there are some overhead so it's not the true size.  
For the "old size" there is the modulus everywhere inside, but not the "new size" (I compared properly only mulFQ12 without the modulus everywhere and the gain was approx ~70%)  
And it's also with the debug version, not the release version of these functions!

## How I wrote the code

Github copilot + https://gist.github.com/frenchfrog42/3cc0f669d5bb9e02fcb6ef9d075709c0

## How I tested it

First, it passes the main zksnark test that was already available in the boilerplate repo.

And then, I tested each function against the scrypt function.  
The file `test_subfunctions.py` does that (sorry for the boilerplate code, it's copilot).  
It creates (for instance) random instances of FQ12 objects, call the original FQ12mul function and my function on it, and check results are equal (and they are equal).  
Before checking it's equal, it applies a modulus because my version doesn't do computation modulus the prime used.  
It also has 100% code coverage. The code has very little amount of branches, so it's been easy, but still a nice thing to have. For instance, each `test_addCurvePoints*.scrypt` goes to a give branch in the code.

## How to run the tests

First, install the scrypt vscode extension to compile the code.  
Then, install the scryptlib python library: `pip install scryptlib`.

Now, you need to compile the file `testSubfunctionsZksnark.scrypt`, and then execute `python3 test_subfunctions.py`. Please adjust the parameter `n_test` at the very top of the python script if you wish to run more tests.

If you want to run the tests without installing everything on your local machine, here is a repl: https://replit.com/@frenchfrog42/zk-hackaton  

## Instruction to generate the scrypt/script code

Clone the Baguette repo: `git clone https://github.com/frenchfrog42/Baguette`  
Install racket: `sudo apt-get install racket`  
If you want a good dev experience, install the racket vscode extension as described in https://github.com/frenchfrog42/Baguette  
Modify and run the file you want, for instance: `racket bn256/line.rkt`  
Copy and paste the result in your scrypt function, and compile your scrypt code :)

If you want to generate the script code without installing everything on your local machine, here is a repl: https://replit.com/@frenchfrog42/bsv-hackaton

## If you want to try without installing anything, here is what to do

Either you want to run the tests, either you want to run the racket code to generate the script.

If you want to run the tests:  
Here is a repl: https://replit.com/@frenchfrog42/zk-hackaton  
Now, type either `pip install scryptlib; python3 test_ZKSNARK.py` or `pip install scryptlib; python3 test_subfunctions.py` to run the tests.

If you want to run the racket code:  
Here is a repl: https://replit.com/@frenchfrog42/bsv-hackaton  
Now, type for instance `cd Baguette; racket bn256/line.rkt`.
