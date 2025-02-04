import * as fs from "fs";
import {
    prv2pub,
    signPoseidon,
} from "../../node_modules/circomlibjs/src/eddsa.js";
import poseidon from "../../node_modules/circomlibjs/src/poseidon.js";
import { BigNumber } from "ethers";

var poseidonHash = async function (items) {
    return BigNumber.from(poseidon(items));
};
const leaf = [123, 456, 789];

const msg = await poseidonHash(leaf);
const prvKey = Buffer.from("1".toString().padStart(64, "0"), "hex");
const pubKey = prv2pub(prvKey);

const signature = signPoseidon(prvKey, msg.toBigInt());

const inputs = {
    from_x: pubKey[0].toString(),
    from_y: pubKey[1].toString(),
    R8x: signature.R8[0].toString(),
    R8y: signature.R8[1].toString(),
    S: signature.S.toString(),
    leaf: leaf,
};

fs.writeFileSync("./input.json", JSON.stringify(inputs), "utf-8");
