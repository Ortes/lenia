import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lenia/my_render_object.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'widget.g.dart';

@riverpod
Future<FragmentProgram> getShader(GetShaderRef ref) async {
  return FragmentProgram.fromAsset('shaders/shader.frag');
}

class ShaderWidget extends ConsumerWidget {
  const ShaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shaderAsync = ref.watch(getShaderProvider);
    if (shaderAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (shaderAsync.hasError) {
      throw Exception([shaderAsync.error, shaderAsync.stackTrace]);
    }
    return LeniaAnimationWidget(shader: shaderAsync.value!.fragmentShader());
  }
}
