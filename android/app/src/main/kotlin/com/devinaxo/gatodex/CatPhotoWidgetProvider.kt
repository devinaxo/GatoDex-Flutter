package com.devinaxo.gatodex

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.util.Log
import android.widget.RemoteViews
import org.json.JSONArray

/**
 * Home screen widget that cycles through stored cat photos.
 *
 * Data is read from the HomeWidget SharedPreferences written by the Flutter side.
 * On each update the widget advances to the next photo.
 *
 * Tapping the widget cycles to the next photo and opens the app.
 */
class CatPhotoWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "CatPhotoWidget"
        private const val PREFS_NAME = "HomeWidgetPreferences"
        private const val KEY_PATHS = "cat_photo_paths"
        private const val KEY_NAMES = "cat_photo_names"
        private const val KEY_LAST_INDEX = "cat_photo_last_index"
        private const val ACTION_WIDGET_TAP = "com.devinaxo.gatodex.ACTION_WIDGET_TAP"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_cat_photo)

            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val pathsJson = prefs.getString(KEY_PATHS, null)
                val namesJson = prefs.getString(KEY_NAMES, null)
                val lastIndex = prefs.getInt(KEY_LAST_INDEX, -1)

                Log.d(TAG, "Updating widget #$appWidgetId. pathsJson=$pathsJson, lastIndex=$lastIndex")

                if (pathsJson == null) {
                    Log.w(TAG, "No photo data found in preferences")
                    views.setTextViewText(R.id.widget_status_text, "Open gatoDex")
                    views.setViewVisibility(R.id.widget_status_text, android.view.View.VISIBLE)
                    views.setViewVisibility(R.id.widget_image, android.view.View.GONE)
                    setTapIntent(context, views, appWidgetId)
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                    return
                }

                val photoPaths = JSONArray(pathsJson)
                val catNames = if (namesJson != null) JSONArray(namesJson) else JSONArray()

                if (photoPaths.length() == 0) {
                    Log.w(TAG, "Photo paths array is empty")
                    views.setTextViewText(R.id.widget_status_text, "No cat photos yet")
                    views.setViewVisibility(R.id.widget_status_text, android.view.View.VISIBLE)
                    views.setViewVisibility(R.id.widget_image, android.view.View.GONE)
                    setTapIntent(context, views, appWidgetId)
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                    return
                }

                // Pick a random photo, avoiding the same one twice in a row if possible
                val photoCount = photoPaths.length()
                val randomIndex = if (photoCount > 1) {
                    var idx = java.util.Random().nextInt(photoCount)
                    if (idx == lastIndex) {
                        idx = (idx + 1) % photoCount
                    }
                    idx
                } else {
                    0
                }

                val photoPath = photoPaths.getString(randomIndex)

                Log.d(TAG, "Showing random photo at index $randomIndex: $photoPath")

                val bitmap = BitmapFactory.decodeFile(photoPath)

                if (bitmap != null) {
                    Log.d(TAG, "Bitmap loaded: ${bitmap.width}x${bitmap.height}")
                    views.setImageViewBitmap(R.id.widget_image, bitmap)
                    views.setViewVisibility(R.id.widget_image, android.view.View.VISIBLE)
                    views.setViewVisibility(R.id.widget_status_text, android.view.View.GONE)
                } else {
                    Log.e(TAG, "Failed to decode bitmap from: $photoPath")
                    views.setTextViewText(R.id.widget_status_text, "Photo unavailable")
                    views.setViewVisibility(R.id.widget_status_text, android.view.View.VISIBLE)
                    views.setViewVisibility(R.id.widget_image, android.view.View.GONE)
                }

                // Show cat name overlay if available
                if (catNames.length() > randomIndex) {
                    val catName = catNames.getString(randomIndex)
                    if (!catName.isNullOrBlank()) {
                        views.setTextViewText(R.id.widget_cat_name, catName)
                        views.setViewVisibility(R.id.widget_cat_name, android.view.View.VISIBLE)
                    } else {
                        views.setViewVisibility(R.id.widget_cat_name, android.view.View.GONE)
                    }
                } else {
                    views.setViewVisibility(R.id.widget_cat_name, android.view.View.GONE)
                }

                // Save the shown index so we can avoid showing it twice in a row
                prefs.edit().putInt(KEY_LAST_INDEX, randomIndex).apply()
                Log.d(TAG, "Saved last shown index: $randomIndex")

            } catch (e: Exception) {
                Log.e(TAG, "Error updating widget", e)
                views.setTextViewText(R.id.widget_status_text, "Error loading photo")
                views.setViewVisibility(R.id.widget_status_text, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.widget_image, android.view.View.GONE)
            }

            setTapIntent(context, views, appWidgetId)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun setTapIntent(context: Context, views: RemoteViews, appWidgetId: Int) {
            val intent = Intent(context, CatPhotoWidgetProvider::class.java).apply {
                action = ACTION_WIDGET_TAP
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId, // unique per widget instance
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_WIDGET_TAP) {
            val appWidgetId = intent.getIntExtra(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
            Log.d(TAG, "Widget tapped: #$appWidgetId")

            if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                // Cycle to next photo immediately
                val appWidgetManager = AppWidgetManager.getInstance(context)
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }

            // Open the main app regardless
            val activityIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            context.startActivity(activityIntent)
            return
        }
        super.onReceive(context, intent)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "onUpdate called for ids: ${appWidgetIds.joinToString()}")
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        Log.d(TAG, "onEnabled called")
        super.onEnabled(context)
    }

    override fun onDisabled(context: Context) {
        Log.d(TAG, "onDisabled called")
        super.onDisabled(context)
    }
}
