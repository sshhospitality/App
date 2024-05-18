import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  double _rating = 3.0;
  File? _image;

  String? _id;
  String? _name;
  String? _email;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  void setMessage(String message) {
    setState(() {
      _messageController.text = message;
    });
  }

  void setRating(double rating) {
    setState(() {
      _rating = rating;
    });
  }

  void setFile(File? file) {
    setState(() {
      _image = file;
    });
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('idnumber');
      _name = prefs.getString('name');
      _email = prefs.getString('email');
      _phoneNumber = prefs.getString('phone');
    });
    print(_id);
    print(prefs.getString('idnumber') ?? 'No ID');
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void submitFeedback() async {
    try {
      FormData formData = FormData.fromMap({
        'name': _name,
        'userId': _id,
        'email': _email,
        'message': _messageController.text,
        'rating': _rating,
      });

      if (_image != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            _image!.path,
            filename: 'image.jpg',
            contentType:
                MediaType('image', 'jpeg'), // Adjust content type accordingly
          ),
        ));
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String sessionCookie = await prefs.getString('token') ?? 'N/A';
      var cookie = 'token=$sessionCookie';

      final response = await Dio().post(
        'https://z1ogo1n55a.execute-api.ap-south-1.amazonaws.com/api/feedback/feedback_post',
        data: formData,
        options: Options(
          headers: {
            'Cookie': cookie,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('Response: ${response.data}');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Feedback Submitted'),
          content: Text('Thank you for your feedback!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setMessage('');
                setRating(0);
                setFile(null);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Please provide your feedback:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildFixedTextField('ID', _id ?? ''),
              const SizedBox(height: 16),
              _buildFixedTextField('Name', _name ?? ''),
              const SizedBox(height: 16),
              _buildFixedTextField('Email', _email ?? ''),
              const SizedBox(height: 16),
              _buildFixedTextField('Phone Number', _phoneNumber ?? ''),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Rate your experience:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Upload an image (optional):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Center(
                child: _image == null
                    ? ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Choose Image'),
                      )
                    : Column(
                        children: [
                          Image.file(
                            _image!,
                            height: 150,
                          ),
                          TextButton(
                            onPressed: _pickImage,
                            child: const Text('Change Image'),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: submitFeedback,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFixedTextField(String labelText, String initialValue) {
    return TextFormField(
      initialValue: initialValue,
      enabled: false,
      decoration: InputDecoration(
        labelText: "$labelText : $initialValue",
        border: OutlineInputBorder(),
      ),
    );
  }
}
