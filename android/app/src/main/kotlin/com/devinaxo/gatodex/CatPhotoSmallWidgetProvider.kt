package com.devinaxo.gatodex

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.util.Log

/**
 * Small (2x2) variant of the cat photo widget.
 * Reuses the same update logic as the main provider.
 */
class CatPhotoSmallWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "CatPhotoSmallWidget"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "onUpdate called for ids: ${appWidgetIds.joinToString()}")
        for (appWidgetId in appWidgetIds) {
            CatPhotoWidgetProvider.updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
}
