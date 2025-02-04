set -e 
if [ -f ../powersOfTau28_hez_final_16.ptau ]; then
    echo "powersOfTau28_hez_final_16.ptau already exists. Skipping."
else
    pushd ../
    echo 'Downloading powersOfTau28_hez_final_16.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_16.ptau
    popd
fi

# echo "verifying ptau"
# snarkjs powersoftau verify powersOfTau28_hez_final_16.ptau
echo "compiling circom"
circom merkle.circom --r1cs --wasm --sym

node generate_circuit_input.js
cd merkle_js;
node generate_witness.js merkle.wasm ../input.json ../witness.wtns
cd ..
#
snarkjs groth16 setup merkle.r1cs ../powersOfTau28_hez_final_16.ptau merkle_0000.zkey
echo "test" | snarkjs zkey contribute merkle_0000.zkey merkle_final.zkey --name="1st Contributor Name" -v
snarkjs zkey verify merkle.r1cs ../powersOfTau28_hez_final_16.ptau merkle_final.zkey
snarkjs zkey export verificationkey merkle_final.zkey verification_key.json
snarkjs groth16 prove merkle_final.zkey witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json
