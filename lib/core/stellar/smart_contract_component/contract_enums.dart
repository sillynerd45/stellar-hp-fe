enum HpError {
  userExist,
  userNotExist,
  dataNotExist,
  wrongAuth,
  unknown,
}

enum LogType {
  bodyTemp(0),
  symptom(1),
  bloodPressure(2),
  medication(3);

  final int typeId;

  const LogType(this.typeId);
}

enum ProfileSex {
  male,
  female,
}

enum AccountType {
  user(0),
  healthWorker(1);

  final int typeId;

  const AccountType(this.typeId);
}
