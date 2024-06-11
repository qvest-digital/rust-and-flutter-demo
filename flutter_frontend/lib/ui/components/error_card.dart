import 'package:flutter/material.dart';
import 'package:flutter_frontend/ui/common.dart';
import 'package:gap/gap.dart';

class ErrorCard extends StatelessWidget {
  final String errorMessage;

  const ErrorCard(this.errorMessage, {super.key});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outlined,
            size: 64,
            color: Colors.red,
          ),
          const Gap(16),
          const Text(
            'An error occurred',
            style: headlineTextStyle,
          ),
          const Gap(8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
          ),
        ],
      );
}
