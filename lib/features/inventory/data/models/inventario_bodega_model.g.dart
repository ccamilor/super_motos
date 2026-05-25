// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventario_bodega_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventarioBodegaModelCollection on Isar {
  IsarCollection<InventarioBodegaModel> get inventarioBodegaModels =>
      this.collection();
}

const InventarioBodegaModelSchema = CollectionSchema(
  name: r'InventarioBodegaModel',
  id: -2830178846918517174,
  properties: {
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.long,
    ),
    r'productoId': PropertySchema(
      id: 1,
      name: r'productoId',
      type: IsarType.long,
    )
  },
  estimateSize: _inventarioBodegaModelEstimateSize,
  serialize: _inventarioBodegaModelSerialize,
  deserialize: _inventarioBodegaModelDeserialize,
  deserializeProp: _inventarioBodegaModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _inventarioBodegaModelGetId,
  getLinks: _inventarioBodegaModelGetLinks,
  attach: _inventarioBodegaModelAttach,
  version: '3.1.0+1',
);

int _inventarioBodegaModelEstimateSize(
  InventarioBodegaModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _inventarioBodegaModelSerialize(
  InventarioBodegaModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cantidad);
  writer.writeLong(offsets[1], object.productoId);
}

InventarioBodegaModel _inventarioBodegaModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventarioBodegaModel();
  object.cantidad = reader.readLong(offsets[0]);
  object.id = id;
  object.productoId = reader.readLong(offsets[1]);
  return object;
}

P _inventarioBodegaModelDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inventarioBodegaModelGetId(InventarioBodegaModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventarioBodegaModelGetLinks(
    InventarioBodegaModel object) {
  return [];
}

void _inventarioBodegaModelAttach(
    IsarCollection<dynamic> col, Id id, InventarioBodegaModel object) {
  object.id = id;
}

extension InventarioBodegaModelQueryWhereSort
    on QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QWhere> {
  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InventarioBodegaModelQueryWhere on QueryBuilder<InventarioBodegaModel,
    InventarioBodegaModel, QWhereClause> {
  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterWhereClause>
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

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterWhereClause>
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

extension InventarioBodegaModelQueryFilter on QueryBuilder<
    InventarioBodegaModel, InventarioBodegaModel, QFilterCondition> {
  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
      QAfterFilterCondition> cantidadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidad',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
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

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
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

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
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

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
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

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
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

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
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

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
      QAfterFilterCondition> productoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
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

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
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

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel,
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

extension InventarioBodegaModelQueryObject on QueryBuilder<
    InventarioBodegaModel, InventarioBodegaModel, QFilterCondition> {}

extension InventarioBodegaModelQueryLinks on QueryBuilder<InventarioBodegaModel,
    InventarioBodegaModel, QFilterCondition> {}

extension InventarioBodegaModelQuerySortBy
    on QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QSortBy> {
  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterSortBy>
      sortByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterSortBy>
      sortByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterSortBy>
      sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterSortBy>
      sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }
}

extension InventarioBodegaModelQuerySortThenBy
    on QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QSortThenBy> {
  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterSortBy>
      thenByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterSortBy>
      thenByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterSortBy>
      thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QAfterSortBy>
      thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }
}

extension InventarioBodegaModelQueryWhereDistinct
    on QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QDistinct> {
  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QDistinct>
      distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<InventarioBodegaModel, InventarioBodegaModel, QDistinct>
      distinctByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId');
    });
  }
}

extension InventarioBodegaModelQueryProperty on QueryBuilder<
    InventarioBodegaModel, InventarioBodegaModel, QQueryProperty> {
  QueryBuilder<InventarioBodegaModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InventarioBodegaModel, int, QQueryOperations>
      cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<InventarioBodegaModel, int, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }
}
