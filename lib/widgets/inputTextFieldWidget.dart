import 'package:easy_localization/easy_localization.dart' as localized;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class InputTextFieldWidget extends StatelessWidget {
  String? text;
  String? labelText;
  String? helperText;
  String? hintText;
  String? prefixText;
  IconData? prefixIcon;
  TextInputAction? textInputAction;

  bool? enabled;

  int? maxLines;
  int? minLines;
  int? maxLength;

  TextInputType? keyboardType;

  bool? obscureText;
  bool? autofocus;

  Function? onSaved;
  Function? validator;
  Function? onChanged;
  InputTextFieldWidget({
    super.key,
    this.enabled,
    this.textInputAction,
    this.text,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.keyboardType,
    this.labelText,
    this.hintText,
    this.helperText,
    this.onSaved,
    this.onChanged,
    this.prefixIcon,
    this.validator,
    this.autofocus,
    this.obscureText,
    this.prefixText,
  });

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = text ?? "";
    return TextFormField(
      key: Key(Uuid().v4()),
      enabled: enabled,
      textDirection: context.locale.languageCode == "ar" ? TextDirection.rtl : TextDirection.ltr ,
      textInputAction: textInputAction ?? TextInputAction.done,
      controller: _controller,
      keyboardType: keyboardType ?? TextInputType.name,
      autofocus: autofocus ?? false,
      obscureText: obscureText ?? false,
      minLines: minLines,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        helperText: helperText,
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        prefixText: prefixText,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
              )
            : null,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black45,
            width: 1,
          ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black45,
            width: 1,
          ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      validator: (val) {
        if (validator != null) {
          return validator!(val);
        }

        return null;
      },
      onChanged: (val) {
        if (onChanged != null) {
          onChanged!(val);
        }
      },
      onSaved: (val) {
        if (onSaved != null) {
          onSaved!(val);
        }
      },
    );
  }
}
