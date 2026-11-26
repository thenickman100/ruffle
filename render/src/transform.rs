use crate::matrix::Matrix;
use crate::matrix3d::Matrix3D;
use crate::perspective_projection::PerspectiveProjection;
use swf::ColorTransform;

/// Represents the transform for a DisplayObject.
/// This includes both the transformation matrix and the color transform.
#[derive(Clone, Debug, Default, PartialEq)]
pub struct Transform {
    pub matrix: Matrix,
    /// The 3D transform of a display object that uses 3D properties.
    ///
    /// When pushed onto a [`TransformStack`], this is the object's local 3D matrix
    /// (in pixels). In the stack it holds the accumulated matrix, including the
    /// perspective projection, from the object's local space to the viewport.
    /// `matrix` then only holds a flattened approximation.
    pub matrix3d: Option<Matrix3D>,
    pub color_transform: ColorTransform,
    pub perspective_projection: Option<PerspectiveProjection>,
}

impl Transform {
    /// Scales the local space of this transform (both its 2D and its 3D matrix).
    pub fn scale_local(&mut self, scale_x: f32, scale_y: f32) {
        self.matrix *= Matrix::scale(scale_x, scale_y);
        if let Some(matrix3d) = &mut self.matrix3d {
            *matrix3d = matrix3d.multiply(&Matrix3D::scale(scale_x, scale_y, 1.0));
        }
    }
}

pub struct TransformStack {
    stack: Vec<Transform>,
    /// The perspective projection (in viewport pixels) applied where a 3D object
    /// is first met below 2D ancestors. Without one, 3D objects are drawn flattened.
    projection: Option<Matrix3D>,
}

impl TransformStack {
    pub fn new() -> Self {
        Self {
            stack: vec![Transform::default()],
            projection: None,
        }
    }

    /// Sets the perspective projection used for 3D objects pushed from now on.
    pub fn set_projection(&mut self, projection: Option<Matrix3D>) {
        self.projection = projection;
    }

    /// The perspective projection used for 3D objects.
    pub fn projection(&self) -> Option<Matrix3D> {
        self.projection
    }

    pub fn push(&mut self, transform: &Transform) {
        let cur_transform = self.transform();
        let matrix = cur_transform.matrix * transform.matrix;
        let color_transform = cur_transform.color_transform * transform.color_transform;
        let matrix3d = match (cur_transform.matrix3d, transform.matrix3d) {
            // Below a 3D object, everything is transformed in 3D, and the
            // projection has already been applied.
            (Some(parent), local) => Some(
                parent.multiply(&local.unwrap_or_else(|| Matrix3D::from_matrix(transform.matrix))),
            ),
            // The first 3D object below 2D ancestors gets projected.
            (None, Some(local)) => {
                let parent = Matrix3D::from_matrix(cur_transform.matrix);
                let projection = self.projection.unwrap_or(Matrix3D::IDENTITY);
                Some(projection.multiply(&parent).multiply(&local))
            }
            (None, None) => None,
        };
        self.stack.push(Transform {
            matrix,
            matrix3d,
            color_transform,
            // TODO: Merge perspective_projections from cur_transform and transform properly
            perspective_projection: Default::default(),
        });
    }

    pub fn pop(&mut self) {
        assert!(self.stack.len() > 1, "Transform stack underflow");
        self.stack.pop();
    }

    pub fn transform(&self) -> Transform {
        self.stack[self.stack.len() - 1].clone()
    }
}

impl Default for TransformStack {
    fn default() -> Self {
        TransformStack::new()
    }
}
