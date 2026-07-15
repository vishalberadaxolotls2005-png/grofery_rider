class ReturnOrderModel {
  bool? success;
  String? message;
  Data? data;

  ReturnOrderModel({this.success, this.message, this.data});

  ReturnOrderModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  int? from;
  int? to;
  List<Pickups>? pickups;

  Data(
      {this.currentPage,
        this.lastPage,
        this.perPage,
        this.total,
        this.from,
        this.to,
        this.pickups});

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
    from = json['from'];
    to = json['to'];
    if (json['pickups'] != null) {
      pickups = <Pickups>[];
      json['pickups'].forEach((v) {
        pickups!.add(Pickups.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['total'] = total;
    data['from'] = from;
    data['to'] = to;
    if (pickups != null) {
      data['pickups'] = pickups!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pickups {
  int? id;
  int? orderId;
  int? orderItemId;
  int? userId;
  int? sellerId;
  int? storeId;
  int? deliveryBoyId;
  String? reason;
  String? refundAmount;
  String? sellerComment;
  String? pickupStatus;
  String? returnStatus;
  String? sellerApprovedAt;
  String? pickedUpAt;
  String? receivedAt;
  String? refundProcessedAt;
  List<String>? images;
  DeliveryRoute? deliveryRoute;
  Earnings? earnings;
  DeliveryZone? deliveryZone;
  Order? order;
  OrderItem? orderItem;
  Store? store;
  User? user;
  String? createdAt;
  String? updatedAt;

  Pickups(
      {this.id,
        this.orderId,
        this.orderItemId,
        this.userId,
        this.sellerId,
        this.storeId,
        this.deliveryBoyId,
        this.reason,
        this.refundAmount,
        this.sellerComment,
        this.pickupStatus,
        this.returnStatus,
        this.sellerApprovedAt,
        this.pickedUpAt,
        this.receivedAt,
        this.refundProcessedAt,
        this.images,
        this.deliveryRoute,
        this.earnings,
        this.deliveryZone,
        this.order,
        this.orderItem,
        this.store,
        this.user,
        this.createdAt,
        this.updatedAt});

  Pickups.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    orderItemId = json['order_item_id'];
    userId = json['user_id'];
    sellerId = json['seller_id'];
    storeId = json['store_id'];
    deliveryBoyId = json['delivery_boy_id'];
    reason = json['reason'];
    refundAmount = json['refund_amount'];
    sellerComment = json['seller_comment'];
    pickupStatus = json['pickup_status'];
    returnStatus = json['return_status'];
    sellerApprovedAt = json['seller_approved_at'];
    pickedUpAt = json['picked_up_at'];
    receivedAt = json['received_at'];
    refundProcessedAt = json['refund_processed_at'];
    images = json['images'].cast<String>();
    deliveryRoute = json['delivery_route'] != null
        ? DeliveryRoute.fromJson(json['delivery_route'])
        : null;
    earnings = json['earnings'] != null
        ? Earnings.fromJson(json['earnings'])
        : null;
    deliveryZone = json['delivery_zone'] != null
        ? DeliveryZone.fromJson(json['delivery_zone'])
        : null;
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
    orderItem = json['order_item'] != null
        ? OrderItem.fromJson(json['order_item'])
        : null;
    store = json['store'] != null ? Store.fromJson(json['store']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['order_item_id'] = orderItemId;
    data['user_id'] = userId;
    data['seller_id'] = sellerId;
    data['store_id'] = storeId;
    data['delivery_boy_id'] = deliveryBoyId;
    data['reason'] = reason;
    data['refund_amount'] = refundAmount;
    data['seller_comment'] = sellerComment;
    data['pickup_status'] = pickupStatus;
    data['return_status'] = returnStatus;
    data['seller_approved_at'] = sellerApprovedAt;
    data['picked_up_at'] = pickedUpAt;
    data['received_at'] = receivedAt;
    data['refund_processed_at'] = refundProcessedAt;
    data['images'] = images;
    if (deliveryRoute != null) {
      data['delivery_route'] = deliveryRoute!.toJson();
    }
    if (earnings != null) {
      data['earnings'] = earnings!.toJson();
    }
    if (deliveryZone != null) {
      data['delivery_zone'] = deliveryZone!.toJson();
    }
    if (order != null) {
      data['order'] = order!.toJson();
    }
    if (orderItem != null) {
      data['order_item'] = orderItem!.toJson();
    }
    if (store != null) {
      data['store'] = store!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class DeliveryRoute {
  num? totalDistance;
  List<int>? route;
  List<RouteDetails>? routeDetails;

  DeliveryRoute({this.totalDistance, this.route, this.routeDetails});

  DeliveryRoute.fromJson(Map<String, dynamic> json) {
    totalDistance = json['total_distance'];
    route = json['route'].cast<int>();
    if (json['route_details'] != null) {
      routeDetails = <RouteDetails>[];
      json['route_details'].forEach((v) {
        routeDetails!.add(RouteDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_distance'] = totalDistance;
    data['route'] = route;
    if (routeDetails != null) {
      data['route_details'] =
          routeDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RouteDetails {
  int? storeId;
  String? storeName;
  num? distanceFromCustomer;
  String? address;
  String? city;
  String? landmark;
  String? state;
  String? zipcode;
  String? country;
  String? countryCode;
  double? latitude;
  double? longitude;
  num? distanceFromPrevious;

  RouteDetails(
      {this.storeId,
        this.storeName,
        this.distanceFromCustomer,
        this.address,
        this.city,
        this.landmark,
        this.state,
        this.zipcode,
        this.country,
        this.countryCode,
        this.latitude,
        this.longitude,
        this.distanceFromPrevious});

  RouteDetails.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'];
    storeName = json['store_name'];
    distanceFromCustomer = json['distance_from_customer'];
    address = json['address'];
    city = json['city'];
    landmark = json['landmark'];
    state = json['state'];
    zipcode = json['zipcode'];
    country = json['country'];
    countryCode = json['country_code'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    distanceFromPrevious = json['distance_from_previous'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['distance_from_customer'] = distanceFromCustomer;
    data['address'] = address;
    data['city'] = city;
    data['landmark'] = landmark;
    data['state'] = state;
    data['zipcode'] = zipcode;
    data['country'] = country;
    data['country_code'] = countryCode;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['distance_from_previous'] = distanceFromPrevious;
    return data;
  }
}

class Earnings {
  int? total;
  Breakdown? breakdown;

  Earnings({this.total, this.breakdown});

  Earnings.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    breakdown = json['breakdown'] != null
        ? Breakdown.fromJson(json['breakdown'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    if (breakdown != null) {
      data['breakdown'] = breakdown!.toJson();
    }
    return data;
  }
}

class Breakdown {
  int? baseFee;
  int? perStorePickupFee;
  int? distanceBasedFee;
  int? perOrderIncentive;

  Breakdown(
      {this.baseFee,
        this.perStorePickupFee,
        this.distanceBasedFee,
        this.perOrderIncentive});

  Breakdown.fromJson(Map<String, dynamic> json) {
    baseFee = json['base_fee'];
    perStorePickupFee = json['per_store_pickup_fee'];
    distanceBasedFee = json['distance_based_fee'];
    perOrderIncentive = json['per_order_incentive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['base_fee'] = baseFee;
    data['per_store_pickup_fee'] = perStorePickupFee;
    data['distance_based_fee'] = distanceBasedFee;
    data['per_order_incentive'] = perOrderIncentive;
    return data;
  }
}

class DeliveryZone {
  int? id;
  String? name;

  DeliveryZone({this.id, this.name});

  DeliveryZone.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Order {
  int? id;
  String? uuid;
  String? shippingName;
  String? shippingPhone;
  String? shippingAddress1;
  String? shippingAddress2;
  String? shippingLandmark;
  String? shippingCity;
  String? shippingState;
  String? shippingZip;
  String? shippingCountry;
  String? shippingLatitude;
  String? shippingLongitude;

  Order(
      {this.id,
        this.uuid,
        this.shippingName,
        this.shippingPhone,
        this.shippingAddress1,
        this.shippingAddress2,
        this.shippingLandmark,
        this.shippingCity,
        this.shippingState,
        this.shippingZip,
        this.shippingCountry,
        this.shippingLatitude,
        this.shippingLongitude});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    shippingName = json['shipping_name'];
    shippingPhone = json['shipping_phone'];
    shippingAddress1 = json['shipping_address_1'];
    shippingAddress2 = json['shipping_address_2'];
    shippingLandmark = json['shipping_landmark'];
    shippingCity = json['shipping_city'];
    shippingState = json['shipping_state'];
    shippingZip = json['shipping_zip'];
    shippingCountry = json['shipping_country'];
    shippingLatitude = json['shipping_latitude'];
    shippingLongitude = json['shipping_longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['shipping_name'] = shippingName;
    data['shipping_phone'] = shippingPhone;
    data['shipping_address_1'] = shippingAddress1;
    data['shipping_address_2'] = shippingAddress2;
    data['shipping_landmark'] = shippingLandmark;
    data['shipping_city'] = shippingCity;
    data['shipping_state'] = shippingState;
    data['shipping_zip'] = shippingZip;
    data['shipping_country'] = shippingCountry;
    data['shipping_latitude'] = shippingLatitude;
    data['shipping_longitude'] = shippingLongitude;
    return data;
  }
}

class OrderItem {
  int? id;
  Product? product;
  Variant? variant;

  OrderItem({this.id, this.product, this.variant});

  OrderItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    product =
    json['product'] != null ? Product.fromJson(json['product']) : null;
    variant =
    json['variant'] != null ? Variant.fromJson(json['variant']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (variant != null) {
      data['variant'] = variant!.toJson();
    }
    return data;
  }
}

class Product {
  int? id;
  String? name;

  Product({this.id, this.name});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Variant {
  int? id;
  String? sku;
  String? title;

  Variant({this.id, this.sku, this.title});

  Variant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sku = json['sku'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sku'] = sku;
    data['title'] = title;
    return data;
  }
}

class Store {
  int? id;
  String? name;
  String? address;
  String? city;
  String? state;
  String? zipcode;
  String? country;
  String? latitude;
  String? longitude;

  Store(
      {this.id,
        this.name,
        this.address,
        this.city,
        this.state,
        this.zipcode,
        this.country,
        this.latitude,
        this.longitude});

  Store.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    zipcode = json['zipcode'];
    country = json['country'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['zipcode'] = zipcode;
    data['country'] = country;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? phone;
  String? email;

  User({this.id, this.name, this.phone, this.email});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    return data;
  }
}
