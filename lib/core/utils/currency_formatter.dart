String formatCOP(double precio) {
  final valorEntero = precio.toInt();
  final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final formateado = valorEntero.toString().replaceAllMapped(reg, (m) => '${m[1]}.');
  return '\$ $formateado COP';
}
