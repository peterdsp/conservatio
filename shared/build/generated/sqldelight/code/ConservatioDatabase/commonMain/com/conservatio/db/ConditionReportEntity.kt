package com.conservatio.db

import kotlin.Long
import kotlin.String

public data class ConditionReportEntity(
  public val id: String,
  public val object_id: String,
  public val report_type: String,
  public val overall_condition: String,
  public val examiner: String,
  public val examination_date: Long,
  public val damage_annotations: String,
  public val notes: String?,
  public val recommendations: String?,
  public val image_ids: String,
  public val created_at: Long,
  public val updated_at: Long,
  public val sync_status: String,
)
