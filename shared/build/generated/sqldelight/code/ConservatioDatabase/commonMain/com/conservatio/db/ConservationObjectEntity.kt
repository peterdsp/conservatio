package com.conservatio.db

import kotlin.Double
import kotlin.Long
import kotlin.String

public data class ConservationObjectEntity(
  public val id: String,
  public val title: String,
  public val object_type: String,
  public val materials: String,
  public val height: Double?,
  public val width: Double?,
  public val depth: Double?,
  public val diameter: Double?,
  public val weight: Double?,
  public val measurement_unit: String?,
  public val owner_name: String?,
  public val location_description: String?,
  public val acquisition_date: Long?,
  public val inventory_number: String?,
  public val description: String?,
  public val image_ids: String,
  public val created_at: Long,
  public val updated_at: Long,
  public val sync_status: String,
)
