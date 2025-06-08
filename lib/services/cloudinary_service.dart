import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static CloudinaryPublic? _cloudinary;

  static CloudinaryPublic get cloudinary {
    if (_cloudinary == null) {
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];
      
      if (cloudName == null || uploadPreset == null) {
        throw Exception('Cloudinary environment variables not set');
      }
      
      _cloudinary = CloudinaryPublic(
        cloudName,
        uploadPreset,
        cache: false,
      );
    }
    return _cloudinary!;
  }

  static Future<String> uploadImage(File image) async {
    try {      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'baby_shop/products',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      throw Exception('Failed to upload image');
    }
  }

  static Future<List<String>> uploadImages(List<File> images) async {
    try {
      List<String> urls = [];
      for (var image in images) {
        String url = await uploadImage(image);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      print('Error uploading images to Cloudinary: $e');
      throw Exception('Failed to upload images');
    }
  }
}
