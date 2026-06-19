package com.conservatio.android.data

import android.net.Uri
import java.util.concurrent.CopyOnWriteArrayList

/**
 * Bridge between MainActivity's `onNewIntent` (which receives the OAuth
 * redirect deep link from the browser) and whichever Composable is waiting
 * for it. Registered handlers get the callback URI in order; the first one
 * that returns `true` consumes it.
 */
object OAuthCallback {
    fun interface OnReceive {
        fun handle(uri: Uri): Boolean
    }

    private val listeners = CopyOnWriteArrayList<OnReceive>()

    fun register(handler: OnReceive) {
        listeners.add(handler)
    }

    fun unregister(handler: OnReceive) {
        listeners.remove(handler)
    }

    fun dispatch(uri: Uri): Boolean {
        for (listener in listeners) {
            if (listener.handle(uri)) return true
        }
        return false
    }
}
