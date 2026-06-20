// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventario_camion_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventarioCamionModelCollection on Isar {
  IsarCollection<InventarioCamionModel> get inventarioCamionModels =>
      this.collection();
}

const InventarioCamionModelSchema = CollectionSchema(
  name: r'InventarioCamionModel',
  id: 2163308590764571913,
  properties: {
    r'canastaId': PropertySchema(
      id: 0,
      name: r'canastaId',
      type: IsarType.string,
    ),
    r'cantidad': PropertySchema(
      id: 1,
      name: r'cantidad',
      type: IsarType.long,
    ),
    r'codigo': PropertySchema(
      id: 2,
      name: r'codigo',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 3,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'productoId': PropertySchema(
      id: 4,
      name: r'productoId',
      type: IsarType.string,
    )
  },
  estimateSize: _inventarioCamionModelEstimateSize,
  serialize: _inventarioCamionModelSerialize,
  deserialize: _inventarioCamionModelDeserialize,
  deserializeProp: _inventarioCamionModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'codigo': IndexSchema(
      id: 2475659939796141935,
      name: r'codigo',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'codigo',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _inventarioCamionModelGetId,
  getLinks: _inventarioCamionModelGetLinks,
  attach: _inventarioCamionModelAttach,
  version: '3.1.0+1',
);

int _inventarioCamionModelEstimateSize(
  InventarioCamionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.canastaId.length * 3;
  bytesCount += 3 + object.codigo.length * 3;
  bytesCount += 3 + object.productoId.length * 3;
  return bytesCount;
}

void _inventarioCamionModelSerialize(
  InventarioCamionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.canastaId);
  writer.writeLong(offsets[1], object.cantidad);
  writer.writeString(offsets[2], object.codigo);
  writer.writeBool(offsets[3], object.isSynced);
  writer.writeString(offsets[4], object.productoId);
}

InventarioCamionModel _inventarioCamionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventarioCamionModel();
  object.canastaId = reader.readString(offsets[0]);
  object.cantidad = reader.readLong(offsets[1]);
  object.codigo = reader.readString(offsets[2]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[3]);
  object.productoId = reader.readString(offsets[4]);
  return object;
}

P _inventarioCamionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inventarioCamionModelGetId(InventarioCamionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventarioCamionModelGetLinks(
    InventarioCamionModel object) {
  return [];
}

void _inventarioCamionModelAttach(
    IsarCollection<dynamic> col, Id id, InventarioCamionModel object) {
  object.id = id;
}

extension InventarioCamionModelByIndex
    on IsarCollection<InventarioCamionModel> {
  Future<InventarioCamionModel?> getByCodigo(String codigo) {
    return getByIndex(r'codigo', [codigo]);
  }

  InventarioCamionModel? getByCodigoSync(String codigo) {
    return getByIndexSync(r'codigo', [codigo]);
  }

  Future<bool> deleteByCodigo(String codigo) {
    return deleteByIndex(r'codigo', [codigo]);
  }

  bool deleteByCodigoSync(String codigo) {
    return deleteByIndexSync(r'codigo', [codigo]);
  }

  Future<List<InventarioCamionModel?>> getAllByCodigo(
      List<String> codigoValues) {
    final values = codigoValues.map((e) => [e]).toList();
    return getAllByIndex(r'codigo', values);
  }

  List<InventarioCamionModel?> getAllByCodigoSync(List<String> codigoValues) {
    final values = codigoValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'codigo', values);
  }

  Future<int> deleteAllByCodigo(List<String> codigoValues) {
    final values = codigoValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'codigo', values);
  }

  int deleteAllByCodigoSync(List<String> codigoValues) {
    final values = codigoValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'codigo', values);
  }

  Future<Id> putByCodigo(InventarioCamionModel object) {
    return putByIndex(r'codigo', object);
  }

  Id putByCodigoSync(InventarioCamionModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'codigo', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCodigo(List<InventarioCamionModel> objects) {
    return putAllByIndex(r'codigo', objects);
  }

  List<Id> putAllByCodigoSync(List<InventarioCamionModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'codigo', objects, saveLinks: saveLinks);
  }
}

extension InventarioCamionModelQueryWhereSort
    on QueryBuilder<InventarioCamionModel, InventarioCamionModel, QWhere> {
  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InventarioCamionModelQueryWhere on QueryBuilder<InventarioCamionModel,
    InventarioCamionModel, QWhereClause> {
  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterWhereClause>
      codigoEqualTo(String codigo) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'codigo',
        value: [codigo],
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterWhereClause>
      codigoNotEqualTo(String codigo) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigo',
              lower: [],
              upper: [codigo],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigo',
              lower: [codigo],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigo',
              lower: [codigo],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigo',
              lower: [],
              upper: [codigo],
              includeUpper: false,
            ));
      }
    });
  }
}

extension InventarioCamionModelQueryFilter on QueryBuilder<
    InventarioCamionModel, InventarioCamionModel, QFilterCondition> {
  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> canastaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canastaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> canastaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'canastaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> canastaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'canastaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> canastaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'canastaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> canastaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'canastaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> canastaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'canastaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
          QAfterFilterCondition>
      canastaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'canastaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
          QAfterFilterCondition>
      canastaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'canastaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> canastaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canastaId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> canastaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'canastaId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> cantidadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidad',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> cantidadGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidad',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> cantidadLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidad',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> cantidadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> codigoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> codigoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> codigoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> codigoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> codigoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> codigoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
          QAfterFilterCondition>
      codigoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
          QAfterFilterCondition>
      codigoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> codigoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigo',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> codigoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigo',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
          QAfterFilterCondition>
      productoIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
          QAfterFilterCondition>
      productoIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productoId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoId',
        value: '',
      ));
    });
  }
}

extension InventarioCamionModelQueryObject on QueryBuilder<
    InventarioCamionModel, InventarioCamionModel, QFilterCondition> {}

extension InventarioCamionModelQueryLinks on QueryBuilder<InventarioCamionModel,
    InventarioCamionModel, QFilterCondition> {}

extension InventarioCamionModelQuerySortBy
    on QueryBuilder<InventarioCamionModel, InventarioCamionModel, QSortBy> {
  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      sortByCanastaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canastaId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      sortByCanastaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canastaId', Sort.desc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      sortByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      sortByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      sortByCodigo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      sortByCodigoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.desc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }
}

extension InventarioCamionModelQuerySortThenBy
    on QueryBuilder<InventarioCamionModel, InventarioCamionModel, QSortThenBy> {
  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByCanastaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canastaId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByCanastaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canastaId', Sort.desc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByCodigo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByCodigoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.desc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }
}

extension InventarioCamionModelQueryWhereDistinct
    on QueryBuilder<InventarioCamionModel, InventarioCamionModel, QDistinct> {
  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QDistinct>
      distinctByCanastaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'canastaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QDistinct>
      distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QDistinct>
      distinctByCodigo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QDistinct>
      distinctByProductoId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId', caseSensitive: caseSensitive);
    });
  }
}

extension InventarioCamionModelQueryProperty on QueryBuilder<
    InventarioCamionModel, InventarioCamionModel, QQueryProperty> {
  QueryBuilder<InventarioCamionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InventarioCamionModel, String, QQueryOperations>
      canastaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'canastaId');
    });
  }

  QueryBuilder<InventarioCamionModel, int, QQueryOperations>
      cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<InventarioCamionModel, String, QQueryOperations>
      codigoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigo');
    });
  }

  QueryBuilder<InventarioCamionModel, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<InventarioCamionModel, String, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }
}
