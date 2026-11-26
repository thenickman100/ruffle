use crate::avm2::Error;
use crate::avm2::activation::Activation;
use crate::avm2::function::FunctionArgs;
use crate::avm2::parameters::ParametersExt;
use crate::avm2::value::Value;
use crate::string::AvmString;
use ruffle_macros::istr;

/// Implements `XMLDocument._convertXmlName`: the name of an element or
/// attribute with the prefix written in the source, like `svg:g`.
pub fn _convert_xml_name<'gc>(
    activation: &mut Activation<'_, 'gc>,
    _this: Value<'gc>,
    args: FunctionArgs<'_, 'gc>,
) -> Result<Value<'gc>, Error<'gc>> {
    let node = args
        .get_object(activation, 0, "node")?
        .as_xml_object()
        .expect("XMLDocument only passes XML objects")
        .node();
    let local_name = node.local_name().unwrap_or_else(|| istr!(""));
    match node.namespace().and_then(|ns| ns.prefix) {
        Some(prefix) if !prefix.is_empty() => {
            let prefix = AvmString::concat(activation.gc(), prefix, istr!(":"));
            Ok(AvmString::concat(activation.gc(), prefix, local_name).into())
        }
        _ => Ok(local_name.into()),
    }
}
