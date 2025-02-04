# set -e makes sure scripts stop if any errors are met. 
set -e
if [ -f ../powersOfTau28_hez_final_16.ptau ]; then
    echo "powersOfTau28_hez_final_16.ptau already exists. Skipping."
else
    pushd ../
    echo 'Downloading powersOfTau28_hez_final_16.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_16.ptau
    popd
fi

echo "compiling circom"
circom eddsa.circom --r1cs --wasm --sym

echo "generating input.json"
node generate_input/generate_circuit_input.js

echo "generating witness.wtns"
cd eddsa_js;
node generate_witness.js eddsa.wasm ../input.json ../witness.wtns
cd ..
#
echo "Setting up circuit specific cerimony"
snarkjs groth16 setup eddsa.r1cs ../powersOfTau28_hez_final_16.ptau eddsa_0000.zkey
echo "Contributing to circuit specific cerimony"
echo "test" | snarkjs zkey contribute eddsa_0000.zkey eddsa_final.zkey --name="1st Contributor Name" -v
echo "Verifying zkey"
snarkjs zkey verify eddsa.r1cs ../powersOfTau28_hez_final_16.ptau eddsa_final.zkey
echo "Exporting verfification key"
snarkjs zkey export verificationkey eddsa_final.zkey verification_key.json
echo "Proving witness"
snarkjs groth16 prove eddsa_final.zkey witness.wtns proof.json public.json
echo "Verifying result"
snarkjs groth16 verify verification_key.json public.json proof.json
