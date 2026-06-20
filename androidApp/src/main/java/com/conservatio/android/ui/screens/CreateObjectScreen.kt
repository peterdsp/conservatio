package com.conservatio.android.ui.screens

import android.graphics.BitmapFactory
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddAPhoto
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.PhotoLibrary
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.conservatio.android.data.ConservationObject
import com.conservatio.android.data.ObjectStore
import com.conservatio.android.data.ObjectType
import com.conservatio.android.data.ServerSyncClient
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

private data class PendingImage(
    val uri: Uri,
    val uploadedId: String? = null,
    val uploading: Boolean = false,
    val error: String? = null,
)

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun CreateObjectScreen(
    objectStore: ObjectStore,
    onDismiss: () -> Unit,
    existingObjectId: String? = null,
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val syncClient = remember { ServerSyncClient(context.applicationContext) }
    val existing = existingObjectId?.let { objectStore.getObject(it) }
    val isEdit = existing != null

    var title by remember { mutableStateOf(existing?.title.orEmpty()) }
    var selectedType by remember { mutableStateOf(existing?.objectType ?: ObjectType.OTHER) }
    var materials by remember { mutableStateOf(existing?.materials?.joinToString(", ").orEmpty()) }
    var heightVal by remember { mutableStateOf(existing?.height?.let { "%g".format(it) }.orEmpty()) }
    var widthVal by remember { mutableStateOf(existing?.width?.let { "%g".format(it) }.orEmpty()) }
    var depthVal by remember { mutableStateOf(existing?.depth?.let { "%g".format(it) }.orEmpty()) }
    var unit by remember { mutableStateOf(existing?.measurementUnit ?: "cm") }
    var owner by remember { mutableStateOf(existing?.ownerName.orEmpty()) }
    var location by remember { mutableStateOf(existing?.locationDescription.orEmpty()) }
    var inventory by remember { mutableStateOf(existing?.inventoryNumber.orEmpty()) }
    var description by remember { mutableStateOf(existing?.description.orEmpty()) }
    var typeExpanded by remember { mutableStateOf(false) }

    var existingImageIds by remember { mutableStateOf(existing?.imageIds.orEmpty()) }
    var pendingImages by remember { mutableStateOf<List<PendingImage>>(emptyList()) }
    var showDeleteConfirm by remember { mutableStateOf(false) }

    val photoPicker = rememberLauncherForActivityResult(
        ActivityResultContracts.GetMultipleContents()
    ) { uris ->
        val newPending = uris.map { PendingImage(uri = it) }
        pendingImages = pendingImages + newPending
        if (syncClient.isAuthenticated) {
            newPending.forEach { pending ->
                scope.launch {
                    pendingImages = pendingImages.map {
                        if (it.uri == pending.uri) it.copy(uploading = true) else it
                    }
                    try {
                        val bytes = withContext(Dispatchers.IO) {
                            context.contentResolver.openInputStream(pending.uri)?.readBytes()
                                ?: throw IllegalStateException("Cannot read image")
                        }
                        val imageId = syncClient.uploadImage(bytes)
                        pendingImages = pendingImages.map {
                            if (it.uri == pending.uri) it.copy(uploading = false, uploadedId = imageId) else it
                        }
                    } catch (e: Exception) {
                        pendingImages = pendingImages.map {
                            if (it.uri == pending.uri) it.copy(uploading = false, error = e.message) else it
                        }
                    }
                }
            }
        }
    }

    if (showDeleteConfirm && isEdit) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirm = false },
            title = { Text("Delete Object") },
            text = { Text("This will permanently delete \"${existing!!.title}\" and all its reports.") },
            confirmButton = {
                TextButton(onClick = {
                    objectStore.deleteObject(existing!!.id)
                    showDeleteConfirm = false
                    onDismiss()
                }) { Text("Delete", color = MaterialTheme.colorScheme.error) }
            },
            dismissButton = { TextButton(onClick = { showDeleteConfirm = false }) { Text("Cancel") } },
        )
    }

    fun save() {
        if (title.isBlank()) return
        val allImageIds = existingImageIds + pendingImages.mapNotNull { it.uploadedId }
        val obj = ConservationObject(
            id = existing?.id ?: java.util.UUID.randomUUID().toString(),
            title = title,
            objectType = selectedType,
            materials = materials.split(",").map { it.trim() }.filter { it.isNotEmpty() },
            height = heightVal.toDoubleOrNull(),
            width = widthVal.toDoubleOrNull(),
            depth = depthVal.toDoubleOrNull(),
            measurementUnit = unit,
            ownerName = owner,
            locationDescription = location,
            inventoryNumber = inventory,
            description = description,
            imageIds = allImageIds,
            createdAt = existing?.createdAt ?: System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis(),
        )
        if (isEdit) objectStore.updateObject(obj) else objectStore.addObject(obj)
        onDismiss()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(if (isEdit) "Edit Object" else "New Object") },
                navigationIcon = {
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, "Close")
                    }
                },
                actions = {
                    if (isEdit) {
                        IconButton(onClick = { showDeleteConfirm = true }) {
                            Icon(Icons.Default.Delete, "Delete", tint = MaterialTheme.colorScheme.error)
                        }
                    }
                    TextButton(onClick = ::save, enabled = title.isNotBlank()) {
                        Text("Save")
                    }
                },
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Spacer(Modifier.height(8.dp))

            OutlinedTextField(
                value = title, onValueChange = { title = it },
                label = { Text("Title *") },
                placeholder = { Text("e.g. Byzantine Icon, 17th century") },
                modifier = Modifier.fillMaxWidth(), singleLine = true,
            )

            ExposedDropdownMenuBox(expanded = typeExpanded, onExpandedChange = { typeExpanded = it }) {
                OutlinedTextField(
                    value = selectedType.displayName,
                    onValueChange = {},
                    readOnly = true,
                    label = { Text("Object Type") },
                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = typeExpanded) },
                    modifier = Modifier.fillMaxWidth().menuAnchor(),
                )
                ExposedDropdownMenu(expanded = typeExpanded, onDismissRequest = { typeExpanded = false }) {
                    ObjectType.entries.forEach { type ->
                        DropdownMenuItem(
                            text = { Text(type.displayName) },
                            onClick = { selectedType = type; typeExpanded = false },
                        )
                    }
                }
            }

            OutlinedTextField(
                value = materials, onValueChange = { materials = it },
                label = { Text("Materials") },
                placeholder = { Text("e.g. tempera, wood panel, gold leaf") },
                modifier = Modifier.fillMaxWidth(),
            )

            Text("Dimensions", style = MaterialTheme.typography.titleSmall)
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = heightVal, onValueChange = { heightVal = it },
                    label = { Text("H") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    modifier = Modifier.weight(1f), singleLine = true,
                )
                OutlinedTextField(
                    value = widthVal, onValueChange = { widthVal = it },
                    label = { Text("W") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    modifier = Modifier.weight(1f), singleLine = true,
                )
                OutlinedTextField(
                    value = depthVal, onValueChange = { depthVal = it },
                    label = { Text("D") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    modifier = Modifier.weight(1f), singleLine = true,
                )
            }

            OutlinedTextField(
                value = owner, onValueChange = { owner = it },
                label = { Text("Owner") }, modifier = Modifier.fillMaxWidth(), singleLine = true,
            )

            OutlinedTextField(
                value = location, onValueChange = { location = it },
                label = { Text("Location") },
                placeholder = { Text("e.g. Church of St. Nicholas, Thessaloniki") },
                modifier = Modifier.fillMaxWidth(),
            )

            OutlinedTextField(
                value = inventory, onValueChange = { inventory = it },
                label = { Text("Inventory Number") }, modifier = Modifier.fillMaxWidth(), singleLine = true,
            )

            OutlinedTextField(
                value = description, onValueChange = { description = it },
                label = { Text("Description") },
                modifier = Modifier.fillMaxWidth(), minLines = 3,
            )

            Text("Photos", style = MaterialTheme.typography.titleSmall)

            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                existingImageIds.forEach { imageId ->
                    Box(
                        modifier = Modifier
                            .size(80.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(MaterialTheme.colorScheme.surfaceVariant),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            imageId.take(6),
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                        IconButton(
                            onClick = { existingImageIds = existingImageIds - imageId },
                            modifier = Modifier.align(Alignment.TopEnd).size(24.dp),
                        ) {
                            Icon(Icons.Default.Close, "Remove", modifier = Modifier.size(14.dp))
                        }
                    }
                }

                pendingImages.forEach { pending ->
                    Box(
                        modifier = Modifier
                            .size(80.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(MaterialTheme.colorScheme.surfaceVariant),
                        contentAlignment = Alignment.Center,
                    ) {
                        val bitmap = remember(pending.uri) {
                            runCatching {
                                context.contentResolver.openInputStream(pending.uri)?.use { stream ->
                                    BitmapFactory.decodeStream(stream)
                                }
                            }.getOrNull()
                        }
                        if (bitmap != null) {
                            Image(
                                bitmap = bitmap.asImageBitmap(),
                                contentDescription = null,
                                modifier = Modifier.fillMaxSize(),
                                contentScale = ContentScale.Crop,
                            )
                        }
                        if (pending.uploading) {
                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .background(MaterialTheme.colorScheme.scrim.copy(alpha = 0.4f)),
                                contentAlignment = Alignment.Center,
                            ) {
                                CircularProgressIndicator(modifier = Modifier.size(24.dp), strokeWidth = 2.dp)
                            }
                        }
                        if (pending.error != null) {
                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .background(MaterialTheme.colorScheme.errorContainer.copy(alpha = 0.7f)),
                                contentAlignment = Alignment.Center,
                            ) {
                                Text("!", color = MaterialTheme.colorScheme.error)
                            }
                        }
                        IconButton(
                            onClick = { pendingImages = pendingImages.filter { it.uri != pending.uri } },
                            modifier = Modifier.align(Alignment.TopEnd).size(24.dp),
                        ) {
                            Icon(Icons.Default.Close, "Remove", modifier = Modifier.size(14.dp))
                        }
                    }
                }
            }

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedButton(onClick = { photoPicker.launch("image/*") }) {
                    Icon(Icons.Default.PhotoLibrary, null, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(6.dp))
                    Text("Add Photos")
                }
            }

            Spacer(Modifier.height(16.dp))
        }
    }
}
