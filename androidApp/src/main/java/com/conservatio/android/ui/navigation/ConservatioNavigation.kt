package com.conservatio.android.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable

sealed class Screen(val route: String) {
    data object Dashboard : Screen("dashboard")
    data object Objects : Screen("objects")
    data object ObjectDetail : Screen("objects/{objectId}") {
        fun createRoute(objectId: String) = "objects/$objectId"
    }
    data object NewObject : Screen("objects/new")
    data object Reports : Screen("reports")
    data object ReportDetail : Screen("reports/{reportId}") {
        fun createRoute(reportId: String) = "reports/$reportId"
    }
    data object NewReport : Screen("reports/new/{objectId}") {
        fun createRoute(objectId: String) = "reports/new/$objectId"
    }
    data object Projects : Screen("projects")
    data object Clients : Screen("clients")
    data object Settings : Screen("settings")
}

@Composable
fun ConservatioNavHost(navController: NavHostController, modifier: Modifier = Modifier) {
    NavHost(
        navController = navController,
        startDestination = Screen.Dashboard.route,
        modifier = modifier
    ) {
        composable(Screen.Dashboard.route) {
            DashboardPlaceholder()
        }
        composable(Screen.Objects.route) {
            ObjectsPlaceholder()
        }
        composable(Screen.Projects.route) {
            ProjectsPlaceholder()
        }
        composable(Screen.Clients.route) {
            ClientsPlaceholder()
        }
        composable(Screen.Settings.route) {
            SettingsPlaceholder()
        }
    }
}

@Composable
private fun DashboardPlaceholder() {
    PlaceholderScreen("Dashboard")
}

@Composable
private fun ObjectsPlaceholder() {
    PlaceholderScreen("Objects")
}

@Composable
private fun ProjectsPlaceholder() {
    PlaceholderScreen("Projects")
}

@Composable
private fun ClientsPlaceholder() {
    PlaceholderScreen("Clients")
}

@Composable
private fun SettingsPlaceholder() {
    PlaceholderScreen("Settings")
}
