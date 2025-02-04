# Zk Rollup Tutorial
In this assignment we'll build circuits for a ZK Rollup using circom.

# What you should do:

## Setup
install required packages by running `yarn` at the root of the assignment

`test.sh` file has already been provided for first 3 parts of the assignment. You're supposed to get an "OK!" at the end of snarkjs verify.

## 1_verify_eddsa.
Modify `eddsa.circom` to hash leaf inputs it receives and sign that hash using VerifyEdDSAPoseidon 

(Hint: Check the function signatures at circomlib)


## 2_verify_merkle
Modify `merkle.circom` to check if the merkle-path provided is valid in a set of merkle-trees instead of checking in a single one like you already implemented. (This is not necessarily related to rollups but you're already implemented a merkle-tree so this should be an interesting variation on it)

This implies that you have multiple valid merkle-trees at once. This can be the case, for example, of tornado-cash.
They maintain more than one merkle-tree as they have smart-contracts both in ethereum and some other chains/l2's.

If they wanted to, they could create a single circuit to validade if a user has deposited in any of the valid chains tornado is deployed on.


## 3_single_tx
Modify `single_tx.circom`. You've been provided with the `merkle.circom` file (no need to change it) and you've already implemented the eddsa.circom file on the first part of the assignment.

You should copy `eddsa.circom` into 3_single_tx and use its template on the `single_tx.circom` file. Make sure to remove the main reference from the eddsa.circom file or the compiler will complain.

## 4_comparator

**This part doesn't need any coding**. This question is just to show a possible problem that if statements may cause in circom.

Because circom compiles into arithmetic circuits, circuit whose behaviour depends on the value of an input can have unexpected behaviour. One example can be found in bad_force_equal_if_enabled.circom


# References 
https://hackmd.io/@n2eVNsYdRe6KIM4PhI_2AQ/SJJ8QdxuB
