package com.conservatio.android.ui

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext

/**
 * Conservatio's lightweight string catalog for Android. Mirrors the web
 * `i18n.ts` and iOS `Localization.swift` so all three platforms share the
 * same translation keys.
 *
 * Stored in SharedPreferences under "app.language". Toggle via
 * Settings; default is English.
 */
object Strings {
    fun current(context: Context): String =
        context.getSharedPreferences("conservatio", Context.MODE_PRIVATE)
            .getString("app.language", "en") ?: "en"

    fun set(context: Context, code: String) {
        context.getSharedPreferences("conservatio", Context.MODE_PRIVATE)
            .edit()
            .putString("app.language", code)
            .apply()
    }

    fun t(code: String, key: String): String =
        table[code]?.get(key) ?: table["en"]?.get(key) ?: key

    private val en = mapOf(
        // Tabs
        "nav.dashboard" to "Home",
        "nav.objects" to "Objects",
        "nav.projects" to "Projects",
        "nav.clients" to "Clients",
        "nav.reports" to "Reports",
        "nav.settings" to "Settings",
        // Login
        "login.continueGoogle" to "Continue with Google",
        "login.continueApple" to "Continue with Apple",
        "login.continueGitHub" to "Continue with GitHub",
        "login.finishingOauth" to "Finishing sign-in…",
        "login.errSignIn" to "Sign-in failed. Try again.",
        // Dashboard
        "dash.welcome" to "Welcome back",
        "dash.title" to "Conservatio",
        "dash.intro" to
            "Document heritage objects, write condition reports, manage conservation projects and clients.",
        "dash.signedInTip" to
            "You're signed in. Every new record is uploaded to your account.",
        "dash.offlineTip" to
            "Offline mode. Records live on this device only.",
        "dash.newObject" to "New Object",
        "dash.takePhoto" to "Take Photo",
        "dash.newReport" to "New Report",
        "dash.newProject" to "New Project",
        "dash.recentObjects" to "Recent Objects",
        // Stat
        "stat.objects" to "Objects",
        "stat.reports" to "Reports",
        "stat.projects" to "Projects",
        "stat.clients" to "Clients",
        // Generic
        "g.save" to "Save",
        "g.cancel" to "Cancel",
        "g.edit" to "Edit",
        "g.delete" to "Delete",
        "g.signOut" to "Sign Out",
        "g.signIn" to "Sign In",
        "g.syncNow" to "Sync Now",
        "g.notSet" to "Not set",
        // Settings
        "settings.title" to "Settings",
        "settings.language" to "Language",
        "settings.account" to "Account",
        "settings.profile" to "Profile",
        "settings.displayName" to "Display name",
        "settings.signOut" to "Sign Out",
        "settings.dangerTitle" to "Local data",
        "settings.clearAll" to "Clear all data",
        "settings.loadSample" to "Load sample data",
    )

    private val el = mapOf(
        // Tabs
        "nav.dashboard" to "Αρχική",
        "nav.objects" to "Αντικείμενα",
        "nav.projects" to "Έργα",
        "nav.clients" to "Πελάτες",
        "nav.reports" to "Αναφορές",
        "nav.settings" to "Ρυθμίσεις",
        // Login
        "login.continueGoogle" to "Συνέχεια με Google",
        "login.continueApple" to "Συνέχεια με Apple",
        "login.continueGitHub" to "Συνέχεια με GitHub",
        "login.finishingOauth" to "Ολοκλήρωση σύνδεσης…",
        "login.errSignIn" to "Αποτυχία σύνδεσης. Δοκίμασε ξανά.",
        // Dashboard
        "dash.welcome" to "Καλώς ήρθατε",
        "dash.title" to "Conservatio",
        "dash.intro" to
            "Τεκμηρίωση αντικειμένων, αναφορές κατάστασης, διαχείριση έργων και πελατών.",
        "dash.signedInTip" to
            "Είσαι συνδεδεμένος. Κάθε νέα καταχώρηση ανεβαίνει στον λογαριασμό σου.",
        "dash.offlineTip" to
            "Λειτουργία εκτός σύνδεσης. Οι καταχωρήσεις μένουν μόνο σε αυτή τη συσκευή.",
        "dash.newObject" to "Νέο αντικείμενο",
        "dash.takePhoto" to "Φωτογραφία",
        "dash.newReport" to "Νέα αναφορά",
        "dash.newProject" to "Νέο έργο",
        "dash.recentObjects" to "Πρόσφατα αντικείμενα",
        // Stat
        "stat.objects" to "Αντικείμενα",
        "stat.reports" to "Αναφορές",
        "stat.projects" to "Έργα",
        "stat.clients" to "Πελάτες",
        // Generic
        "g.save" to "Αποθήκευση",
        "g.cancel" to "Άκυρο",
        "g.edit" to "Επεξεργασία",
        "g.delete" to "Διαγραφή",
        "g.signOut" to "Αποσύνδεση",
        "g.signIn" to "Σύνδεση",
        "g.syncNow" to "Συγχρονισμός",
        "g.notSet" to "Δεν έχει οριστεί",
        // Settings
        "settings.title" to "Ρυθμίσεις",
        "settings.language" to "Γλώσσα",
        "settings.account" to "Λογαριασμός",
        "settings.profile" to "Προφίλ",
        "settings.displayName" to "Εμφανιζόμενο όνομα",
        "settings.signOut" to "Αποσύνδεση",
        "settings.dangerTitle" to "Τοπικά δεδομένα",
        "settings.clearAll" to "Διαγραφή όλων",
        "settings.loadSample" to "Φόρτωση δείγματος",
    )

    private val table: Map<String, Map<String, String>> = mapOf(
        "en" to en,
        "el" to el,
    )
}

/** CompositionLocal exposing the active language to Composable trees. */
val LocalLanguageCode = compositionLocalOf { "en" }

/** Read a translated string from inside a Composable. */
@Composable
fun str(key: String): String {
    val code = LocalLanguageCode.current
    return Strings.t(code, key)
}

/**
 * Wrap your app's root with this to make `str("…")` available everywhere.
 * Re-reads the saved language on each composition so toggles in Settings
 * propagate immediately.
 */
@Composable
fun WithLanguage(content: @Composable () -> Unit) {
    val context = LocalContext.current
    val code by remember { mutableStateOf(Strings.current(context)) }
    CompositionLocalProvider(LocalLanguageCode provides code) {
        content()
    }
}
