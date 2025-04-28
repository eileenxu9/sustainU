from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import (
    UserViewSet,
    MealSwipeViewSet,
    FoodItemViewSet,
    RestaurantDealViewSet,
    IncentiveViewSet,
    current_user,             # ← our override view
)

router = DefaultRouter()
router.register(r'users',            UserViewSet)
router.register(r'meal-swipes',      MealSwipeViewSet)
router.register(r'food-items',       FoodItemViewSet)
router.register(r'restaurant-deals', RestaurantDealViewSet)
router.register(r'incentives',       IncentiveViewSet)

urlpatterns = [
    # 1) Override dj-rest-auth’s /auth/user/ first:
    path('auth/user/', current_user),

    # 2) Then include all of dj-rest-auth’s endpoints (login, logout, password, etc.)
    path('auth/', include('dj_rest_auth.urls')),

    # 3) Finally, expose your router’ed API endpoints
    path('', include(router.urls)),
]
