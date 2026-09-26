class CrudModel {
  String? name;
  String? title;
  String? description;
  String? sId;
  String? createdAt;
  String? updatedAt;

  CrudModel(
      {this.name,
      this.title,
      this.description,
      this.sId,
      this.createdAt,
      this.updatedAt});

  CrudModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    title = json['title'];
    description = json['description'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['title'] = this.title;
    data['description'] = this.description;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
