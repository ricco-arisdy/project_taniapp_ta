import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';

class OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final Function(String)? onCompleted;
  final String? Function(String?)? validator;

  const OtpInputField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
    this.validator,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _controllers = List.generate(widget.length, (_) => TextEditingController());

    // Set initial values if controller has text
    if (widget.controller.text.isNotEmpty) {
      _setInitialValues();
    }

    // Listen to main controller changes
    widget.controller.addListener(_onMainControllerChanged);
  }

  void _setInitialValues() {
    final text = widget.controller.text;
    for (int i = 0; i < text.length && i < widget.length; i++) {
      _controllers[i].text = text[i];
    }
  }

  void _onMainControllerChanged() {
    if (widget.controller.text.isEmpty) {
      // Clear all fields
      for (var controller in _controllers) {
        controller.clear();
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onMainControllerChanged);
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    // Update main controller
    _updateMainController();
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _updateMainController() {
    final otp = _controllers.map((c) => c.text.trim()).join();
    widget.controller.text = otp;

    print('🔐 [OTP_INPUT] Combined OTP: "$otp" (length: ${otp.length})');

    // Call onCompleted if all fields are filled
    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) => widget.validator?.call(widget.controller.text),
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                widget.length,
                (index) => _buildOtpBox(index, formFieldState),
              ),
            ),
            if (formFieldState.hasError) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  formFieldState.errorText ?? '',
                  style: const TextStyle(
                    color: Color(AppColors.errorRed),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildOtpBox(int index, FormFieldState formFieldState) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.darkGreen),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: formFieldState.hasError
                  ? const Color(AppColors.errorRed)
                  : Colors.grey[300]!,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: formFieldState.hasError
                  ? const Color(AppColors.errorRed)
                  : Colors.grey[300]!,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: formFieldState.hasError
                  ? const Color(AppColors.errorRed)
                  : const Color(AppColors.primaryGreen),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(0),
        ),
        onChanged: (value) => _onChanged(value, index),
        onTap: () {
          // Clear only current field on tap, not all fields
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        },
        onEditingComplete: () {
          if (index < widget.length - 1) {
            _focusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }
}
