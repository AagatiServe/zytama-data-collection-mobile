// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedProductsTable extends CachedProducts
    with TableInfo<$CachedProductsTable, CachedProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _foundMeta = const VerificationMeta('found');
  @override
  late final GeneratedColumn<bool> found = GeneratedColumn<bool>(
      'found', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("found" IN (0, 1))'));
  static const VerificationMeta _productImageUrlMeta =
      const VerificationMeta('productImageUrl');
  @override
  late final GeneratedColumn<String> productImageUrl = GeneratedColumn<String>(
      'product_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [barcode, found, productImageUrl, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_products';
  @override
  VerificationContext validateIntegrity(Insertable<CachedProduct> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('found')) {
      context.handle(
          _foundMeta, found.isAcceptableOrUnknown(data['found']!, _foundMeta));
    } else if (isInserting) {
      context.missing(_foundMeta);
    }
    if (data.containsKey('product_image_url')) {
      context.handle(
          _productImageUrlMeta,
          productImageUrl.isAcceptableOrUnknown(
              data['product_image_url']!, _productImageUrlMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {barcode};
  @override
  CachedProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProduct(
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      found: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}found'])!,
      productImageUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}product_image_url']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedProductsTable createAlias(String alias) {
    return $CachedProductsTable(attachedDatabase, alias);
  }
}

class CachedProduct extends DataClass implements Insertable<CachedProduct> {
  final String barcode;
  final bool found;
  final String? productImageUrl;
  final DateTime cachedAt;
  const CachedProduct(
      {required this.barcode,
      required this.found,
      this.productImageUrl,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['barcode'] = Variable<String>(barcode);
    map['found'] = Variable<bool>(found);
    if (!nullToAbsent || productImageUrl != null) {
      map['product_image_url'] = Variable<String>(productImageUrl);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedProductsCompanion toCompanion(bool nullToAbsent) {
    return CachedProductsCompanion(
      barcode: Value(barcode),
      found: Value(found),
      productImageUrl: productImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(productImageUrl),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedProduct.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProduct(
      barcode: serializer.fromJson<String>(json['barcode']),
      found: serializer.fromJson<bool>(json['found']),
      productImageUrl: serializer.fromJson<String?>(json['productImageUrl']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'barcode': serializer.toJson<String>(barcode),
      'found': serializer.toJson<bool>(found),
      'productImageUrl': serializer.toJson<String?>(productImageUrl),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedProduct copyWith(
          {String? barcode,
          bool? found,
          Value<String?> productImageUrl = const Value.absent(),
          DateTime? cachedAt}) =>
      CachedProduct(
        barcode: barcode ?? this.barcode,
        found: found ?? this.found,
        productImageUrl: productImageUrl.present
            ? productImageUrl.value
            : this.productImageUrl,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedProduct copyWithCompanion(CachedProductsCompanion data) {
    return CachedProduct(
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      found: data.found.present ? data.found.value : this.found,
      productImageUrl: data.productImageUrl.present
          ? data.productImageUrl.value
          : this.productImageUrl,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProduct(')
          ..write('barcode: $barcode, ')
          ..write('found: $found, ')
          ..write('productImageUrl: $productImageUrl, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(barcode, found, productImageUrl, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProduct &&
          other.barcode == this.barcode &&
          other.found == this.found &&
          other.productImageUrl == this.productImageUrl &&
          other.cachedAt == this.cachedAt);
}

class CachedProductsCompanion extends UpdateCompanion<CachedProduct> {
  final Value<String> barcode;
  final Value<bool> found;
  final Value<String?> productImageUrl;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedProductsCompanion({
    this.barcode = const Value.absent(),
    this.found = const Value.absent(),
    this.productImageUrl = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedProductsCompanion.insert({
    required String barcode,
    required bool found,
    this.productImageUrl = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : barcode = Value(barcode),
        found = Value(found),
        cachedAt = Value(cachedAt);
  static Insertable<CachedProduct> custom({
    Expression<String>? barcode,
    Expression<bool>? found,
    Expression<String>? productImageUrl,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (barcode != null) 'barcode': barcode,
      if (found != null) 'found': found,
      if (productImageUrl != null) 'product_image_url': productImageUrl,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedProductsCompanion copyWith(
      {Value<String>? barcode,
      Value<bool>? found,
      Value<String?>? productImageUrl,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return CachedProductsCompanion(
      barcode: barcode ?? this.barcode,
      found: found ?? this.found,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (found.present) {
      map['found'] = Variable<bool>(found.value);
    }
    if (productImageUrl.present) {
      map['product_image_url'] = Variable<String>(productImageUrl.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProductsCompanion(')
          ..write('barcode: $barcode, ')
          ..write('found: $found, ')
          ..write('productImageUrl: $productImageUrl, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingUploadsTable extends PendingUploads
    with TableInfo<$PendingUploadsTable, PendingUpload> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingUploadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productImagePathMeta =
      const VerificationMeta('productImagePath');
  @override
  late final GeneratedColumn<String> productImagePath = GeneratedColumn<String>(
      'product_image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ingredientsImagePathMeta =
      const VerificationMeta('ingredientsImagePath');
  @override
  late final GeneratedColumn<String> ingredientsImagePath =
      GeneratedColumn<String>('ingredients_image_path', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nutritionImagePathMeta =
      const VerificationMeta('nutritionImagePath');
  @override
  late final GeneratedColumn<String> nutritionImagePath =
      GeneratedColumn<String>('nutrition_image_path', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        barcode,
        productImagePath,
        ingredientsImagePath,
        nutritionImagePath,
        isSynced,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_uploads';
  @override
  VerificationContext validateIntegrity(Insertable<PendingUpload> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('product_image_path')) {
      context.handle(
          _productImagePathMeta,
          productImagePath.isAcceptableOrUnknown(
              data['product_image_path']!, _productImagePathMeta));
    } else if (isInserting) {
      context.missing(_productImagePathMeta);
    }
    if (data.containsKey('ingredients_image_path')) {
      context.handle(
          _ingredientsImagePathMeta,
          ingredientsImagePath.isAcceptableOrUnknown(
              data['ingredients_image_path']!, _ingredientsImagePathMeta));
    } else if (isInserting) {
      context.missing(_ingredientsImagePathMeta);
    }
    if (data.containsKey('nutrition_image_path')) {
      context.handle(
          _nutritionImagePathMeta,
          nutritionImagePath.isAcceptableOrUnknown(
              data['nutrition_image_path']!, _nutritionImagePathMeta));
    } else if (isInserting) {
      context.missing(_nutritionImagePathMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingUpload map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingUpload(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      productImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}product_image_path'])!,
      ingredientsImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ingredients_image_path'])!,
      nutritionImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}nutrition_image_path'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PendingUploadsTable createAlias(String alias) {
    return $PendingUploadsTable(attachedDatabase, alias);
  }
}

class PendingUpload extends DataClass implements Insertable<PendingUpload> {
  final int id;
  final String barcode;
  final String productImagePath;
  final String ingredientsImagePath;
  final String nutritionImagePath;
  final bool isSynced;
  final DateTime createdAt;
  const PendingUpload(
      {required this.id,
      required this.barcode,
      required this.productImagePath,
      required this.ingredientsImagePath,
      required this.nutritionImagePath,
      required this.isSynced,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['barcode'] = Variable<String>(barcode);
    map['product_image_path'] = Variable<String>(productImagePath);
    map['ingredients_image_path'] = Variable<String>(ingredientsImagePath);
    map['nutrition_image_path'] = Variable<String>(nutritionImagePath);
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingUploadsCompanion toCompanion(bool nullToAbsent) {
    return PendingUploadsCompanion(
      id: Value(id),
      barcode: Value(barcode),
      productImagePath: Value(productImagePath),
      ingredientsImagePath: Value(ingredientsImagePath),
      nutritionImagePath: Value(nutritionImagePath),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
    );
  }

  factory PendingUpload.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingUpload(
      id: serializer.fromJson<int>(json['id']),
      barcode: serializer.fromJson<String>(json['barcode']),
      productImagePath: serializer.fromJson<String>(json['productImagePath']),
      ingredientsImagePath:
          serializer.fromJson<String>(json['ingredientsImagePath']),
      nutritionImagePath:
          serializer.fromJson<String>(json['nutritionImagePath']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barcode': serializer.toJson<String>(barcode),
      'productImagePath': serializer.toJson<String>(productImagePath),
      'ingredientsImagePath': serializer.toJson<String>(ingredientsImagePath),
      'nutritionImagePath': serializer.toJson<String>(nutritionImagePath),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingUpload copyWith(
          {int? id,
          String? barcode,
          String? productImagePath,
          String? ingredientsImagePath,
          String? nutritionImagePath,
          bool? isSynced,
          DateTime? createdAt}) =>
      PendingUpload(
        id: id ?? this.id,
        barcode: barcode ?? this.barcode,
        productImagePath: productImagePath ?? this.productImagePath,
        ingredientsImagePath: ingredientsImagePath ?? this.ingredientsImagePath,
        nutritionImagePath: nutritionImagePath ?? this.nutritionImagePath,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
      );
  PendingUpload copyWithCompanion(PendingUploadsCompanion data) {
    return PendingUpload(
      id: data.id.present ? data.id.value : this.id,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      productImagePath: data.productImagePath.present
          ? data.productImagePath.value
          : this.productImagePath,
      ingredientsImagePath: data.ingredientsImagePath.present
          ? data.ingredientsImagePath.value
          : this.ingredientsImagePath,
      nutritionImagePath: data.nutritionImagePath.present
          ? data.nutritionImagePath.value
          : this.nutritionImagePath,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingUpload(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('productImagePath: $productImagePath, ')
          ..write('ingredientsImagePath: $ingredientsImagePath, ')
          ..write('nutritionImagePath: $nutritionImagePath, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, barcode, productImagePath,
      ingredientsImagePath, nutritionImagePath, isSynced, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingUpload &&
          other.id == this.id &&
          other.barcode == this.barcode &&
          other.productImagePath == this.productImagePath &&
          other.ingredientsImagePath == this.ingredientsImagePath &&
          other.nutritionImagePath == this.nutritionImagePath &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt);
}

class PendingUploadsCompanion extends UpdateCompanion<PendingUpload> {
  final Value<int> id;
  final Value<String> barcode;
  final Value<String> productImagePath;
  final Value<String> ingredientsImagePath;
  final Value<String> nutritionImagePath;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  const PendingUploadsCompanion({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    this.productImagePath = const Value.absent(),
    this.ingredientsImagePath = const Value.absent(),
    this.nutritionImagePath = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingUploadsCompanion.insert({
    this.id = const Value.absent(),
    required String barcode,
    required String productImagePath,
    required String ingredientsImagePath,
    required String nutritionImagePath,
    this.isSynced = const Value.absent(),
    required DateTime createdAt,
  })  : barcode = Value(barcode),
        productImagePath = Value(productImagePath),
        ingredientsImagePath = Value(ingredientsImagePath),
        nutritionImagePath = Value(nutritionImagePath),
        createdAt = Value(createdAt);
  static Insertable<PendingUpload> custom({
    Expression<int>? id,
    Expression<String>? barcode,
    Expression<String>? productImagePath,
    Expression<String>? ingredientsImagePath,
    Expression<String>? nutritionImagePath,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (productImagePath != null) 'product_image_path': productImagePath,
      if (ingredientsImagePath != null)
        'ingredients_image_path': ingredientsImagePath,
      if (nutritionImagePath != null)
        'nutrition_image_path': nutritionImagePath,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingUploadsCompanion copyWith(
      {Value<int>? id,
      Value<String>? barcode,
      Value<String>? productImagePath,
      Value<String>? ingredientsImagePath,
      Value<String>? nutritionImagePath,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt}) {
    return PendingUploadsCompanion(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      productImagePath: productImagePath ?? this.productImagePath,
      ingredientsImagePath: ingredientsImagePath ?? this.ingredientsImagePath,
      nutritionImagePath: nutritionImagePath ?? this.nutritionImagePath,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (productImagePath.present) {
      map['product_image_path'] = Variable<String>(productImagePath.value);
    }
    if (ingredientsImagePath.present) {
      map['ingredients_image_path'] =
          Variable<String>(ingredientsImagePath.value);
    }
    if (nutritionImagePath.present) {
      map['nutrition_image_path'] = Variable<String>(nutritionImagePath.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingUploadsCompanion(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('productImagePath: $productImagePath, ')
          ..write('ingredientsImagePath: $ingredientsImagePath, ')
          ..write('nutritionImagePath: $nutritionImagePath, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedProductsTable cachedProducts = $CachedProductsTable(this);
  late final $PendingUploadsTable pendingUploads = $PendingUploadsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cachedProducts, pendingUploads];
}

typedef $$CachedProductsTableCreateCompanionBuilder = CachedProductsCompanion
    Function({
  required String barcode,
  required bool found,
  Value<String?> productImageUrl,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$CachedProductsTableUpdateCompanionBuilder = CachedProductsCompanion
    Function({
  Value<String> barcode,
  Value<bool> found,
  Value<String?> productImageUrl,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$CachedProductsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedProductsTable> {
  $$CachedProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get found => $composableBuilder(
      column: $table.found, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productImageUrl => $composableBuilder(
      column: $table.productImageUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedProductsTable> {
  $$CachedProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get found => $composableBuilder(
      column: $table.found, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productImageUrl => $composableBuilder(
      column: $table.productImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedProductsTable> {
  $$CachedProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<bool> get found =>
      $composableBuilder(column: $table.found, builder: (column) => column);

  GeneratedColumn<String> get productImageUrl => $composableBuilder(
      column: $table.productImageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedProductsTable,
    CachedProduct,
    $$CachedProductsTableFilterComposer,
    $$CachedProductsTableOrderingComposer,
    $$CachedProductsTableAnnotationComposer,
    $$CachedProductsTableCreateCompanionBuilder,
    $$CachedProductsTableUpdateCompanionBuilder,
    (
      CachedProduct,
      BaseReferences<_$AppDatabase, $CachedProductsTable, CachedProduct>
    ),
    CachedProduct,
    PrefetchHooks Function()> {
  $$CachedProductsTableTableManager(
      _$AppDatabase db, $CachedProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> barcode = const Value.absent(),
            Value<bool> found = const Value.absent(),
            Value<String?> productImageUrl = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedProductsCompanion(
            barcode: barcode,
            found: found,
            productImageUrl: productImageUrl,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String barcode,
            required bool found,
            Value<String?> productImageUrl = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedProductsCompanion.insert(
            barcode: barcode,
            found: found,
            productImageUrl: productImageUrl,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedProductsTable,
    CachedProduct,
    $$CachedProductsTableFilterComposer,
    $$CachedProductsTableOrderingComposer,
    $$CachedProductsTableAnnotationComposer,
    $$CachedProductsTableCreateCompanionBuilder,
    $$CachedProductsTableUpdateCompanionBuilder,
    (
      CachedProduct,
      BaseReferences<_$AppDatabase, $CachedProductsTable, CachedProduct>
    ),
    CachedProduct,
    PrefetchHooks Function()>;
typedef $$PendingUploadsTableCreateCompanionBuilder = PendingUploadsCompanion
    Function({
  Value<int> id,
  required String barcode,
  required String productImagePath,
  required String ingredientsImagePath,
  required String nutritionImagePath,
  Value<bool> isSynced,
  required DateTime createdAt,
});
typedef $$PendingUploadsTableUpdateCompanionBuilder = PendingUploadsCompanion
    Function({
  Value<int> id,
  Value<String> barcode,
  Value<String> productImagePath,
  Value<String> ingredientsImagePath,
  Value<String> nutritionImagePath,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
});

class $$PendingUploadsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingUploadsTable> {
  $$PendingUploadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productImagePath => $composableBuilder(
      column: $table.productImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredientsImagePath => $composableBuilder(
      column: $table.ingredientsImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nutritionImagePath => $composableBuilder(
      column: $table.nutritionImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PendingUploadsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingUploadsTable> {
  $$PendingUploadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productImagePath => $composableBuilder(
      column: $table.productImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredientsImagePath => $composableBuilder(
      column: $table.ingredientsImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nutritionImagePath => $composableBuilder(
      column: $table.nutritionImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PendingUploadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingUploadsTable> {
  $$PendingUploadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get productImagePath => $composableBuilder(
      column: $table.productImagePath, builder: (column) => column);

  GeneratedColumn<String> get ingredientsImagePath => $composableBuilder(
      column: $table.ingredientsImagePath, builder: (column) => column);

  GeneratedColumn<String> get nutritionImagePath => $composableBuilder(
      column: $table.nutritionImagePath, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingUploadsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingUploadsTable,
    PendingUpload,
    $$PendingUploadsTableFilterComposer,
    $$PendingUploadsTableOrderingComposer,
    $$PendingUploadsTableAnnotationComposer,
    $$PendingUploadsTableCreateCompanionBuilder,
    $$PendingUploadsTableUpdateCompanionBuilder,
    (
      PendingUpload,
      BaseReferences<_$AppDatabase, $PendingUploadsTable, PendingUpload>
    ),
    PendingUpload,
    PrefetchHooks Function()> {
  $$PendingUploadsTableTableManager(
      _$AppDatabase db, $PendingUploadsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingUploadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingUploadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingUploadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<String> productImagePath = const Value.absent(),
            Value<String> ingredientsImagePath = const Value.absent(),
            Value<String> nutritionImagePath = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingUploadsCompanion(
            id: id,
            barcode: barcode,
            productImagePath: productImagePath,
            ingredientsImagePath: ingredientsImagePath,
            nutritionImagePath: nutritionImagePath,
            isSynced: isSynced,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String barcode,
            required String productImagePath,
            required String ingredientsImagePath,
            required String nutritionImagePath,
            Value<bool> isSynced = const Value.absent(),
            required DateTime createdAt,
          }) =>
              PendingUploadsCompanion.insert(
            id: id,
            barcode: barcode,
            productImagePath: productImagePath,
            ingredientsImagePath: ingredientsImagePath,
            nutritionImagePath: nutritionImagePath,
            isSynced: isSynced,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingUploadsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingUploadsTable,
    PendingUpload,
    $$PendingUploadsTableFilterComposer,
    $$PendingUploadsTableOrderingComposer,
    $$PendingUploadsTableAnnotationComposer,
    $$PendingUploadsTableCreateCompanionBuilder,
    $$PendingUploadsTableUpdateCompanionBuilder,
    (
      PendingUpload,
      BaseReferences<_$AppDatabase, $PendingUploadsTable, PendingUpload>
    ),
    PendingUpload,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedProductsTableTableManager get cachedProducts =>
      $$CachedProductsTableTableManager(_db, _db.cachedProducts);
  $$PendingUploadsTableTableManager get pendingUploads =>
      $$PendingUploadsTableTableManager(_db, _db.pendingUploads);
}
