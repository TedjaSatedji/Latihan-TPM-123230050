import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/data_controller.dart';
import 'detail_page.dart';

class ListPage extends StatelessWidget {
  final String title;
  final String type;

  const ListPage({super.key, required this.title, required this.type});

  @override
  Widget build(BuildContext context) {
    final dataController = Get.put(DataController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataController.fetchList(type);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('$title List'),
      ),
      body: Obx(() {
        if (dataController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (dataController.errorMessage.value.isNotEmpty) {
          return Center(child: Text(dataController.errorMessage.value));
        }

        final data = dataController.dataList;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ListTile(
                leading: item['image_url'] != null
                    ? Image.network(
                        item['image_url'],
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      )
                    : const Icon(Icons.image),
                title: Text(
                  item['title'] ?? 'No Title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item['news_site'] ?? item['summary'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Get.to(() => DetailPage(
                        id: item['id'].toString(),
                        type: type,
                        title: title,
                      ));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
