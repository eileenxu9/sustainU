# yourapp/views.py

from rest_framework import viewsets, permissions, status
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.permissions import BasePermission, IsAuthenticated
from rest_framework.response import Response

from .models import User, MealSwipe, FoodItem, RestaurantDeal, Incentive
from .serializers import (
    UserSerializer,
    MealSwipeSerializer,
    FoodItemSerializer,
    RestaurantDealSerializer,
    IncentiveSerializer
)


class IsAdminRole(BasePermission):
    """
    Allows access only to users whose `role` field is 'admin'.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == 'admin')


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class MealSwipeViewSet(viewsets.ModelViewSet):
    queryset = MealSwipe.objects.all()
    serializer_class = MealSwipeSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=False, methods=['post'], url_path='claim')
    def claim(self, request):
        user = request.user
        try:
            requested = int(request.data.get('count', 1))
        except (TypeError, ValueError):
            return Response({"detail": "Invalid count."},
                            status=status.HTTP_400_BAD_REQUEST)

        if requested < 1 or requested > 2:
            return Response(
                {"detail": "You can claim between 1 and 2 swipes at a time."},
                status=status.HTTP_400_BAD_REQUEST
            )

        swipe = MealSwipe.objects.filter(
            requested_by__isnull=True,
            available_swipes__gt=0
        ).order_by('timestamp').first()

        if not swipe:
            return Response(
                {"detail": "No swipes available to claim."},
                status=status.HTTP_400_BAD_REQUEST
            )

        to_claim = min(requested, swipe.available_swipes)

        # decrement donation
        swipe.available_swipes -= to_claim
        swipe.save()

        # credit user
        user.available_swipes += to_claim
        user.save()

        # if emptied, mark claimed
        if swipe.available_swipes == 0:
            swipe.requested_by = user
            swipe.save()

        return Response(self.get_serializer(swipe).data)


class FoodItemViewSet(viewsets.ModelViewSet):
    queryset = FoodItem.objects.all()
    serializer_class = FoodItemSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(posted_by=self.request.user)

    @action(detail=True, methods=['patch'], permission_classes=[IsAuthenticated])
    def claim(self, request, pk=None):
        food_item = self.get_object()
        if food_item.claimed_by is not None:
            return Response(
                {'error': 'This item has already been claimed.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        food_item.claimed_by = request.user
        food_item.save()
        return Response(
            {'success': 'Food item claimed successfully!'},
            status=status.HTTP_200_OK
        )


class RestaurantDealViewSet(viewsets.ModelViewSet):
    """
    Students can list & retrieve; only admins can create/update/delete.
    """
    queryset = RestaurantDeal.objects.all()
    serializer_class = RestaurantDealSerializer

    def get_permissions(self):
        # safe actions for everyone authenticated
        if self.action in ['list', 'retrieve']:
            perms = [IsAuthenticated]
        # all other actions (create, update, partial_update, destroy) require admin
        else:
            perms = [IsAuthenticated, IsAdminRole]
        return [p() for p in perms]

    def perform_create(self, serializer):
        # only admins get this far
        serializer.save(posted_by=self.request.user)

class IncentiveViewSet(viewsets.ModelViewSet):
    queryset = Incentive.objects.all()
    serializer_class = IncentiveSerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def current_user(request):
    """
    GET /auth/user/
    Returns the logged-in user including id, username, email,
    role, available_swipes, and points.
    """
    serializer = UserSerializer(request.user)
    return Response(serializer.data)
