use crate::matrix::Matrix;
use swf::Twips;

/// The transformation matrix for 3D used by Flash display objects.
#[derive(Copy, Clone, Debug, PartialEq)]
pub struct Matrix3D {
    /// 4x4 matrix elements.
    pub raw_data: [f32; 16],
}

impl Matrix3D {
    pub const IDENTITY: Self = Self {
        raw_data: [
            1.0, 0.0, 0.0, 0.0, //
            0.0, 1.0, 0.0, 0.0, //
            0.0, 0.0, 1.0, 0.0, //
            0.0, 0.0, 0.0, 1.0,
        ],
    };

    pub fn scale(x: f32, y: f32, z: f32) -> Self {
        Self {
            raw_data: [
                x, 0.0, 0.0, 0.0, //
                0.0, y, 0.0, 0.0, //
                0.0, 0.0, z, 0.0, //
                0.0, 0.0, 0.0, 1.0,
            ],
        }
    }

    pub fn translate(x: f32, y: f32, z: f32) -> Self {
        Self {
            raw_data: [
                1.0, 0.0, 0.0, 0.0, //
                0.0, 1.0, 0.0, 0.0, //
                0.0, 0.0, 1.0, 0.0, //
                x, y, z, 1.0,
            ],
        }
    }

    pub fn from_matrix(matrix: Matrix) -> Self {
        Self {
            raw_data: [
                // 1st column
                matrix.a,
                matrix.b,
                0.0,
                0.0,
                // 2nd column
                matrix.c,
                matrix.d,
                0.0,
                0.0,
                // 3rd column
                0.0,
                0.0,
                1.0,
                0.0,
                // 4th column
                matrix.tx.to_pixels() as f32,
                matrix.ty.to_pixels() as f32,
                0.0,
                1.0,
            ],
        }
    }

    pub fn to_matrix(self) -> Matrix {
        Matrix {
            a: self.raw_data[0],
            b: self.raw_data[1],
            c: self.raw_data[4],
            d: self.raw_data[5],
            tx: Twips::from_pixels(self.raw_data[12] as f64),
            ty: Twips::from_pixels(self.raw_data[13] as f64),
        }
    }

    pub fn transpose_in_place(&mut self) {
        self.raw_data.swap(1, 4);
        self.raw_data.swap(2, 8);
        self.raw_data.swap(3, 12);
        self.raw_data.swap(6, 9);
        self.raw_data.swap(7, 13);
        self.raw_data.swap(11, 14);
    }

    pub fn determinant(&self) -> f32 {
        let m = &self.raw_data;

        /// The determinant of a 3x3 matrix, stored in column-major order.
        fn determinant_3x3(m: [f32; 9]) -> f32 {
            m[0] * (m[4] * m[8] - m[7] * m[5]) - m[3] * (m[1] * m[8] - m[7] * m[2])
                + m[6] * (m[1] * m[5] - m[4] * m[2])
        }

        // When projection is 0, Flash ignores translation, suggesting there is
        // a fast path here.
        if m[3] == 0.0 && m[7] == 0.0 && m[11] == 0.0 {
            // This is equivalent to doing a Laplace expansion over the last
            // column, but considering only the last row is non-zero, we can
            // skip other rows.
            //
            // Usually we'd calculate the determinant of the inner 3x3 matrix
            // and multiply by the last element, but Flash appears to factor the
            // last element into the formula (observable when it's +-Infinity).
            determinant_3x3([
                m[0],
                m[1],
                m[2] * m[15],
                m[4],
                m[5],
                m[6] * m[15],
                m[8],
                m[9],
                m[10] * m[15],
            ])
        } else {
            // Based on the condition above, it looks like we should do the
            // Laplace expansion over the last column, but that's not what
            // happens. This is observable when using +-Infinity in a dense
            // matrix; infinities are preserved only in the first row, which
            // means that no two infinities are subtracted in the expression,
            // suggesting we should do the Laplace expansion over that row.
            let det0 = determinant_3x3([m[5], m[6], m[7], m[9], m[10], m[11], m[13], m[14], m[15]]);
            let det4 = determinant_3x3([m[1], m[2], m[3], m[9], m[10], m[11], m[13], m[14], m[15]]);
            let det8 = determinant_3x3([m[1], m[2], m[3], m[5], m[6], m[7], m[13], m[14], m[15]]);
            let det12 = determinant_3x3([m[1], m[2], m[3], m[5], m[6], m[7], m[9], m[10], m[11]]);
            m[0] * det0 - m[4] * det4 + m[8] * det8 - m[12] * det12
        }
    }

    pub fn invert(&self) -> Option<Self> {
        let d = self.determinant();
        let invertible = d.abs() > 0.00000000001;

        if !invertible {
            return None;
        }

        let d = 1.0 / d;

        let m = self.raw_data;
        let m11 = m[0];
        let m21 = m[4];
        let m31 = m[8];
        let m41 = m[12];
        let m12 = m[1];
        let m22 = m[5];
        let m32 = m[9];
        let m42 = m[13];
        let m13 = m[2];
        let m23 = m[6];
        let m33 = m[10];
        let m43 = m[14];
        let m14 = m[3];
        let m24 = m[7];
        let m34 = m[11];
        let m44 = m[15];

        #[rustfmt::skip]
        let raw_data = [
             d * (m22 * (m33 * m44 - m43 * m34) - m32 * (m23 * m44 - m43 * m24) + m42 * (m23 * m34 - m33 * m24)),
            -d * (m12 * (m33 * m44 - m43 * m34) - m32 * (m13 * m44 - m43 * m14) + m42 * (m13 * m34 - m33 * m14)),
             d * (m12 * (m23 * m44 - m43 * m24) - m22 * (m13 * m44 - m43 * m14) + m42 * (m13 * m24 - m23 * m14)),
            -d * (m12 * (m23 * m34 - m33 * m24) - m22 * (m13 * m34 - m33 * m14) + m32 * (m13 * m24 - m23 * m14)),
            -d * (m21 * (m33 * m44 - m43 * m34) - m31 * (m23 * m44 - m43 * m24) + m41 * (m23 * m34 - m33 * m24)),
             d * (m11 * (m33 * m44 - m43 * m34) - m31 * (m13 * m44 - m43 * m14) + m41 * (m13 * m34 - m33 * m14)),
            -d * (m11 * (m23 * m44 - m43 * m24) - m21 * (m13 * m44 - m43 * m14) + m41 * (m13 * m24 - m23 * m14)),
             d * (m11 * (m23 * m34 - m33 * m24) - m21 * (m13 * m34 - m33 * m14) + m31 * (m13 * m24 - m23 * m14)),
             d * (m21 * (m32 * m44 - m42 * m34) - m31 * (m22 * m44 - m42 * m24) + m41 * (m22 * m34 - m32 * m24)),
            -d * (m11 * (m32 * m44 - m42 * m34) - m31 * (m12 * m44 - m42 * m14) + m41 * (m12 * m34 - m32 * m14)),
             d * (m11 * (m22 * m44 - m42 * m24) - m21 * (m12 * m44 - m42 * m14) + m41 * (m12 * m24 - m22 * m14)),
            -d * (m11 * (m22 * m34 - m32 * m24) - m21 * (m12 * m34 - m32 * m14) + m31 * (m12 * m24 - m22 * m14)),
            -d * (m21 * (m32 * m43 - m42 * m33) - m31 * (m22 * m43 - m42 * m23) + m41 * (m22 * m33 - m32 * m23)),
             d * (m11 * (m32 * m43 - m42 * m33) - m31 * (m12 * m43 - m42 * m13) + m41 * (m12 * m33 - m32 * m13)),
            -d * (m11 * (m22 * m43 - m42 * m23) - m21 * (m12 * m43 - m42 * m13) + m41 * (m12 * m23 - m22 * m13)),
             d * (m11 * (m22 * m33 - m32 * m23) - m21 * (m12 * m33 - m32 * m13) + m31 * (m12 * m23 - m22 * m13)),
        ];

        Some(Self { raw_data })
    }

    pub fn multiply(&self, rhs: &Self) -> Self {
        let lhs = &self.raw_data;
        let rhs = &rhs.raw_data;
        let mut result = [0.0; 16];

        for column in 0..4 {
            for row in 0..4 {
                result[column * 4 + row] = lhs[row] * rhs[column * 4]
                    + lhs[4 + row] * rhs[column * 4 + 1]
                    + lhs[8 + row] * rhs[column * 4 + 2]
                    + lhs[12 + row] * rhs[column * 4 + 3];
            }
        }

        Self { raw_data: result }
    }

    /// Composes `translation * rotation_z * rotation_y * rotation_x * scale`.
    ///
    /// This is the order Flash Player uses for the 3D transform of a display object
    /// (and for `Matrix3D.recompose` with Euler angles). Rotations are in radians.
    pub fn from_components(translation: [f64; 3], rotation: [f64; 3], scale: [f64; 3]) -> Self {
        let [tx, ty, tz] = translation;
        let [rx, ry, rz] = rotation;
        let [sx, sy, sz] = scale;
        let (sin_x, cos_x) = rx.sin_cos();
        let (sin_y, cos_y) = ry.sin_cos();
        let (sin_z, cos_z) = rz.sin_cos();
        let raw_data = [
            // 1st column
            cos_y * cos_z * sx,
            cos_y * sin_z * sx,
            -sin_y * sx,
            0.0,
            // 2nd column
            (sin_x * sin_y * cos_z - cos_x * sin_z) * sy,
            (sin_x * sin_y * sin_z + cos_x * cos_z) * sy,
            sin_x * cos_y * sy,
            0.0,
            // 3rd column
            (cos_x * sin_y * cos_z + sin_x * sin_z) * sz,
            (cos_x * sin_y * sin_z - sin_x * cos_z) * sz,
            cos_x * cos_y * sz,
            0.0,
            // 4th column
            tx,
            ty,
            tz,
            1.0,
        ];
        Self {
            raw_data: raw_data.map(|v| v as f32),
        }
    }

    /// Decomposes this matrix into translation, Euler angles (in radians) and scale
    /// the way Flash Player does for the 3D transform of a display object.
    ///
    /// The axes are made orthogonal first (Gram-Schmidt), so a skew only shortens
    /// the y and z scales, and a mirrored matrix gets a negative z scale (with the
    /// rotations compensating for it).
    pub fn decompose_display_object(&self) -> ([f64; 3], [f64; 3], [f64; 3]) {
        fn dot(a: [f64; 3], b: [f64; 3]) -> f64 {
            a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
        }
        fn sub_scaled(a: [f64; 3], b: [f64; 3], k: f64) -> [f64; 3] {
            [a[0] - b[0] * k, a[1] - b[1] * k, a[2] - b[2] * k]
        }
        fn normalized(a: [f64; 3], length: f64, fallback: [f64; 3]) -> [f64; 3] {
            if length != 0.0 {
                [a[0] / length, a[1] / length, a[2] / length]
            } else {
                fallback
            }
        }

        let m = self.raw_data.map(f64::from);
        let translation = [m[12], m[13], m[14]];
        let col0 = [m[0], m[1], m[2]];
        let col1 = [m[4], m[5], m[6]];
        let col2 = [m[8], m[9], m[10]];

        let scale_x = dot(col0, col0).sqrt();
        let x_axis = normalized(col0, scale_x, [1.0, 0.0, 0.0]);

        let col1 = sub_scaled(col1, x_axis, dot(x_axis, col1));
        let scale_y = dot(col1, col1).sqrt();
        let y_axis = normalized(col1, scale_y, [0.0, 1.0, 0.0]);

        let col2 = sub_scaled(col2, x_axis, dot(x_axis, col2));
        let col2 = sub_scaled(col2, y_axis, dot(y_axis, col2));
        let mut scale_z = dot(col2, col2).sqrt();
        let determinant = m[0] * (m[5] * m[10] - m[6] * m[9]) - m[1] * (m[4] * m[10] - m[6] * m[8])
            + m[2] * (m[4] * m[9] - m[5] * m[8]);
        if determinant < 0.0 {
            scale_z = -scale_z;
        }
        let z_axis = normalized(col2, scale_z, [0.0, 0.0, 1.0]);

        let rotation_y = (-x_axis[2]).clamp(-1.0, 1.0).asin();
        // Adding 0 turns negative zeros into positive ones, which avoids
        // getting -180 degrees instead of 180 from `atan2`.
        let (rotation_x, rotation_z) = if x_axis[2].abs() < 1.0 {
            (
                (y_axis[2] + 0.0).atan2(z_axis[2] + 0.0),
                (x_axis[1] + 0.0).atan2(x_axis[0] + 0.0),
            )
        } else {
            ((y_axis[0] + 0.0).atan2(y_axis[1] + 0.0), 0.0)
        };
        (
            translation,
            [rotation_x, rotation_y, rotation_z],
            [scale_x, scale_y, scale_z],
        )
    }

    /// The perspective projection Flash Player applies to 3D display objects,
    /// flattened onto the `z = 0` plane.
    ///
    /// The viewpoint is at `(center_x, center_y, -focal_length)`, so a point at
    /// `z = 0` is left unchanged, and a point at `(x, y, z)` is drawn at
    /// `center + (point - center) * focal_length / (focal_length + z)`.
    pub fn perspective(center_x: f64, center_y: f64, focal_length: f64) -> Self {
        let raw_data = [
            // 1st column
            1.0,
            0.0,
            0.0,
            0.0,
            // 2nd column
            0.0,
            1.0,
            0.0,
            0.0,
            // 3rd column
            center_x / focal_length,
            center_y / focal_length,
            0.0,
            1.0 / focal_length,
            // 4th column
            0.0,
            0.0,
            0.0,
            1.0,
        ];
        Self {
            raw_data: raw_data.map(|v| v as f32),
        }
    }

    /// Transforms the point `(x, y, z, 1)`, returning its homogeneous coordinates.
    pub fn transform_point(&self, x: f64, y: f64, z: f64) -> [f64; 4] {
        let m = self.raw_data.map(f64::from);
        [
            m[0] * x + m[4] * y + m[8] * z + m[12],
            m[1] * x + m[5] * y + m[9] * z + m[13],
            m[2] * x + m[6] * y + m[10] * z + m[14],
            m[3] * x + m[7] * y + m[11] * z + m[15],
        ]
    }

    /// Projects the point `(x, y, 0)` of this matrix's local plane onto the screen,
    /// returning `None` when the point is at or behind the viewpoint.
    pub fn project_plane_point(&self, x: f64, y: f64) -> Option<(f64, f64)> {
        let [px, py, _, w] = self.transform_point(x, y, 0.0);
        (w > f64::EPSILON).then(|| (px / w, py / w))
    }

    /// Finds the point `(x, y)` on this matrix's local `z = 0` plane that projects
    /// onto the screen point `(screen_x, screen_y)`.
    ///
    /// The plane is mapped to the screen by the 3x3 homography made of the
    /// x, y and w rows and the 1st, 2nd and 4th columns, which is inverted here.
    /// Returns `None` if the plane is seen edge-on, or the point lies behind the viewpoint.
    pub fn unproject_plane_point(&self, screen_x: f64, screen_y: f64) -> Option<(f64, f64)> {
        let m = self.raw_data.map(f64::from);
        // Homography rows: [a b c] [d e f] [g h i] mapping (x, y, 1) to (X, Y, W).
        let (a, b, c) = (m[0], m[4], m[12]);
        let (d, e, f) = (m[1], m[5], m[13]);
        let (g, h, i) = (m[3], m[7], m[15]);
        // Adjugate of the homography (proportional to its inverse).
        let (ia, ib, ic) = (e * i - f * h, c * h - b * i, b * f - c * e);
        let (id, ie, if_) = (f * g - d * i, a * i - c * g, c * d - a * f);
        let (ig, ih, ii) = (d * h - e * g, b * g - a * h, a * e - b * d);
        let det = a * ia + b * id + c * ig;
        if det.abs() < 1e-12 {
            return None;
        }
        let x = ia * screen_x + ib * screen_y + ic;
        let y = id * screen_x + ie * screen_y + if_;
        let w = ig * screen_x + ih * screen_y + ii;
        if w.abs() < f64::EPSILON {
            return None;
        }
        let (x, y) = (x / w, y / w);
        // The point must lie in front of the viewpoint.
        let point_w = g * x + h * y + i;
        (point_w > f64::EPSILON).then_some((x, y))
    }

    pub fn tz(&self) -> f32 {
        self.raw_data[14]
    }
    pub fn set_tz(&mut self, tz: f32) {
        self.raw_data[14] = tz;
    }
}
