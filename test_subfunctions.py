import os
import json
import random

from scryptlib import (
        compile_contract, build_contract_class, build_type_classes
        )

n_test = 10

"""Smart contract to test
import "bn256.scrypt";
import "bn256pairing.scrypt";

/*
    List of functions to test:
    bn256:
    static function OLDmulFQ12(FQ12 a, FQ12 b) : FQ12
    static function OLDsquareFQ12(FQ12 a) : FQ12
    static function OLDdoubleCurvePoint(CurvePoint a) : CurvePoint
    static function OLDaddCurvePoints(CurvePoint a, CurvePoint b) : CurvePoint

    bn256pairing:
    static function OLDlineFuncAdd(TwistPoint r, TwistPoint p, CurvePoint q, FQ2 r2) : LineFuncRes
    static function OLDlineFuncDouble(TwistPoint r, CurvePoint q) : LineFuncRes
    static function OLDmulLine(FQ12 ret, FQ2 a, FQ2 b, FQ2 c) : FQ12
*/

contract TestEverything {

    /* BN256 */

    public function test_mulFQ12(FQ12 a, FQ12 b) {
        require(BN256.modFQ12(BN256.OLDmulFQ12(a, b)) == BN256.modFQ12(BN256.mulFQ12(a, b)));
    }

    public function test_squareFQ12(FQ12 a) {
        require(BN256.modFQ12(BN256.OLDsquareFQ12(a)) == BN256.modFQ12(BN256.squareFQ12(a)));
    }

    public function test_doubleCurvePoint(CurvePoint a) {
        require(BN256.modCurvePoint(BN256.OLDdoubleCurvePoint(a)) == BN256.modCurvePoint(BN256.doubleCurvePoint(a)));
    }

    public function test_addCurvePoints(CurvePoint a, CurvePoint b) {
        require(BN256.modCurvePoint(BN256.OLDaddCurvePoints(a, b)) == BN256.modCurvePoint(BN256.addCurvePoints(a, b)));
    }

    /* BN256Pairing */

    public function test_lineFuncAdd(TwistPoint r, TwistPoint p, CurvePoint q, FQ2 r2) {
        LineFuncRes res1 = BN256Pairing.OLDlineFuncAdd(r, p, q, r2);
        LineFuncRes res2 = BN256Pairing.lineFuncAdd(r, p, q, r2);
        require(BN256Pairing.modLineFuncRes(res1) == BN256Pairing.modLineFuncRes(res2));
    }

    public function test_lineFuncDouble(TwistPoint r, CurvePoint q) {
        LineFuncRes res1 = BN256Pairing.OLDlineFuncDouble(r, q);
        LineFuncRes res2 = BN256Pairing.lineFuncDouble(r, q);
        require(BN256Pairing.modLineFuncRes(res1) == BN256Pairing.modLineFuncRes(res2));
    }

    public function test_mulLine(FQ12 ret, FQ2 a, FQ2 b, FQ2 c) {
        require(BN256.modFQ12(BN256Pairing.OLDmulLine(ret, a, b, c)) == BN256.modFQ12(BN256Pairing.mulLine(ret, a, b, c)));
    }
"""

# Load desc instead:
with open('./testSubfunctionsZksnark_debug_desc.json', 'r') as f:
    desc = json.load(f)

type_classes = build_type_classes(desc)
FQ2 = type_classes['FQ2']
FQ6 = type_classes['FQ6']
FQ12 = type_classes['FQ12']
CurvePoint = type_classes['CurvePoint']
TwistPoint = type_classes['TwistPoint']

BN256CurveTest = build_contract_class(desc)
bn256_curve_test = BN256CurveTest()

def create_FQ12(l):
    return FQ12({
            'x': FQ6({
                'x': FQ2({
                    'x': l[0],
                    'y': l[1]
                    }),
                'y': FQ2({
                    'x': l[2],
                    'y': l[3]
                    }),
                'z': FQ2({
                    'x': l[4],
                    'y': l[5]
                    })
                }),
            'y': FQ6({
                'x': FQ2({
                    'x': l[6],
                    'y': l[7]
                    }),
                'y': FQ2({
                    'x': l[8],
                    'y': l[9]
                    }),
                'z': FQ2({
                    'x': l[10],
                    'y': l[11]
                    })
                })
            })

def create_CurvePoint(l):
    return CurvePoint({
            'x': l[0],
            'y': l[1],
            'z': l[2],
            't': l[3]
            })

def create_TwistPoint(l):
    return TwistPoint({
            'x': FQ2({
                'x': l[0],
                'y': l[1]
                }),
            'y': FQ2({
                'x': l[2],
                'y': l[3]
                }),
            'z': FQ2({
                'x': l[4],
                'y': l[5]
                }),
            't': FQ2({
                'x': l[6],
                'y': l[7]
                })
            })

def create_FQ2(l):
    return FQ2({
            'x': l[0],
            'y': l[1]
            })

def test_mulFQ12():
    a = create_FQ12([random.randint(0, 2**256-1) for _ in range(12)])
    b = create_FQ12([random.randint(0, 2**256-1) for _ in range(12)])
    assert bn256_curve_test.testMulFQ12(a, b).verify()

def test_squareFQ12():
    a = create_FQ12([random.randint(0, 2**256-1) for _ in range(12)])
    assert bn256_curve_test.testSquareFQ12(a).verify()

def test_doubleCurvePoint():
    a = create_CurvePoint([random.randint(0, 2**256-1) for _ in range(4)])
    assert bn256_curve_test.testDoubleCurvePoint(a).verify()

# General case, is false for every if encountered in the scrypt code
# As you can see with the next 3 functions, it's ok to take random points for this function
# (Most random points will make each if go to the else condition)
def test_addCurvePoints():
    a = create_CurvePoint([random.randint(0, 2**256-1) for _ in range(4)])
    b = create_CurvePoint([random.randint(0, 2**256-1) for _ in range(4)])
    assert bn256_curve_test.testAddCurvePoints(a, b).verify()

# a.z == 0
def test_addCurvePoints_firstbranch():
    a = create_CurvePoint([random.randint(0, 2**256-1) for _ in range(2)] + [0] + [random.randint(0, 2**256-1)])
    b = create_CurvePoint([random.randint(0, 2**256-1) for _ in range(4)])
    assert bn256_curve_test.testAddCurvePoints(a, b).verify()

# b.z == 0
def test_addCurvePoints_secondbranch():
    a = create_CurvePoint([random.randint(0, 2**256-1) for _ in range(4)])
    b = create_CurvePoint([random.randint(0, 2**256-1) for _ in range(2)] + [0] + [random.randint(0, 2**256-1)])
    assert bn256_curve_test.testAddCurvePoints(a, b).verify()

# bothEqual == true
def test_addCurvePoints_thirdbranch():
    # xEqual means z*z*x is the same for both value
    # yValue means b.y*a.z*a.z*a.z is the same as a.y*b.z*b.z*b.z
    # To simplify for the first condition we'll take a.z = b.z, and a.x = b.x
    # This implies that a.y = b.y for the 2nd condition to be true
    # This may sound like a simplification, we could have bothEqual && not (a.z == b.z && a.x == b.x)
    # But, when bothEqual==true, the result returned is doubleCurvePoint which we already test elsewhere
    args = [random.randint(0, 2**256-1) for _ in range(4)]
    a = create_CurvePoint(args)
    b = create_CurvePoint(args[:3] + [random.randint(0, 2**256-1)])
    assert bn256_curve_test.testAddCurvePoints(a, b).verify()

def test_lineFuncAdd():
    r = create_TwistPoint([random.randint(0, 2**256-1) for _ in range(8)])
    p = create_TwistPoint([random.randint(0, 2**256-1) for _ in range(8)])
    q = create_CurvePoint([random.randint(0, 2**256-1) for _ in range(4)])
    r2 = create_FQ2([random.randint(0, 2**256-1) for _ in range(2)])
    assert bn256_curve_test.testLineFuncAdd(r, p, q, r2).verify()

def test_lineFuncDouble():
    r = create_TwistPoint([random.randint(0, 2**256-1) for _ in range(8)])
    q = create_CurvePoint([random.randint(0, 2**256-1) for _ in range(4)])
    assert bn256_curve_test.testLineFuncDouble(r, q).verify()

def test_mulLine():
    ret = create_FQ12([random.randint(0, 2**256-1) for _ in range(12)])
    a = create_FQ2([random.randint(0, 2**256-1) for _ in range(2)])
    b = create_FQ2([random.randint(0, 2**256-1) for _ in range(2)])
    c = create_FQ2([random.randint(0, 2**256-1) for _ in range(2)])
    assert bn256_curve_test.testMulLine(ret, a, b, c).verify()

# Run all tests
for _ in range(n_test):
    test_mulFQ12()
print("Test mul ok")
for _ in range(n_test):
    test_squareFQ12()
print("Test square ok")
for _ in range(n_test):
    test_doubleCurvePoint()
print("Test double ok")
for _ in range(n_test):
    test_addCurvePoints()
# These tests are less interesting than the others
# So we make them less numerous
for _ in range(max(2, n_test//10)):
    test_addCurvePoints_firstbranch()
    test_addCurvePoints_secondbranch()
    test_addCurvePoints_thirdbranch()
print("Test add ok")
for _ in range(n_test):
    test_lineFuncAdd()
print("Test line add ok")
for _ in range(n_test):
    test_lineFuncDouble()
print("Test line double ok")
for _ in range(n_test):
    test_mulLine()
print("Test mul line ok")
