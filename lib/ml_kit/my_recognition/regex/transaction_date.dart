import 'regex.dart';

String check(String sample){
  print("======== $sample ========");

  for(var regex in regexDates){
    var convert = regex.firstMatch(sample)?.group(0);
    if(convert!=null){
      return "Output: $convert";
    }
  }

  return "Output: Bukan date";
}

void main() {
  var sample1 = "04-03-2023";
  var sample2 = "06-12-2022 20:10 HENGKI";
  var sample3 = "KELUAR : 01/06/2021 21:55:03";
  var sample4 = "JAINUL, POSC1, 01-04-2021";
  var sample5 = ": 10 Jan 2023 09:20:49- MO3";
  var sample6 = "lorem ipsum dolor";
  var sample7 = "22.08.19-18:36";
  var sample8 = "Telp.(0752)34956 Delivery. 085217610505";

  print(check(sample1));
  print(check(sample2));
  print(check(sample3));
  print(check(sample4));
  print(check(sample5));
  print(check(sample6));
  print(check(sample7));
  print(check(sample8));
}
