class LoginResponse {
  final bool loginSuccess;
  final String? empCode;
  final String? designation;
  final String? departmentCode;
  final String? departmentName;
  final String? salutation;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? gender;
  final String? mobile;
  final bool? mobileVerified;
  final String? email;
  final String? personalEmail;
  final String? workPhone;
  final String? residencePhone;
  final String? photo;
  final String? quarterNo;
  final String? quarterAlpha;
  final String? employeeType;
  final String? bloodGroup;
  final String? roomNo;
  final bool? loggedIn;
  final String? deviceIMEI;
  final String? message;
  DateTime? loginTime;

  LoginResponse({
    required this.loginSuccess,
    this.empCode,
    this.designation,
    this.departmentCode,
    this.departmentName,
    this.salutation,
    this.firstName,
    this.middleName,
    this.lastName,
    this.gender,
    this.mobile,
    this.mobileVerified,
    this.email,
    this.personalEmail,
    this.workPhone,
    this.residencePhone,
    this.photo,
    this.quarterNo,
    this.quarterAlpha,
    this.employeeType,
    this.bloodGroup,
    this.roomNo,
    this.loggedIn,
    this.deviceIMEI,
    this.message,
    this.loginTime,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      loginSuccess: json['loginSuccess'],
      empCode: json['empCode'],
      designation: json['designation'],
      departmentCode: json['departmentCode'],
      departmentName: json['departmentName'],
      salutation: json['salutation'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      gender: json['gender'],
      mobile: json['mobile'],
      mobileVerified: json['mobileVerified'],
      email: json['email'],
      personalEmail: json['personalEmail'],
      workPhone: json['workPhone'],
      residencePhone: json['residencePhone'],
      photo: json['photo'],
      quarterNo: json['quarterNo'],
      quarterAlpha: json['quarterAlpha'],
      employeeType: json['employeeType'],
      bloodGroup: json['bloodGroup'],
      roomNo: json['roomNo'],
      loggedIn: json['loggedIn'],
      deviceIMEI: json['deviceIMEI'],
      message: json['message'],
      loginTime: DateTime.now(),
    );
  }

  // This method is used to convert the object into a JSON format
  Map<String, dynamic> toJson() {
    return {
      'loginSuccess': loginSuccess,
      'empCode': empCode,
      'designation': designation,
      'departmentCode': departmentCode,
      'departmentName': departmentName,
      'salutation': salutation,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'gender': gender,
      'mobile': mobile,
      'mobileVerified': mobileVerified,
      'email': email,
      'personalEmail': personalEmail,
      'workPhone': workPhone,
      'residencePhone': residencePhone,
      'photo': photo,
      'quarterNo': quarterNo,
      'quarterAlpha': quarterAlpha,
      'employeeType': employeeType,
      'bloodGroup': bloodGroup,
      'roomNo': roomNo,
      'loggedIn': loggedIn,
      'deviceIMEI': deviceIMEI,
      'message': message,
      'loginTime': loginTime.toString(),
    };
  }
}
