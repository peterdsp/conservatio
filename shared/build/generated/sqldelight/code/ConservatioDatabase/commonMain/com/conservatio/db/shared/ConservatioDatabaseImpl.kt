package com.conservatio.db.shared

import app.cash.sqldelight.TransacterImpl
import app.cash.sqldelight.db.AfterVersion
import app.cash.sqldelight.db.QueryResult
import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.db.SqlSchema
import com.conservatio.db.ClientQueries
import com.conservatio.db.ConditionReportQueries
import com.conservatio.db.ConservatioDatabase
import com.conservatio.db.ConservationObjectQueries
import com.conservatio.db.ProjectQueries
import kotlin.Long
import kotlin.Unit
import kotlin.reflect.KClass

internal val KClass<ConservatioDatabase>.schema: SqlSchema<QueryResult.Value<Unit>>
  get() = ConservatioDatabaseImpl.Schema

internal fun KClass<ConservatioDatabase>.newInstance(driver: SqlDriver): ConservatioDatabase =
    ConservatioDatabaseImpl(driver)

private class ConservatioDatabaseImpl(
  driver: SqlDriver,
) : TransacterImpl(driver), ConservatioDatabase {
  override val clientQueries: ClientQueries = ClientQueries(driver)

  override val conditionReportQueries: ConditionReportQueries = ConditionReportQueries(driver)

  override val conservationObjectQueries: ConservationObjectQueries =
      ConservationObjectQueries(driver)

  override val projectQueries: ProjectQueries = ProjectQueries(driver)

  public object Schema : SqlSchema<QueryResult.Value<Unit>> {
    override val version: Long
      get() = 1

    override fun create(driver: SqlDriver): QueryResult.Value<Unit> {
      driver.execute(null, """
          |CREATE TABLE ClientEntity (
          |    id TEXT NOT NULL PRIMARY KEY,
          |    name TEXT NOT NULL,
          |    type TEXT NOT NULL,
          |    contact_person TEXT,
          |    email TEXT,
          |    phone TEXT,
          |    address TEXT,
          |    notes TEXT,
          |    created_at INTEGER NOT NULL,
          |    updated_at INTEGER NOT NULL,
          |    sync_status TEXT NOT NULL DEFAULT 'PENDING'
          |)
          """.trimMargin(), 0)
      driver.execute(null, """
          |CREATE TABLE ConditionReportEntity (
          |    id TEXT NOT NULL PRIMARY KEY,
          |    object_id TEXT NOT NULL,
          |    report_type TEXT NOT NULL,
          |    overall_condition TEXT NOT NULL,
          |    examiner TEXT NOT NULL,
          |    examination_date INTEGER NOT NULL,
          |    damage_annotations TEXT NOT NULL,
          |    notes TEXT,
          |    recommendations TEXT,
          |    image_ids TEXT NOT NULL,
          |    created_at INTEGER NOT NULL,
          |    updated_at INTEGER NOT NULL,
          |    sync_status TEXT NOT NULL DEFAULT 'PENDING',
          |    FOREIGN KEY (object_id) REFERENCES ConservationObjectEntity(id) ON DELETE CASCADE
          |)
          """.trimMargin(), 0)
      driver.execute(null, """
          |CREATE TABLE ConservationObjectEntity (
          |    id TEXT NOT NULL PRIMARY KEY,
          |    title TEXT NOT NULL,
          |    object_type TEXT NOT NULL,
          |    materials TEXT NOT NULL,
          |    height REAL,
          |    width REAL,
          |    depth REAL,
          |    diameter REAL,
          |    weight REAL,
          |    measurement_unit TEXT,
          |    owner_name TEXT,
          |    location_description TEXT,
          |    acquisition_date INTEGER,
          |    inventory_number TEXT,
          |    description TEXT,
          |    image_ids TEXT NOT NULL,
          |    created_at INTEGER NOT NULL,
          |    updated_at INTEGER NOT NULL,
          |    sync_status TEXT NOT NULL DEFAULT 'PENDING'
          |)
          """.trimMargin(), 0)
      driver.execute(null, """
          |CREATE TABLE ProjectEntity (
          |    id TEXT NOT NULL PRIMARY KEY,
          |    title TEXT NOT NULL,
          |    client_id TEXT,
          |    object_ids TEXT NOT NULL,
          |    status TEXT NOT NULL,
          |    start_date INTEGER,
          |    end_date INTEGER,
          |    description TEXT,
          |    total_budget REAL,
          |    currency TEXT,
          |    created_at INTEGER NOT NULL,
          |    updated_at INTEGER NOT NULL,
          |    sync_status TEXT NOT NULL DEFAULT 'PENDING'
          |)
          """.trimMargin(), 0)
      return QueryResult.Unit
    }

    override fun migrate(
      driver: SqlDriver,
      oldVersion: Long,
      newVersion: Long,
      vararg callbacks: AfterVersion,
    ): QueryResult.Value<Unit> = QueryResult.Unit
  }
}
