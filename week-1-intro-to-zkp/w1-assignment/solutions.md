# Solutions

## Part 1

Q1: Explain in 2-4 sentences why SNARK requires a trusted setup while STARK doesn’t.

A1: SNARKs require a trusted setup because they rely on pre-generated parameters used in their cryptographic construction which ensures efficiency and succinctness. If these parameters are compromised, the security of the entire system is at risk and so we must trust the party that started the setup ceremony to delete the secret parameters immediately. STARKs on the other hand avoid this need by using publicly verifiable hash functions, making their setup transparent, trustless and resistant to quantum computers.

Q2: Name two more differences between SNARK and STARK proofs.

A2: SNARKs required a trusted setup while STARKs don't require a trrusted setup. SNARKs have very short proof size(succinct) which makes highly efficient on blockchains applications where storage is critical while STARKs have large proof size.

## Part 2

Q2a: What does the circuit in HelloWorld.circom do?
A2a: The circuit checks that c is the multiplication of a and b.

Q2b: What is a Powers of Tau ceremony? Explain why this is important in the setup of zk-SNARK applications.

A2b: The Powers of Tau ceremony is a cryptographic process used to generate the foundational parameters required for zk-SNARK applications. It involves multiple participants contributing randomness to create a sequence of structured powers of a generator in a cryptographic group. The critical aspect is that each participant destroys their contribution's randomness, ensuring the parameters cannot be reconstructed. The process enhances the security and scalability of zk-SNARK-based systems while minimizing trust requirements in the setup phase.

Q2c: How are Phase 1 and Phase 2 trusted setup ceremonies different from each other?

A2c: Phase 1 is the general purpose reusable parameters that are independent of any specific zk-SNARK circuit. The output of Phase 1 can be reused for multiplications and circuits. Phase 2 uses the universal parameters generated in Phase 1 to create parameters that's specific to the zk-SNARK circuit. The output of Phase 2 are tied to a single circuit and cannot be reused for other circuits.

Q4a: With Plonk we can just use the powers of Tau generated in Phase and not have to contribute the second time.

Q4b:
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
| Groth16 | Plonk
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
| Trusted Setup | Circuit-specific | Universal and reusable |
| Representation | R1CS | Polynomial constraint system |
| Proof Size | Smaller ~ 200 bytes | Slightly larger (few KB) |
| Efficiency | Faster proof generation | Slower proof generation |
| Flexibility | Less flexible | Highly flexible |
| Use Case | Fixed circuits | Dynamic, evolving applications |
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
