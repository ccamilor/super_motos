// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'factura_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFacturaModelCollection on Isar {
  IsarCollection<FacturaModel> get facturaModels => this.collection();
}

const FacturaModelSchema = CollectionSchema(
  name: r'FacturaModel',
  id: -6748147298321532866,
  properties: {
    r'clienteId': PropertySchema(
      id: 0,
      name: r'clienteId',
      type: IsarType.long,
    ),
    r'detalles': PropertySchema(
      id: 1,
      name: r'detalles',
      type: IsarType.objectList,
      target: r'DetalleFacturaModel',
    ),
    r'fecha': PropertySchema(
      id: 2,
      name: r'fecha',
      type: IsarType.dateTime,
    ),
    r'latitudVenta': PropertySchema(
      id: 3,
      name: r'latitudVenta',
      type: IsarType.double,
    ),
    r'longitudVenta': PropertySchema(
      id: 4,
      name: r'longitudVenta',
      type: IsarType.double,
    ),
    r'tipoPago': PropertySchema(
      id: 5,
      name: r'tipoPago',
      type: IsarType.string,
    ),
    r'total': PropertySchema(
      id: 6,
      name: r'total',
      type: IsarType.double,
    ),
    r'vendedorId': PropertySchema(
      id: 7,
      name: r'vendedorId',
      type: IsarType.long,
    )
  },
  estimateSize: _facturaModelEstimateSize,
  serialize: _facturaModelSerialize,
  deserialize: _facturaModelDeserialize,
  deserializeProp: _facturaModelDeserializeProp,
  idName: r'numeroFactura',
  indexes: {},
  links: {},
  embeddedSchemas: {r'DetalleFacturaModel': DetalleFacturaModelSchema},
  getId: _facturaModelGetId,
  getLinks: _facturaModelGetLinks,
  attach: _facturaModelAttach,
  version: '3.1.0+1',
);

int _facturaModelEstimateSize(
  FacturaModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.detalles;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[DetalleFacturaModel]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += DetalleFacturaModelSchema.estimateSize(
              value, offsets, allOffsets);
        }
      }
    }
  }
  bytesCount += 3 + object.tipoPago.length * 3;
  return bytesCount;
}

void _facturaModelSerialize(
  FacturaModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.clienteId);
  writer.writeObjectList<DetalleFacturaModel>(
    offsets[1],
    allOffsets,
    DetalleFacturaModelSchema.serialize,
    object.detalles,
  );
  writer.writeDateTime(offsets[2], object.fecha);
  writer.writeDouble(offsets[3], object.latitudVenta);
  writer.writeDouble(offsets[4], object.longitudVenta);
  writer.writeString(offsets[5], object.tipoPago);
  writer.writeDouble(offsets[6], object.total);
  writer.writeLong(offsets[7], object.vendedorId);
}

FacturaModel _facturaModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FacturaModel();
  object.clienteId = reader.readLong(offsets[0]);
  object.detalles = reader.readObjectList<DetalleFacturaModel>(
    offsets[1],
    DetalleFacturaModelSchema.deserialize,
    allOffsets,
    DetalleFacturaModel(),
  );
  object.fecha = reader.readDateTime(offsets[2]);
  object.latitudVenta = reader.readDoubleOrNull(offsets[3]);
  object.longitudVenta = reader.readDoubleOrNull(offsets[4]);
  object.numeroFactura = id;
  object.tipoPago = reader.readString(offsets[5]);
  object.total = reader.readDouble(offsets[6]);
  object.vendedorId = reader.readLong(offsets[7]);
  return object;
}

P _facturaModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readObjectList<DetalleFacturaModel>(
        offset,
        DetalleFacturaModelSchema.deserialize,
        allOffsets,
        DetalleFacturaModel(),
      )) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _facturaModelGetId(FacturaModel object) {
  return object.numeroFactura;
}

List<IsarLinkBase<dynamic>> _facturaModelGetLinks(FacturaModel object) {
  return [];
}

void _facturaModelAttach(
    IsarCollection<dynamic> col, Id id, FacturaModel object) {
  object.numeroFactura = id;
}

extension FacturaModelQueryWhereSort
    on QueryBuilder<FacturaModel, FacturaModel, QWhere> {
  QueryBuilder<FacturaModel, FacturaModel, QAfterWhere> anyNumeroFactura() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FacturaModelQueryWhere
    on QueryBuilder<FacturaModel, FacturaModel, QWhereClause> {
  QueryBuilder<FacturaModel, FacturaModel, QAfterWhereClause>
      numeroFacturaEqualTo(Id numeroFactura) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: numeroFactura,
        upper: numeroFactura,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterWhereClause>
      numeroFacturaNotEqualTo(Id numeroFactura) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: numeroFactura, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(
                  lower: numeroFactura, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(
                  lower: numeroFactura, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: numeroFactura, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterWhereClause>
      numeroFacturaGreaterThan(Id numeroFactura, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: numeroFactura, includeLower: include),
      );
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterWhereClause>
      numeroFacturaLessThan(Id numeroFactura, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: numeroFactura, includeUpper: include),
      );
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterWhereClause>
      numeroFacturaBetween(
    Id lowerNumeroFactura,
    Id upperNumeroFactura, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerNumeroFactura,
        includeLower: includeLower,
        upper: upperNumeroFactura,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FacturaModelQueryFilter
    on QueryBuilder<FacturaModel, FacturaModel, QFilterCondition> {
  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      clienteIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteId',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      clienteIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clienteId',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      clienteIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clienteId',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      clienteIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clienteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      detallesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'detalles',
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      detallesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'detalles',
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      detallesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detalles',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      detallesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detalles',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      detallesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detalles',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      detallesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detalles',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      detallesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detalles',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      detallesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detalles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition> fechaEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      fechaGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition> fechaLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition> fechaBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fecha',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      latitudVentaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'latitudVenta',
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      latitudVentaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'latitudVenta',
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      latitudVentaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitudVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      latitudVentaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitudVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      latitudVentaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitudVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      latitudVentaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitudVenta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      longitudVentaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longitudVenta',
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      longitudVentaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longitudVenta',
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      longitudVentaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitudVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      longitudVentaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitudVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      longitudVentaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitudVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      longitudVentaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitudVenta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      numeroFacturaEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numeroFactura',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      numeroFacturaGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'numeroFactura',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      numeroFacturaLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'numeroFactura',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      numeroFacturaBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'numeroFactura',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      tipoPagoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      tipoPagoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      tipoPagoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      tipoPagoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoPago',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      tipoPagoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      tipoPagoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      tipoPagoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      tipoPagoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoPago',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      tipoPagoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoPago',
        value: '',
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      tipoPagoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoPago',
        value: '',
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition> totalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      totalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition> totalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition> totalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'total',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      vendedorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vendedorId',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      vendedorIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vendedorId',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      vendedorIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vendedorId',
        value: value,
      ));
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      vendedorIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vendedorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FacturaModelQueryObject
    on QueryBuilder<FacturaModel, FacturaModel, QFilterCondition> {
  QueryBuilder<FacturaModel, FacturaModel, QAfterFilterCondition>
      detallesElement(FilterQuery<DetalleFacturaModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'detalles');
    });
  }
}

extension FacturaModelQueryLinks
    on QueryBuilder<FacturaModel, FacturaModel, QFilterCondition> {}

extension FacturaModelQuerySortBy
    on QueryBuilder<FacturaModel, FacturaModel, QSortBy> {
  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> sortByClienteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> sortByClienteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> sortByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> sortByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> sortByLatitudVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitudVenta', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy>
      sortByLatitudVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitudVenta', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> sortByLongitudVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitudVenta', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy>
      sortByLongitudVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitudVenta', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> sortByTipoPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPago', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> sortByTipoPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPago', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> sortByVendedorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vendedorId', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy>
      sortByVendedorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vendedorId', Sort.desc);
    });
  }
}

extension FacturaModelQuerySortThenBy
    on QueryBuilder<FacturaModel, FacturaModel, QSortThenBy> {
  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByClienteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByClienteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByLatitudVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitudVenta', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy>
      thenByLatitudVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitudVenta', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByLongitudVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitudVenta', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy>
      thenByLongitudVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitudVenta', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByNumeroFactura() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroFactura', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy>
      thenByNumeroFacturaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroFactura', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByTipoPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPago', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByTipoPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPago', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy> thenByVendedorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vendedorId', Sort.asc);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QAfterSortBy>
      thenByVendedorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vendedorId', Sort.desc);
    });
  }
}

extension FacturaModelQueryWhereDistinct
    on QueryBuilder<FacturaModel, FacturaModel, QDistinct> {
  QueryBuilder<FacturaModel, FacturaModel, QDistinct> distinctByClienteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteId');
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QDistinct> distinctByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fecha');
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QDistinct> distinctByLatitudVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitudVenta');
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QDistinct>
      distinctByLongitudVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitudVenta');
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QDistinct> distinctByTipoPago(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoPago', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QDistinct> distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }

  QueryBuilder<FacturaModel, FacturaModel, QDistinct> distinctByVendedorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vendedorId');
    });
  }
}

extension FacturaModelQueryProperty
    on QueryBuilder<FacturaModel, FacturaModel, QQueryProperty> {
  QueryBuilder<FacturaModel, int, QQueryOperations> numeroFacturaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroFactura');
    });
  }

  QueryBuilder<FacturaModel, int, QQueryOperations> clienteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteId');
    });
  }

  QueryBuilder<FacturaModel, List<DetalleFacturaModel>?, QQueryOperations>
      detallesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'detalles');
    });
  }

  QueryBuilder<FacturaModel, DateTime, QQueryOperations> fechaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fecha');
    });
  }

  QueryBuilder<FacturaModel, double?, QQueryOperations> latitudVentaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitudVenta');
    });
  }

  QueryBuilder<FacturaModel, double?, QQueryOperations>
      longitudVentaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitudVenta');
    });
  }

  QueryBuilder<FacturaModel, String, QQueryOperations> tipoPagoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoPago');
    });
  }

  QueryBuilder<FacturaModel, double, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }

  QueryBuilder<FacturaModel, int, QQueryOperations> vendedorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vendedorId');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const DetalleFacturaModelSchema = Schema(
  name: r'DetalleFacturaModel',
  id: 4795833135690052401,
  properties: {
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.long,
    ),
    r'precioUnitario': PropertySchema(
      id: 1,
      name: r'precioUnitario',
      type: IsarType.double,
    ),
    r'productoId': PropertySchema(
      id: 2,
      name: r'productoId',
      type: IsarType.long,
    ),
    r'subtotal': PropertySchema(
      id: 3,
      name: r'subtotal',
      type: IsarType.double,
    )
  },
  estimateSize: _detalleFacturaModelEstimateSize,
  serialize: _detalleFacturaModelSerialize,
  deserialize: _detalleFacturaModelDeserialize,
  deserializeProp: _detalleFacturaModelDeserializeProp,
);

int _detalleFacturaModelEstimateSize(
  DetalleFacturaModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _detalleFacturaModelSerialize(
  DetalleFacturaModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cantidad);
  writer.writeDouble(offsets[1], object.precioUnitario);
  writer.writeLong(offsets[2], object.productoId);
  writer.writeDouble(offsets[3], object.subtotal);
}

DetalleFacturaModel _detalleFacturaModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DetalleFacturaModel();
  object.cantidad = reader.readLongOrNull(offsets[0]);
  object.precioUnitario = reader.readDoubleOrNull(offsets[1]);
  object.productoId = reader.readLongOrNull(offsets[2]);
  object.subtotal = reader.readDoubleOrNull(offsets[3]);
  return object;
}

P _detalleFacturaModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension DetalleFacturaModelQueryFilter on QueryBuilder<DetalleFacturaModel,
    DetalleFacturaModel, QFilterCondition> {
  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      cantidadIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cantidad',
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      cantidadIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cantidad',
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      cantidadEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidad',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      cantidadGreaterThan(
    int? value, {
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

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      cantidadLessThan(
    int? value, {
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

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      cantidadBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      precioUnitarioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'precioUnitario',
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      precioUnitarioIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'precioUnitario',
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      precioUnitarioEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      precioUnitarioGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      precioUnitarioLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      precioUnitarioBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioUnitario',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      productoIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productoId',
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      productoIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productoId',
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      productoIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      productoIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      productoIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      productoIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      subtotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subtotal',
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      subtotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subtotal',
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      subtotalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      subtotalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      subtotalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleFacturaModel, DetalleFacturaModel, QAfterFilterCondition>
      subtotalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension DetalleFacturaModelQueryObject on QueryBuilder<DetalleFacturaModel,
    DetalleFacturaModel, QFilterCondition> {}
