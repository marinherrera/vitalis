import 'package:flutter/material.dart';
import 'package:vitalis/ui/theme/app_colors.dart';

/// Marca do Vitalis: o emblema circular de saúde (coração, hidratação,
/// temperatura e sol) acompanhado do nome do app.
class VitalisLogo extends StatelessWidget {
  const VitalisLogo({super.key, this.size = 56, this.showName = true});

  static const String emblemAsset = 'assets/images/emblema_vitalis.png';

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          emblemAsset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          semanticLabel: 'Emblema do Vitalis',
        ),
        if (showName) ...[
          SizedBox(width: size * 0.25),
          Text(
            'Vitalis',
            style: TextStyle(
              fontSize: size * 0.55,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: AppColors.fieldDark,
            ),
          ),
        ],
      ],
    );
  }
}
