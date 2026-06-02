package com.conservatio.db

import app.cash.sqldelight.Query
import app.cash.sqldelight.TransacterImpl
import app.cash.sqldelight.db.QueryResult
import app.cash.sqldelight.db.SqlCursor
import app.cash.sqldelight.db.SqlDriver
import kotlin.Any
import kotlin.Long
import kotlin.String

public class ConditionReportQueries(
  driver: SqlDriver,
) : TransacterImpl(driver) {
  public fun <T : Any> selectAll(mapper: (
    id: String,
    object_id: String,
    report_type: String,
    overall_condition: String,
    examiner: String,
    examination_date: Long,
    damage_annotations: String,
    notes: String?,
    recommendations: String?,
    image_ids: String,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = Query(-1_274_860_998, arrayOf("ConditionReportEntity"), driver,
      "ConditionReport.sq", "selectAll",
      "SELECT ConditionReportEntity.id, ConditionReportEntity.object_id, ConditionReportEntity.report_type, ConditionReportEntity.overall_condition, ConditionReportEntity.examiner, ConditionReportEntity.examination_date, ConditionReportEntity.damage_annotations, ConditionReportEntity.notes, ConditionReportEntity.recommendations, ConditionReportEntity.image_ids, ConditionReportEntity.created_at, ConditionReportEntity.updated_at, ConditionReportEntity.sync_status FROM ConditionReportEntity ORDER BY examination_date DESC") {
      cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3)!!,
      cursor.getString(4)!!,
      cursor.getLong(5)!!,
      cursor.getString(6)!!,
      cursor.getString(7),
      cursor.getString(8),
      cursor.getString(9)!!,
      cursor.getLong(10)!!,
      cursor.getLong(11)!!,
      cursor.getString(12)!!
    )
  }

  public fun selectAll(): Query<ConditionReportEntity> = selectAll { id, object_id, report_type,
      overall_condition, examiner, examination_date, damage_annotations, notes, recommendations,
      image_ids, created_at, updated_at, sync_status ->
    ConditionReportEntity(
      id,
      object_id,
      report_type,
      overall_condition,
      examiner,
      examination_date,
      damage_annotations,
      notes,
      recommendations,
      image_ids,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun <T : Any> selectByObject(object_id: String, mapper: (
    id: String,
    object_id: String,
    report_type: String,
    overall_condition: String,
    examiner: String,
    examination_date: Long,
    damage_annotations: String,
    notes: String?,
    recommendations: String?,
    image_ids: String,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = SelectByObjectQuery(object_id) { cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3)!!,
      cursor.getString(4)!!,
      cursor.getLong(5)!!,
      cursor.getString(6)!!,
      cursor.getString(7),
      cursor.getString(8),
      cursor.getString(9)!!,
      cursor.getLong(10)!!,
      cursor.getLong(11)!!,
      cursor.getString(12)!!
    )
  }

  public fun selectByObject(object_id: String): Query<ConditionReportEntity> =
      selectByObject(object_id) { id, object_id_, report_type, overall_condition, examiner,
      examination_date, damage_annotations, notes, recommendations, image_ids, created_at,
      updated_at, sync_status ->
    ConditionReportEntity(
      id,
      object_id_,
      report_type,
      overall_condition,
      examiner,
      examination_date,
      damage_annotations,
      notes,
      recommendations,
      image_ids,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun <T : Any> selectById(id: String, mapper: (
    id: String,
    object_id: String,
    report_type: String,
    overall_condition: String,
    examiner: String,
    examination_date: Long,
    damage_annotations: String,
    notes: String?,
    recommendations: String?,
    image_ids: String,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = SelectByIdQuery(id) { cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3)!!,
      cursor.getString(4)!!,
      cursor.getLong(5)!!,
      cursor.getString(6)!!,
      cursor.getString(7),
      cursor.getString(8),
      cursor.getString(9)!!,
      cursor.getLong(10)!!,
      cursor.getLong(11)!!,
      cursor.getString(12)!!
    )
  }

  public fun selectById(id: String): Query<ConditionReportEntity> = selectById(id) { id_, object_id,
      report_type, overall_condition, examiner, examination_date, damage_annotations, notes,
      recommendations, image_ids, created_at, updated_at, sync_status ->
    ConditionReportEntity(
      id_,
      object_id,
      report_type,
      overall_condition,
      examiner,
      examination_date,
      damage_annotations,
      notes,
      recommendations,
      image_ids,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun <T : Any> selectPending(mapper: (
    id: String,
    object_id: String,
    report_type: String,
    overall_condition: String,
    examiner: String,
    examination_date: Long,
    damage_annotations: String,
    notes: String?,
    recommendations: String?,
    image_ids: String,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = Query(1_533_429_168, arrayOf("ConditionReportEntity"), driver,
      "ConditionReport.sq", "selectPending",
      "SELECT ConditionReportEntity.id, ConditionReportEntity.object_id, ConditionReportEntity.report_type, ConditionReportEntity.overall_condition, ConditionReportEntity.examiner, ConditionReportEntity.examination_date, ConditionReportEntity.damage_annotations, ConditionReportEntity.notes, ConditionReportEntity.recommendations, ConditionReportEntity.image_ids, ConditionReportEntity.created_at, ConditionReportEntity.updated_at, ConditionReportEntity.sync_status FROM ConditionReportEntity WHERE sync_status = 'PENDING'") {
      cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3)!!,
      cursor.getString(4)!!,
      cursor.getLong(5)!!,
      cursor.getString(6)!!,
      cursor.getString(7),
      cursor.getString(8),
      cursor.getString(9)!!,
      cursor.getLong(10)!!,
      cursor.getLong(11)!!,
      cursor.getString(12)!!
    )
  }

  public fun selectPending(): Query<ConditionReportEntity> = selectPending { id, object_id,
      report_type, overall_condition, examiner, examination_date, damage_annotations, notes,
      recommendations, image_ids, created_at, updated_at, sync_status ->
    ConditionReportEntity(
      id,
      object_id,
      report_type,
      overall_condition,
      examiner,
      examination_date,
      damage_annotations,
      notes,
      recommendations,
      image_ids,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun insertReport(
    id: String,
    object_id: String,
    report_type: String,
    overall_condition: String,
    examiner: String,
    examination_date: Long,
    damage_annotations: String,
    notes: String?,
    recommendations: String?,
    image_ids: String,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) {
    driver.execute(205_503_992, """
        |INSERT OR REPLACE INTO ConditionReportEntity(
        |    id, object_id, report_type, overall_condition, examiner, examination_date,
        |    damage_annotations, notes, recommendations, image_ids,
        |    created_at, updated_at, sync_status
        |) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """.trimMargin(), 13) {
          bindString(0, id)
          bindString(1, object_id)
          bindString(2, report_type)
          bindString(3, overall_condition)
          bindString(4, examiner)
          bindLong(5, examination_date)
          bindString(6, damage_annotations)
          bindString(7, notes)
          bindString(8, recommendations)
          bindString(9, image_ids)
          bindLong(10, created_at)
          bindLong(11, updated_at)
          bindString(12, sync_status)
        }
    notifyQueries(205_503_992) { emit ->
      emit("ConditionReportEntity")
    }
  }

  public fun deleteById(id: String) {
    driver.execute(-1_740_365_944, """DELETE FROM ConditionReportEntity WHERE id = ?""", 1) {
          bindString(0, id)
        }
    notifyQueries(-1_740_365_944) { emit ->
      emit("ConditionReportEntity")
    }
  }

  private inner class SelectByObjectQuery<out T : Any>(
    public val object_id: String,
    mapper: (SqlCursor) -> T,
  ) : Query<T>(mapper) {
    override fun addListener(listener: Query.Listener) {
      driver.addListener("ConditionReportEntity", listener = listener)
    }

    override fun removeListener(listener: Query.Listener) {
      driver.removeListener("ConditionReportEntity", listener = listener)
    }

    override fun <R> execute(mapper: (SqlCursor) -> QueryResult<R>): QueryResult<R> =
        driver.executeQuery(1_342_997_885,
        """SELECT ConditionReportEntity.id, ConditionReportEntity.object_id, ConditionReportEntity.report_type, ConditionReportEntity.overall_condition, ConditionReportEntity.examiner, ConditionReportEntity.examination_date, ConditionReportEntity.damage_annotations, ConditionReportEntity.notes, ConditionReportEntity.recommendations, ConditionReportEntity.image_ids, ConditionReportEntity.created_at, ConditionReportEntity.updated_at, ConditionReportEntity.sync_status FROM ConditionReportEntity WHERE object_id = ? ORDER BY examination_date DESC""",
        mapper, 1) {
      bindString(0, object_id)
    }

    override fun toString(): String = "ConditionReport.sq:selectByObject"
  }

  private inner class SelectByIdQuery<out T : Any>(
    public val id: String,
    mapper: (SqlCursor) -> T,
  ) : Query<T>(mapper) {
    override fun addListener(listener: Query.Listener) {
      driver.addListener("ConditionReportEntity", listener = listener)
    }

    override fun removeListener(listener: Query.Listener) {
      driver.removeListener("ConditionReportEntity", listener = listener)
    }

    override fun <R> execute(mapper: (SqlCursor) -> QueryResult<R>): QueryResult<R> =
        driver.executeQuery(-865_943_975,
        """SELECT ConditionReportEntity.id, ConditionReportEntity.object_id, ConditionReportEntity.report_type, ConditionReportEntity.overall_condition, ConditionReportEntity.examiner, ConditionReportEntity.examination_date, ConditionReportEntity.damage_annotations, ConditionReportEntity.notes, ConditionReportEntity.recommendations, ConditionReportEntity.image_ids, ConditionReportEntity.created_at, ConditionReportEntity.updated_at, ConditionReportEntity.sync_status FROM ConditionReportEntity WHERE id = ?""",
        mapper, 1) {
      bindString(0, id)
    }

    override fun toString(): String = "ConditionReport.sq:selectById"
  }
}
