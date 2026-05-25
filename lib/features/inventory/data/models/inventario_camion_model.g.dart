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
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.long,
    ),
    r'numeroCanasta': PropertySchema(
      id: 1,
      name: r'numeroCanasta',
      type: IsarType.long,
    ),
    r'productoId': PropertySchema(
      id: 2,
      name: r'productoId',
      type: IsarType.long,
    )
  },
  estimateSize: _inventarioCamionModelEstimateSize,
  serialize: _inventarioCamionModelSerialize,
  deserialize: _inventarioCamionModelDeserialize,
  deserializeProp: _inventarioCamionModelDeserializeProp,
  idName: r'id',
  indexes: {},
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
  return bytesCount;
}

void _inventarioCamionModelSerialize(
  InventarioCamionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cantidad);
  writer.writeLong(offsets[1], object.numeroCanasta);
  writer.writeLong(offsets[2], object.productoId);
}

InventarioCamionModel _inventarioCamionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventarioCamionModel();
  object.cantidad = reader.readLong(offsets[0]);
  object.id = id;
  object.numeroCanasta = reader.readLong(offsets[1]);
  object.productoId = reader.readLong(offsets[2]);
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
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
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
}

extension InventarioCamionModelQueryFilter on QueryBuilder<
    InventarioCamionModel, InventarioCamionModel, QFilterCondition> {
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
      QAfterFilterCondition> numeroCanastaEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numeroCanasta',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> numeroCanastaGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'numeroCanasta',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> numeroCanastaLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'numeroCanasta',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> numeroCanastaBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'numeroCanasta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdGreaterThan(
    int value, {
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

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdLessThan(
    int value, {
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

  QueryBuilder<InventarioCamionModel, InventarioCamionModel,
      QAfterFilterCondition> productoIdBetween(
    int lower,
    int upper, {
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
}

extension InventarioCamionModelQueryObject on QueryBuilder<
    InventarioCamionModel, InventarioCamionModel, QFilterCondition> {}

extension InventarioCamionModelQueryLinks on QueryBuilder<InventarioCamionModel,
    InventarioCamionModel, QFilterCondition> {}

extension InventarioCamionModelQuerySortBy
    on QueryBuilder<InventarioCamionModel, InventarioCamionModel, QSortBy> {
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
      sortByNumeroCanasta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCanasta', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      sortByNumeroCanastaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCanasta', Sort.desc);
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
      thenByNumeroCanasta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCanasta', Sort.asc);
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QAfterSortBy>
      thenByNumeroCanastaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCanasta', Sort.desc);
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
      distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QDistinct>
      distinctByNumeroCanasta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numeroCanasta');
    });
  }

  QueryBuilder<InventarioCamionModel, InventarioCamionModel, QDistinct>
      distinctByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId');
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

  QueryBuilder<InventarioCamionModel, int, QQueryOperations>
      cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<InventarioCamionModel, int, QQueryOperations>
      numeroCanastaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroCanasta');
    });
  }

  QueryBuilder<InventarioCamionModel, int, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }
}
