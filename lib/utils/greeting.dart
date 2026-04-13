String swahiliTimeGreeting() {
  final h = DateTime.now().hour;
  if (h >= 5 && h < 12) {
    return 'HABARI ZA ASUBUHI';
  }
  if (h >= 12 && h < 15) {
    return 'HABARI ZA MCHANA';
  }
  if (h >= 15 && h < 19) {
    return 'HABARI ZA JIONI';
  }
  return 'HABARI ZA USIKU';
}
