class AvailableOrdersResponse {
  final bool success;
  final String message;
  final AvailableOrdersData data;

  AvailableOrdersResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AvailableOrdersResponse.fromJson(Map<String, dynamic> json) {
    return AvailableOrdersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AvailableOrdersData.fromJson(json['data'] ?? {}),
    );
  }
}

class AvailableOrdersData {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;
  final List<Orders> orders;
  final List<OrderCluster>? clusters;

  AvailableOrdersData({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
    required this.orders,
    this.clusters,
  });

  factory AvailableOrdersData.fromJson(Map<String, dynamic> json) {
    return AvailableOrdersData(
      currentPage: json['current_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map((order) => Orders.fromJson(order))
              .toList() ??
          [],
      clusters:
          (json['clusters'] as List<dynamic>?)
              ?.map((cluster) => OrderCluster.fromJson(cluster))
              .toList(),
    );
  }
}

class Orders {
  final int? id;
  final String? uuid;
  final String? slug;
  final String? status;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? fulfillmentType;
  final int? estimatedDeliveryTime;
  final int? deliveryTimeSlotId;
  final int? deliveryBoyId;
  final String? deliveryCharge;
  final String? subtotal;
  final String? totalPayable;
  final String? orderNote;
  final String? finalTotal;
  final String? shippingName;
  final String? shippingAddress1;
  final String? shippingAddress2;
  final String? shippingLandmark;
  final String? shippingZip;
  final String? shippingPhone;
  final String? shippingPhonecode;
  final String? shippingAddressType;
  final String? shippingLatitude;
  final String? shippingLongitude;
  final String? shippingCity;
  final String? shippingState;
  final String? shippingCountry;
  final DeliveryRoute? deliveryRoute;
  final Earnings? earnings;
  final List<Items>? items;
  final DeliveryZone? deliveryZone;
  final DeliveryTimeSlot? deliveryTimeSlot;
  final int? otpVerified;
  final String? createdAt;
  final String? updatedAt;
  final String? total;

  Orders({
    this.id,
    this.uuid,
    this.slug,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.fulfillmentType,
    this.orderNote,
    this.estimatedDeliveryTime,
    this.deliveryTimeSlotId,
    this.deliveryBoyId,
    this.deliveryCharge,
    this.subtotal,
    this.totalPayable,
    this.finalTotal,
    this.shippingName,
    this.shippingAddress1,
    this.shippingAddress2,
    this.shippingLandmark,
    this.shippingZip,
    this.shippingPhone,
    this.shippingPhonecode,
    this.shippingAddressType,
    this.shippingLatitude,
    this.shippingLongitude,
    this.shippingCity,
    this.shippingState,
    this.shippingCountry,
    this.deliveryRoute,
    this.earnings,
    this.items,
    this.deliveryZone,
    this.deliveryTimeSlot,
    this.otpVerified,
    this.createdAt,
    this.updatedAt,
    this.total
  });

  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
      id: json['id'],
      uuid: json['uuid'],
      slug: json['slug'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      fulfillmentType: json['fulfillment_type'],
      orderNote: json['order_note'],
      estimatedDeliveryTime: json['estimated_delivery_time'],
      deliveryTimeSlotId: json['delivery_time_slot_id'],
      deliveryBoyId: json['delivery_boy_id'],
      deliveryCharge: json['delivery_charge'],
      subtotal: json['subtotal'],
      totalPayable: json['total_payable'],
      finalTotal: json['final_total'],
      shippingName: json['shipping_name'],
      shippingAddress1: json['shipping_address_1'],
      shippingAddress2: json['shipping_address_2'],
      shippingLandmark: json['shipping_landmark'],
      shippingZip: json['shipping_zip'],
      shippingPhone: json['shipping_phone'],
      shippingPhonecode: json['shipping_phonecode'],
      shippingAddressType: json['shipping_address_type'],
      shippingLatitude: json['shipping_latitude'],
      shippingLongitude: json['shipping_longitude'],
      shippingCity: json['shipping_city'],
      shippingState: json['shipping_state'],
      shippingCountry: json['shipping_country'],
      deliveryRoute:
          json['delivery_route'] != null
              ? DeliveryRoute.fromJson(json['delivery_route'])
              : null,
      earnings:
          json['earnings'] != null ? Earnings.fromJson(json['earnings']) : null,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => Items.fromJson(item))
              .toList() ??
          [],
      deliveryZone:
          json['delivery_zone'] != null
              ? DeliveryZone.fromJson(json['delivery_zone'])
              : null,
      deliveryTimeSlot:
          json['delivery_time_slot'] != null
              ? DeliveryTimeSlot.fromJson(json['delivery_time_slot'])
              : null,
      otpVerified: json['otp_verified'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      total: json['total']
    );
  }

  Orders copyWith({
    int? id,
    String? uuid,
    String? slug,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    String? fulfillmentType,
    int? estimatedDeliveryTime,
    int? deliveryTimeSlotId,
    int? deliveryBoyId,
    String? deliveryCharge,
    String? subtotal,
    String? orderNote,
    String? totalPayable,
    String? finalTotal,
    String? shippingName,
    String? shippingAddress1,
    String? shippingAddress2,
    String? shippingLandmark,
    String? shippingZip,
    String? shippingPhone,
    String? shippingPhonecode,
    String? shippingAddressType,
    String? shippingLatitude,
    String? shippingLongitude,
    String? shippingCity,
    String? shippingState,
    String? shippingCountry,
    DeliveryRoute? deliveryRoute,
    Earnings? earnings,
    List<Items>? items,
    DeliveryZone? deliveryZone,
    DeliveryTimeSlot? deliveryTimeSlot,
    int? otpVerified,
    String? createdAt,
    String? updatedAt,
    String? total
  }) {
    return Orders(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      slug: slug ?? this.slug,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      fulfillmentType: fulfillmentType ?? this.fulfillmentType,
      orderNote: orderNote ?? this.orderNote,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      deliveryTimeSlotId: deliveryTimeSlotId ?? this.deliveryTimeSlotId,
      deliveryBoyId: deliveryBoyId ?? this.deliveryBoyId,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      subtotal: subtotal ?? this.subtotal,
      totalPayable: totalPayable ?? this.totalPayable,
      finalTotal: finalTotal ?? this.finalTotal,
      shippingName: shippingName ?? this.shippingName,
      shippingAddress1: shippingAddress1 ?? this.shippingAddress1,
      shippingAddress2: shippingAddress2 ?? this.shippingAddress2,
      shippingLandmark: shippingLandmark ?? this.shippingLandmark,
      shippingZip: shippingZip ?? this.shippingZip,
      shippingPhone: shippingPhone ?? this.shippingPhone,
      shippingPhonecode: shippingPhonecode ?? this.shippingPhonecode,
      shippingAddressType: shippingAddressType ?? this.shippingAddressType,
      shippingLatitude: shippingLatitude ?? this.shippingLatitude,
      shippingLongitude: shippingLongitude ?? this.shippingLongitude,
      shippingCity: shippingCity ?? this.shippingCity,
      shippingState: shippingState ?? this.shippingState,
      shippingCountry: shippingCountry ?? this.shippingCountry,
      deliveryRoute: deliveryRoute ?? this.deliveryRoute,
      earnings: earnings ?? this.earnings,
      items: items ?? this.items,
      deliveryZone: deliveryZone ?? this.deliveryZone,
      deliveryTimeSlot: deliveryTimeSlot ?? this.deliveryTimeSlot,
      otpVerified: otpVerified ?? this.otpVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      total: total ?? this.total
    );
  }
}

class DeliveryRoute {
  final double? totalDistance;
  final List<int>? route;
  final List<RouteDetails>? routeDetails;

  DeliveryRoute({this.totalDistance, this.route, this.routeDetails});

  factory DeliveryRoute.fromJson(Map<String, dynamic> json) {
    return DeliveryRoute(
      totalDistance: json['total_distance']?.toDouble(),
      route: (json['route'] as List<dynamic>?)?.cast<int>(),
      routeDetails:
          (json['route_details'] as List<dynamic>?)
              ?.map((detail) => RouteDetails.fromJson(detail))
              .toList() ??
          [],
    );
  }
}

class RouteDetails {
  final int? storeId;
  final String? storeName;
  final double? distanceFromCustomer;
  final double? distanceFromPrevious;
  final String? address;
  final String? city;
  final String? landmark;
  final String? state;
  final String? zipcode;
  final String? country;
  final String? countryCode;
  final double? latitude;
  final double? longitude;

  RouteDetails({
    this.storeId,
    this.storeName,
    this.distanceFromCustomer,
    this.distanceFromPrevious,
    this.address,
    this.city,
    this.landmark,
    this.state,
    this.zipcode,
    this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
  });

  factory RouteDetails.fromJson(Map<String, dynamic> json) {
    return RouteDetails(
      storeId: json['store_id'],
      storeName: json['store_name'],
      distanceFromCustomer: json['distance_from_customer']?.toDouble(),
      distanceFromPrevious: json['distance_from_previous']?.toDouble(),
      address: json['address'],
      city: json['city'],
      landmark: json['landmark'],
      state: json['state'],
      zipcode: json['zipcode'],
      country: json['country'],
      countryCode: json['country_code'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

class Earnings {
  final double? total;
  final EarningsBreakdown? breakdown;

  Earnings({this.total, this.breakdown});

  factory Earnings.fromJson(Map<String, dynamic> json) {
    return Earnings(
      total: json['total']?.toDouble(),
      breakdown:
          json['breakdown'] != null
              ? EarningsBreakdown.fromJson(json['breakdown'])
              : null,
    );
  }
}

class EarningsBreakdown {
  final double? baseFee;
  final double? perStorePickupFee;
  final double? distanceBasedFee;
  final double? perOrderIncentive;

  EarningsBreakdown({
    this.baseFee,
    this.perStorePickupFee,
    this.distanceBasedFee,
    this.perOrderIncentive,
  });

  factory EarningsBreakdown.fromJson(Map<String, dynamic> json) {
    return EarningsBreakdown(
      baseFee: json['base_fee']?.toDouble(),
      perStorePickupFee: json['per_store_pickup_fee']?.toDouble(),
      distanceBasedFee: json['distance_based_fee']?.toDouble(),
      perOrderIncentive: json['per_order_incentive']?.toDouble(),
    );
  }
}

class Items {
  final int? id;
  final int? orderId;
  final int? productId;
  final int? productVariantId;
  final int? storeId;
  final String? title;
  final String? variantTitle;
  final String? giftCardDiscount;
  final String? adminCommissionAmount;
  final String? sellerCommissionAmount;
  final String? commissionSettled;
  final String? discountedPrice;
  final String? discount;
  final String? taxAmount;
  final String? taxPercent;
  final String? sku;
  final int? quantity;
  final String? price;
  final String? subtotal;
  final String? status;
  final int? otpVerified;
  final bool reachedDestination;
  final Product? product;
  final Variant? variant;
  final Store? store;
  final String? createdAt;
  final String? updatedAt;

  Items({
    this.id,
    this.orderId,
    this.productId,
    this.productVariantId,
    this.storeId,
    this.title,
    this.variantTitle,
    this.giftCardDiscount,
    this.adminCommissionAmount,
    this.sellerCommissionAmount,
    this.commissionSettled,
    this.discountedPrice,
    this.discount,
    this.taxAmount,
    this.taxPercent,
    this.sku,
    this.quantity,
    this.price,
    this.subtotal,
    this.status,
    this.otpVerified,
    this.reachedDestination = false,
    this.product,
    this.variant,
    this.store,
    this.createdAt,
    this.updatedAt,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      productVariantId: json['product_variant_id'],
      storeId: json['store_id'],
      title: json['title'],
      variantTitle: json['variant_title'],
      giftCardDiscount: json['gift_card_discount'],
      adminCommissionAmount: json['admin_commission_amount'],
      sellerCommissionAmount: json['seller_commission_amount'],
      commissionSettled: json['commission_settled'],
      discountedPrice: json['discounted_price'],
      discount: json['discount'],
      taxAmount: json['tax_amount'],
      taxPercent: json['tax_percent'],
      sku: json['sku'],
      quantity: json['quantity'],
      price: json['price'],
      subtotal: json['subtotal'],
      status: json['status'],
      otpVerified: json['otp_verified'],
      reachedDestination: false, // Default to false, bloc will update this
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      variant:
          json['variant'] != null ? Variant.fromJson(json['variant']) : null,
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Items copyWith({
    int? id,
    int? orderId,
    int? productId,
    int? productVariantId,
    int? storeId,
    String? title,
    String? variantTitle,
    String? giftCardDiscount,
    String? adminCommissionAmount,
    String? sellerCommissionAmount,
    String? commissionSettled,
    String? discountedPrice,
    String? discount,
    String? taxAmount,
    String? taxPercent,
    String? sku,
    int? quantity,
    String? price,
    String? subtotal,
    String? status,
    int? otpVerified,
    bool? reachedDestination,
    Product? product,
    Variant? variant,
    Store? store,
    String? createdAt,
    String? updatedAt,
  }) {
    return Items(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productVariantId: productVariantId ?? this.productVariantId,
      storeId: storeId ?? this.storeId,
      title: title ?? this.title,
      variantTitle: variantTitle ?? this.variantTitle,
      giftCardDiscount: giftCardDiscount ?? this.giftCardDiscount,
      adminCommissionAmount:
          adminCommissionAmount ?? this.adminCommissionAmount,
      sellerCommissionAmount:
          sellerCommissionAmount ?? this.sellerCommissionAmount,
      commissionSettled: commissionSettled ?? this.commissionSettled,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discount: discount ?? this.discount,
      taxAmount: taxAmount ?? this.taxAmount,
      taxPercent: taxPercent ?? this.taxPercent,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
      status: status ?? this.status,
      otpVerified: otpVerified ?? this.otpVerified,
      reachedDestination: reachedDestination ?? this.reachedDestination,
      product: product ?? this.product,
      variant: variant ?? this.variant,
      store: store ?? this.store,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Product {
  final int? id;
  final String? name;
  final String? slug;
  final String? image;
  final int? requiresOtp;

  Product({this.id, this.name, this.slug, this.image, this.requiresOtp});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      image: json['image'],
      requiresOtp: json['requires_otp'],
    );
  }
}

class Variant {
  final int? id;
  final String? title;
  final String? slug;
  final String? image;

  Variant({this.id, this.title, this.slug, this.image});

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      image: json['image'],
    );
  }
}

class Store {
  final int? id;
  final String? name;
  final String? slug;

  Store({this.id, this.name, this.slug});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(id: json['id'], name: json['name'], slug: json['slug']);
  }
}

class DeliveryZone {
  final int? id;
  final String? name;

  DeliveryZone({this.id, this.name});

  factory DeliveryZone.fromJson(Map<String, dynamic> json) {
    return DeliveryZone(id: json['id'], name: json['name']);
  }
}

class DeliveryTimeSlot {
  final int? id;
  final String? title;
  final String? startTime;
  final String? endTime;

  DeliveryTimeSlot({this.id, this.title, this.startTime, this.endTime});

  factory DeliveryTimeSlot.fromJson(Map<String, dynamic> json) {
    return DeliveryTimeSlot(
      id: json['id'],
      title: json['title'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class OrderCluster {
  final String? timeSlot;
  final List<PincodeCluster>? pincodeClusters;

  OrderCluster({this.timeSlot, this.pincodeClusters});

  factory OrderCluster.fromJson(Map<String, dynamic> json) {
    return OrderCluster(
      timeSlot: json['time_slot'],
      pincodeClusters: (json['pincode_clusters'] as List<dynamic>?)
              ?.map((item) => PincodeCluster.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class PincodeCluster {
  final int? pincode;
  final int? orderCount;
  final List<Orders>? orders;

  PincodeCluster({this.pincode, this.orderCount, this.orders});

  factory PincodeCluster.fromJson(Map<String, dynamic> json) {
    return PincodeCluster(
      pincode: json['pincode'],
      orderCount: json['order_count'],
      orders: (json['orders'] as List<dynamic>?)
              ?.map((order) => Orders.fromJson(order))
              .toList() ??
          [],
    );
  }
}

class PincodeClusterItem {
  final String? timeSlot;
  final PincodeCluster cluster;

  PincodeClusterItem({this.timeSlot, required this.cluster});
}
