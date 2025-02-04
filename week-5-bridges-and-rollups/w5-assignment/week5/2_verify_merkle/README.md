# Merkle Trees - Again

By now you should've already implemented a merkle tree verifier on circom, so lets add new functionalities to the merkle tree.

Suppose you have not one but many merkle trees. One for each blockchain your application is deployed on.

You could implement a circuit that is shared among all your applications. In this case you wouldn't have only one valid merkle root but a set of merkle roots.

In this assignment you should modify the merkle-tree implementation to use a set of merkle-roots instead of a single root.

