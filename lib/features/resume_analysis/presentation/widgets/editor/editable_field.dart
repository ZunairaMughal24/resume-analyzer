import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class EditableField extends StatefulWidget {
  final String label;
  final String value;
  final int maxLines;
  final TextInputType keyboardType;
  final ValueChanged<String> onSaved;

  const EditableField({
    super.key,
    required this.label,
    required this.value,
    required this.onSaved,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  late TextEditingController _ctrl;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(EditableField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_dirty) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _ctrl,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 13,
              height: 1.5,
            ),
        onChanged: (_) {
          if (!_dirty) setState(() => _dirty = true);
        },
        onEditingComplete: () {
          if (_dirty) {
            widget.onSaved(_ctrl.text.trim());
            setState(() => _dirty = false);
          }
        },
        onTapOutside: (_) {
          if (_dirty) {
            widget.onSaved(_ctrl.text.trim());
            setState(() => _dirty = false);
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textMuted, fontSize: 11),
          filled: true,
          fillColor: AppColors.surfaceElevated.withValues(alpha: 0.6),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          suffixIcon: _dirty
              ? GestureDetector(
                  onTap: () {
                    widget.onSaved(_ctrl.text.trim());
                    setState(() => _dirty = false);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : const Icon(Icons.check_circle_outline_rounded,
                  size: 16, color: AppColors.success),
        ),
        cursorColor: AppColors.primary,
      ),
    );
  }
}
