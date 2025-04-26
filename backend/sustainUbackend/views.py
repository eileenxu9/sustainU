from rest_framework import viewsets, permissions
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
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        # automatically set posted_by to the current user
        serializer.save(posted_by=self.request.user)

class RestaurantDealViewSet(viewsets.ModelViewSet):
    queryset = RestaurantDeal.objects.all()
    serializer_class = RestaurantDealSerializer

class IncentiveViewSet(viewsets.ModelViewSet):
    queryset = Incentive.objects.all()
    serializer_class = IncentiveSerializer
