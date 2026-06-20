import Foundation
import SwiftUI

/// Conservatio's lightweight string catalog. Mirrors the web `i18n.ts`
/// keys exactly so the same translation table can be reused across
/// platforms.
///
/// Wired with a single global `t("…")` helper plus a `LanguagePreference`
/// observable that backs Settings. Default language is English; the user
/// flips to Greek from Settings and the choice is persisted in
/// UserDefaults under `app.language`.

@MainActor
@Observable
final class LanguagePreference {
    static let shared = LanguagePreference()

    var code: String {
        didSet { UserDefaults.standard.set(code, forKey: "app.language") }
    }

    private init() {
        code = UserDefaults.standard.string(forKey: "app.language") ?? "en"
    }
}

@MainActor
func t(_ key: String) -> String {
    let lang = LanguagePreference.shared.code
    return (Strings.table[lang]?[key]) ?? (Strings.table["en"]?[key]) ?? key
}

private enum Strings {
    static let table: [String: [String: String]] = [
        "en": en,
        "el": el,
    ]

    static let en: [String: String] = [
        // Tabs
        "nav.dashboard": "Home",
        "nav.objects": "Objects",
        "nav.projects": "Projects",
        "nav.clients": "Clients",
        "nav.reports": "Reports",
        "nav.settings": "Settings",
        // Login
        "login.continueGoogle": "Continue with Google",
        "login.continueApple": "Continue with Apple",
        "login.continueGitHub": "Continue with GitHub",
        "login.finishingOauth": "Finishing sign-in…",
        "login.errSignIn": "Sign-in failed. Try again.",
        // Dashboard
        "dash.welcome": "Welcome back",
        "dash.title": "Conservatio",
        "dash.intro":
            "Document heritage objects, write condition reports, manage conservation projects and clients.",
        "dash.signedInTip":
            "You're signed in. Every new record is uploaded to your account.",
        "dash.offlineTip":
            "Offline mode. Records live on this device only.",
        "dash.newObject": "New Object",
        "dash.takePhoto": "Take Photo",
        "dash.newReport": "New Report",
        "dash.newProject": "New Project",
        "dash.recentObjects": "Recent Objects",
        // Stat
        "stat.objects": "Objects",
        "stat.reports": "Reports",
        "stat.projects": "Projects",
        "stat.clients": "Clients",
        // Generic
        "g.save": "Save",
        "g.cancel": "Cancel",
        "g.edit": "Edit",
        "g.delete": "Delete",
        "g.signOut": "Sign Out",
        "g.signIn": "Sign In",
        "g.syncNow": "Sync Now",
        "g.notSet": "Not set",
        // Settings
        "settings.title": "Settings",
        "settings.language": "Language",
        "settings.account": "Account",
        "settings.profile": "Profile",
        "settings.displayName": "Display name",
        "settings.signOut": "Sign Out",
        "settings.dangerTitle": "Local data",
        "settings.clearAll": "Clear all data",
        "settings.loadSample": "Load sample data",
        "settings.clearConfirm": "This will remove every object, client, project, and report. Are you sure?",
        // Cloud
        "cloud.title": "Cloud Storage",
        "cloud.subtitle": "Where your conservation records and photos live. Connect a provider to add capacity beyond the free Conservatio quota.",
        "cloud.conservatio": "Conservatio Cloud",
        "cloud.conservatioFreeNote": "Included with every account. 2 GB free, then upgradeable.",
        "cloud.signedOutUsage": "Sign in to see your cloud usage.",
        "cloud.usageLabel": "Storage used",
        "cloud.providers": "Other providers",
        "cloud.comingSoon": "Coming soon",
        "cloud.providersHint": "Connecting a third-party provider lets Conservatio mirror your records and photos there. None are wired yet; tap to express interest.",
        "cloud.connectGoogleDrive": "Google Drive",
        "cloud.connectICloud": "iCloud",
        "cloud.connectOneDrive": "OneDrive",
        "cloud.connectMega": "MEGA",
        "cloud.connectDropbox": "Dropbox",
        "cloud.interestNoted": "Noted",
        "cloud.connected": "Connected",
        "g.offline": "Offline",
    ]

    static let el: [String: String] = [
        // Tabs
        "nav.dashboard": "Αρχική",
        "nav.objects": "Αντικείμενα",
        "nav.projects": "Έργα",
        "nav.clients": "Πελάτες",
        "nav.reports": "Αναφορές",
        "nav.settings": "Ρυθμίσεις",
        // Login
        "login.continueGoogle": "Συνέχεια με Google",
        "login.continueApple": "Συνέχεια με Apple",
        "login.continueGitHub": "Συνέχεια με GitHub",
        "login.finishingOauth": "Ολοκλήρωση σύνδεσης…",
        "login.errSignIn": "Αποτυχία σύνδεσης. Δοκίμασε ξανά.",
        // Dashboard
        "dash.welcome": "Καλώς ήρθατε",
        "dash.title": "Conservatio",
        "dash.intro":
            "Τεκμηρίωση αντικειμένων, αναφορές κατάστασης, διαχείριση έργων και πελατών.",
        "dash.signedInTip":
            "Είσαι συνδεδεμένος. Κάθε νέα καταχώρηση ανεβαίνει στον λογαριασμό σου.",
        "dash.offlineTip":
            "Λειτουργία εκτός σύνδεσης. Οι καταχωρήσεις μένουν μόνο σε αυτή τη συσκευή.",
        "dash.newObject": "Νέο αντικείμενο",
        "dash.takePhoto": "Φωτογραφία",
        "dash.newReport": "Νέα αναφορά",
        "dash.newProject": "Νέο έργο",
        "dash.recentObjects": "Πρόσφατα αντικείμενα",
        // Stat
        "stat.objects": "Αντικείμενα",
        "stat.reports": "Αναφορές",
        "stat.projects": "Έργα",
        "stat.clients": "Πελάτες",
        // Generic
        "g.save": "Αποθήκευση",
        "g.cancel": "Άκυρο",
        "g.edit": "Επεξεργασία",
        "g.delete": "Διαγραφή",
        "g.signOut": "Αποσύνδεση",
        "g.signIn": "Σύνδεση",
        "g.syncNow": "Συγχρονισμός",
        "g.notSet": "Δεν έχει οριστεί",
        // Settings
        "settings.title": "Ρυθμίσεις",
        "settings.language": "Γλώσσα",
        "settings.account": "Λογαριασμός",
        "settings.profile": "Προφίλ",
        "settings.displayName": "Εμφανιζόμενο όνομα",
        "settings.signOut": "Αποσύνδεση",
        "settings.dangerTitle": "Τοπικά δεδομένα",
        "settings.clearAll": "Διαγραφή όλων",
        "settings.loadSample": "Φόρτωση δείγματος",
        "settings.clearConfirm": "Θα αφαιρεθούν όλα τα αντικείμενα, πελάτες, έργα και αναφορές. Είστε σίγουροι;",
        // Cloud
        "cloud.title": "Αποθήκευση στο cloud",
        "cloud.subtitle": "Εδώ ζουν οι καταχωρήσεις και οι φωτογραφίες σας. Συνδέστε πάροχο για χώρο πέρα από τη δωρεάν ποσόστωση.",
        "cloud.conservatio": "Conservatio Cloud",
        "cloud.conservatioFreeNote": "Περιλαμβάνεται σε κάθε λογαριασμό. 2 GB δωρεάν, μετά αναβαθμίσιμο.",
        "cloud.signedOutUsage": "Συνδέσου για να δεις τη χρήση του cloud.",
        "cloud.usageLabel": "Χρήση αποθηκευτικού χώρου",
        "cloud.providers": "Άλλοι πάροχοι",
        "cloud.comingSoon": "Σύντομα",
        "cloud.providersHint": "Η σύνδεση τρίτου παρόχου επιτρέπει στο Conservatio να αντικατοπτρίζει τα αρχεία σας εκεί. Πατήστε για να εκδηλώσετε ενδιαφέρον.",
        "cloud.connectGoogleDrive": "Google Drive",
        "cloud.connectICloud": "iCloud",
        "cloud.connectOneDrive": "OneDrive",
        "cloud.connectMega": "MEGA",
        "cloud.connectDropbox": "Dropbox",
        "cloud.interestNoted": "Σημειώθηκε",
        "cloud.connected": "Συνδεδεμένο",
        "g.offline": "Εκτός σύνδεσης",
    ]
}
