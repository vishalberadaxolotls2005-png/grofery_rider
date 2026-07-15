abstract class RatingsEvent {}

class FetchRatings extends RatingsEvent {}

class RefreshRatings extends RatingsEvent {}

class LoadMoreRatings extends RatingsEvent {}
