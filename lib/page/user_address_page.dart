
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../models/address_model.dart';
import '../providers/user_provider.dart';

class UserAddressPage extends StatefulWidget {
  static const String routeName = '/user_address';
  const UserAddressPage({Key? key}) : super(key: key);

  @override
  State<UserAddressPage> createState() => _UserAddressPageState();
}

class _UserAddressPageState extends State<UserAddressPage> {
  late UserProvider userProvider;
  final addressController = TextEditingController();
  final zipCodeController = TextEditingController();
  String? city;
  String? area;
  final formKey = GlobalKey<FormState>();
  @override
  void didChangeDependencies() {
    userProvider = Provider.of<UserProvider>(context);
    userProvider.getAllCities();
    super.didChangeDependencies();
  }
  @override
  void dispose() {
    addressController.dispose();
    zipCodeController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Address'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Street Address'
              ),
              validator: (value) {

              },
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: zipCodeController,
              decoration: InputDecoration(
                  filled: true,
                  labelText: 'Zip Code'
              ),
              validator: (value) {

              },
            ),
            const SizedBox(height: 10,),
            DropdownButtonFormField<String>(
              value: city,
                hint: const Text('Select City'),
                items: userProvider.cityList.map((city) => DropdownMenuItem<String>(
                    child: Text(city.name),
                  value: city.name,
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    city = value;
                  });
                }
            ),
            const SizedBox(height: 10,),
            DropdownButtonFormField<String>(
                value: area,
                hint: const Text('Select Area'),
                items: userProvider.getAreasByCity(city).map((area) => DropdownMenuItem<String>(
                  child: Text(area),
                  value: area,
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    area = value;
                  });
                }
            ),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Set Address'),
            )
          ],
        ),
      ),
    );
  }

  void _save() {
    if(formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Please wait');
      final addressModel = AddressModel(
        streetAddress: addressController.text,
        city: city!,
        area: area!,
        zipCode: int.parse(zipCodeController.text)
      );
      userProvider
          .updateProfile(
          AuthService.user!.uid, addressModel.toMap())
      .then((value) {
        EasyLoading.dismiss();
        Navigator.pop(context);
      });
    }
  }
}
