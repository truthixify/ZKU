pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib-matrix/circuits/matMul.circom";
include "../../node_modules/circomlib-matrix/circuits/matSub.circom";

template SystemOfEquations(n) { // n is the number of variables in the system of equations
    signal input x[n]; // this is the solution to the system of equations
    signal input A[n][n]; // this is the coefficient matrix
    signal input b[n]; // this are the constants in the system of equations
    signal output out; // 1 for correct solution, 0 for incorrect solution

    component ax = matMul(n, n, 1);

    // [bonus] insert your code here
    // initialize input of matMul
    for (var i = 0; i < n; i++) {
        for (var j = 0; j < n; j++) {
            ax.a[i][j] <== A[i][j];
        }
    }

    for (var i = 0; i < n; i++) {
        ax.b[i][0] <== x[i];
    }

    signal elsum[n];
    elsum[0] <== ax.out[0][0] - b[0];

    for (var i = 1; i < n; i++) {
        elsum[i] <== elsum[i - 1] + (ax.out[i][0] - b[i]);
    }

    component eq = IsEqual();
    eq.in[0] <== elsum[n - 1];
    eq.in[1] <== 0;

    out <== eq.out;
}

component main {public [A, b]} = SystemOfEquations(3);