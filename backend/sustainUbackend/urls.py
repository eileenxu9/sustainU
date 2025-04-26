from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    UserViewSet,
    MealSwipeViewSet,
    FoodItemViewSet,
    RestaurantDealViewSet,
    IncentiveViewSet,
)

router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'meal-swipes', MealSwipeViewSet)
router.register(r'food-items', FoodItemViewSet)
router.register(r'restaurant-deals', RestaurantDealViewSet)
router.register(r'incentives', IncentiveViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('auth/', include('dj_rest_auth.urls')),  
]
