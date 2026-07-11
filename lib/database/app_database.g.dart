// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _mobileMeta = const VerificationMeta('mobile');
  @override
  late final GeneratedColumn<String> mobile = GeneratedColumn<String>(
      'mobile', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _bloodGroupMeta =
      const VerificationMeta('bloodGroup');
  @override
  late final GeneratedColumn<String> bloodGroup = GeneratedColumn<String>(
      'blood_group', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Active'));
  static const VerificationMeta _additionalInfoMeta =
      const VerificationMeta('additionalInfo');
  @override
  late final GeneratedColumn<String> additionalInfo = GeneratedColumn<String>(
      'additional_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        mobile,
        email,
        address,
        dateOfBirth,
        bloodGroup,
        photoPath,
        status,
        additionalInfo,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(Insertable<Member> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('mobile')) {
      context.handle(_mobileMeta,
          mobile.isAcceptableOrUnknown(data['mobile']!, _mobileMeta));
    } else if (isInserting) {
      context.missing(_mobileMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('blood_group')) {
      context.handle(
          _bloodGroupMeta,
          bloodGroup.isAcceptableOrUnknown(
              data['blood_group']!, _bloodGroupMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('additional_info')) {
      context.handle(
          _additionalInfoMeta,
          additionalInfo.isAcceptableOrUnknown(
              data['additional_info']!, _additionalInfoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      mobile: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mobile'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth']),
      bloodGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}blood_group']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      additionalInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}additional_info']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final int id;
  final String name;
  final String mobile;
  final String? email;
  final String? address;
  final DateTime? dateOfBirth;
  final String? bloodGroup;
  final String? photoPath;
  final String status;
  final String? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Member(
      {required this.id,
      required this.name,
      required this.mobile,
      this.email,
      this.address,
      this.dateOfBirth,
      this.bloodGroup,
      this.photoPath,
      required this.status,
      this.additionalInfo,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['mobile'] = Variable<String>(mobile);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || bloodGroup != null) {
      map['blood_group'] = Variable<String>(bloodGroup);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || additionalInfo != null) {
      map['additional_info'] = Variable<String>(additionalInfo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      name: Value(name),
      mobile: Value(mobile),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      bloodGroup: bloodGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(bloodGroup),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      status: Value(status),
      additionalInfo: additionalInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(additionalInfo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Member.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      mobile: serializer.fromJson<String>(json['mobile']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      bloodGroup: serializer.fromJson<String?>(json['bloodGroup']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      status: serializer.fromJson<String>(json['status']),
      additionalInfo: serializer.fromJson<String?>(json['additionalInfo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'mobile': serializer.toJson<String>(mobile),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'bloodGroup': serializer.toJson<String?>(bloodGroup),
      'photoPath': serializer.toJson<String?>(photoPath),
      'status': serializer.toJson<String>(status),
      'additionalInfo': serializer.toJson<String?>(additionalInfo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Member copyWith(
          {int? id,
          String? name,
          String? mobile,
          Value<String?> email = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<DateTime?> dateOfBirth = const Value.absent(),
          Value<String?> bloodGroup = const Value.absent(),
          Value<String?> photoPath = const Value.absent(),
          String? status,
          Value<String?> additionalInfo = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Member(
        id: id ?? this.id,
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        email: email.present ? email.value : this.email,
        address: address.present ? address.value : this.address,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        bloodGroup: bloodGroup.present ? bloodGroup.value : this.bloodGroup,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        status: status ?? this.status,
        additionalInfo:
            additionalInfo.present ? additionalInfo.value : this.additionalInfo,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      mobile: data.mobile.present ? data.mobile.value : this.mobile,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      bloodGroup:
          data.bloodGroup.present ? data.bloodGroup.value : this.bloodGroup,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      status: data.status.present ? data.status.value : this.status,
      additionalInfo: data.additionalInfo.present
          ? data.additionalInfo.value
          : this.additionalInfo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mobile: $mobile, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('photoPath: $photoPath, ')
          ..write('status: $status, ')
          ..write('additionalInfo: $additionalInfo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, mobile, email, address, dateOfBirth,
      bloodGroup, photoPath, status, additionalInfo, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.id == this.id &&
          other.name == this.name &&
          other.mobile == this.mobile &&
          other.email == this.email &&
          other.address == this.address &&
          other.dateOfBirth == this.dateOfBirth &&
          other.bloodGroup == this.bloodGroup &&
          other.photoPath == this.photoPath &&
          other.status == this.status &&
          other.additionalInfo == this.additionalInfo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> mobile;
  final Value<String?> email;
  final Value<String?> address;
  final Value<DateTime?> dateOfBirth;
  final Value<String?> bloodGroup;
  final Value<String?> photoPath;
  final Value<String> status;
  final Value<String?> additionalInfo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.mobile = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.status = const Value.absent(),
    this.additionalInfo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MembersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String mobile,
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.status = const Value.absent(),
    this.additionalInfo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        mobile = Value(mobile);
  static Insertable<Member> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? mobile,
    Expression<String>? email,
    Expression<String>? address,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? bloodGroup,
    Expression<String>? photoPath,
    Expression<String>? status,
    Expression<String>? additionalInfo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mobile != null) 'mobile': mobile,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (photoPath != null) 'photo_path': photoPath,
      if (status != null) 'status': status,
      if (additionalInfo != null) 'additional_info': additionalInfo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MembersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? mobile,
      Value<String?>? email,
      Value<String?>? address,
      Value<DateTime?>? dateOfBirth,
      Value<String?>? bloodGroup,
      Value<String?>? photoPath,
      Value<String>? status,
      Value<String?>? additionalInfo,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return MembersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mobile.present) {
      map['mobile'] = Variable<String>(mobile.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (bloodGroup.present) {
      map['blood_group'] = Variable<String>(bloodGroup.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (additionalInfo.present) {
      map['additional_info'] = Variable<String>(additionalInfo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mobile: $mobile, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('photoPath: $photoPath, ')
          ..write('status: $status, ')
          ..write('additionalInfo: $additionalInfo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountPerMemberMeta =
      const VerificationMeta('amountPerMember');
  @override
  late final GeneratedColumn<double> amountPerMember = GeneratedColumn<double>(
      'amount_per_member', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
      'month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, type, amountPerMember, description, month, year, dateCreated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(Insertable<Collection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_per_member')) {
      context.handle(
          _amountPerMemberMeta,
          amountPerMember.isAcceptableOrUnknown(
              data['amount_per_member']!, _amountPerMemberMeta));
    } else if (isInserting) {
      context.missing(_amountPerMemberMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amountPerMember: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}amount_per_member'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month']),
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year']),
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final int id;
  final String title;
  final String type;
  final double amountPerMember;
  final String? description;
  final int? month;
  final int? year;
  final DateTime dateCreated;
  const Collection(
      {required this.id,
      required this.title,
      required this.type,
      required this.amountPerMember,
      this.description,
      this.month,
      this.year,
      required this.dateCreated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    map['amount_per_member'] = Variable<double>(amountPerMember);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || month != null) {
      map['month'] = Variable<int>(month);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    map['date_created'] = Variable<DateTime>(dateCreated);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      amountPerMember: Value(amountPerMember),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      month:
          month == null && nullToAbsent ? const Value.absent() : Value(month),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      dateCreated: Value(dateCreated),
    );
  }

  factory Collection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      amountPerMember: serializer.fromJson<double>(json['amountPerMember']),
      description: serializer.fromJson<String?>(json['description']),
      month: serializer.fromJson<int?>(json['month']),
      year: serializer.fromJson<int?>(json['year']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'amountPerMember': serializer.toJson<double>(amountPerMember),
      'description': serializer.toJson<String?>(description),
      'month': serializer.toJson<int?>(month),
      'year': serializer.toJson<int?>(year),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
    };
  }

  Collection copyWith(
          {int? id,
          String? title,
          String? type,
          double? amountPerMember,
          Value<String?> description = const Value.absent(),
          Value<int?> month = const Value.absent(),
          Value<int?> year = const Value.absent(),
          DateTime? dateCreated}) =>
      Collection(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        amountPerMember: amountPerMember ?? this.amountPerMember,
        description: description.present ? description.value : this.description,
        month: month.present ? month.value : this.month,
        year: year.present ? year.value : this.year,
        dateCreated: dateCreated ?? this.dateCreated,
      );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      amountPerMember: data.amountPerMember.present
          ? data.amountPerMember.value
          : this.amountPerMember,
      description:
          data.description.present ? data.description.value : this.description,
      month: data.month.present ? data.month.value : this.month,
      year: data.year.present ? data.year.value : this.year,
      dateCreated:
          data.dateCreated.present ? data.dateCreated.value : this.dateCreated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('amountPerMember: $amountPerMember, ')
          ..write('description: $description, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('dateCreated: $dateCreated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, type, amountPerMember, description, month, year, dateCreated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.amountPerMember == this.amountPerMember &&
          other.description == this.description &&
          other.month == this.month &&
          other.year == this.year &&
          other.dateCreated == this.dateCreated);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> type;
  final Value<double> amountPerMember;
  final Value<String?> description;
  final Value<int?> month;
  final Value<int?> year;
  final Value<DateTime> dateCreated;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.amountPerMember = const Value.absent(),
    this.description = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.dateCreated = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String type,
    required double amountPerMember,
    this.description = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.dateCreated = const Value.absent(),
  })  : title = Value(title),
        type = Value(type),
        amountPerMember = Value(amountPerMember);
  static Insertable<Collection> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<double>? amountPerMember,
    Expression<String>? description,
    Expression<int>? month,
    Expression<int>? year,
    Expression<DateTime>? dateCreated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (amountPerMember != null) 'amount_per_member': amountPerMember,
      if (description != null) 'description': description,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (dateCreated != null) 'date_created': dateCreated,
    });
  }

  CollectionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? type,
      Value<double>? amountPerMember,
      Value<String?>? description,
      Value<int?>? month,
      Value<int?>? year,
      Value<DateTime>? dateCreated}) {
    return CollectionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      amountPerMember: amountPerMember ?? this.amountPerMember,
      description: description ?? this.description,
      month: month ?? this.month,
      year: year ?? this.year,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountPerMember.present) {
      map['amount_per_member'] = Variable<double>(amountPerMember.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('amountPerMember: $amountPerMember, ')
          ..write('description: $description, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('dateCreated: $dateCreated')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<int> memberId = GeneratedColumn<int>(
      'member_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES members (id)'));
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
      'collection_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES collections (id)'));
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _paymentDateMeta =
      const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
      'payment_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Pending'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _advanceStartMonthMeta =
      const VerificationMeta('advanceStartMonth');
  @override
  late final GeneratedColumn<int> advanceStartMonth = GeneratedColumn<int>(
      'advance_start_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _advanceStartYearMeta =
      const VerificationMeta('advanceStartYear');
  @override
  late final GeneratedColumn<int> advanceStartYear = GeneratedColumn<int>(
      'advance_start_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _advanceEndMonthMeta =
      const VerificationMeta('advanceEndMonth');
  @override
  late final GeneratedColumn<int> advanceEndMonth = GeneratedColumn<int>(
      'advance_end_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _advanceEndYearMeta =
      const VerificationMeta('advanceEndYear');
  @override
  late final GeneratedColumn<int> advanceEndYear = GeneratedColumn<int>(
      'advance_end_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fineAmountMeta =
      const VerificationMeta('fineAmount');
  @override
  late final GeneratedColumn<double> fineAmount = GeneratedColumn<double>(
      'fine_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        memberId,
        collectionId,
        paidAmount,
        paymentDate,
        status,
        notes,
        advanceStartMonth,
        advanceStartYear,
        advanceEndMonth,
        advanceEndYear,
        fineAmount,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collection_id']!, _collectionIdMeta));
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('payment_date')) {
      context.handle(
          _paymentDateMeta,
          paymentDate.isAcceptableOrUnknown(
              data['payment_date']!, _paymentDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('advance_start_month')) {
      context.handle(
          _advanceStartMonthMeta,
          advanceStartMonth.isAcceptableOrUnknown(
              data['advance_start_month']!, _advanceStartMonthMeta));
    }
    if (data.containsKey('advance_start_year')) {
      context.handle(
          _advanceStartYearMeta,
          advanceStartYear.isAcceptableOrUnknown(
              data['advance_start_year']!, _advanceStartYearMeta));
    }
    if (data.containsKey('advance_end_month')) {
      context.handle(
          _advanceEndMonthMeta,
          advanceEndMonth.isAcceptableOrUnknown(
              data['advance_end_month']!, _advanceEndMonthMeta));
    }
    if (data.containsKey('advance_end_year')) {
      context.handle(
          _advanceEndYearMeta,
          advanceEndYear.isAcceptableOrUnknown(
              data['advance_end_year']!, _advanceEndYearMeta));
    }
    if (data.containsKey('fine_amount')) {
      context.handle(
          _fineAmountMeta,
          fineAmount.isAcceptableOrUnknown(
              data['fine_amount']!, _fineAmountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}member_id'])!,
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}collection_id'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}paid_amount'])!,
      paymentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}payment_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      advanceStartMonth: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}advance_start_month']),
      advanceStartYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}advance_start_year']),
      advanceEndMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}advance_end_month']),
      advanceEndYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}advance_end_year']),
      fineAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fine_amount']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final int memberId;
  final int collectionId;
  final double paidAmount;
  final DateTime? paymentDate;
  final String status;
  final String? notes;
  final int? advanceStartMonth;
  final int? advanceStartYear;
  final int? advanceEndMonth;
  final int? advanceEndYear;
  final double? fineAmount;
  final DateTime createdAt;
  const Payment(
      {required this.id,
      required this.memberId,
      required this.collectionId,
      required this.paidAmount,
      this.paymentDate,
      required this.status,
      this.notes,
      this.advanceStartMonth,
      this.advanceStartYear,
      this.advanceEndMonth,
      this.advanceEndYear,
      this.fineAmount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['member_id'] = Variable<int>(memberId);
    map['collection_id'] = Variable<int>(collectionId);
    map['paid_amount'] = Variable<double>(paidAmount);
    if (!nullToAbsent || paymentDate != null) {
      map['payment_date'] = Variable<DateTime>(paymentDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || advanceStartMonth != null) {
      map['advance_start_month'] = Variable<int>(advanceStartMonth);
    }
    if (!nullToAbsent || advanceStartYear != null) {
      map['advance_start_year'] = Variable<int>(advanceStartYear);
    }
    if (!nullToAbsent || advanceEndMonth != null) {
      map['advance_end_month'] = Variable<int>(advanceEndMonth);
    }
    if (!nullToAbsent || advanceEndYear != null) {
      map['advance_end_year'] = Variable<int>(advanceEndYear);
    }
    if (!nullToAbsent || fineAmount != null) {
      map['fine_amount'] = Variable<double>(fineAmount);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      memberId: Value(memberId),
      collectionId: Value(collectionId),
      paidAmount: Value(paidAmount),
      paymentDate: paymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDate),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      advanceStartMonth: advanceStartMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(advanceStartMonth),
      advanceStartYear: advanceStartYear == null && nullToAbsent
          ? const Value.absent()
          : Value(advanceStartYear),
      advanceEndMonth: advanceEndMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(advanceEndMonth),
      advanceEndYear: advanceEndYear == null && nullToAbsent
          ? const Value.absent()
          : Value(advanceEndYear),
      fineAmount: fineAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(fineAmount),
      createdAt: Value(createdAt),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      memberId: serializer.fromJson<int>(json['memberId']),
      collectionId: serializer.fromJson<int>(json['collectionId']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      paymentDate: serializer.fromJson<DateTime?>(json['paymentDate']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      advanceStartMonth: serializer.fromJson<int?>(json['advanceStartMonth']),
      advanceStartYear: serializer.fromJson<int?>(json['advanceStartYear']),
      advanceEndMonth: serializer.fromJson<int?>(json['advanceEndMonth']),
      advanceEndYear: serializer.fromJson<int?>(json['advanceEndYear']),
      fineAmount: serializer.fromJson<double?>(json['fineAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'memberId': serializer.toJson<int>(memberId),
      'collectionId': serializer.toJson<int>(collectionId),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'paymentDate': serializer.toJson<DateTime?>(paymentDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'advanceStartMonth': serializer.toJson<int?>(advanceStartMonth),
      'advanceStartYear': serializer.toJson<int?>(advanceStartYear),
      'advanceEndMonth': serializer.toJson<int?>(advanceEndMonth),
      'advanceEndYear': serializer.toJson<int?>(advanceEndYear),
      'fineAmount': serializer.toJson<double?>(fineAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Payment copyWith(
          {int? id,
          int? memberId,
          int? collectionId,
          double? paidAmount,
          Value<DateTime?> paymentDate = const Value.absent(),
          String? status,
          Value<String?> notes = const Value.absent(),
          Value<int?> advanceStartMonth = const Value.absent(),
          Value<int?> advanceStartYear = const Value.absent(),
          Value<int?> advanceEndMonth = const Value.absent(),
          Value<int?> advanceEndYear = const Value.absent(),
          Value<double?> fineAmount = const Value.absent(),
          DateTime? createdAt}) =>
      Payment(
        id: id ?? this.id,
        memberId: memberId ?? this.memberId,
        collectionId: collectionId ?? this.collectionId,
        paidAmount: paidAmount ?? this.paidAmount,
        paymentDate: paymentDate.present ? paymentDate.value : this.paymentDate,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        advanceStartMonth: advanceStartMonth.present
            ? advanceStartMonth.value
            : this.advanceStartMonth,
        advanceStartYear: advanceStartYear.present
            ? advanceStartYear.value
            : this.advanceStartYear,
        advanceEndMonth: advanceEndMonth.present
            ? advanceEndMonth.value
            : this.advanceEndMonth,
        advanceEndYear:
            advanceEndYear.present ? advanceEndYear.value : this.advanceEndYear,
        fineAmount: fineAmount.present ? fineAmount.value : this.fineAmount,
        createdAt: createdAt ?? this.createdAt,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      advanceStartMonth: data.advanceStartMonth.present
          ? data.advanceStartMonth.value
          : this.advanceStartMonth,
      advanceStartYear: data.advanceStartYear.present
          ? data.advanceStartYear.value
          : this.advanceStartYear,
      advanceEndMonth: data.advanceEndMonth.present
          ? data.advanceEndMonth.value
          : this.advanceEndMonth,
      advanceEndYear: data.advanceEndYear.present
          ? data.advanceEndYear.value
          : this.advanceEndYear,
      fineAmount:
          data.fineAmount.present ? data.fineAmount.value : this.fineAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('collectionId: $collectionId, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('advanceStartMonth: $advanceStartMonth, ')
          ..write('advanceStartYear: $advanceStartYear, ')
          ..write('advanceEndMonth: $advanceEndMonth, ')
          ..write('advanceEndYear: $advanceEndYear, ')
          ..write('fineAmount: $fineAmount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      memberId,
      collectionId,
      paidAmount,
      paymentDate,
      status,
      notes,
      advanceStartMonth,
      advanceStartYear,
      advanceEndMonth,
      advanceEndYear,
      fineAmount,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.memberId == this.memberId &&
          other.collectionId == this.collectionId &&
          other.paidAmount == this.paidAmount &&
          other.paymentDate == this.paymentDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.advanceStartMonth == this.advanceStartMonth &&
          other.advanceStartYear == this.advanceStartYear &&
          other.advanceEndMonth == this.advanceEndMonth &&
          other.advanceEndYear == this.advanceEndYear &&
          other.fineAmount == this.fineAmount &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<int> memberId;
  final Value<int> collectionId;
  final Value<double> paidAmount;
  final Value<DateTime?> paymentDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<int?> advanceStartMonth;
  final Value<int?> advanceStartYear;
  final Value<int?> advanceEndMonth;
  final Value<int?> advanceEndYear;
  final Value<double?> fineAmount;
  final Value<DateTime> createdAt;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.memberId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.advanceStartMonth = const Value.absent(),
    this.advanceStartYear = const Value.absent(),
    this.advanceEndMonth = const Value.absent(),
    this.advanceEndYear = const Value.absent(),
    this.fineAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int memberId,
    required int collectionId,
    this.paidAmount = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.advanceStartMonth = const Value.absent(),
    this.advanceStartYear = const Value.absent(),
    this.advanceEndMonth = const Value.absent(),
    this.advanceEndYear = const Value.absent(),
    this.fineAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : memberId = Value(memberId),
        collectionId = Value(collectionId);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<int>? memberId,
    Expression<int>? collectionId,
    Expression<double>? paidAmount,
    Expression<DateTime>? paymentDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<int>? advanceStartMonth,
    Expression<int>? advanceStartYear,
    Expression<int>? advanceEndMonth,
    Expression<int>? advanceEndYear,
    Expression<double>? fineAmount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memberId != null) 'member_id': memberId,
      if (collectionId != null) 'collection_id': collectionId,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (advanceStartMonth != null) 'advance_start_month': advanceStartMonth,
      if (advanceStartYear != null) 'advance_start_year': advanceStartYear,
      if (advanceEndMonth != null) 'advance_end_month': advanceEndMonth,
      if (advanceEndYear != null) 'advance_end_year': advanceEndYear,
      if (fineAmount != null) 'fine_amount': fineAmount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PaymentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? memberId,
      Value<int>? collectionId,
      Value<double>? paidAmount,
      Value<DateTime?>? paymentDate,
      Value<String>? status,
      Value<String?>? notes,
      Value<int?>? advanceStartMonth,
      Value<int?>? advanceStartYear,
      Value<int?>? advanceEndMonth,
      Value<int?>? advanceEndYear,
      Value<double?>? fineAmount,
      Value<DateTime>? createdAt}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      collectionId: collectionId ?? this.collectionId,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      advanceStartMonth: advanceStartMonth ?? this.advanceStartMonth,
      advanceStartYear: advanceStartYear ?? this.advanceStartYear,
      advanceEndMonth: advanceEndMonth ?? this.advanceEndMonth,
      advanceEndYear: advanceEndYear ?? this.advanceEndYear,
      fineAmount: fineAmount ?? this.fineAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<int>(memberId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (advanceStartMonth.present) {
      map['advance_start_month'] = Variable<int>(advanceStartMonth.value);
    }
    if (advanceStartYear.present) {
      map['advance_start_year'] = Variable<int>(advanceStartYear.value);
    }
    if (advanceEndMonth.present) {
      map['advance_end_month'] = Variable<int>(advanceEndMonth.value);
    }
    if (advanceEndYear.present) {
      map['advance_end_year'] = Variable<int>(advanceEndYear.value);
    }
    if (fineAmount.present) {
      map['fine_amount'] = Variable<double>(fineAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('collectionId: $collectionId, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('advanceStartMonth: $advanceStartMonth, ')
          ..write('advanceStartYear: $advanceStartYear, ')
          ..write('advanceEndMonth: $advanceEndMonth, ')
          ..write('advanceEndYear: $advanceEndYear, ')
          ..write('fineAmount: $fineAmount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, purpose, amount, category, date, notes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final String purpose;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  const Expense(
      {required this.id,
      required this.purpose,
      required this.amount,
      required this.category,
      required this.date,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['purpose'] = Variable<String>(purpose);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      purpose: Value(purpose),
      amount: Value(amount),
      category: Value(category),
      date: Value(date),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      purpose: serializer.fromJson<String>(json['purpose']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'purpose': serializer.toJson<String>(purpose),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Expense copyWith(
          {int? id,
          String? purpose,
          double? amount,
          String? category,
          DateTime? date,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      Expense(
        id: id ?? this.id,
        purpose: purpose ?? this.purpose,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        date: date ?? this.date,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('purpose: $purpose, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, purpose, amount, category, date, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.purpose == this.purpose &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<String> purpose;
  final Value<double> amount;
  final Value<String> category;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.purpose = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required String purpose,
    required double amount,
    required String category,
    required DateTime date,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : purpose = Value(purpose),
        amount = Value(amount),
        category = Value(category),
        date = Value(date);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<String>? purpose,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purpose != null) 'purpose': purpose,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExpensesCompanion copyWith(
      {Value<int>? id,
      Value<String>? purpose,
      Value<double>? amount,
      Value<String>? category,
      Value<DateTime>? date,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      purpose: purpose ?? this.purpose,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('purpose: $purpose, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MembersTable members = $MembersTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [members, collections, payments, expenses];
}

typedef $$MembersTableCreateCompanionBuilder = MembersCompanion Function({
  Value<int> id,
  required String name,
  required String mobile,
  Value<String?> email,
  Value<String?> address,
  Value<DateTime?> dateOfBirth,
  Value<String?> bloodGroup,
  Value<String?> photoPath,
  Value<String> status,
  Value<String?> additionalInfo,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$MembersTableUpdateCompanionBuilder = MembersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> mobile,
  Value<String?> email,
  Value<String?> address,
  Value<DateTime?> dateOfBirth,
  Value<String?> bloodGroup,
  Value<String?> photoPath,
  Value<String> status,
  Value<String?> additionalInfo,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$MembersTableReferences
    extends BaseReferences<_$AppDatabase, $MembersTable, Member> {
  $$MembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.payments,
          aliasName: $_aliasNameGenerator(db.members.id, db.payments.memberId));

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments)
        .filter((f) => f.memberId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mobile => $composableBuilder(
      column: $table.mobile, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bloodGroup => $composableBuilder(
      column: $table.bloodGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get additionalInfo => $composableBuilder(
      column: $table.additionalInfo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> paymentsRefs(
      Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.memberId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mobile => $composableBuilder(
      column: $table.mobile, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bloodGroup => $composableBuilder(
      column: $table.bloodGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get additionalInfo => $composableBuilder(
      column: $table.additionalInfo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mobile =>
      $composableBuilder(column: $table.mobile, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<String> get bloodGroup => $composableBuilder(
      column: $table.bloodGroup, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get additionalInfo => $composableBuilder(
      column: $table.additionalInfo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> paymentsRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.memberId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MembersTable,
    Member,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (Member, $$MembersTableReferences),
    Member,
    PrefetchHooks Function({bool paymentsRefs})> {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> mobile = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String?> bloodGroup = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> additionalInfo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MembersCompanion(
            id: id,
            name: name,
            mobile: mobile,
            email: email,
            address: address,
            dateOfBirth: dateOfBirth,
            bloodGroup: bloodGroup,
            photoPath: photoPath,
            status: status,
            additionalInfo: additionalInfo,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String mobile,
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String?> bloodGroup = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> additionalInfo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MembersCompanion.insert(
            id: id,
            name: name,
            mobile: mobile,
            email: email,
            address: address,
            dateOfBirth: dateOfBirth,
            bloodGroup: bloodGroup,
            photoPath: photoPath,
            status: status,
            additionalInfo: additionalInfo,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MembersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentsRefs) db.payments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsRefs)
                    await $_getPrefetchedData<Member, $MembersTable, Payment>(
                        currentTable: table,
                        referencedTable:
                            $$MembersTableReferences._paymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MembersTableReferences(db, table, p0)
                                .paymentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.memberId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MembersTable,
    Member,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (Member, $$MembersTableReferences),
    Member,
    PrefetchHooks Function({bool paymentsRefs})>;
typedef $$CollectionsTableCreateCompanionBuilder = CollectionsCompanion
    Function({
  Value<int> id,
  required String title,
  required String type,
  required double amountPerMember,
  Value<String?> description,
  Value<int?> month,
  Value<int?> year,
  Value<DateTime> dateCreated,
});
typedef $$CollectionsTableUpdateCompanionBuilder = CollectionsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String> type,
  Value<double> amountPerMember,
  Value<String?> description,
  Value<int?> month,
  Value<int?> year,
  Value<DateTime> dateCreated,
});

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, Collection> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.payments,
          aliasName: $_aliasNameGenerator(
              db.collections.id, db.payments.collectionId));

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments)
        .filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amountPerMember => $composableBuilder(
      column: $table.amountPerMember,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
      column: $table.dateCreated, builder: (column) => ColumnFilters(column));

  Expression<bool> paymentsRefs(
      Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.collectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amountPerMember => $composableBuilder(
      column: $table.amountPerMember,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
      column: $table.dateCreated, builder: (column) => ColumnOrderings(column));
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amountPerMember => $composableBuilder(
      column: $table.amountPerMember, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
      column: $table.dateCreated, builder: (column) => column);

  Expression<T> paymentsRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.collectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CollectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CollectionsTable,
    Collection,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (Collection, $$CollectionsTableReferences),
    Collection,
    PrefetchHooks Function({bool paymentsRefs})> {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> amountPerMember = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int?> month = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<DateTime> dateCreated = const Value.absent(),
          }) =>
              CollectionsCompanion(
            id: id,
            title: title,
            type: type,
            amountPerMember: amountPerMember,
            description: description,
            month: month,
            year: year,
            dateCreated: dateCreated,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String type,
            required double amountPerMember,
            Value<String?> description = const Value.absent(),
            Value<int?> month = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<DateTime> dateCreated = const Value.absent(),
          }) =>
              CollectionsCompanion.insert(
            id: id,
            title: title,
            type: type,
            amountPerMember: amountPerMember,
            description: description,
            month: month,
            year: year,
            dateCreated: dateCreated,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CollectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentsRefs) db.payments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsRefs)
                    await $_getPrefetchedData<Collection, $CollectionsTable,
                            Payment>(
                        currentTable: table,
                        referencedTable:
                            $$CollectionsTableReferences._paymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CollectionsTableReferences(db, table, p0)
                                .paymentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.collectionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CollectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CollectionsTable,
    Collection,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (Collection, $$CollectionsTableReferences),
    Collection,
    PrefetchHooks Function({bool paymentsRefs})>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  required int memberId,
  required int collectionId,
  Value<double> paidAmount,
  Value<DateTime?> paymentDate,
  Value<String> status,
  Value<String?> notes,
  Value<int?> advanceStartMonth,
  Value<int?> advanceStartYear,
  Value<int?> advanceEndMonth,
  Value<int?> advanceEndYear,
  Value<double?> fineAmount,
  Value<DateTime> createdAt,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  Value<int> memberId,
  Value<int> collectionId,
  Value<double> paidAmount,
  Value<DateTime?> paymentDate,
  Value<String> status,
  Value<String?> notes,
  Value<int?> advanceStartMonth,
  Value<int?> advanceStartYear,
  Value<int?> advanceEndMonth,
  Value<int?> advanceEndYear,
  Value<double?> fineAmount,
  Value<DateTime> createdAt,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MembersTable _memberIdTable(_$AppDatabase db) => db.members
      .createAlias($_aliasNameGenerator(db.payments.memberId, db.members.id));

  $$MembersTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<int>('member_id')!;

    final manager = $$MembersTableTableManager($_db, $_db.members)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections.createAlias(
          $_aliasNameGenerator(db.payments.collectionId, db.collections.id));

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<int>('collection_id')!;

    final manager = $$CollectionsTableTableManager($_db, $_db.collections)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get advanceStartMonth => $composableBuilder(
      column: $table.advanceStartMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get advanceStartYear => $composableBuilder(
      column: $table.advanceStartYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get advanceEndMonth => $composableBuilder(
      column: $table.advanceEndMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get advanceEndYear => $composableBuilder(
      column: $table.advanceEndYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fineAmount => $composableBuilder(
      column: $table.fineAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memberId,
        referencedTable: $db.members,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MembersTableFilterComposer(
              $db: $db,
              $table: $db.members,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableFilterComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get advanceStartMonth => $composableBuilder(
      column: $table.advanceStartMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get advanceStartYear => $composableBuilder(
      column: $table.advanceStartYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get advanceEndMonth => $composableBuilder(
      column: $table.advanceEndMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get advanceEndYear => $composableBuilder(
      column: $table.advanceEndYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fineAmount => $composableBuilder(
      column: $table.fineAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memberId,
        referencedTable: $db.members,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MembersTableOrderingComposer(
              $db: $db,
              $table: $db.members,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableOrderingComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get advanceStartMonth => $composableBuilder(
      column: $table.advanceStartMonth, builder: (column) => column);

  GeneratedColumn<int> get advanceStartYear => $composableBuilder(
      column: $table.advanceStartYear, builder: (column) => column);

  GeneratedColumn<int> get advanceEndMonth => $composableBuilder(
      column: $table.advanceEndMonth, builder: (column) => column);

  GeneratedColumn<int> get advanceEndYear => $composableBuilder(
      column: $table.advanceEndYear, builder: (column) => column);

  GeneratedColumn<double> get fineAmount => $composableBuilder(
      column: $table.fineAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memberId,
        referencedTable: $db.members,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MembersTableAnnotationComposer(
              $db: $db,
              $table: $db.members,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableAnnotationComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableReferences),
    Payment,
    PrefetchHooks Function({bool memberId, bool collectionId})> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> memberId = const Value.absent(),
            Value<int> collectionId = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            Value<DateTime?> paymentDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> advanceStartMonth = const Value.absent(),
            Value<int?> advanceStartYear = const Value.absent(),
            Value<int?> advanceEndMonth = const Value.absent(),
            Value<int?> advanceEndYear = const Value.absent(),
            Value<double?> fineAmount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            memberId: memberId,
            collectionId: collectionId,
            paidAmount: paidAmount,
            paymentDate: paymentDate,
            status: status,
            notes: notes,
            advanceStartMonth: advanceStartMonth,
            advanceStartYear: advanceStartYear,
            advanceEndMonth: advanceEndMonth,
            advanceEndYear: advanceEndYear,
            fineAmount: fineAmount,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int memberId,
            required int collectionId,
            Value<double> paidAmount = const Value.absent(),
            Value<DateTime?> paymentDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> advanceStartMonth = const Value.absent(),
            Value<int?> advanceStartYear = const Value.absent(),
            Value<int?> advanceEndMonth = const Value.absent(),
            Value<int?> advanceEndYear = const Value.absent(),
            Value<double?> fineAmount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            memberId: memberId,
            collectionId: collectionId,
            paidAmount: paidAmount,
            paymentDate: paymentDate,
            status: status,
            notes: notes,
            advanceStartMonth: advanceStartMonth,
            advanceStartYear: advanceStartYear,
            advanceEndMonth: advanceEndMonth,
            advanceEndYear: advanceEndYear,
            fineAmount: fineAmount,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PaymentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({memberId = false, collectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (memberId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.memberId,
                    referencedTable:
                        $$PaymentsTableReferences._memberIdTable(db),
                    referencedColumn:
                        $$PaymentsTableReferences._memberIdTable(db).id,
                  ) as T;
                }
                if (collectionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.collectionId,
                    referencedTable:
                        $$PaymentsTableReferences._collectionIdTable(db),
                    referencedColumn:
                        $$PaymentsTableReferences._collectionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableReferences),
    Payment,
    PrefetchHooks Function({bool memberId, bool collectionId})>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  required String purpose,
  required double amount,
  required String category,
  required DateTime date,
  Value<String?> notes,
  Value<DateTime> createdAt,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<String> purpose,
  Value<double> amount,
  Value<String> category,
  Value<DateTime> date,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()> {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> purpose = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            purpose: purpose,
            amount: amount,
            category: category,
            date: date,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String purpose,
            required double amount,
            required String category,
            required DateTime date,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            purpose: purpose,
            amount: amount,
            category: category,
            date: date,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
}
