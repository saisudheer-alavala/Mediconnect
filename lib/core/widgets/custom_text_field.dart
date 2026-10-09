import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Standardized text input field with built-in password visibility toggle and validation styling
class CustomTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isPassword;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimaryLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20, color: AppColors.textSecondaryLight)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textSecondaryLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}
