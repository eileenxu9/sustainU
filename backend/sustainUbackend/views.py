from rest_framework import viewsets
from .models import User, MealSwipe, FoodItem, RestaurantDeal, Incentive
from .serializers import (
    UserSerializer,
    MealSwipeSerializer,
    FoodItemSerializer,
    RestaurantDealSerializer,
    IncentiveSerializer
)

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class MealSwipeViewSet(viewsets.ModelViewSet):
    queryset = MealSwipe.objects.all()
    serializer_class = MealSwipeSerializer

class FoodItemViewSet(viewsets.ModelViewSet):
    queryset = FoodItem.objects.all()
    serializer_class = FoodItemSerializer

class RestaurantDealViewSet(viewsets.ModelViewSet):
    queryset = RestaurantDeal.objects.all()
    serializer_class = RestaurantDealSerializer

class IncentiveViewSet(viewsets.ModelViewSet):
    queryset = Incentive.objects.all()
    serializer_class = IncentiveSerializer
