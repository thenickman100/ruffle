use crate::avm2::Error;
use crate::avm2::activation::Activation;
use crate::avm2::function::FunctionArgs;
use crate::avm2::globals::slots::flash_events_mouse_event as slots;
use crate::avm2::object::{Object, TObject as _};
use crate::avm2::value::Value;
use crate::display_object::{DisplayObject, TDisplayObject};
use swf::Point;

/// Implements `stageX`'s getter.
pub fn get_stage_x<'gc>(
    activation: &mut Activation<'_, 'gc>,
    this: Value<'gc>,
    _args: FunctionArgs<'_, 'gc>,
) -> Result<Value<'gc>, Error<'gc>> {
    let this = this.as_object().unwrap();

    local_to_stage_x(activation, this, slots::_LOCAL_X, slots::_LOCAL_Y)
}

/// Implements `stageY`'s getter.
pub fn get_stage_y<'gc>(
    activation: &mut Activation<'_, 'gc>,
    this: Value<'gc>,
    _args: FunctionArgs<'_, 'gc>,
) -> Result<Value<'gc>, Error<'gc>> {
    let this = this.as_object().unwrap();

    local_to_stage_y(activation, this, slots::_LOCAL_X, slots::_LOCAL_Y)
}

pub fn update_after_event<'gc>(
    activation: &mut Activation<'_, 'gc>,
    _this: Value<'gc>,
    _args: FunctionArgs<'_, 'gc>,
) -> Result<Value<'gc>, Error<'gc>> {
    *activation.context.needs_render = true;
    Ok(Value::Undefined)
}

/// Converts the local position of a mouse event to stage coordinates, in pixels.
fn local_to_stage(target: DisplayObject<'_>, local_x: f64, local_y: f64) -> (f64, f64) {
    // Seen through a 3D projection, the local position isn't rounded to twips.
    if let Some(matrix3d) = target.local_to_global_matrix3d()
        && let Some((x, y)) = matrix3d.project_plane_point(local_x, local_y)
    {
        let to_twips = |v: f64| (v * 20.0).round() / 20.0;
        return (to_twips(x), to_twips(y));
    }
    let local = Point::from_pixels(local_x, local_y);
    // `local_to_global` does a matrix multiplication, which in general
    // depends on both the x and y coordinates.
    let global = target.local_to_global(local);
    (global.x.to_pixels(), global.y.to_pixels())
}

pub(super) fn local_to_stage_x<'gc>(
    activation: &mut Activation<'_, 'gc>,
    this: Object<'gc>,
    slot_x: usize,
    slot_y: usize,
) -> Result<Value<'gc>, Error<'gc>> {
    if let Some(evt) = this.as_event() {
        let local_x = this.get_slot(slot_x).coerce_to_number(activation)?;
        let local_y = this.get_slot(slot_y).coerce_to_number(activation)?;

        if local_x.is_nan() || local_y.is_nan() {
            return Ok(Value::Number(local_x));
        } else if let Some(target) = evt.target().and_then(|t| t.as_display_object()) {
            let global = local_to_stage(target, local_x, local_y);
            return Ok(Value::Number(global.0));
        } else {
            return Ok(Value::Number(local_x * 0.0));
        }
    }

    Ok(Value::Undefined)
}

pub(super) fn local_to_stage_y<'gc>(
    activation: &mut Activation<'_, 'gc>,
    this: Object<'gc>,
    slot_x: usize,
    slot_y: usize,
) -> Result<Value<'gc>, Error<'gc>> {
    if let Some(evt) = this.as_event() {
        let local_x = this.get_slot(slot_x).coerce_to_number(activation)?;
        let local_y = this.get_slot(slot_y).coerce_to_number(activation)?;

        if local_x.is_nan() || local_y.is_nan() {
            return Ok(Value::Number(local_y));
        } else if let Some(target) = evt.target().and_then(|t| t.as_display_object()) {
            let global = local_to_stage(target, local_x, local_y);
            return Ok(Value::Number(global.1));
        } else {
            return Ok(Value::Number(local_y * 0.0));
        }
    }

    Ok(Value::Undefined)
}
