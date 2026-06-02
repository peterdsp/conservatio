package com.conservatio.db

import kotlin.Double
import kotlin.Long
import kotlin.String

public data class ProjectEntity(
  public val id: String,
  public val title: String,
  public val client_id: String?,
  public val object_ids: String,
  public val status: String,
  public val start_date: Long?,
  public val end_date: Long?,
  public val description: String?,
  public val total_budget: Double?,
  public val currency: String?,
  public val created_at: Long,
  public val updated_at: Long,
  public val sync_status: String,
)
