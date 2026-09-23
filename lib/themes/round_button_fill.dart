import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:flutter/material.dart';
import 'package:customer/widget/translated_text.dart';
import 'package:get/get.dart';

class RoundedButtonFill extends StatelessWidget {
  final String title;
  final double? width;
  final double? height;
  final double? fontSizes;
  final double? radius;
  final Color? color;
  final Color? textColor;
  final Widget? icon;
  final bool? isRight;
  final bool? isEnabled;

  /// Optional gradient — when provided it overrides [color] for a vibrant CTA.
  final Gradient? gradient;

  /// Adds a soft coloured glow beneath the button. Defaults to on.
  final bool elevated;

  final Function()? onPress;

  const RoundedButtonFill(
      {super.key,
      this.isEnabled = true,
      required this.title,
      this.height,
      required this.onPress,
      this.width,
      this.color,
      this.icon,
      this.fontSizes,
      this.textColor,
      this.isRight,
      this.radius,
      this.gradient,
      this.elevated = true});

  @override
  Widget build(BuildContext context) {
    final bool enabled = isEnabled == true;
    final Color baseColor = color ?? AppThemeData.primary300;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius ?? AppThemeData.radiusPill),
          onTap: enabled
              ? () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onPress!();
                }
              : () {},
          child: Container(
            width: Responsive.width(width ?? 100, context),
            height: Responsive.height(height ?? 6, context),
            decoration: BoxDecoration(
              color: gradient == null ? baseColor : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(radius ?? AppThemeData.radiusPill),
              boxShadow: (elevated && enabled)
                  ? [
                      BoxShadow(
                        color: baseColor.withOpacity(0.32),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (isRight == false) ? Padding(padding: const EdgeInsets.only(right: 5), child: icon) : const SizedBox(),
                TranslatedText(
                  title.tr.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    color: textColor ?? AppThemeData.grey800,
                    fontSize: fontSizes ?? 14,
                  ),
                ),
                (isRight == true) ? Padding(padding: const EdgeInsets.only(left: 5), child: icon) : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
