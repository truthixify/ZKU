// TODO: Import necessary libraries. Check cargo.toml and the documentation of the libraries.
use ark_bls12_381::{Fq, FQ_ZERO};
use ark_ff::{Field, UniformRand};
use nalgebra::DMatrix;
use ndarray::{Array1, Array2};
use rand::rngs::OsRng;

struct Freivald {
    x: Array1<Fq>, // Array/Vec of Fq,
}

impl Freivald {
    // TODO: Create constructor for object
    fn new(array_size: usize) -> Self {
        // Generate random number
        // Populate vector with values r^i for i=0..matrix_size
        // Return freivald value with this vector as its x value
        let mut rng = OsRng;
        let r = Fq::rand(&mut rng);
        let x = (0..array_size).map(|i| r.pow(&[i as u64])).collect();

        Self { x }
    }

    // TODO: Add proper types to input matrices. Remember matrices should hold Fq values
    fn verify(&self, matrix_a: Array2<Fq>, matrix_b: Array2<Fq>, supposed_ab: Array2<Fq>) -> bool {
        assert!(check_matrix_dimensions(
            matrix_a.clone(),
            matrix_b.clone(),
            supposed_ab.clone()
        ));
        // TODO: check if a * b * x == c * x. Check algorithm to make sure order of operations are
        // correct
        let a = array_to__matrix(matrix_a);
        let b = array_to__matrix(matrix_b);
        let c = array_to__matrix(supposed_ab);

        let x = DMatrix::from_column_slice(self.x.len(), 1, &self.x.to_vec());

        a * (b * x.clone()) == c * x
    }

    // utility function to not have to instantiate Freivalds if you just want to make one
    // verification.
    // TODO: Add types for arguments
    fn verify_once(matrix_a: Array2<Fq>, matrix_b: Array2<Fq>, supposed_ab: Array2<Fq>) -> bool {
        let freivald = Freivald::new(supposed_ab.nrows());
        freivald.verify(matrix_a, matrix_b, supposed_ab)
    }
}
// TODO: [Bonus] Modify code to increase your certainty that A * B == C by iterating over the protocol.
// Note that you need to generate new vectors for new iterations or you'll be recomputing same
// value over and over. No problem in changing data structures used by the algorithm (currently its a struct
// but that can change if you want to)

// You can either do a test on main or just remove main function and rename this file to lib.rs to remove the
// warning of not having a main implementation
// fn main() {
//     todo!()
// }

// TODO: Add proper types to input matrices. Remember matrices should hold Fq values
pub fn check_matrix_dimensions(
    matrix_a: Array2<Fq>,
    matrix_b: Array2<Fq>,
    supposed_ab: Array2<Fq>,
) -> bool {
    // TODO: Check if dimensions of making matrix_a * matrix_b matches values in supposed_ab.
    // If it doesn't you know its not the correct result independently of matrix contents
    let a_m = matrix_a.nrows();
    let a_n = matrix_a.ncols();
    let b_n = matrix_b.nrows();
    let b_p = matrix_b.ncols();
    let c_m = supposed_ab.nrows();
    let c_p = supposed_ab.ncols();

    a_m == c_m && a_n == b_n && b_p == c_p
}

pub fn array_to__matrix(arr: Array2<Fq>) -> DMatrix<Fq> {
    let (rows, cols) = arr.dim();
    let mut matrix = DMatrix::from_element(rows, cols, Fq::new(FQ_ZERO.into()));

    for r in 0..rows {
        for c in 0..cols {
            matrix[(r, c)] = arr[(r, c)];
        }
    }

    matrix
}

#[cfg(test)]
mod tests {
    // #[macro_use]
    use lazy_static::lazy_static;
    use rstest::rstest;

    use super::*;

    lazy_static! {
        static ref MATRIX_A: Array2<Fq> =
            Array2::from_shape_fn((200, 200), |(i, j)| Fq::from((i + j) as u64));
        static ref MATRIX_A_DOT_A: Array2<Fq> = {
            let mut result = Array2::zeros((200, 200));
            for i in 0..200 {
                for j in 0..200 {
                    let mut sum = Fq::from(0u64);
                    for k in 0..200 {
                        sum += MATRIX_A[(i, k)] * MATRIX_A[(k, j)];
                    }
                    result[(i, j)] = sum;
                }
            }
            result
        };
        static ref MATRIX_B: Array2<Fq> =
            Array2::from_shape_fn((200, 200), |(i, j)| Fq::from((i + j + 1) as u64));
        static ref MATRIX_B_DOT_B: Array2<Fq> = {
            let mut result = Array2::zeros((200, 200));
            for i in 0..200 {
                for j in 0..200 {
                    let mut sum = Fq::from(0u64);
                    for k in 0..200 {
                        sum += MATRIX_B[(i, k)] * MATRIX_B[(k, j)];
                    }
                    result[(i, j)] = sum;
                }
            }
            result
        };
        static ref MATRIX_C: Array2<Fq> =
            Array2::from_shape_fn((200, 200), |(i, j)| Fq::from((i + j) as u64));
        static ref MATRIX_C_DOT_C: Array2<Fq> = {
            let mut result = Array2::zeros((200, 200));
            for i in 0..200 {
                for j in 0..200 {
                    let mut sum = Fq::from(0u64);
                    for k in 0..200 {
                        sum += MATRIX_C[(i, k)] * MATRIX_C[(k, j)];
                    }
                    result[(i, j)] = sum;
                }
            }
            result
        };
    }

    #[rstest]
    #[case(&MATRIX_A, &MATRIX_A, &MATRIX_A_DOT_A)]
    #[case(&MATRIX_B, &MATRIX_B, &MATRIX_B_DOT_B)]
    #[case(&MATRIX_C, &MATRIX_C, &MATRIX_C_DOT_C)]
    fn freivald_verify_success_test(
        #[case] matrix_a: &Array2<Fq>,
        #[case] matrix_b: &Array2<Fq>,
        #[case] supposed_ab: &Array2<Fq>,
    ) {
        let freivald = Freivald::new(supposed_ab.nrows());
        assert!(freivald.verify(matrix_a.clone(), matrix_b.clone(), supposed_ab.clone()));
    }

    #[rstest]
    #[case(&MATRIX_A, &MATRIX_B, &MATRIX_A_DOT_A)]
    #[case(&MATRIX_B, &MATRIX_A, &MATRIX_B_DOT_B)]
    #[case(&MATRIX_C, &MATRIX_B, &MATRIX_C_DOT_C)]
    fn freivald_verify_fail_test(
        #[case] a: &Array2<Fq>,
        #[case] b: &Array2<Fq>,
        #[case] c: &Array2<Fq>,
    ) {
        let freivald = Freivald::new(c.nrows());
        assert!(!freivald.verify(a.clone(), b.clone(), c.clone()));
    }
}
