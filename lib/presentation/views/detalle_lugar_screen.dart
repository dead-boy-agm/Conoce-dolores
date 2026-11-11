import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/lugar_turistico.dart';
import '../viewmodels/detalle_view_model.dart';

class DetalleLugarScreen extends StatefulWidget {
  final LugarTuristico lugar;

  const DetalleLugarScreen({super.key, required this.lugar});

  @override
  State<DetalleLugarScreen> createState() => _DetalleLugarScreenState();
}

class _DetalleLugarScreenState extends State<DetalleLugarScreen> {
  late final DetalleViewModel _viewModel;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _viewModel = DetalleViewModel(widget.lugar);

    final video = widget.lugar.videoAsset;
    if (video != null) {
      _videoController = VideoPlayerController.asset(video)
        ..initialize().then((_) {
          if (mounted) setState(() {});
        }).catchError((_) {
          // Si el archivo de video no existe, simplemente no se muestra.
        });
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;
    return Scaffold(
      appBar: AppBar(title: Text(widget.lugar.nombre)),
      body: ListView(
        children: [
          Image.asset(
            widget.lugar.imagenAsset,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
              height: 220,
              child: Center(child: Icon(Icons.image_not_supported, size: 48)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.lugar.descripcion,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          AnimatedBuilder(
            animation: _viewModel,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _viewModel.alternarAudio,
                icon: Icon(
                  _viewModel.reproduciendo ? Icons.pause : Icons.headphones,
                ),
                label: Text(
                  _viewModel.reproduciendo
                      ? 'Pausar audioguia'
                      : 'Escuchar audioguia',
                ),
              ),
            ),
          ),
          if (controller != null && controller.value.isInitialized)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                  IconButton(
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                    ),
                    iconSize: 48,
                    onPressed: () {
                      setState(() {
                        controller.value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
