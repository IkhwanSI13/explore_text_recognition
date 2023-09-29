/// For transaction date
var regDateStrip = RegExp('\\d{2}-\\d{2}-\\d{4}');
var regDateSlash = RegExp('\\d{2}/\\d{2}/\\d{4}');
var regDateLongMonth = RegExp('\\d{2} [a-zA-Z]{3,8} \\d{4}');
var regDateDot = RegExp('\\d{2}[.]\\d{2}[.]\\d{2}');

List<RegExp> regexDates = [
  regDateStrip,
  regDateSlash,
  regDateLongMonth,
  regDateDot
];

/// For transaction amount
var regCurrency = RegExp('\\d{1,3}(?:(.)|(,))\\d{1,3}(?:(.)|(,))\\d{1,3}');

List<RegExp> regexAmounts = [
  regCurrency,
];