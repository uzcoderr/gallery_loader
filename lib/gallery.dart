import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  late final Future<File> imageFile;

  List<AssetEntity> assets = [];

  _fetchAssets() async {
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );

    // Update the state and notify UI
    setState(() => assets = recentAssets);
  }

  List<File> images = [];

  @override
  void initState() {
    _fetchAssets();
    loadImg();
    super.initState();
  }

  var index = 0;

  Future loadImg() async {
    try {
      for (int i = 0; i < assets.length; i++) {
        assets[i].file.then((value) => {
              setState(() {
                images.add(value!);
              })
        });
      }
    } catch (e) {
      print('xato');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        itemBuilder: (context, index) {
          return Expanded(
              child: Container(
                child: images[index] != null ?
                Image.file(
                  fit: BoxFit.cover,
                    File(images[index].path)
                ) : const CircularProgressIndicator()
                ,));
        },
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            loadImg();
          });
        },
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}