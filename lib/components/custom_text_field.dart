import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    Key? key,
    required this.label,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.placeholder,
    this.validator,
    this.maxLines,
    this.prefixIcon,
    this.inputFormatters,
    this.onChanged,
  }) : super(key: key);

  String label;
  bool isPassword;
  TextInputType keyboardType;
  TextEditingController? controller;
  String? placeholder;
  String? Function(String?)? validator;
  int? maxLines;
  Icon? prefixIcon;
  List<TextInputFormatter>? inputFormatters;
  String? Function(String?)? onChanged;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;
  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodyLarge),
        SizedBox(height: 8),
        TextFormField(
          obscureText: _isObscured,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            labelText: widget.placeholder,
            labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: toggleObscure,
                    )
                    : null,
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}