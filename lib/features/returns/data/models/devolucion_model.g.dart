// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devolucion_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDevolucionModelCollection on Isar {
  IsarCollection<DevolucionModel> get devolucionModels => this.collection();
}

const DevolucionModelSchema = CollectionSchema(
  name: r'DevolucionModel',
  id: -(183417014 * 10000000000 + 1947563791),
  properties: {
    r'canastaDestino': PropertySchema(
      id: 0,
      name: r'canastaDestino',
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
    r'facturaId': PropertySchema(
      id: 3,
      name: r'facturaId',
      type: IsarType.string,
    ),
    r'fechaDevolucion': PropertySchema(
      id: 4,
      name: r'fechaDevolucion',
      type: IsarType.dateTime,
    ),
    r'isSynced': PropertySchema(
      id: 5,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'motivo': PropertySchema(
      id: 6,
      name: r'motivo',
      type: IsarType.string,
    ),
    r'productoId': PropertySchema(
      id: 7,
      name: r'productoId',
      type: IsarType.string,
    )
  },
  estimateSize: _devolucionModelEstimateSize,
  serialize: _devolucionModelSerialize,
  deserialize: _devolucionModelDeserialize,
  deserializeProp: _devolucionModelDeserializeProp,
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
  getId: _devolucionModelGetId,
  getLinks: _devolucionModelGetLinks,
  attach: _devolucionModelAttach,
  version: '3.1.0+1',
);

int _devolucionModelEstimateSize(
  DevolucionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.canastaDestino.length * 3;
  bytesCount += 3 + object.codigo.length * 3;
  bytesCount += 3 + object.facturaId.length * 3;
  bytesCount += 3 + object.motivo.length * 3;
  bytesCount += 3 + object.productoId.length * 3;
  return bytesCount;
}

void _devolucionModelSerialize(
  DevolucionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.canastaDestino);
  writer.writeLong(offsets[1], object.cantidad);
  writer.writeString(offsets[2], object.codigo);
  writer.writeString(offsets[3], object.facturaId);
  writer.writeDateTime(offsets[4], object.fechaDevolucion);
  writer.writeBool(offsets[5], object.isSynced);
  writer.writeString(offsets[6], object.motivo);
  writer.writeString(offsets[7], object.productoId);
}

DevolucionModel _devolucionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DevolucionModel();
  object.canastaDestino = reader.readString(offsets[0]);
  object.cantidad = reader.readLong(offsets[1]);
  object.codigo = reader.readString(offsets[2]);
  object.facturaId = reader.readString(offsets[3]);
  object.fechaDevolucion = reader.readDateTime(offsets[4]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[5]);
  object.motivo = reader.readString(offsets[6]);
  object.productoId = reader.readString(offsets[7]);
  return object;
}

P _devolucionModelDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _devolucionModelGetId(DevolucionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _devolucionModelGetLinks(DevolucionModel object) {
  return [];
}

void _devolucionModelAttach(
    IsarCollection<dynamic> col, Id id, DevolucionModel object) {
  object.id = id;
}

extension DevolucionModelByIndex on IsarCollection<DevolucionModel> {
  Future<DevolucionModel?> getByCodigo(String codigo) {
    return getByIndex(r'codigo', [codigo]);
  }

  DevolucionModel? getByCodigoSync(String codigo) {
    return getByIndexSync(r'codigo', [codigo]);
  }

  Future<bool> deleteByCodigo(String codigo) {
    return deleteByIndex(r'codigo', [codigo]);
  }

  bool deleteByCodigoSync(String codigo) {
    return deleteByIndexSync(r'codigo', [codigo]);
  }

  Future<List<DevolucionModel?>> getAllByCodigo(List<String> codigoValues) {
    final values = codigoValues.map((e) => [e]).toList();
    return getAllByIndex(r'codigo', values);
  }

  List<DevolucionModel?> getAllByCodigoSync(List<String> codigoValues) {
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

  Future<Id> putByCodigo(DevolucionModel object) {
    return putByIndex(r'codigo', object);
  }

  Id putByCodigoSync(DevolucionModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'codigo', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCodigo(List<DevolucionModel> objects) {
    return putAllByIndex(r'codigo', objects);
  }

  List<Id> putAllByCodigoSync(List<DevolucionModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'codigo', objects, saveLinks: saveLinks);
  }
}

extension DevolucionModelQueryWhereSort
    on QueryBuilder<DevolucionModel, DevolucionModel, QWhere> {
  QueryBuilder<DevolucionModel, DevolucionModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DevolucionModelQueryWhere
    on QueryBuilder<DevolucionModel, DevolucionModel, QWhereClause> {
  QueryBuilder<DevolucionModel, DevolucionModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterWhereClause>
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterWhereClause>
      codigoEqualTo(String codigo) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'codigo',
        value: [codigo],
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterWhereClause>
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

extension DevolucionModelQueryFilter
    on QueryBuilder<DevolucionModel, DevolucionModel, QFilterCondition> {
  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      canastaDestinoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      canastaDestinoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'canastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      canastaDestinoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'canastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      canastaDestinoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'canastaDestino',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      canastaDestinoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'canastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      canastaDestinoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'canastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      canastaDestinoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'canastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      canastaDestinoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'canastaDestino',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      canastaDestinoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canastaDestino',
        value: '',
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      canastaDestinoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'canastaDestino',
        value: '',
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      cantidadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidad',
        value: value,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      cantidadGreaterThan(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      cantidadLessThan(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      cantidadBetween(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      codigoEqualTo(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      codigoGreaterThan(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      codigoLessThan(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      codigoBetween(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      codigoStartsWith(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      codigoEndsWith(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      codigoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      codigoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      codigoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigo',
        value: '',
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      codigoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigo',
        value: '',
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      facturaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'facturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      facturaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'facturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      facturaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'facturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      facturaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'facturaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      facturaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'facturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      facturaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'facturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      facturaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'facturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      facturaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'facturaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      facturaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'facturaId',
        value: '',
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      facturaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'facturaId',
        value: '',
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      fechaDevolucionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaDevolucion',
        value: value,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      fechaDevolucionGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaDevolucion',
        value: value,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      fechaDevolucionLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaDevolucion',
        value: value,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      fechaDevolucionBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaDevolucion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      motivoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      motivoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      motivoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      motivoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motivo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      motivoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      motivoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      motivoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      motivoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motivo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      motivoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motivo',
        value: '',
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      motivoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motivo',
        value: '',
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      productoIdEqualTo(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      productoIdGreaterThan(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      productoIdLessThan(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      productoIdBetween(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      productoIdStartsWith(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      productoIdEndsWith(
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

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      productoIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      productoIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productoId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      productoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      productoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoId',
        value: '',
      ));
    });
  }
}

extension DevolucionModelQueryObject
    on QueryBuilder<DevolucionModel, DevolucionModel, QFilterCondition> {}

extension DevolucionModelQueryLinks
    on QueryBuilder<DevolucionModel, DevolucionModel, QFilterCondition> {}

extension DevolucionModelQuerySortBy
    on QueryBuilder<DevolucionModel, DevolucionModel, QSortBy> {
  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByCanastaDestino() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canastaDestino', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByCanastaDestinoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canastaDestino', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy> sortByCodigo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByCodigoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByFacturaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facturaId', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByFacturaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facturaId', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByFechaDevolucion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaDevolucion', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByFechaDevolucionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaDevolucion', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy> sortByMotivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByMotivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }
}

extension DevolucionModelQuerySortThenBy
    on QueryBuilder<DevolucionModel, DevolucionModel, QSortThenBy> {
  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByCanastaDestino() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canastaDestino', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByCanastaDestinoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canastaDestino', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy> thenByCodigo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByCodigoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByFacturaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facturaId', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByFacturaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facturaId', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByFechaDevolucion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaDevolucion', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByFechaDevolucionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaDevolucion', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy> thenByMotivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByMotivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.desc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }
}

extension DevolucionModelQueryWhereDistinct
    on QueryBuilder<DevolucionModel, DevolucionModel, QDistinct> {
  QueryBuilder<DevolucionModel, DevolucionModel, QDistinct>
      distinctByCanastaDestino({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'canastaDestino',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QDistinct>
      distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QDistinct> distinctByCodigo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QDistinct> distinctByFacturaId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'facturaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QDistinct>
      distinctByFechaDevolucion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaDevolucion');
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QDistinct> distinctByMotivo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motivo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QDistinct>
      distinctByProductoId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId', caseSensitive: caseSensitive);
    });
  }
}

extension DevolucionModelQueryProperty
    on QueryBuilder<DevolucionModel, DevolucionModel, QQueryProperty> {
  QueryBuilder<DevolucionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DevolucionModel, String, QQueryOperations>
      canastaDestinoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'canastaDestino');
    });
  }

  QueryBuilder<DevolucionModel, int, QQueryOperations> cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<DevolucionModel, String, QQueryOperations> codigoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigo');
    });
  }

  QueryBuilder<DevolucionModel, String, QQueryOperations> facturaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'facturaId');
    });
  }

  QueryBuilder<DevolucionModel, DateTime, QQueryOperations>
      fechaDevolucionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaDevolucion');
    });
  }

  QueryBuilder<DevolucionModel, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<DevolucionModel, String, QQueryOperations> motivoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motivo');
    });
  }

  QueryBuilder<DevolucionModel, String, QQueryOperations> productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }
}
