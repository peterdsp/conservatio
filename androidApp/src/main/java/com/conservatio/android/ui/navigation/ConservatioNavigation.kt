package com.conservatio.android.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.conservatio.android.data.ObjectStore
import com.conservatio.android.ui.screens.CreateObjectScreen
import com.conservatio.android.ui.screens.DashboardScreen
import com.conservatio.android.ui.screens.ObjectsScreen
import com.conservatio.android.ui.screens.SettingsScreen
import com.conservatio.android.ui.screens.SplashScreen
import com.conservatio.android.ui.screens.settings.AboutScreen
import com.conservatio.android.ui.screens.settings.ProfileScreen
import com.conservatio.android.ui.screens.settings.SyncScreen

sealed class Screen(val route: String) {
    data object Splash : Screen("splash")
    data object Dashboard : Screen("dashboard")
    data object Objects : Screen("objects")
    data object NewObject : Screen("objects/new")
    data object Projects : Screen("projects")
    data object Clients : Screen("clients")
    data object Settings : Screen("settings")
    data object SettingsProfile : Screen("settings/profile")
    data object SettingsSync : Screen("settings/sync")
    data object SettingsAbout : Screen("settings/about")
}

@Composable
fun ConservatioNavHost(
    navController: NavHostController,
    objectStore: ObjectStore,
    modifier: Modifier = Modifier
) {
    NavHost(
        navController = navController,
        startDestination = Screen.Splash.route,
        modifier = modifier
    ) {
        composable(Screen.Splash.route) {
            SplashScreen {
                navController.navigate(Screen.Dashboard.route) {
                    popUpTo(Screen.Splash.route) { inclusive = true }
                }
            }
        }

        composable(Screen.Dashboard.route) {
            DashboardScreen(
                objectStore = objectStore,
                onNavigateToNewObject = { navController.navigate(Screen.NewObject.route) },
                onNavigateToObjects = { navController.navigate(Screen.Objects.route) }
            )
        }

        composable(Screen.Objects.route) {
            ObjectsScreen(
                objectStore = objectStore,
                onAddObject = { navController.navigate(Screen.NewObject.route) }
            )
        }

        composable(Screen.NewObject.route) {
            CreateObjectScreen(
                objectStore = objectStore,
                onDismiss = { navController.popBackStack() }
            )
        }

        composable(Screen.Projects.route) {
            PlaceholderScreen("Projects")
        }

        composable(Screen.Clients.route) {
            PlaceholderScreen("Clients")
        }

        composable(Screen.Settings.route) {
            SettingsScreen { destination ->
                when (destination) {
                    "profile" -> navController.navigate(Screen.SettingsProfile.route)
                    "sync" -> navController.navigate(Screen.SettingsSync.route)
                    "about" -> navController.navigate(Screen.SettingsAbout.route)
                    else -> {}
                }
            }
        }

        composable(Screen.SettingsProfile.route) {
            ProfileScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.SettingsSync.route) {
            SyncScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.SettingsAbout.route) {
            AboutScreen(onBack = { navController.popBackStack() })
        }
    }
}
