import * as fs from "fs";
import {
    prv2pub,
    signPoseidon,
} from "../../node_modules/circomlibjs/src/eddsa.js";
import poseidon from "../../node_modules/circomlibjs/src/poseidon.js";
import MerkleTree from "./merkle-tree-lib/lib/index.js";
import { BigNumber } from "ethers";

var poseidonHash = async function (items) {
    return BigNumber.from(await poseidon(items));
};
const alicePrvKey = Buffer.from("1".toString().padStart(64, "0"), "hex");
const alicePubKey = prv2pub(alicePrvKey);
const bobPrvKey = Buffer.from("2".toString().padStart(64, "0"), "hex");
const bobPubKey = prv2pub(bobPrvKey);

// accounts
const Alice = {
    pubkey: alicePubKey,
    balance: 500,
};
const aliceHash = await poseidonHash([
    Alice.pubkey[0],
    Alice.pubkey[1],
    Alice.balance,
]);

const Bob = {
    pubkey: bobPubKey,
    balance: 0,
};
const bobHash = await poseidonHash([Bob.pubkey[0], Bob.pubkey[1], Bob.balance]);
const leafArray = [aliceHash, bobHash];
const tree = new MerkleTree.MerkleTree(1, leafArray);
const accounts_root = tree.root();
// const accounts_root = await poseidonHash([aliceHash, bobHash]);

// transaction
const tx = {
    from: Alice.pubkey,
    to: Bob.pubkey,
    amount: 500,
};

// Alice sign tx
const txHash = await poseidonHash([
    tx.from[0],
    tx.from[1],
    tx.to[0],
    tx.to[1],
    tx.amount,
]);
// const bufTxHash = Buffer.from(txHash.toString());
const signature = signPoseidon(alicePrvKey, txHash.toBigInt());

// update Alice account
const newAlice = {
    pubkey: alicePubKey,
    balance: 0,
};
const newAliceHash = await poseidonHash([
    newAlice.pubkey[0],
    newAlice.pubkey[1],
    newAlice.balance,
]);

// update intermediate root
const intermediate_root = new MerkleTree.MerkleTree(1, [
    newAliceHash,
    bobHash,
]).root();

// update Bob account
const newBob = {
    pubkey: bobPubKey,
    balance: 500,
};
const newBobHash = await poseidonHash([
    newBob.pubkey[0],
    newBob.pubkey[1],
    newBob.balance,
]);

// update final root
const final_root = await poseidonHash([newAliceHash, newBobHash]);

const inputs = {
    accounts_root: accounts_root.toString(),
    intermediate_root: intermediate_root.toString(),
    accounts_pubkeys: [
        [Alice.pubkey[0].toString(), Alice.pubkey[1].toString()],
        [Bob.pubkey[0].toString(), Bob.pubkey[1].toString()],
    ],
    accounts_balances: [Alice.balance, Bob.balance],
    sender_pubkey: [Alice.pubkey[0].toString(), Alice.pubkey[1].toString()],
    sender_balance: Alice.balance,
    receiver_pubkey: [Bob.pubkey[0].toString(), Bob.pubkey[1].toString()],
    receiver_balance: Bob.balance,
    amount: tx.amount,
    signature_R8x: signature["R8"][0].toString(),
    signature_R8y: signature["R8"][1].toString(),
    signature_S: signature["S"].toString(),
    sender_proof: [bobHash.toString()],
    sender_proof_pos: [0],
    receiver_proof: [newAliceHash.toString()],
    receiver_proof_pos: [1],
};

fs.writeFileSync("./input.json", JSON.stringify(inputs), "utf-8");
