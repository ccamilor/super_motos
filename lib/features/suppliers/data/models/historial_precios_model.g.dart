// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historial_precios_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHistorialPreciosModelCollection on Isar {
  IsarCollection<HistorialPreciosModel> get historialPreciosModels =>
      this.collection();
}

const HistorialPreciosModelSchema = CollectionSchema(
  name: r'HistorialPreciosModel',
  id: (224572299 * 10000000000 + 1053323034),
  properties: {
    r'codigo': PropertySchema(
      id: 0,
      name: r'codigo',
      type: IsarType.string,
    ),
    r'fechaRegistro': PropertySchema(
      id: 1,
      name: r'fechaRegistro',
      type: IsarType.dateTime,
    ),
    r'isSynced': PropertySchema(
      id: 2,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'precioCompra': PropertySchema(
      id: 3,
      name: r'precioCompra',
      type: IsarType.double,
    ),
    r'productoId': PropertySchema(
      id: 4,
      name: r'productoId',
      type: IsarType.string,
    ),
    r'proveedorId': PropertySchema(
      id: 5,
      name: r'proveedorId',
      type: IsarType.string,
    )
  },
  estimateSize: _historialPreciosModelEstimateSize,
  serialize: _historialPreciosModelSerialize,
  deserialize: _historialPreciosModelDeserialize,
  deserializeProp: _historialPreciosModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'codigo': IndexSchema(
      id: (247565993 * 10000000000 + 9796141935),
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
  getId: _historialPreciosModelGetId,
  getLinks: _historialPreciosModelGetLinks,
  attach: _historialPreciosModelAttach,
  version: '3.1.0+1',
);

int _historialPreciosModelEstimateSize(
  HistorialPreciosModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.codigo.length * 3;
  bytesCount += 3 + object.productoId.length * 3;
  bytesCount += 3 + object.proveedorId.length * 3;
  return bytesCount;
}

void _historialPreciosModelSerialize(
  HistorialPreciosModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.codigo);
  writer.writeDateTime(offsets[1], object.fechaRegistro);
  writer.writeBool(offsets[2], object.isSynced);
  writer.writeDouble(offsets[3], object.precioCompra);
  writer.writeString(offsets[4], object.productoId);
  writer.writeString(offsets[5], object.proveedorId);
}

HistorialPreciosModel _historialPreciosModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HistorialPreciosModel();
  object.codigo = reader.readString(offsets[0]);
  object.fechaRegistro = reader.readDateTime(offsets[1]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[2]);
  object.precioCompra = reader.readDouble(offsets[3]);
  object.productoId = reader.readString(offsets[4]);
  object.proveedorId = reader.readString(offsets[5]);
  return object;
}

P _historialPreciosModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _historialPreciosModelGetId(HistorialPreciosModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _historialPreciosModelGetLinks(
    HistorialPreciosModel object) {
  return [];
}

void _historialPreciosModelAttach(
    IsarCollection<dynamic> col, Id id, HistorialPreciosModel object) {
  object.id = id;
}

extension HistorialPreciosModelByIndex
    on IsarCollection<HistorialPreciosModel> {
  Future<HistorialPreciosModel?> getByCodigo(String codigo) {
    return getByIndex(r'codigo', [codigo]);
  }

  HistorialPreciosModel? getByCodigoSync(String codigo) {
    return getByIndexSync(r'codigo', [codigo]);
  }

  Future<bool> deleteByCodigo(String codigo) {
    return deleteByIndex(r'codigo', [codigo]);
  }

  bool deleteByCodigoSync(String codigo) {
    return deleteByIndexSync(r'codigo', [codigo]);
  }

  Future<List<HistorialPreciosModel?>> getAllByCodigo(
      List<String> codigoValues) {
    final values = codigoValues.map((e) => [e]).toList();
    return getAllByIndex(r'codigo', values);
  }

  List<HistorialPreciosModel?> getAllByCodigoSync(List<String> codigoValues) {
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

  Future<Id> putByCodigo(HistorialPreciosModel object) {
    return putByIndex(r'codigo', object);
  }

  Id putByCodigoSync(HistorialPreciosModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'codigo', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCodigo(List<HistorialPreciosModel> objects) {
    return putAllByIndex(r'codigo', objects);
  }

  List<Id> putAllByCodigoSync(List<HistorialPreciosModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'codigo', objects, saveLinks: saveLinks);
  }
}

extension HistorialPreciosModelQueryWhereSort
    on QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QWhere> {
  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HistorialPreciosModelQueryWhere on QueryBuilder<HistorialPreciosModel,
    HistorialPreciosModel, QWhereClause> {
  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterWhereClause>
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterWhereClause>
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterWhereClause>
      codigoEqualTo(String codigo) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'codigo',
        value: [codigo],
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterWhereClause>
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

extension HistorialPreciosModelQueryFilter on QueryBuilder<
    HistorialPreciosModel, HistorialPreciosModel, QFilterCondition> {
  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> codigoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigo',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> codigoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigo',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> fechaRegistroEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> fechaRegistroGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> fechaRegistroLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> fechaRegistroBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaRegistro',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> precioCompraEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioCompra',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> precioCompraGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioCompra',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> precioCompraLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioCompra',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> precioCompraBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioCompra',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
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

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> productoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> productoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> proveedorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> proveedorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proveedorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> proveedorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proveedorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> proveedorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proveedorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> proveedorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proveedorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> proveedorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proveedorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
          QAfterFilterCondition>
      proveedorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proveedorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
          QAfterFilterCondition>
      proveedorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proveedorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> proveedorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorId',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel,
      QAfterFilterCondition> proveedorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proveedorId',
        value: '',
      ));
    });
  }
}

extension HistorialPreciosModelQueryObject on QueryBuilder<
    HistorialPreciosModel, HistorialPreciosModel, QFilterCondition> {}

extension HistorialPreciosModelQueryLinks on QueryBuilder<HistorialPreciosModel,
    HistorialPreciosModel, QFilterCondition> {}

extension HistorialPreciosModelQuerySortBy
    on QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QSortBy> {
  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByCodigo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByCodigoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.desc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByPrecioCompra() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioCompra', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByPrecioCompraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioCompra', Sort.desc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByProveedorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      sortByProveedorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorId', Sort.desc);
    });
  }
}

extension HistorialPreciosModelQuerySortThenBy
    on QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QSortThenBy> {
  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByCodigo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByCodigoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.desc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByPrecioCompra() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioCompra', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByPrecioCompraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioCompra', Sort.desc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByProveedorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QAfterSortBy>
      thenByProveedorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorId', Sort.desc);
    });
  }
}

extension HistorialPreciosModelQueryWhereDistinct
    on QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QDistinct> {
  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QDistinct>
      distinctByCodigo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QDistinct>
      distinctByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaRegistro');
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QDistinct>
      distinctByPrecioCompra() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precioCompra');
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QDistinct>
      distinctByProductoId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistorialPreciosModel, HistorialPreciosModel, QDistinct>
      distinctByProveedorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proveedorId', caseSensitive: caseSensitive);
    });
  }
}

extension HistorialPreciosModelQueryProperty on QueryBuilder<
    HistorialPreciosModel, HistorialPreciosModel, QQueryProperty> {
  QueryBuilder<HistorialPreciosModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HistorialPreciosModel, String, QQueryOperations>
      codigoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigo');
    });
  }

  QueryBuilder<HistorialPreciosModel, DateTime, QQueryOperations>
      fechaRegistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaRegistro');
    });
  }

  QueryBuilder<HistorialPreciosModel, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<HistorialPreciosModel, double, QQueryOperations>
      precioCompraProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precioCompra');
    });
  }

  QueryBuilder<HistorialPreciosModel, String, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }

  QueryBuilder<HistorialPreciosModel, String, QQueryOperations>
      proveedorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proveedorId');
    });
  }
}
