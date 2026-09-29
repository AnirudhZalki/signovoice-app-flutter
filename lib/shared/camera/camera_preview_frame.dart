import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Full-bleed, aspect-correct preview (cover). [children] are laid over the
/// preview in the *same* coordinate space, so normalised landmarks line up.
class CameraPreviewFrame extends StatelessWidget {
  const CameraPreviewFrame({super.key, required this.controller, this.children = const []});
  final CameraController controller;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.previewSize;
    if (size == null) return const SizedBox.shrink();
    // previewSize is reported in landscape; portrait UI swaps the axes.
    final portrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    final w = portrait ? size.height : size.width;
    final h = portrait ? size.width : size.height;
    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(fit: StackFit.expand, children: [CameraPreview(controller), ...children]),
          ),
        ),
      ),
    );
  }
}
