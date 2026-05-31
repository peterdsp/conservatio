package com.conservatio.android.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Inventory2
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Inventory2
import androidx.compose.material.icons.outlined.People
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.conservatio.android.data.ObjectStore
import com.conservatio.android.ui.navigation.ConservatioNavHost
import com.conservatio.android.ui.navigation.Screen
import com.conservatio.android.ui.theme.ConservatioColors
import com.conservatio.android.ui.theme.ConservatioTheme

data class BottomNavItem(
    val label: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
    val route: String
)

@Composable
fun ConservatioApp() {
    ConservatioTheme {
        val navController = rememberNavController()
        val context = LocalContext.current
        val objectStore = remember { ObjectStore(context) }

        val navItems = listOf(
            BottomNavItem("Home", Icons.Filled.Home, Icons.Outlined.Home, Screen.Dashboard.route),
            BottomNavItem("Objects", Icons.Filled.Inventory2, Icons.Outlined.Inventory2, Screen.Objects.route),
            BottomNavItem("Projects", Icons.Filled.Folder, Icons.Outlined.Folder, Screen.Projects.route),
            BottomNavItem("Clients", Icons.Filled.People, Icons.Outlined.People, Screen.Clients.route),
            BottomNavItem("Settings", Icons.Filled.Settings, Icons.Outlined.Settings, Screen.Settings.route),
        )

        val navBackStackEntry by navController.currentBackStackEntryAsState()
        val currentRoute = navBackStackEntry?.destination?.route

        val showBottomBar = currentRoute in navItems.map { it.route }

        Scaffold(
            bottomBar = {
                if (showBottomBar) {
                    NavigationBar(containerColor = ConservatioColors.background) {
                        navItems.forEach { item ->
                            NavigationBarItem(
                                selected = currentRoute == item.route,
                                onClick = {
                                    navController.navigate(item.route) {
                                        popUpTo(Screen.Dashboard.route) { saveState = true }
                                        launchSingleTop = true
                                        restoreState = true
                                    }
                                },
                                icon = {
                                    Icon(
                                        if (currentRoute == item.route) item.selectedIcon else item.unselectedIcon,
                                        item.label
                                    )
                                },
                                label = { Text(item.label) },
                                colors = NavigationBarItemDefaults.colors(
                                    selectedIconColor = ConservatioColors.primary,
                                    selectedTextColor = ConservatioColors.primary,
                                    indicatorColor = ConservatioColors.primaryLight.copy(alpha = 0.2f)
                                )
                            )
                        }
                    }
                }
            }
        ) { padding ->
            ConservatioNavHost(
                navController = navController,
                objectStore = objectStore,
                modifier = Modifier.padding(padding)
            )
        }
    }
}
