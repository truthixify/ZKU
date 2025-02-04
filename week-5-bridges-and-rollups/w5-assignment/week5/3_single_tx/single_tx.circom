pragma circom 2.0.3;
include "./merkle.circom";
include "./eddsa.circom";
include "./poseidon.circom";

// k is depth of accounts tree
template ProcessTx(k){

    // accounts tree info
    signal input accounts_root;
    signal input intermediate_root;
    signal input accounts_pubkeys[2**k][2];
    signal input accounts_balances[2**k];

    // transactions info
    signal input sender_pubkey[2];
    signal input sender_balance;
    signal input receiver_pubkey[2];
    signal input receiver_balance;
    signal input amount;
    signal input signature_R8x;
    signal input signature_R8y;
    signal input signature_S;
    signal input sender_proof[k];
    signal input sender_proof_pos[k];
    signal input receiver_proof[k];
    signal input receiver_proof_pos[k];

    signal output new_accounts_root;

    // [assignment] verify sender account exists in accounts_root
    component senderExistence = GetMerkleRoot(k, 3);
    senderExistence.leaf[0] <== sender_pubkey[0];
    senderExistence.leaf[1] <== sender_pubkey[1];
    senderExistence.leaf[2] <== sender_balance;
    for (var i = 0; i < k; i++) {
        senderExistence.pathElements[i] <== sender_proof[i];
        senderExistence.pathIndices[i] <== sender_proof_pos[i];
    }
    senderExistence.out === accounts_root;

    // [assignment] check that transaction was signed by sender
    component signatureCheck = VerifyEdDSAPoseidon(5);
    signatureCheck.from_x <== sender_pubkey[0];
    signatureCheck.from_y <== sender_pubkey[1];
    signatureCheck.R8x <== signature_R8x;
    signatureCheck.R8y <== signature_R8y;
    signatureCheck.S <== signature_S;
    signatureCheck.leaf[0] <== sender_pubkey[0];
    signatureCheck.leaf[1] <== sender_pubkey[1];
    signatureCheck.leaf[2] <== receiver_pubkey[0];
    signatureCheck.leaf[3] <== receiver_pubkey[1];
    signatureCheck.leaf[4] <== amount;

    // [assignment] debit sender account and hash new sender leaf
    // check intermediate tree with new sender balance
    component intermediate_tree = GetMerkleRoot(k, 3);
    intermediate_tree.leaf[0] <== sender_pubkey[0];
    intermediate_tree.leaf[1] <== sender_pubkey[1];
    intermediate_tree.leaf[2] <== sender_balance - amount;
    for (var i = 0; i < k; i++) {
        intermediate_tree.pathElements[i] <== sender_proof[i];
        intermediate_tree.pathIndices[i] <== sender_proof_pos[i];
    }
    intermediate_tree.out === intermediate_root;

    // [assignment] verify receiver account exists in intermediate_root
    component receiverExistence = GetMerkleRoot(k, 3);
    receiverExistence.leaf[0] <== receiver_pubkey[0];
    receiverExistence.leaf[1] <== receiver_pubkey[1];
    receiverExistence.leaf[2] <== receiver_balance;
    for (var i = 0; i < k; i++) {
        receiverExistence.pathElements[i] <== receiver_proof[i];
        receiverExistence.pathIndices[i] <== receiver_proof_pos[i];
    }
    receiverExistence.out === intermediate_root;

    // [assignment] credit receiver account and hash new receiver leaf
    component updated_tree = GetMerkleRoot(k, 3);
    updated_tree.leaf[0] <== receiver_pubkey[0];
    updated_tree.leaf[1] <== receiver_pubkey[1];
    updated_tree.leaf[2] <== receiver_balance + amount;
    for (var i = 0; i < k; i++) {
        updated_tree.pathElements[i] <== receiver_proof[i];
        updated_tree.pathIndices[i] <== receiver_proof_pos[i];
    }

    // [assignment] output final accounts_root
    new_accounts_root <== updated_tree.out;
    log(new_accounts_root);
}

component main{public [accounts_root]} = ProcessTx(1);
