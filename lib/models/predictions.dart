class Prediction {
  String placeId;
  String mainText;
  String secondryText;

  Prediction({
    this.placeId,
    this.mainText,
    this.secondryText
});

  Prediction.fromJson(Map<String,dynamic> json) {
    placeId = json["place_id"];
    mainText = json["structured_formatting"]["main_text"];
    secondryText = json["structured_formatting"]["secondary_text"];
  }

}