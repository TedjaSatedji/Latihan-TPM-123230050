import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controllers/data_controller.dart';

class DetailPage extends StatelessWidget {
  final String id;
  final String type;
  final String title;

  const DetailPage({
    super.key,
    required this.id,
    required this.type,
    required this.title,
  });

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      Get.snackbar('Error', 'Could not launch URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataController = Get.find<DataController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataController.fetchDetail(type, id);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('$title Detail'),
      ),
      body: Obx(() {
        if (dataController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (dataController.errorMessage.value.isNotEmpty) {
          return Center(child: Text(dataController.errorMessage.value));
        }

        final data = dataController.detailData;
        if (data.isEmpty) {
          return const Center(child: Text('No Detail Found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data['image_url'] != null)
                Image.network(
                  data['image_url'],
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 250,
                    child: Center(child: Icon(Icons.broken_image, size: 50)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['news_site'] ?? 'Unknown Site',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data['summary'] ?? 'No Description',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    if (data['published_at'] != null)
                      Text(
                        'Published: ${data['published_at']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        final data = dataController.detailData;
        if (!dataController.isLoading.value && data.isNotEmpty && data['url'] != null) {
          return FloatingActionButton(
            onPressed: () => _launchUrl(data['url']),
            child: const Icon(Icons.open_in_browser),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}
