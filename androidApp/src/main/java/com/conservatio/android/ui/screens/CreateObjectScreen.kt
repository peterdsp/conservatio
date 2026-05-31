package com.conservatio.android.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.conservatio.android.data.ConservationObject
import com.conservatio.android.data.ObjectStore
import com.conservatio.android.data.ObjectType

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateObjectScreen(objectStore: ObjectStore, onDismiss: () -> Unit) {
    var title by remember { mutableStateOf("") }
    var selectedType by remember { mutableStateOf(ObjectType.OTHER) }
    var materials by remember { mutableStateOf("") }
    var height by remember { mutableStateOf("") }
    var width by remember { mutableStateOf("") }
    var depth by remember { mutableStateOf("") }
    var unit by remember { mutableStateOf("cm") }
    var owner by remember { mutableStateOf("") }
    var location by remember { mutableStateOf("") }
    var inventory by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var typeExpanded by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("New Object") },
                navigationIcon = {
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, "Close")
                    }
                },
                actions = {
                    TextButton(
                        onClick = {
                            if (title.isNotBlank()) {
                                objectStore.addObject(
                                    ConservationObject(
                                        title = title,
                                        objectType = selectedType,
                                        materials = materials.split(",").map { it.trim() }.filter { it.isNotEmpty() },
                                        height = height.toDoubleOrNull(),
                                        width = width.toDoubleOrNull(),
                                        depth = depth.toDoubleOrNull(),
                                        measurementUnit = unit,
                                        ownerName = owner,
                                        locationDescription = location,
                                        inventoryNumber = inventory,
                                        description = description
                                    )
                                )
                                onDismiss()
                            }
                        },
                        enabled = title.isNotBlank()
                    ) {
                        Text("Save")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Spacer(Modifier.height(8.dp))

            OutlinedTextField(
                value = title, onValueChange = { title = it },
                label = { Text("Title *") },
                placeholder = { Text("e.g. Byzantine Icon, 17th century") },
                modifier = Modifier.fillMaxWidth(), singleLine = true
            )

            ExposedDropdownMenuBox(expanded = typeExpanded, onExpandedChange = { typeExpanded = it }) {
                OutlinedTextField(
                    value = selectedType.displayName,
                    onValueChange = {},
                    readOnly = true,
                    label = { Text("Object Type") },
                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = typeExpanded) },
                    modifier = Modifier.fillMaxWidth().menuAnchor()
                )
                ExposedDropdownMenu(expanded = typeExpanded, onDismissRequest = { typeExpanded = false }) {
                    ObjectType.entries.forEach { type ->
                        DropdownMenuItem(
                            text = { Text(type.displayName) },
                            onClick = { selectedType = type; typeExpanded = false }
                        )
                    }
                }
            }

            OutlinedTextField(
                value = materials, onValueChange = { materials = it },
                label = { Text("Materials") },
                placeholder = { Text("e.g. tempera, wood panel, gold leaf") },
                modifier = Modifier.fillMaxWidth()
            )

            Text("Dimensions", style = MaterialTheme.typography.titleSmall)
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = height, onValueChange = { height = it },
                    label = { Text("H") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    modifier = Modifier.weight(1f), singleLine = true
                )
                OutlinedTextField(
                    value = width, onValueChange = { width = it },
                    label = { Text("W") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    modifier = Modifier.weight(1f), singleLine = true
                )
                OutlinedTextField(
                    value = depth, onValueChange = { depth = it },
                    label = { Text("D") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    modifier = Modifier.weight(1f), singleLine = true
                )
            }

            OutlinedTextField(
                value = owner, onValueChange = { owner = it },
                label = { Text("Owner") }, modifier = Modifier.fillMaxWidth(), singleLine = true
            )

            OutlinedTextField(
                value = location, onValueChange = { location = it },
                label = { Text("Location") },
                placeholder = { Text("e.g. Church of St. Nicholas, Thessaloniki") },
                modifier = Modifier.fillMaxWidth()
            )

            OutlinedTextField(
                value = inventory, onValueChange = { inventory = it },
                label = { Text("Inventory Number") }, modifier = Modifier.fillMaxWidth(), singleLine = true
            )

            OutlinedTextField(
                value = description, onValueChange = { description = it },
                label = { Text("Description") },
                modifier = Modifier.fillMaxWidth(), minLines = 3
            )

            Spacer(Modifier.height(16.dp))
        }
    }
}
