package com.conservatio.db

import app.cash.sqldelight.Transacter
import app.cash.sqldelight.db.QueryResult
import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.db.SqlSchema
import com.conservatio.db.shared.newInstance
import com.conservatio.db.shared.schema
import kotlin.Unit

public interface ConservatioDatabase : Transacter {
  public val clientQueries: ClientQueries

  public val conditionReportQueries: ConditionReportQueries

  public val conservationObjectQueries: ConservationObjectQueries

  public val projectQueries: ProjectQueries

  public companion object {
    public val Schema: SqlSchema<QueryResult.Value<Unit>>
      get() = ConservatioDatabase::class.schema

    public operator fun invoke(driver: SqlDriver): ConservatioDatabase =
        ConservatioDatabase::class.newInstance(driver)
  }
}
