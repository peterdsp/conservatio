package com.conservatio.db

import kotlin.Long
import kotlin.String

public data class ClientEntity(
  public val id: String,
  public val name: String,
  public val type: String,
  public val contact_person: String?,
  public val email: String?,
  public val phone: String?,
  public val address: String?,
  public val notes: String?,
  public val created_at: Long,
  public val updated_at: Long,
  public val sync_status: String,
)
