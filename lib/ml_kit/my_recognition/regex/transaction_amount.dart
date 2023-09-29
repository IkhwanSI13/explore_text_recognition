String check(String sample){
  print("Input: $sample");

// ^                # start of string anchor
// \$?              # optional '$'
// (?=              # only match if inner regex can match (lookahead)
//    \(.*\)          # both '(' and ')' are present
//    |               # OR
//    [^()]*$         # niether '(' or ')' are present
// )                # end of lookaheand
// \(?              # optional '('
// \d{1,3}          # match 1 to 3 digits
// (,?\d{3})?       # optionally match another 3 digits, preceeded by an optional ','
// (\.\d\d?)?       # optionally match '.' followed by 1 or 2 digits
// \)?              # optional ')'
// $                # end of string anchor

//   var regDateStrip = RegExp('\\d{3}');
//   var regDateStrip = RegExp('\\d{1,3}(?:.)');
//   var regDateStrip = RegExp('\\d{1,3}(?:.)\\d{1,3}(?:.)\\d{1,3}');

//   var regDateStrip = RegExp('\\d{1,3}(?:(.)|(,))');
//   var regDateStrip = RegExp('\\d{1,3}(?:(.)|(,))\\d{1,3}(?:(.)|(,))\\d{1,3}');
  var regDateStrip = RegExp('\\d{1,3}(?:(.)|(,))\\d{1,3}(?:(.)|(,))\\d{1,3}');

//   var regDateStrip = RegExp('\\d{1,3}(?:(.)|(,))\\d{1,3}(?:(.)|(,))\\d{1,3}');
//   var regDateStrip = RegExp(r'^(S?\$|\₩|Rp|\¥|\€|\₹|\₽|fr|R$|R)?[ ]?[-]?([0-9]{1,3}[,.]([0-9]{3}[,.])*[0-9]{3}|[0-9]+)([,.][0-9]{1,2})?( ?(USD?|AUD|NZD|CAD|CHF|GBP|CNY|EUR|JPY|IDR|MXN|NOK|KRW|TRY|INR|RUB|BRL|ZAR|SGD|MYR))?$');
//   var regDateStrip = RegExp(r'^([0-9]{1,3}[,.]([0-9]{3}[,.])*[0-9]{3}|[0-9]+)?$');

//   var regDateStrip = RegExp(r'[0-9]{1,3}[,.]*[0-9]{3}|[0-9]+');
//   var regDateStrip = RegExp(r'[0-9]{1,3}[,.]*[0-9]{3}|[0-9]+[,.]*[0-9]{3}|[0-9]+');
//   var regDateStrip = RegExp(r'[0-9]{1,3}[,.]([0-9]{3}|[0-9])([,.][0-9]{3}|[0-9])');

//   var regDateStrip = RegExp('\\d{1,3}(?:(.)|(,))(?:\s+)\\d{1,3}');

  //(?=.*?\d)^\$?(([1-9]\d{0,2}(,\d{3})*)|\d+)?(\.\d{1,2})?$
//   var regDateStrip = RegExp('\\d{1,3}(?:,\\d{3})');

//   var regDateStrip = RegExp('\\d{1,3}(?=(\.)|(\,))');
//   var regDateStrip = RegExp('\\d{1,3}\(?\\d{1,3}(,?\\d{3})?\)?');
//   var regDateStrip = RegExp(r"^\$?(?=\(.*\)|[^()]*$)\(?\d{1,3}(,?\d{3})?(\.\d\d?)?\)?$");
//   var regDateSlace = RegExp('\\d{2}/\\d{2}/\\d{4}');
//   var regDateLongMonth = RegExp('\\d{2} [a-zA-Z]{3,8} \\d{4}');
//   var regDateDot = RegExp('\\d{2}.\\d{2}.\\d{2}');

  List<RegExp> regexs = [
    regDateStrip,
//     regDateSlace,
//     regDateLongMonth,
//     regDateDot
  ];

  for(var regex in regexs){
    var convert = regex.firstMatch(sample)?.group(0);
//     var convert3 = regex.

//     var matchs = regex.allMatches(sample);
//     print("number of all match : ${matchs.length}");
//     if(matchs.length != 0){
//       print("number of all match last : ${matchs.last.group(0)}");
//     }

    if(convert!=null){
      return "Output: $convert \n";
    }
  }

  return "Output: Bukan date \n";
}

void main() {

  var sample1 = "222.500";
  var sample2 = "Total Rp. = 131,000";
  var sample3 = "TOTAL: 9,640,000";
  var sample4 = "37,000";
  var sample5 = "Biaya Parkir: Rp 18.000";
  var sample6 = "lorem ipsum dolor";
  var sample7 = "halo bandung 500 bandung mantap";
  var sample8 = "Rp.500.123.345 0232";
  var sample9 = "200 Rp.500.123.345 0232";
  var sample10 = "200 500 0232";

  print(check(sample1));
  print(check(sample2));
  print(check(sample3));
  print(check(sample4));
  print(check(sample5));
  print(check(sample6));
  print(check(sample7));
  print(check(sample8));
  print(check(sample9));
  print(check(sample10));
}
