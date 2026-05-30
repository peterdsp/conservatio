package com.conservatio.android

import android.app.Application
import com.conservatio.di.sharedModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class ConservatioApp : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidContext(this@ConservatioApp)
            modules(sharedModule)
        }
    }
}
