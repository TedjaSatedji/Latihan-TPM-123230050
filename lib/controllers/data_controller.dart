import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataController extends GetxController {
  var dataList = [].obs;
  var detailData = {}.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  Future<void> fetchList(String type) async {
    isLoading.value = true;
    errorMessage.value = '';
    dataList.clear();

    try {
      final response = await http.get(
        Uri.parse('https://api.spaceflightnewsapi.net/v4/$type/'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        dataList.value = decoded['results'];
      } else {
        errorMessage.value = 'Failed to load data';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDetail(String type, String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    detailData.clear();

    try {
      final response = await http.get(
        Uri.parse('https://api.spaceflightnewsapi.net/v4/$type/$id/'),
      );

      if (response.statusCode == 200) {
        detailData.value = json.decode(response.body);
      } else {
        errorMessage.value = 'Failed to load detail';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
