package com.conservatio.android.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.conservatio.android.data.ObjectStore
import com.conservatio.android.data.ServerSyncClient
import com.conservatio.android.ui.screens.CreateObjectScreen
import com.conservatio.android.ui.screens.DashboardScreen
import com.conservatio.android.ui.screens.LoginScreen
import com.conservatio.android.ui.screens.ObjectsScreen
import com.conservatio.android.ui.screens.SettingsScreen
import com.conservatio.android.ui.screens.SplashScreen
import androidx.compose.ui.platform.LocalContext
import com.conservatio.android.ui.screens.settings.AboutScreen
import com.conservatio.android.ui.screens.settings.AppearanceScreen
import com.conservatio.android.ui.screens.settings.CloudStorageScreen
import com.conservatio.android.ui.screens.settings.ExportSettingsScreen
import com.conservatio.android.ui.screens.settings.LanguageScreen
import com.conservatio.android.ui.screens.settings.ProfileScreen
import com.conservatio.android.ui.screens.settings.StorageScreen
import com.conservatio.android.ui.screens.settings.SyncScreen
import androidx.navigation.NavType
import androidx.navigation.navArgument

sealed class Screen(val route: String) {
    data object Splash : Screen("splash")
    data object Login : Screen("login")
    data object Dashboard : Screen("dashboard")
    data object Objects : Screen("objects")
    data object NewObject : Screen("objects/new")
    data object EditObject : Screen("objects/edit/{objectId}") {
        fun withId(id: String) = "objects/edit/$id"
    }
    data object Projects : Screen("projects")
    data object Clients : Screen("clients")
    data object Settings : Screen("settings")
    data object SettingsProfile : Screen("settings/profile")
    data object SettingsSync : Screen("settings/sync")
    data object SettingsCloud : Screen("settings/cloud")
    data object SettingsAbout : Screen("settings/about")
    data object SettingsLanguage : Screen("settings/language")
    data object SettingsExport : Screen("settings/export")
    data object SettingsAppearance : Screen("settings/appearance")
    data object SettingsStorage : Screen("settings/storage")
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
            val ctx = LocalContext.current
            SplashScreen {
                val signedIn = ServerSyncClient(ctx.applicationContext).isAuthenticated
                val next = if (signedIn) Screen.Dashboard.route else Screen.Login.route
                navController.navigate(next) {
                    popUpTo(Screen.Splash.route) { inclusive = true }
                }
            }
        }

        composable(Screen.Login.route) {
            LoginScreen {
                navController.navigate(Screen.Dashboard.route) {
                    popUpTo(Screen.Login.route) { inclusive = true }
                }
            }
        }

        composable(Screen.Dashboard.route) {
            DashboardScreen(
                objectStore = objectStore,
                onNavigateToNewObject = { navController.navigate(Screen.NewObject.route) },
                onNavigateToObjects = { navController.navigate(Screen.Objects.route) },
                onNavigateToEditObject = { id -> navController.navigate(Screen.EditObject.withId(id)) },
            )
        }

        composable(Screen.Objects.route) {
            ObjectsScreen(
                objectStore = objectStore,
                onAddObject = { navController.navigate(Screen.NewObject.route) },
                onEditObject = { id -> navController.navigate(Screen.EditObject.withId(id)) },
            )
        }

        composable(Screen.NewObject.route) {
            CreateObjectScreen(
                objectStore = objectStore,
                onDismiss = { navController.popBackStack() },
            )
        }

        composable(
            Screen.EditObject.route,
            arguments = listOf(navArgument("objectId") { type = NavType.StringType }),
        ) { backStackEntry ->
            val objectId = backStackEntry.arguments?.getString("objectId")
            CreateObjectScreen(
                objectStore = objectStore,
                onDismiss = { navController.popBackStack() },
                existingObjectId = objectId,
            )
        }

        composable(Screen.Projects.route) {
            PlaceholderScreen("Projects")
        }

        composable(Screen.Clients.route) {
            PlaceholderScreen("Clients")
        }

        composable(Screen.Settings.route) {
            SettingsScreen(objectStore = objectStore) { destination ->
                when (destination) {
                    "profile" -> navController.navigate(Screen.SettingsProfile.route)
                    "sync" -> navController.navigate(Screen.SettingsSync.route)
                    "cloud" -> navController.navigate(Screen.SettingsCloud.route)
                    "about" -> navController.navigate(Screen.SettingsAbout.route)
                    "language" -> navController.navigate(Screen.SettingsLanguage.route)
                    "export" -> navController.navigate(Screen.SettingsExport.route)
                    "appearance" -> navController.navigate(Screen.SettingsAppearance.route)
                    "storage" -> navController.navigate(Screen.SettingsStorage.route)
                    else -> {}
                }
            }
        }

        composable(Screen.SettingsProfile.route) {
            ProfileScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.SettingsSync.route) {
            SyncScreen(
                objectStore = objectStore,
                onBack = { navController.popBackStack() }
            )
        }

        composable(Screen.SettingsCloud.route) {
            CloudStorageScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.SettingsAbout.route) {
            AboutScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.SettingsLanguage.route) {
            LanguageScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.SettingsExport.route) {
            ExportSettingsScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.SettingsAppearance.route) {
            AppearanceScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.SettingsStorage.route) {
            StorageScreen(onBack = { navController.popBackStack() })
        }
    }
}
