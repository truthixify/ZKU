pragma circom 2.0.3;
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/eddsaposeidon.circom";

template VerifyEdDSAPoseidon(k) {
    signal input from_x;
    signal input from_y;
    signal input R8x;
    signal input R8y;
    signal input S;
    signal input leaf[k];
    
    // [assignment] Hash leaf using poseidon hasher
    component hasher = Poseidon(k);
    for (var i = 0; i < k; i++) {
        hasher.inputs[i] <== leaf[i];
    }
    
    // [assignment] Add inputs to verifier
    component verifier = EdDSAPoseidonVerifier();   
    verifier.enabled <== 1;
    verifier.Ax <== from_x;
    verifier.Ay <== from_y;
    verifier.R8x <== R8x;
    verifier.R8y <== R8y;
    verifier.S <== S;
    verifier.M <== hasher.out;
}

// component main{public[from_x, from_y, R8x, R8y, S]} = VerifyEdDSAPoseidon(3);
