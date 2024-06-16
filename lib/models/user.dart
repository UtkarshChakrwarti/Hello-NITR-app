// Keeping only that part of the JSON response that is required for the User class.
// in case more fields are required, they can be added here.

class User {
  final String? empCode;
  final String? designation;
  final String? departmentCode;
  final String? departmentName;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? mobile;
  final String? personalEmail;
  final String? email;
  final String? workPhone;
  final String? residencePhone;
  final String? quarterAlpha;
  final String? quarterNo;
  final String? employeeType;
  final String? roomNo;
  String? photo;

  // Constructor for the User class.
  User({
    this.empCode,
    this.designation,
    this.departmentCode,
    this.departmentName,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobile,
    this.personalEmail,
    this.email,
    this.workPhone,
    this.residencePhone,
    this.quarterAlpha,
    this.quarterNo,
    this.employeeType,
    this.roomNo,
    this.photo,
  });

  // Factory method to create a User instance from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      empCode: json['empCode'],
      designation: json['designation'],
      departmentCode: json['departmentCode'],
      departmentName: json['departmentName'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      mobile: json['mobile'],
      personalEmail: json['personalEmail'],
      email: json['email'],
      workPhone: json['workPhone'],
      residencePhone: json['residencePhone'],
      quarterAlpha: json['quarterAlpha'],
      quarterNo: json['quarterNo'],
      employeeType: json['employeeType'],
      roomNo: json['roomNo'],
      photo: json['photo'],
    );
  }

  // Method to convert a User instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'empCode': empCode,
      'designation': designation,
      'departmentCode': departmentCode,
      'departmentName': departmentName,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'mobile': mobile,
      'email': email,
      'personalEmail': personalEmail,
      'workPhone': workPhone,
      'residencePhone': residencePhone,
      'quarterAlpha': quarterAlpha,
      'quarterNo': quarterNo,
      'employeeType': employeeType,
      'roomNo': roomNo,
      'photo': photo,
    };
  }
}
