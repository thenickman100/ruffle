use crate::avm2::object::script_object::ScriptObjectData;
use crate::avm2::object::{Object, TObject};
use crate::avm2::{Activation, Class, ClassObject, Error};
use crate::character::Character;
use crate::context::UpdateContext;
use crate::font::Font;
use gc_arena::{Collect, Gc, GcWeak, Mutation};
use ruffle_common::utils::HasPrefixField;
use std::fmt;

/// A class instance allocator that allocates Font objects.
pub fn font_allocator<'gc>(
    class: ClassObject<'gc>,
    activation: &mut Activation<'_, 'gc>,
) -> Result<Object<'gc>, Error<'gc>> {
    let base = ScriptObjectData::new(class);
    let font = font_for_class(class.inner_class_definition(), activation.context);

    Ok(FontObject(Gc::new(activation.gc(), FontObjectData { base, font })).into())
}

/// The embedded font that a `Font` subclass is linked to, if any.
fn font_for_class<'gc>(class: Class<'gc>, context: &UpdateContext<'gc>) -> Option<Font<'gc>> {
    let (movie, id) = context.library.avm2_class_registry().class_symbol(class)?;
    match context
        .library
        .library_for_movie(movie)?
        .character_by_id(id)
    {
        Some(Character::Font(font)) => Some(font),
        _ => None,
    }
}

#[derive(Clone, Collect, Copy)]
#[collect(no_drop)]
pub struct FontObject<'gc>(pub Gc<'gc, FontObjectData<'gc>>);

#[derive(Clone, Collect, Copy, Debug)]
#[collect(no_drop)]
pub struct FontObjectWeak<'gc>(pub GcWeak<'gc, FontObjectData<'gc>>);

impl<'gc> FontObject<'gc> {
    pub fn for_font(mc: &Mutation<'gc>, class: ClassObject<'gc>, font: Font<'gc>) -> Object<'gc> {
        let base = ScriptObjectData::new(class);
        FontObject(Gc::new(
            mc,
            FontObjectData {
                base,
                font: Some(font),
            },
        ))
        .into()
    }

    /// The font of this object. Like Flash, this also works if the object
    /// was created before its class was linked to a font.
    pub fn font(self, context: &UpdateContext<'gc>) -> Option<Font<'gc>> {
        self.0
            .font
            .or_else(|| font_for_class(self.instance_class(), context))
    }
}

impl<'gc> TObject<'gc> for FontObject<'gc> {
    fn gc_base(&self) -> Gc<'gc, ScriptObjectData<'gc>> {
        HasPrefixField::as_prefix_gc(self.0)
    }
}

#[derive(Collect, HasPrefixField)]
#[collect(no_drop)]
#[repr(C, align(8))]
pub struct FontObjectData<'gc> {
    /// Base script object
    base: ScriptObjectData<'gc>,

    font: Option<Font<'gc>>,
}

impl fmt::Debug for FontObject<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "FontObject")
    }
}
