import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import 'item_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  @override
  _MyReportsScreenState createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<Item> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    final items = await ItemService.getMyItems();
    if (!mounted) return;
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgLightBlue,
      appBar: AppBar(
        title: Text('Riwayat Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Text('Anda belum membuat laporan apapun.', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _fetchItems,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return _buildItemCard(item);
                    },
                  ),
                ),
    );
  }

  Widget _buildItemCard(Item item) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item.photoUrl != null
              ? CachedNetworkImage(
                  imageUrl: item.photoUrl!,
                  httpHeaders: const {'ngrok-skip-browser-warning': 'true'},
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, color: Colors.grey),
                ),
        ),
        title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Row(
              children: [
                if (item.status == 'hilang' || item.status == 'ditemukan')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.status == 'hilang' ? Colors.deepOrangeAccent : Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status == 'hilang' ? 'Hilang' : 'Ditemukan',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (item.status == 'hilang' || item.status == 'ditemukan') SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (item.status == 'selesai' || item.resolvedBy != null) ? Colors.blueAccent : Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (item.status == 'selesai' || item.resolvedBy != null) ? 'Selesai' : 'Proses',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
          );
          if (result == true) {
            _fetchItems();
          }
        },
      ),
    );
  }
}
