import 'package:postgres/postgres.dart';

import 'db_mixins.dart';
import '../models/user_model.dart';

class UserRepository
    with
        Readable<UserModel>,
        Updatable<UserModel>,
        Writable<UserModel>,
        Deletable {
  static UserRepository? instance;

  UserRepository._internal(this.connection);

  factory UserRepository(Connection connection) {
    return instance ??= UserRepository._internal(connection);
  }

  void init() {
    instance = UserRepository._internal(connection);
  }

  final Connection connection;

  @override
  Future<void> delete(String id) {
// TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<UserModel>?> getAll() {
// TODO: implement getAll
    throw UnimplementedError();
  }

  ///--------------------------------
  ///-------------------
  ///---------
  ///GETS BY GUID
  ///---------
  ///-------------------
  ///--------------------------------
  @override
  Future<UserModel?> getById(String guid) async {
    final result = await connection.execute(
      Sql.named("SELECT * FROM users WHERE guid=@guid AND isDeleted=false"),
      parameters: {'guid': guid},
    );
    if (result.isEmpty) {
      return null;
    }
    return UserModel(
        id: result[0][0].toString(),
        mobileNumber: result[0][1].toString(),
        nationalCode: result[0][2].toString(),
        guid: result[0][5].toString(),
        firstName: result[0][6].toString(),
        lastName: result[0][7].toString());
  }

  @override
  Future<void> update(String id, UserModel model) async {
    final result = await connection.execute(
      Sql.named(
          "UPDATE users SET mobileNumber=@mobileNumber, nationalCode=@nationalCode, firstName=@firstName, lastName=@lastName WHERE id=@id"),
      parameters: {
        'mobileNumber': model.mobileNumber,
        'nationalCode': model.nationalCode,
        'firstName': model.firstName,
        'lastName': model.lastName,
        'id': id,
      },
    );
  }

  @override
  Future<void> write(UserModel model) async {
    final result = await connection.execute(
      Sql.named(
          "INSERT INTO users (mobileNumber, nationalCode, guid, firstName, lastName) VALUES (@mobileNumber, @nationalCode, @guid, @firstName, @lastName)"),
      parameters: {
        'mobileNumber': model.mobileNumber,
        'nationalCode': model.nationalCode,
        'guid':model.guid,
        'firstName': model.firstName,
        'lastName': model.lastName,
      },
    );
  }

  Future<void> saveUserInDb(UserModel user) async {
    final foundUser = await getById(user.guid ?? '-1');
    if (foundUser == null) {
      await write(user);
    } else {
      if (foundUser.id != null) {
        final newUser = UserModel(
          nationalCode: (user.nationalCode?.isEmpty ?? true)
              ? foundUser.nationalCode
              : user.nationalCode,
          mobileNumber: (user.mobileNumber?.isEmpty ?? true)
              ? foundUser.mobileNumber
              : user.mobileNumber,
          firstName: (user.firstName?.isEmpty ?? true)
              ? foundUser.firstName
              : user.firstName,
          lastName: (user.lastName?.isEmpty ?? true)
              ? foundUser.lastName
              : user.lastName,
        );
        await update(foundUser.id!, newUser);
      }
    }
  }
}
