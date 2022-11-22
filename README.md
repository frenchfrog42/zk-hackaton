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

## How I wrote the code

https://gist.github.com/frenchfrog42/3cc0f669d5bb9e02fcb6ef9d075709c0

## How I tested it

Todo

(todo make the random test go under all branches)

## Instruction to run

Todo
