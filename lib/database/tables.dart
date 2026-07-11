import 'package:drift/drift.dart';

class Members extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get mobile => text().withLength(min: 1, max: 20).unique()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get bloodGroup => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('Active'))();
  TextColumn get additionalInfo => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // MONTHLY | EVENT
  RealColumn get amountPerMember => real()();
  TextColumn get description => text().nullable()();
  IntColumn get month => integer().nullable()(); // for MONTHLY type
  IntColumn get year => integer().nullable()(); // for MONTHLY type
  DateTimeColumn get dateCreated => dateTime().withDefault(currentDateAndTime)();
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get memberId => integer().references(Members, #id)();
  IntColumn get collectionId => integer().references(Collections, #id)();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get paymentDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('Pending'))();
  TextColumn get notes => text().nullable()();
  // Advance payment range (null = single-month payment)
  IntColumn get advanceStartMonth => integer().nullable()();
  IntColumn get advanceStartYear => integer().nullable()();
  IntColumn get advanceEndMonth => integer().nullable()();
  IntColumn get advanceEndYear => integer().nullable()();
  // Late fine (null = no fine)
  RealColumn get fineAmount => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get purpose => text().withLength(min: 1, max: 100)();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
