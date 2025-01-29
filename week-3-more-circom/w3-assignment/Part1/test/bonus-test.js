// [bonus] unit test for bonus.circom
const { assert } = require("chai");
const wasm_tester = require("circom_tester").wasm;

describe("Sum circuit", function () {
  let sumCircuit;

  before(async function () {
    sumCircuit = await wasm_tester("contracts/circuits/bonus.circom");
  });

  it("Should generate the witness successfully", async function () {
    let input = {
      numbers: [1, 2, 3, 4, 5, 6, 7, 8, 9],
      subset: [1, 1, 1, 0, 0, 0, 0, 0, 0],
      target: 6,
    };
    const witness = await sumCircuit.calculateWitness(input);
    await sumCircuit.assertOut(witness, {});
  });
});
