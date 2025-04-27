from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework import status
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
        serializer.save(posted_by=self.request.user)

    @action(detail=True, methods=['patch'], permission_classes=[permissions.IsAuthenticated])
    def claim(self, request, pk=None):
        food_item = self.get_object()

        if food_item.claimed_by is not None:
            return Response({'error': 'This item has already been claimed.'}, status=status.HTTP_400_BAD_REQUEST)

        food_item.claimed_by = request.user
        food_item.save()
        return Response({'success': 'Food item claimed successfully!'}, status=status.HTTP_200_OK)


class RestaurantDealViewSet(viewsets.ModelViewSet):
    queryset = RestaurantDeal.objects.all()
    serializer_class = RestaurantDealSerializer

class IncentiveViewSet(viewsets.ModelViewSet):
    queryset = Incentive.objects.all()
    serializer_class = IncentiveSerializer
