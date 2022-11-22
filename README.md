# Todo

Compiled testZKSNARK.scrypt successfully, [1505512 bytes]

## Contribution

Rewrite/optimize the following functions, so that the resulting scriptcode is a lot smaller

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

Indicative size saved by functions:

|                  | New size | Old size | % improvement |
|------------------|----------|----------|---------------|
| mulFQ12          | 1038     | 11373    | 90.87%        |
| squareFQ12       | 763      | 8459     | 90.98%        |
| doubleCurvePoint | 92       | 648      | 85.8%         |
| addCurvePoints   | 327      | 1409     | 76.79%        |
| lineFuncAdd      | 548      | 4971     | 88.98%        |
| lineFuncDouble   | 484      | 4525     | 89.3%         |
| mulLine          | 580      | 8799     | 93.41%        |

(It's only an indicative size, for the "old size" there are some overhead it's not the true size. And the "old size" have the modulus everywhere inside, but not the "new size". I compared properly only mulFQ12 without the modulus everywhere and the gain was approx ~70%)  
(And it's also with the debug version, not the release version of these functions!)

I mainly rewrote it in Baguette because it's more low level and you have more control (for instance you don't have to copy every arguments on top of the stack each time you make a function call) (todo finir ça)

And I also remove the modulus everywhere, and only kept the minimal amount of them. Unfortunatly it's probably longer (CPU time) to verify now, but the scriptcode is smaller, so 🤷

## How I wrote the code

https://gist.github.com/frenchfrog42/3cc0f669d5bb9e02fcb6ef9d075709c0

todo finish the gist

## How I tested it

First, it passes the main zksnark test that was already available in the boilerplate repo (todo link)

And then, I tested each function against the scrypt function.  
The file `test_subfunctions.py` does that (sorry for the boilerplate code, it's copilot).  
It creates (for instance) random instances of FQ12 objects, call the original FQ12mul function and my function on it, and check results are equal (and they are equal).  
Before checking it's equal, it applies a modulus because my version doesn't do computation modulus the prime used.

(todo make the random test go under all branches)

## Instruction to run

Clone the Baguette repo: `git clone https://github.com/frenchfrog42/Baguette`  
Install racket: `sudo apt-get install racket`
If you want a good dev experience, install the racket vscode extension as described in https://github.com/frenchfrog42/Baguette  
Modify and run the file you want, for instance: `racket bn256/line.rkt`  
Copy and paste the result in your scrypt function :)
