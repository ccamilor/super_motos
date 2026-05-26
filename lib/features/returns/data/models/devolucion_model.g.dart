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
  id: -1834170141947563791,
  properties: {
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.long,
    ),
    r'facturaId': PropertySchema(
      id: 1,
      name: r'facturaId',
      type: IsarType.string,
    ),
    r'fechaDevolucion': PropertySchema(
      id: 2,
      name: r'fechaDevolucion',
      type: IsarType.dateTime,
    ),
    r'isSynced': PropertySchema(
      id: 3,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'motivo': PropertySchema(
      id: 4,
      name: r'motivo',
      type: IsarType.string,
    ),
    r'numeroCanastaDestino': PropertySchema(
      id: 5,
      name: r'numeroCanastaDestino',
      type: IsarType.string,
    ),
    r'productoId': PropertySchema(
      id: 6,
      name: r'productoId',
      type: IsarType.string,
    )
  },
  estimateSize: _devolucionModelEstimateSize,
  serialize: _devolucionModelSerialize,
  deserialize: _devolucionModelDeserialize,
  deserializeProp: _devolucionModelDeserializeProp,
  idName: r'id',
  indexes: {},
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
  bytesCount += 3 + object.facturaId.length * 3;
  bytesCount += 3 + object.motivo.length * 3;
  bytesCount += 3 + object.numeroCanastaDestino.length * 3;
  bytesCount += 3 + object.productoId.length * 3;
  return bytesCount;
}

void _devolucionModelSerialize(
  DevolucionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cantidad);
  writer.writeString(offsets[1], object.facturaId);
  writer.writeDateTime(offsets[2], object.fechaDevolucion);
  writer.writeBool(offsets[3], object.isSynced);
  writer.writeString(offsets[4], object.motivo);
  writer.writeString(offsets[5], object.numeroCanastaDestino);
  writer.writeString(offsets[6], object.productoId);
}

DevolucionModel _devolucionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DevolucionModel();
  object.cantidad = reader.readLong(offsets[0]);
  object.facturaId = reader.readString(offsets[1]);
  object.fechaDevolucion = reader.readDateTime(offsets[2]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[3]);
  object.motivo = reader.readString(offsets[4]);
  object.numeroCanastaDestino = reader.readString(offsets[5]);
  object.productoId = reader.readString(offsets[6]);
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
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
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
}

extension DevolucionModelQueryFilter
    on QueryBuilder<DevolucionModel, DevolucionModel, QFilterCondition> {
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
      numeroCanastaDestinoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numeroCanastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      numeroCanastaDestinoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'numeroCanastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      numeroCanastaDestinoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'numeroCanastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      numeroCanastaDestinoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'numeroCanastaDestino',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      numeroCanastaDestinoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'numeroCanastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      numeroCanastaDestinoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'numeroCanastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      numeroCanastaDestinoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'numeroCanastaDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      numeroCanastaDestinoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'numeroCanastaDestino',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      numeroCanastaDestinoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numeroCanastaDestino',
        value: '',
      ));
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterFilterCondition>
      numeroCanastaDestinoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'numeroCanastaDestino',
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
      sortByNumeroCanastaDestino() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCanastaDestino', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      sortByNumeroCanastaDestinoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCanastaDestino', Sort.desc);
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
      thenByNumeroCanastaDestino() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCanastaDestino', Sort.asc);
    });
  }

  QueryBuilder<DevolucionModel, DevolucionModel, QAfterSortBy>
      thenByNumeroCanastaDestinoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCanastaDestino', Sort.desc);
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
      distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
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
      distinctByNumeroCanastaDestino({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numeroCanastaDestino',
          caseSensitive: caseSensitive);
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

  QueryBuilder<DevolucionModel, int, QQueryOperations> cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
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

  QueryBuilder<DevolucionModel, String, QQueryOperations>
      numeroCanastaDestinoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroCanastaDestino');
    });
  }

  QueryBuilder<DevolucionModel, String, QQueryOperations> productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }
}
