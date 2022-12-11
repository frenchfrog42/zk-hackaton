# My submission to the ZK bsv hackaton

Compiled testZKSNARK.scrypt successfully, [1383468 bytes]  
(Instead of 5MB! Use my files to save a lot of fees for your users).

If you want to use my code, just replace your `bn256.scrypt` and `bn256pairing.scrypt` files with my files and enjoy the lower size (and faster compilation time) of your contract.

[EDIT]: I tried my lib on one of the submission of the hackaton, zk-minesweeper, and it indeed reduces the size of the contract, from (when compiled with release) 7 575 932 Bytes, to 1 954 015 Bytes, by replacing the single file "verifier.scrypt" (which is the concatenation of `bn256.scrypt`, `bn256pairing.scrypt`, and 15lines at the bottom).  
Check out the diff here: https://github.com/frenchfrog42/zk-minesweeper/commit/e4d963fbf30199e96e291a50bad8589ef21b01aa

## First, some background

I'm adding this paragraph (and doing some fixes to the readme, no other files are modified) based on feedback I got. If you wish to see the original README please click here https://github.com/frenchfrog42/zk-hackaton/blob/7b322a24e43e9f5f1cd891ed7dce1e973309a652/README.md

### Why does the size (of script) matter

Script is the code executed on chain. The larger it is the more fee you or your users pay. It's therefore crucial to make it as small as possible, but it's not trivial as it seems. For instance `<x> OP_PICK OP_0 OP_ADD` cannot be rewritten as `<x> OP_PICK` (can you see why? :)). But thankfully, scrypt with their premium license does an awesome job optimizing the size of the generated script code so you don't have to worry about it!

### Cool, but what it has to do with the zeroknowledge thing?

When you code a smart contract that uses this new trending zk tech, most of the time you want to verify a proof onchain. To verify this proof, you give it to a script code whose job is to verify it. Therefore the smaller it is, the better.

The nice thing about zk tech is that while the cost of generating the proof isn't constant, the cost of verifying is (as least for SNARKs it's in O(1), but it's in O(log(n)) for STARK I think).  
So, if you build a game, you'll encode all the logic in the proof, and on chain the only single computation you'll do is to verify it. So, probably 90% of the fee you'll pay is to verify this proof, therefore optimizing the verifier (the name given to the piece of code whose job is to verify this proof) will optimize naturally your contract as most of the cost is the verifier.

This is what I did at the hackaton. The size of the verifier is now 1.27MB with release mode. Before it was 5MB.  
So, if before your contract was let's say 5.1MB (5MB for the verifier, 100kB for your logic), now it's only 1.28MB! It's furthermore very easy to use this new verifier, as you just have to use the `bn256.scrypt` and `bn256pairing.scrypt` of this repo instead of the files of the scrypt boilerplate repo. Just copy/paste them, recompile, and boom you pay /3 in fees.

### Before the tech explanation, some background about Baguette/Racket

So, I've been developing a compiler that targets script. It's not very easy to use, but I've had a lot of fun creating it (and have learned a lot). Here is the page of the project https://frenchfrog42.github.io

It's written in Racket, which is a lisp. An example code of lisp `(* 3 (+ 1 2))`.

So, Baguette, my compiler, is written in Racket, takes lisp code as input, and outputs script code. For instance from `'(public (a b) (= (destroy a) (destroy b)))` it will output `OP_EQUAL`.  
Here is an example from the hackaton (https://github.com/frenchfrog42/zk-hackaton/blob/7b322a24e43e9f5f1cd891ed7dce1e973309a652/bn256/fq12.rkt#L46:L58):
```racket
(define (mulFQ12)
    (append
        (fq6 mulFQ6 "ay" "by" "ac")
        (fq6 mulFQ6 "ax" "bx" "bd")
        (fq6-unary mulTauFQ6 "bd" "bd2")

        (fq6 addFQ6 "ax" "ay" "aplusb")
        (fq6 addFQ6 "bx" "by" "cplusd")
        (fq6 mulFQ6 "destroy aplusb" "destroy cplusd" "resx")
        (fq6 subFQ6 "destroy resx" "ac" "resx")
        (fq6 subFQ6 "destroy resx" "destroy bd" "resx")

        (fq6 addFQ6 "destroy ac" "destroy bd2" "resy")
    ))
```

The code is less readable than scrypt code. The compiler is anyway less polished than scrypt's one. But it gives you more flexibility, and it was crucial for this hackaton as it allowed me to write more efficient code.

## Now, what is my contribution

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

As you can see, it's not a lot of code. This makes it easier to verify my code is equivalent to the old code. To do so I test each function as well as the full contract, please see below.

Here is the indicative size[1] I saved for each functions:

|                  | New size | Old size | % improvement |
|------------------|----------|----------|---------------|
| mulFQ12          | 1038     | 11373    | 90.87%        |
| squareFQ12       | 763      | 8459     | 90.98%        |
| doubleCurvePoint | 92       | 648      | 85.8%         |
| addCurvePoints   | 340      | 1409     | 75.87%        |
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
For instance, you don't have to copy every argument on top of the stack each time you make a function call. Here is an example, the first function does not copy arguments to the top of the stack, but the 2nd function does https://gist.github.com/frenchfrog42/576e0b54f73148dfe965ab935c9c261c  
Another difference, that gives a lot of improvement here, is the fact that Baguette modifies the order of variables in the stack when you modify a variable. So modifying a variable has always a fixed cost, and this variable will be at the top of the stack after the modification.

And I also remove the modulus everywhere, and only kept a minimal amount of them. Unfortunately, it's probably longer (CPU time) to verify now, but the scriptcode is smaller, so 🤷

To remove the modulus I used the file `abstract-interpretation.rkt` which takes source code and estimates the maximum value variable can possibly have. So if you do `c=a+b`, the maximum value `c` can have is the sum of the maximum value. It's, however, a bit tricky because numbers are very large so I do these estimates with their log256. So `a*b` is easy to estimate, but not `a+b`.  
This approach is feasible and somewhat "easy" because it's lisp. It's easy to parse source code and compute information about it.  
The result of this approach is however depressing. In the worst case, you NEED to keep a lot of modulus to not cross the 750.000 bytes limit. You can play yourself with the file if you want, but key takeaways are:
+ You need a modulus each 3 iterations of the loop in `mulCurvePoint`
+ You need a modulus each 5 instructions of either `linefuncdouble` or `linefuncadd`  
I applied these in the source code as you can check yourself. Without this script I'd have intuitively put far less modulus, and therefore wrote an incorrect code!

[1]: It's only an indicative size, for the "old size" there is some overhead so it's not the true size.  
For the "old size" there is the modulus everywhere inside, but not the "new size" (I compared properly only mulFQ12 without the modulus everywhere and the gain was approx ~70%)  
And it's also with the debug version, not the release version of these functions!

## How I wrote the code

Github copilot + https://gist.github.com/frenchfrog42/3cc0f669d5bb9e02fcb6ef9d075709c0

## How I tested it

First, it passes the main zksnark test that was already available in the boilerplate repo.

And then, I tested each function against the scrypt function.  
The file `test_subfunctions.py` does that (sorry for the boilerplate code, it's copilot).  
It creates (for instance) random instances of FQ12 objects, calls the original FQ12mul function and my function on it, and checks results are equal (and they are equal).  
Before checking it's equal, it applies a modulus because my version doesn't do the computation modulus the prime used.  
It also has 100% code coverage. The code has very little amount of branches, so it's been easy, but still a nice thing to have. For instance, each `test_addCurvePoints*.scrypt` goes to a given branch in the code.

## How to run the tests

First, install the scryptlib python library: `pip install scryptlib`.  
If you want to compile the scrypt code before running the tests, then install the scrypt vscode extension and compile the code to replace the json files by yours.  

There is 2 tests:
+ Either the test that each of my functions are the same as the scrypt function
+ Either a sample test that verifies a zk proof

If you want to run the tests without installing everything on your local machine, here is a repl: https://replit.com/@frenchfrog42/zk-hackaton  
Type either `pip install scryptlib; python3 test_ZKSNARK.py` or `pip install scryptlib; python3 test_subfunctions.py` depending on which test you want to run.

#### To test that my functions are the same as the scrypt's one
Clone this repo, and cd in it: `git clone https://github.com/frenchfrog42/zk-hackaton; cd zk-hackaton`  
Execute `python3 test_subfunctions.py`. Please adjust the parameter `n_test` at the very top of the python script if you wish to run more tests.

This will execute tests with the compiled scrypt file `testSubfunctionsZksnark.scrypt`.  
If you modify the script code of one of the 7 functions tested, you will need to recompile this file before running the tests.

#### To test a verify a sample proof
Clone this repo, and cd in it: `git clone https://github.com/frenchfrog42/zk-hackaton; cd zk-hackaton`  
Execute `python3 test_ZKSNARK.py`.

## Instruction to generate the scrypt/script code

First, Install racket: `sudo apt-get install racket`  
Clone this repo, and cd in it: `git clone https://github.com/frenchfrog42/zk-hackaton; cd zk-hackaton`  
Clone the Baguette repo: `git clone https://github.com/frenchfrog42/Baguette`  
Move the bn256 folder that contains the racket code into the Baguette folder: `mv bn256 Baguette/bn256`  
Modify and run the file you want, for instance: `racket Baguette/bn256/line.rkt`  
Copy and paste the result in your scrypt function, and compile your scrypt code :)

If you want a better dev experience, install the racket vscode extension as described in https://github.com/frenchfrog42/Baguette  

If you want to generate the script code without installing everything on your local machine, here is a repl: https://replit.com/@frenchfrog42/bsv-hackaton

## If you want to try without installing anything, here is what to do

Either you want to run the tests, either you want to run the racket code to generate the script.

If you want to run the tests:  
Here is a repl: https://replit.com/@frenchfrog42/zk-hackaton  
Now, type either `pip install scryptlib; python3 test_ZKSNARK.py` or `pip install scryptlib; python3 test_subfunctions.py` to run the tests.

If you want to run the racket code:  
Here is a repl: https://replit.com/@frenchfrog42/bsv-hackaton  
Now, type for instance `cd Baguette; racket bn256/line.rkt`.

---

I am not responsible if there is a bug in the code.

No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER, CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE. FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE, AND DISTRIBUTES IT "AS IS."
