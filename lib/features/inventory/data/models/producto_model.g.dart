// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producto_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProductoModelCollection on Isar {
  IsarCollection<ProductoModel> get productoModels => this.collection();
}

const ProductoModelSchema = CollectionSchema(
  name: r'ProductoModel',
  id: -8283790178398363742,
  properties: {
    r'imagenUrl': PropertySchema(
      id: 0,
      name: r'imagenUrl',
      type: IsarType.string,
    ),
    r'isOriginal': PropertySchema(
      id: 1,
      name: r'isOriginal',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 2,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'motosCompatibles': PropertySchema(
      id: 3,
      name: r'motosCompatibles',
      type: IsarType.string,
    ),
    r'nombre': PropertySchema(
      id: 4,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'precio': PropertySchema(
      id: 5,
      name: r'precio',
      type: IsarType.double,
    ),
    r'stockMinimo': PropertySchema(
      id: 6,
      name: r'stockMinimo',
      type: IsarType.long,
    )
  },
  estimateSize: _productoModelEstimateSize,
  serialize: _productoModelSerialize,
  deserialize: _productoModelDeserialize,
  deserializeProp: _productoModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _productoModelGetId,
  getLinks: _productoModelGetLinks,
  attach: _productoModelAttach,
  version: '3.1.0+1',
);

int _productoModelEstimateSize(
  ProductoModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.imagenUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.motosCompatibles.length * 3;
  bytesCount += 3 + object.nombre.length * 3;
  return bytesCount;
}

void _productoModelSerialize(
  ProductoModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.imagenUrl);
  writer.writeBool(offsets[1], object.isOriginal);
  writer.writeBool(offsets[2], object.isSynced);
  writer.writeString(offsets[3], object.motosCompatibles);
  writer.writeString(offsets[4], object.nombre);
  writer.writeDouble(offsets[5], object.precio);
  writer.writeLong(offsets[6], object.stockMinimo);
}

ProductoModel _productoModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProductoModel();
  object.id = id;
  object.imagenUrl = reader.readStringOrNull(offsets[0]);
  object.isOriginal = reader.readBool(offsets[1]);
  object.isSynced = reader.readBool(offsets[2]);
  object.motosCompatibles = reader.readString(offsets[3]);
  object.nombre = reader.readString(offsets[4]);
  object.precio = reader.readDouble(offsets[5]);
  object.stockMinimo = reader.readLong(offsets[6]);
  return object;
}

P _productoModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _productoModelGetId(ProductoModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _productoModelGetLinks(ProductoModel object) {
  return [];
}

void _productoModelAttach(
    IsarCollection<dynamic> col, Id id, ProductoModel object) {
  object.id = id;
}

extension ProductoModelQueryWhereSort
    on QueryBuilder<ProductoModel, ProductoModel, QWhere> {
  QueryBuilder<ProductoModel, ProductoModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProductoModelQueryWhere
    on QueryBuilder<ProductoModel, ProductoModel, QWhereClause> {
  QueryBuilder<ProductoModel, ProductoModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ProductoModel, ProductoModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterWhereClause> idBetween(
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

extension ProductoModelQueryFilter
    on QueryBuilder<ProductoModel, ProductoModel, QFilterCondition> {
  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
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

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imagenUrl',
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imagenUrl',
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagenUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagenUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagenUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      imagenUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagenUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      isOriginalEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOriginal',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      motosCompatiblesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motosCompatibles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      motosCompatiblesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motosCompatibles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      motosCompatiblesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motosCompatibles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      motosCompatiblesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motosCompatibles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      motosCompatiblesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motosCompatibles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      motosCompatiblesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motosCompatibles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      motosCompatiblesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motosCompatibles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      motosCompatiblesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motosCompatibles',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      motosCompatiblesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motosCompatibles',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      motosCompatiblesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motosCompatibles',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      nombreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      nombreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      nombreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      nombreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      nombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      nombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      nombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      nombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      precioEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precio',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      precioGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precio',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      precioLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precio',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      precioBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precio',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      stockMinimoEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stockMinimo',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      stockMinimoGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stockMinimo',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      stockMinimoLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stockMinimo',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterFilterCondition>
      stockMinimoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stockMinimo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProductoModelQueryObject
    on QueryBuilder<ProductoModel, ProductoModel, QFilterCondition> {}

extension ProductoModelQueryLinks
    on QueryBuilder<ProductoModel, ProductoModel, QFilterCondition> {}

extension ProductoModelQuerySortBy
    on QueryBuilder<ProductoModel, ProductoModel, QSortBy> {
  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> sortByImagenUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      sortByImagenUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> sortByIsOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOriginal', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      sortByIsOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOriginal', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      sortByMotosCompatibles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motosCompatibles', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      sortByMotosCompatiblesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motosCompatibles', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> sortByPrecio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precio', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> sortByPrecioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precio', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> sortByStockMinimo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockMinimo', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      sortByStockMinimoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockMinimo', Sort.desc);
    });
  }
}

extension ProductoModelQuerySortThenBy
    on QueryBuilder<ProductoModel, ProductoModel, QSortThenBy> {
  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> thenByImagenUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      thenByImagenUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> thenByIsOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOriginal', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      thenByIsOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOriginal', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      thenByMotosCompatibles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motosCompatibles', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      thenByMotosCompatiblesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motosCompatibles', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> thenByPrecio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precio', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> thenByPrecioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precio', Sort.desc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy> thenByStockMinimo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockMinimo', Sort.asc);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QAfterSortBy>
      thenByStockMinimoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockMinimo', Sort.desc);
    });
  }
}

extension ProductoModelQueryWhereDistinct
    on QueryBuilder<ProductoModel, ProductoModel, QDistinct> {
  QueryBuilder<ProductoModel, ProductoModel, QDistinct> distinctByImagenUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagenUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QDistinct> distinctByIsOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOriginal');
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QDistinct>
      distinctByMotosCompatibles({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motosCompatibles',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QDistinct> distinctByNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QDistinct> distinctByPrecio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precio');
    });
  }

  QueryBuilder<ProductoModel, ProductoModel, QDistinct>
      distinctByStockMinimo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stockMinimo');
    });
  }
}

extension ProductoModelQueryProperty
    on QueryBuilder<ProductoModel, ProductoModel, QQueryProperty> {
  QueryBuilder<ProductoModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProductoModel, String?, QQueryOperations> imagenUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagenUrl');
    });
  }

  QueryBuilder<ProductoModel, bool, QQueryOperations> isOriginalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOriginal');
    });
  }

  QueryBuilder<ProductoModel, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<ProductoModel, String, QQueryOperations>
      motosCompatiblesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motosCompatibles');
    });
  }

  QueryBuilder<ProductoModel, String, QQueryOperations> nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<ProductoModel, double, QQueryOperations> precioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precio');
    });
  }

  QueryBuilder<ProductoModel, int, QQueryOperations> stockMinimoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stockMinimo');
    });
  }
}
