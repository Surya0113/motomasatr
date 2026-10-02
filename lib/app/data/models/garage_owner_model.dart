class GarageOwnerModel {
  final String id;
  final String mobileNumber;
  final String workshopName;
  final List<String> workshopType;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber2;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String? termsAndConditions;
  final String? billHeader;
  final String? workshopCode;
  final String? customBanner;
  final String? customLogo;

  GarageOwnerModel({
    required this.id,
    required this.mobileNumber,
    required this.workshopName,
    required this.workshopType,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber2,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.termsAndConditions,
    this.billHeader,
    this.workshopCode,
    this.customBanner,
    this.customLogo,
  });

  factory GarageOwnerModel.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    final workshopName = normalized['workshopName'] ?? normalized['garageName'] ?? '';
    final customLogo = normalized['customLogo'] ?? normalized['logoUrl'] ?? normalized['logo'] ?? '';
    final customBanner = normalized['customBanner'] ?? normalized['bannerUrl'] ?? normalized['coverImage'] ?? '';

    normalized['workshopName'] = workshopName;
    normalized['customLogo'] = customLogo;
    normalized['customBanner'] = customBanner;

    return GarageOwnerModel(
      id: normalized['id'] ?? normalized['_id'] ?? '',
      mobileNumber: normalized['mobileNumber'] ?? '',
      workshopName: workshopName.toString(),
      workshopType: normalized['workshopType'] != null
          ? List<String>.from(normalized['workshopType'])
          : [],
      firstName: normalized['firstName'] ?? '',
      lastName: normalized['lastName'] ?? '',
      email: normalized['email'] ?? '',
      phoneNumber2: normalized['phoneNumber2'],
      address: normalized['address'] ?? '',
      city: normalized['city'] ?? '',
      state: normalized['state'] ?? '',
      pincode: normalized['pincode'] ?? '',
      termsAndConditions: normalized['termsAndConditions'],
      billHeader: normalized['billHeader'],
      workshopCode: normalized['workshopCode'],
      customBanner: customBanner.toString().isEmpty ? null : customBanner.toString(),
      customLogo: customLogo.toString().isEmpty ? null : customLogo.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      'workshopName': workshopName,
      'workshopType': workshopType,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber2': phoneNumber2,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'termsAndConditions': termsAndConditions,
      'billHeader': billHeader,
      'workshopCode': workshopCode,
      'customBanner': customBanner,
      'customLogo': customLogo,
    };
  }

  String get fullName => '$firstName $lastName';
}
